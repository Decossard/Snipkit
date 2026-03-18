import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/app_models.dart';
import 'auth_service.dart';
import 'contacts_service.dart';

// ─── Conversations ────────────────────────────────────────────────────────────

class ConversationsNotifier extends AsyncNotifier<List<Conversation>> {
  SupabaseClient get _client => ref.read(supabaseClientProvider);
  String? get _uid => _client.auth.currentUser?.id;

  @override
  Future<List<Conversation>> build() async {
    ref.watch(authProvider);
    _subscribeRealtime();
    return _fetch();
  }

  RealtimeChannel? _channel;

  void _subscribeRealtime() {
    _channel?.unsubscribe();
    final uid = _uid;
    if (uid == null) return;
    _channel = _client
        .channel('conversations:$uid')
        .onPostgresChanges(
          event: PostgresChangeEvent.all,
          schema: 'public',
          table: 'conversations',
          callback: (_) => refresh(),
        )
        .subscribe();
    ref.onDispose(() => _channel?.unsubscribe());
  }

  Future<List<Conversation>> _fetch() async {
    final uid = _uid;
    if (uid == null) return [];

    final data = await _client
        .from('conversations')
        .select(
          '*, '
          'profile_a:profiles!participant_a(id, username), '
          'profile_b:profiles!participant_b(id, username)',
        )
        .or('participant_a.eq.$uid,participant_b.eq.$uid')
        .order('last_message_at', ascending: false, nullsFirst: false);

    // Fetch contacts to resolve nicknames
    final contacts = await ref.read(contactsProvider.future);
    final nicknameMap = {for (final c in contacts) c.contactId: c.nickname};

    return (data as List).map((row) {
      final profileA = row['profile_a'] as Map<String, dynamic>;
      final profileB = row['profile_b'] as Map<String, dynamic>;
      final isA = profileA['id'] == uid;
      final other = isA ? profileB : profileA;
      final otherId = other['id'] as String;
      final otherUsername = other['username'] as String;
      return Conversation(
        id: row['id'] as String,
        otherUserId: otherId,
        otherUsername: otherUsername,
        nickname: nicknameMap[otherId],
        activeTurnId: row['active_turn'] as String?,
        lastMessageAt: row['last_message_at'] != null
            ? DateTime.parse(row['last_message_at'] as String)
            : null,
        createdAt: DateTime.parse(row['created_at'] as String),
      );
    }).toList();
  }

  Future<void> refresh() async {
    state = await AsyncValue.guard(_fetch);
  }

  /// Returns the existing conversation with [otherUserId], or creates one.
  Future<Conversation> getOrCreate(String otherUserId) async {
    final uid = _uid!;
    // Try to find existing
    final existing = await _client
        .from('conversations')
        .select(
          '*, '
          'profile_a:profiles!participant_a(id, username), '
          'profile_b:profiles!participant_b(id, username)',
        )
        .or(
          'and(participant_a.eq.$uid,participant_b.eq.$otherUserId),'
          'and(participant_a.eq.$otherUserId,participant_b.eq.$uid)',
        )
        .maybeSingle();

    if (existing != null) {
      final contacts = await ref.read(contactsProvider.future);
      final nicknameMap = {for (final c in contacts) c.contactId: c.nickname};
      final profileA = existing['profile_a'] as Map<String, dynamic>;
      final profileB = existing['profile_b'] as Map<String, dynamic>;
      final isA = profileA['id'] == uid;
      final other = isA ? profileB : profileA;
      final otherId = other['id'] as String;
      return Conversation(
        id: existing['id'] as String,
        otherUserId: otherId,
        otherUsername: other['username'] as String,
        nickname: nicknameMap[otherId],
        activeTurnId: existing['active_turn'] as String?,
        lastMessageAt: existing['last_message_at'] != null
            ? DateTime.parse(existing['last_message_at'] as String)
            : null,
        createdAt: DateTime.parse(existing['created_at'] as String),
      );
    }

    // Create new
    final row = await _client
        .from('conversations')
        .insert({
          'participant_a': uid,
          'participant_b': otherUserId,
          'active_turn': uid,
        })
        .select(
          '*, '
          'profile_a:profiles!participant_a(id, username), '
          'profile_b:profiles!participant_b(id, username)',
        )
        .single();

    await refresh();
    final other = (row['profile_b'] as Map<String, dynamic>);
    return Conversation(
      id: row['id'] as String,
      otherUserId: other['id'] as String,
      otherUsername: other['username'] as String,
      activeTurnId: row['active_turn'] as String?,
      lastMessageAt: null,
      createdAt: DateTime.parse(row['created_at'] as String),
    );
  }
}

final conversationsProvider =
    AsyncNotifierProvider<ConversationsNotifier, List<Conversation>>(
        ConversationsNotifier.new);
