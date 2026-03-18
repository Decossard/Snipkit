import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../presentation/screens/onboarding/splash_screen.dart';
import '../../presentation/screens/onboarding/welcome_screen.dart';
import '../../presentation/screens/onboarding/signup_screen.dart';
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

final appRouterProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/',
    errorBuilder: (context, state) => const NotFoundScreen(),
    routes: [
      GoRoute(path: '/', builder: (c, s) => const SplashScreen()),
      GoRoute(path: '/welcome', builder: (c, s) => const WelcomeScreen()),
      GoRoute(path: '/signup', builder: (c, s) => const SignupScreen()),
      GoRoute(path: '/account-created', builder: (c, s) => const AccountCreatedScreen()),
      GoRoute(path: '/recovery', builder: (c, s) => const RecoveryEntryScreen()),
      GoRoute(path: '/login', builder: (c, s) => const LoginScreen()),
      GoRoute(path: '/home', builder: (c, s) => const HomeScreen()),
      GoRoute(path: '/contacts', builder: (c, s) => const ContactsScreen()),
      GoRoute(path: '/add-contact', builder: (c, s) => const AddContactScreen()),
      GoRoute(
        path: '/name-contact/:username',
        builder: (c, s) => NameContactScreen(username: s.pathParameters['username'] ?? ''),
      ),
      GoRoute(path: '/request-sent', builder: (c, s) => const RequestSentScreen()),
      GoRoute(
        path: '/contact/:username',
        builder: (c, s) => ContactProfileScreen(username: s.pathParameters['username'] ?? ''),
      ),
      GoRoute(
        path: '/conversation/:username',
        builder: (c, s) => ConversationScreen(username: s.pathParameters['username'] ?? ''),
      ),
      GoRoute(path: '/article-composer', builder: (c, s) => const ArticleComposerScreen()),
      GoRoute(path: '/article-viewer', builder: (c, s) => const ArticleViewerScreen()),
      GoRoute(path: '/picture-preview', builder: (c, s) => const PicturePreviewScreen()),
      GoRoute(path: '/picture-viewer', builder: (c, s) => const PictureViewerScreen()),
      GoRoute(path: '/voice-record', builder: (c, s) => const VoiceRecordScreen()),
      GoRoute(path: '/settings', builder: (c, s) => const ProfileScreen()),
      GoRoute(path: '/blocked-contacts', builder: (c, s) => const BlockedContactsScreen()),
      GoRoute(path: '/recovery-reminder', builder: (c, s) => const RecoveryReminderScreen()),
      GoRoute(path: '/lock-account', builder: (c, s) => const LockAccountScreen()),
      GoRoute(path: '/account-locked', builder: (c, s) => const AccountLockedScreen()),
      GoRoute(path: '/no-internet', builder: (c, s) => const NoInternetScreen()),
      GoRoute(path: '/terms', builder: (c, s) => const TermsScreen()),
      GoRoute(path: '/privacy', builder: (c, s) => const PrivacyScreen()),
    ],
  );
});
