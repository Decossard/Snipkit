import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/tokens/design_tokens.dart';
import '../../widgets/top_bar.dart';

class PrivacyScreen extends StatelessWidget {
  const PrivacyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundPrimary,
      appBar: SnipkitTopBar(showBack: true, onBack: () => context.pop()),
      body: SafeArea(
        top: false,
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.xxl,
            AppSpacing.xxxl,
            AppSpacing.xxl,
            AppSpacing.giant,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Privacy Policy',
                style: AppTextStyles.headingLarge.copyWith(
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: AppSpacing.xs),
              Text(
                'Last updated March 2026',
                style: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.textDisabled,
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              // Privacy commitment callout
              Container(
                padding: const EdgeInsets.all(AppSpacing.lg),
                decoration: BoxDecoration(
                  color: AppColors.backgroundSecondary,
                  borderRadius: AppRadius.mediumRadius,
                ),
                child: Text(
                  'Snipkit is built around privacy. We collect as little as possible and store even less.',
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w500,
                    height: 1.5,
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.xxxl),

              const _Section(
                title: '1. What We Collect',
                body:
                    'We do not collect your name, email address, phone number, or any personally identifiable information.\n\n'
                    'When you create an account, we generate:\n\n'
                    '• A pseudonymous username (e.g. cedar.hayes)\n'
                    '• A five-word recovery code that only you hold\n\n'
                    'We do not store your recovery code. It is shown to you once and never transmitted to our servers again.',
              ),

              const _Section(
                title: '2. Messages and Media',
                body:
                    'Message content is end-to-end encrypted and designed to be ephemeral. Once a message has been delivered and opened, it is deleted from our systems. We do not read, analyse, or retain the content of your conversations.\n\n'
                    'Media — photos, voice messages, and articles — is stored only until it has been opened by the recipient, at which point it is permanently deleted.',
              ),

              const _Section(
                title: '3. Local Storage',
                body:
                    'Some data is stored locally on your device to make the app function — for example, your list of contacts and recent conversation state. This data stays on your device and is not uploaded to our servers beyond what is necessary to deliver messages.',
              ),

              const _Section(
                title: '4. No Tracking. No Ads.',
                body:
                    'We do not use advertising networks. We do not track your behaviour across apps or websites. We do not sell, rent, or share your data with third parties for marketing purposes.\n\n'
                    'We do not use analytics tools that profile individual users.',
              ),

              const _Section(
                title: '5. Technical Data',
                body:
                    'To operate the service, we may process minimal technical data such as IP addresses (used only for routing and rate-limiting, not stored long-term) and device type (used only for compatibility). This information is not linked to your identity.',
              ),

              const _Section(
                title: '6. Data Retention',
                body:
                    'We retain as little as possible for as short a time as necessary:\n\n'
                    '• Unread messages: stored until delivered, then deleted\n'
                    '• Read messages: deleted immediately on open\n'
                    '• Account data: your username and public key, retained while your account exists\n'
                    '• Deleted accounts: all associated data is removed within 30 days',
              ),

              const _Section(
                title: '7. Security',
                body:
                    'All data in transit is encrypted using TLS. Messages are end-to-end encrypted so only you and your contact can read them. We do not have access to message content.\n\n'
                    'Your account security depends entirely on keeping your recovery code private. Never share it with anyone.',
              ),

              const _Section(
                title: '8. Children',
                body:
                    'Snipkit is not intended for users under the age of 13. We do not knowingly collect data from children. If you believe a child is using the service, please contact us.',
              ),

              const _Section(
                title: '9. Changes to This Policy',
                body:
                    'If we make material changes to this policy, we will notify you within the app before they take effect. The date at the top of this page reflects when it was last updated.',
              ),

              const _Section(
                title: '10. Contact',
                body:
                    'If you have questions about this policy or how your data is handled, you can reach us through the app\'s support channel.',
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Section extends StatelessWidget {
  const _Section({required this.title, required this.body});

  final String title;
  final String body;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.xxl),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: AppTextStyles.bodyLarge.copyWith(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            body,
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.textSecondary,
              height: 1.6,
            ),
          ),
        ],
      ),
    );
  }
}
