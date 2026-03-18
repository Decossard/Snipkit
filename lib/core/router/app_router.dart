import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../services/auth_service.dart';
import '../../presentation/screens/onboarding/splash_screen.dart';
import '../../presentation/screens/onboarding/welcome_screen.dart';
import '../../presentation/screens/onboarding/account_created_screen.dart';
import '../../presentation/screens/onboarding/recovery_entry_screen.dart';
import '../../presentation/screens/onboarding/login_screen.dart';
import '../../presentation/screens/home/home_screen.dart';
import '../../presentation/screens/contacts/contacts_screen.dart';
import '../../presentation/screens/contacts/add_contact_screen.dart';
import '../../presentation/screens/contacts/name_contact_screen.dart';
import '../../presentation/screens/contacts/request_sent_screen.dart';
import '../../presentation/screens/contacts/contact_profile_screen.dart';
import '../../presentation/screens/conversation/conversation_screen.dart';
import '../../presentation/screens/conversation/article_composer_screen.dart';
import '../../presentation/screens/conversation/article_viewer_screen.dart';
import '../../presentation/screens/conversation/picture_preview_screen.dart';
import '../../presentation/screens/conversation/picture_viewer_screen.dart';
import '../../presentation/screens/conversation/voice_record_screen.dart';
import '../../presentation/screens/account/profile_screen.dart';
import '../../presentation/screens/account/blocked_contacts_screen.dart';
import '../../presentation/screens/account/recovery_reminder_screen.dart';
import '../../presentation/screens/account/lock_account_screen.dart';
import '../../presentation/screens/account/account_locked_screen.dart';
import '../../presentation/screens/errors/no_internet_screen.dart';
import '../../presentation/screens/errors/not_found_screen.dart';
import '../../presentation/screens/legal/terms_screen.dart';
import '../../presentation/screens/legal/privacy_screen.dart';

// Routes accessible without being signed in
const _publicRoutes = {
  '/',
  '/welcome',
  '/account-created',
  '/login',
  '/recovery',
  '/terms',
  '/privacy',
};

// ─── Router notifier ──────────────────────────────────────────────────────────
// Wraps auth state as a ChangeNotifier so GoRouter.refreshListenable
// re-evaluates the redirect without recreating the entire router.

class _RouterNotifier extends ChangeNotifier {
  _RouterNotifier(this._ref) {
    _ref.listen<AuthState>(authProvider, (_, __) => notifyListeners());
  }

  final Ref _ref;

  bool get isAuthenticated => _ref.read(authProvider).isAuthenticated;
  bool get isSigningUp => _ref.read(authProvider).isSigningUp;
}

// ─── Router provider ──────────────────────────────────────────────────────────

final appRouterProvider = Provider<GoRouter>((ref) {
  final notifier = _RouterNotifier(ref);

  return GoRouter(
    initialLocation: '/',
    refreshListenable: notifier,
    errorBuilder: (context, state) => const NotFoundScreen(),
    redirect: (context, state) {
      final isAuthenticated = notifier.isAuthenticated;
      final isSigningUp = notifier.isSigningUp;
      final location = state.matchedLocation;
      final isPublic = _publicRoutes.contains(location);

      // Never interrupt the sign-up flow — user must see their credentials
      if (isSigningUp) return null;

      // Signed-in user on any onboarding page → go home
      // (exempt '/' so the splash screen can still render its animation)
      if (isAuthenticated && isPublic && location != '/') return '/home';

      // Signed-out user on a protected page → go to welcome
      if (!isAuthenticated && !isPublic) return '/welcome';

      return null;
    },
    routes: [
      GoRoute(path: '/', builder: (c, s) => const SplashScreen()),
      GoRoute(path: '/welcome', builder: (c, s) => const WelcomeScreen()),
      GoRoute(
          path: '/account-created',
          builder: (c, s) => const AccountCreatedScreen()),
      GoRoute(
          path: '/recovery', builder: (c, s) => const RecoveryEntryScreen()),
      GoRoute(path: '/login', builder: (c, s) => const LoginScreen()),
      GoRoute(path: '/home', builder: (c, s) => const HomeScreen()),
      GoRoute(path: '/contacts', builder: (c, s) => const ContactsScreen()),
      GoRoute(
          path: '/add-contact', builder: (c, s) => const AddContactScreen()),
      GoRoute(
        path: '/name-contact/:username',
        builder: (c, s) =>
            NameContactScreen(username: s.pathParameters['username'] ?? ''),
      ),
      GoRoute(
          path: '/request-sent',
          builder: (c, s) => const RequestSentScreen()),
      GoRoute(
        path: '/contact/:username',
        builder: (c, s) =>
            ContactProfileScreen(username: s.pathParameters['username'] ?? ''),
      ),
      GoRoute(
        path: '/conversation/:username',
        builder: (c, s) =>
            ConversationScreen(username: s.pathParameters['username'] ?? ''),
      ),
      GoRoute(
          path: '/article-composer',
          builder: (c, s) => const ArticleComposerScreen()),
      GoRoute(
          path: '/article-viewer',
          builder: (c, s) => const ArticleViewerScreen()),
      GoRoute(
          path: '/picture-preview',
          builder: (c, s) => const PicturePreviewScreen()),
      GoRoute(
          path: '/picture-viewer',
          builder: (c, s) => const PictureViewerScreen()),
      GoRoute(
          path: '/voice-record', builder: (c, s) => const VoiceRecordScreen()),
      GoRoute(path: '/settings', builder: (c, s) => const ProfileScreen()),
      GoRoute(
          path: '/blocked-contacts',
          builder: (c, s) => const BlockedContactsScreen()),
      GoRoute(
          path: '/recovery-reminder',
          builder: (c, s) => const RecoveryReminderScreen()),
      GoRoute(
          path: '/lock-account', builder: (c, s) => const LockAccountScreen()),
      GoRoute(
          path: '/account-locked',
          builder: (c, s) => const AccountLockedScreen()),
      GoRoute(
          path: '/no-internet', builder: (c, s) => const NoInternetScreen()),
      GoRoute(path: '/terms', builder: (c, s) => const TermsScreen()),
      GoRoute(path: '/privacy', builder: (c, s) => const PrivacyScreen()),
    ],
  );
});
