import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/app_models.dart';
import 'auth_service.dart';

/// Fetches the current user's profile from the `profiles` table.
final currentProfileProvider = FutureProvider<UserProfile?>((ref) async {
  final authState = ref.watch(authProvider);
  final userId = authState.user?.id;
  if (userId == null) return null;

  final client = ref.watch(supabaseClientProvider);
  final data = await client
      .from('profiles')
      .select()
      .eq('id', userId)
      .maybeSingle();

  if (data == null) return null;
  return UserProfile.fromJson(data);
});

/// Convenience provider — just the username string.
final currentUsernameProvider = Provider<String?>((ref) {
  return ref
      .watch(currentProfileProvider)
      .whenOrNull(data: (p) => p?.username);
});
