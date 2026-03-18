import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'username_generator.dart';

// ─── Supabase client ──────────────────────────────────────────────────────────

final supabaseClientProvider = Provider<SupabaseClient>((ref) {
  return Supabase.instance.client;
});

// ─── Pending signup (shown on AccountCreatedScreen) ───────────────────────────

class PendingSignup {
  final String username;
  final List<String> recoveryWords;
  const PendingSignup({required this.username, required this.recoveryWords});
}

// ─── Auth state ───────────────────────────────────────────────────────────────

class AuthState {
  final bool isLoading;
  final User? user;
  final String? errorMessage;
  final PendingSignup? pendingSignup;

  const AuthState({
    this.isLoading = false,
    this.user,
    this.errorMessage,
    this.pendingSignup,
  });

  bool get isAuthenticated => user != null;

  /// True while the user is in the middle of the sign-up flow and hasn't
  /// yet confirmed they've saved their credentials.
  bool get isSigningUp => pendingSignup != null;

  AuthState copyWith({
    bool? isLoading,
    User? user,
    String? errorMessage,
    PendingSignup? pendingSignup,
    bool clearError = false,
    bool clearPendingSignup = false,
    bool clearUser = false,
  }) {
    return AuthState(
      isLoading: isLoading ?? this.isLoading,
      user: clearUser ? null : (user ?? this.user),
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      pendingSignup:
          clearPendingSignup ? null : (pendingSignup ?? this.pendingSignup),
    );
  }
}

// ─── Auth notifier ────────────────────────────────────────────────────────────

class AuthNotifier extends StateNotifier<AuthState> {
  final SupabaseClient _client;

  AuthNotifier(this._client)
      : super(AuthState(user: _client.auth.currentUser)) {
    // Keep state in sync with Supabase session changes.
    // Note: we intentionally preserve pendingSignup across this update so the
    // router doesn't redirect mid-signup when auth state arrives.
    _client.auth.onAuthStateChange.listen((data) {
      if (!mounted) return;
      final user = data.session?.user;
      state = state.copyWith(
        user: user,
        clearUser: user == null,
        // preserve pendingSignup — cleared explicitly by the user
      );
    });
  }

  /// Generates credentials, stores them in state FIRST, then calls Supabase.
  /// This ensures [pendingSignup] is set before [onAuthStateChange] fires,
  /// so the router never redirects mid-signup.
  Future<void> signUp() async {
    state = state.copyWith(isLoading: true, clearError: true);

    final username = UsernameGenerator.generateUsername();
    final recoveryWords = UsernameGenerator.generateRecoveryPhrase();

    // ⚠️ Set pendingSignup BEFORE the API call.
    // Supabase's onAuthStateChange fires synchronously on the response,
    // so we must ensure the router can see isSigningUp == true before
    // isAuthenticated becomes true.
    state = state.copyWith(
      pendingSignup: PendingSignup(
        username: username,
        recoveryWords: recoveryWords,
      ),
    );

    final email = '$username@snipkit.app';
    final password = recoveryWords.join(' ');

    try {
      final response = await _client.auth.signUp(
        email: email,
        password: password,
        data: {'username': username},
      );

      if (response.user == null) {
        state = state.copyWith(
          isLoading: false,
          clearPendingSignup: true,
          errorMessage: 'Sign up failed. Please try again.',
        );
        return;
      }

      state = state.copyWith(isLoading: false);
    } on AuthException catch (e) {
      state = state.copyWith(
        isLoading: false,
        clearPendingSignup: true,
        errorMessage: e.message,
      );
    } catch (_) {
      state = state.copyWith(
        isLoading: false,
        clearPendingSignup: true,
        errorMessage: 'Something went wrong. Please try again.',
      );
    }
  }

  /// Signs in with [username] + [recoveryPhrase].
  /// Returns true on success, false on failure.
  Future<bool> signIn(String username, String recoveryPhrase) async {
    state = state.copyWith(isLoading: true, clearError: true);

    final email = '${username.trim().toLowerCase()}@snipkit.app';
    final password = recoveryPhrase.trim();

    try {
      await _client.auth.signInWithPassword(email: email, password: password);
      state = state.copyWith(isLoading: false);
      return true;
    } on AuthException catch (_) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Invalid username or recovery code.',
      );
      return false;
    } catch (_) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Something went wrong. Please try again.',
      );
      return false;
    }
  }

  /// Signs the current user out.
  Future<void> signOut() async {
    await _client.auth.signOut();
    state = const AuthState();
  }

  /// Permanently deletes the current user's account and all their data.
  /// Calls the `delete_user` Postgres function which cascades via RLS.
  Future<void> deleteAccount() async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      await _client.rpc('delete_user');
      await _client.auth.signOut();
      state = const AuthState();
    } catch (_) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Could not delete account. Please try again.',
      );
    }
  }

  void clearPendingSignup() {
    state = state.copyWith(clearPendingSignup: true);
  }

  void clearError() {
    state = state.copyWith(clearError: true);
  }
}

// ─── Providers ────────────────────────────────────────────────────────────────

final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  final client = ref.watch(supabaseClientProvider);
  return AuthNotifier(client);
});

/// Holds the username typed on LoginScreen so RecoveryEntryScreen can use it.
final pendingLoginUsernameProvider = StateProvider<String>((ref) => '');
