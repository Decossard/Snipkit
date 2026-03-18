import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/app_models.dart';
import 'auth_service.dart';

// ─── Contacts ─────────────────────────────────────────────────────────────────

class ContactsNotifier extends AsyncNotifier<List<Contact>> {
  SupabaseClient get _client => ref.read(supabaseClientProvider);
  String? get _uid => _client.auth.currentUser?.id;

  @override
  Future<List<Contact>> build() async {
    // Re-fetch whenever auth changes
    ref.watch(authProvider);
    return _fetch();
  }

  Future<List<Contact>> _fetch() async {
    final uid = _uid;
    if (uid == null) return [];
    final data = await _client
        .from('contacts')
        .select('*, profile:profiles!contact_id(id, username)')
        .eq('user_id', uid)
        .order('created_at');
    return (data as List).map((e) => Contact.fromJson(e)).toList();
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(_fetch);
  }

  /// Look up a username and send a contact request.
  /// Returns an error string on failure, null on success.
  Future<String?> sendRequest(String username) async {
    final uid = _uid;
    if (uid == null) return 'Not signed in.';

    // Check the user exists
    final profile = await _client
        .from('profiles')
        .select()
        .eq('username', username.trim().toLowerCase())
        .maybeSingle();

    if (profile == null) return 'No user found with that username.';
    if (profile['id'] == uid) return 'That\'s your own username.';

    // Check not already contacts
    final existing = await _client
        .from('contacts')
        .select()
        .eq('user_id', uid)
        .eq('contact_id', profile['id'] as String)
        .maybeSingle();
    if (existing != null) return 'You\'re already contacts.';

    // Check not already requested
    final pending = await _client
        .from('contact_requests')
        .select()
        .eq('from_id', uid)
        .eq('to_id', profile['id'] as String)
        .maybeSingle();
    if (pending != null) return 'Request already sent.';

    await _client.from('contact_requests').insert({
      'from_id': uid,
      'to_id': profile['id'],
    });
    return null;
  }

  /// Accept an incoming contact request by its ID.
  Future<void> acceptRequest(String requestId) async {
    await _client.rpc('accept_contact_request', params: {
      'request_id': requestId,
    });
    await refresh();
  }

  /// Decline / cancel a contact request.
  Future<void> deleteRequest(String requestId) async {
    await _client
        .from('contact_requests')
        .delete()
        .eq('id', requestId);
  }

  /// Update the local nickname for a contact.
  Future<void> setNickname(String contactId, String? nickname) async {
    final uid = _uid;
    if (uid == null) return;
    await _client
        .from('contacts')
        .update({'nickname': nickname})
        .eq('user_id', uid)
        .eq('contact_id', contactId);
    await refresh();
  }

  /// Remove a contact (deletes both sides of the relationship).
  Future<void> removeContact(String contactId) async {
    final uid = _uid;
    if (uid == null) return;
    await _client
        .from('contacts')
        .delete()
        .eq('user_id', uid)
        .eq('contact_id', contactId);
    await _client
        .from('contacts')
        .delete()
        .eq('user_id', contactId)
        .eq('contact_id', uid);
    await refresh();
  }
}

final contactsProvider =
    AsyncNotifierProvider<ContactsNotifier, List<Contact>>(
        ContactsNotifier.new);

// ─── Incoming contact requests ────────────────────────────────────────────────

class ContactRequestsNotifier extends AsyncNotifier<List<ContactRequest>> {
  SupabaseClient get _client => ref.read(supabaseClientProvider);
  String? get _uid => _client.auth.currentUser?.id;

  @override
  Future<List<ContactRequest>> build() async {
    ref.watch(authProvider);
    return _fetch();
  }

  Future<List<ContactRequest>> _fetch() async {
    final uid = _uid;
    if (uid == null) return [];
    final data = await _client
        .from('contact_requests')
        .select('*, sender:profiles!from_id(id, username)')
        .eq('to_id', uid)
        .order('created_at', ascending: false);
    return (data as List).map((e) => ContactRequest.fromJson(e)).toList();
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(_fetch);
  }
}

final contactRequestsProvider =
    AsyncNotifierProvider<ContactRequestsNotifier, List<ContactRequest>>(
        ContactRequestsNotifier.new);
