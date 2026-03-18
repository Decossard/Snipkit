import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/app_models.dart';
import 'auth_service.dart';

// ─── Messages for a single conversation ──────────────────────────────────────

class MessagesNotifier
    extends FamilyAsyncNotifier<List<Message>, String> {
  SupabaseClient get _client => ref.read(supabaseClientProvider);

  @override
  Future<List<Message>> build(String conversationId) async {
    _subscribeRealtime(conversationId);
    return _fetch(conversationId);
  }

  RealtimeChannel? _channel;

  void _subscribeRealtime(String conversationId) {
    _channel?.unsubscribe();
    _channel = _client
        .channel('messages:$conversationId')
        .onPostgresChanges(
          event: PostgresChangeEvent.insert,
          schema: 'public',
          table: 'messages',
          filter: PostgresChangeFilter(
            type: PostgresChangeFilterType.eq,
            column: 'conversation_id',
            value: conversationId,
          ),
          callback: (payload) {
            // Append new message directly without a full refetch
            final newMsg = Message.fromJson(payload.newRecord);
            state.whenData((msgs) {
              state = AsyncData([...msgs, newMsg]);
            });
          },
        )
        .subscribe();
    ref.onDispose(() => _channel?.unsubscribe());
  }

  Future<List<Message>> _fetch(String conversationId) async {
    final data = await _client
        .from('messages')
        .select()
        .eq('conversation_id', conversationId)
        .order('created_at');
    return (data as List).map((e) => Message.fromJson(e)).toList();
  }

  /// Send a text message and hand the turn to the other participant.
  Future<void> sendMessage({
    required String conversationId,
    required String content,
    required String type,
    required String currentUserId,
    required String otherUserId,
  }) async {
    // Insert message
    await _client.from('messages').insert({
      'conversation_id': conversationId,
      'sender_id': currentUserId,
      'content': content,
      'type': type,
    });

    // Update conversation: hand turn + refresh last_message_at
    await _client.from('conversations').update({
      'active_turn': otherUserId,
      'last_message_at': DateTime.now().toIso8601String(),
    }).eq('id', conversationId);
  }

  /// Mark a media message as opened (ephemeral — one-time view).
  Future<void> markOpened(String messageId) async {
    await _client.from('messages').update({
      'opened_at': DateTime.now().toIso8601String(),
    }).eq('id', messageId);

    state.whenData((msgs) {
      state = AsyncData(msgs.map((m) {
        if (m.id == messageId) {
          return Message(
            id: m.id,
            conversationId: m.conversationId,
            senderId: m.senderId,
            content: m.content,
            type: m.type,
            createdAt: m.createdAt,
            openedAt: DateTime.now(),
          );
        }
        return m;
      }).toList());
    });
  }
}

final messagesProvider = AsyncNotifierProviderFamily<MessagesNotifier,
    List<Message>, String>(MessagesNotifier.new);
