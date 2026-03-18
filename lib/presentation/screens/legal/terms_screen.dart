import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/tokens/design_tokens.dart';
import '../../widgets/top_bar.dart';

class TermsScreen extends StatelessWidget {
  const TermsScreen({super.key});

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
                'Terms of Service',
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
              const SizedBox(height: AppSpacing.xxxl),

              const _Section(
                title: '1. Acceptance',
                body:
                    'By creating an account or using Snipkit, you agree to these Terms of Service. If you do not agree, do not use the app. These terms apply to all users.',
              ),

              const _Section(
                title: '2. What Snipkit Is',
                body:
                    'Snipkit is a turn-based ephemeral messaging service. Messages are delivered one turn at a time. Once media (photos, voice messages, articles) is opened, it cannot be viewed again. Snipkit does not retain message content after delivery.',
              ),

              const _Section(
                title: '3. Your Account',
                body:
                    'Your account is identified by a system-generated username and protected by a five-word recovery code. We do not collect an email address or phone number. You are solely responsible for storing your recovery code. If you lose it, your account cannot be recovered — we have no way to verify your identity or restore access.',
              ),

              const _Section(
                title: '4. Acceptable Use',
                body:
                    'You agree not to use Snipkit to:\n\n'
                    '• Send harassing, threatening, or abusive messages\n'
                    '• Share illegal content of any kind\n'
                    '• Attempt to reverse-engineer or circumvent the app\'s security\n'
                    '• Impersonate another person or create misleading usernames\n'
                    '• Use automated tools or bots to access the service\n\n'
                    'We reserve the right to suspend accounts that violate these rules.',
              ),

              const _Section(
                title: '5. Ephemeral Content',
                body:
                    'Media sent through Snipkit is designed to be viewed once and not stored. You must not attempt to screenshot, record, or otherwise capture content sent by others without their consent. While we take technical measures to prevent capture, we cannot guarantee absolute protection.',
              ),

              const _Section(
                title: '6. No Guarantees',
                body:
                    'Snipkit is provided "as is." We make no warranty that the service will be uninterrupted, error-free, or free from data loss. Messaging services can fail. Do not rely on Snipkit for time-sensitive or critical communications.',
              ),

              const _Section(
                title: '7. Limitation of Liability',
                body:
                    'To the fullest extent permitted by law, Snipkit and its developers are not liable for any indirect, incidental, or consequential damages arising from your use of the service, including loss of messages or account access.',
              ),

              const _Section(
                title: '8. Changes to These Terms',
                body:
                    'We may update these terms. If we make material changes, we will notify you within the app before they take effect. Continued use of Snipkit after changes are posted constitutes acceptance.',
              ),

              const _Section(
                title: '9. Governing Law',
                body:
                    'These terms are governed by applicable law. Any disputes will be handled in good faith before any formal proceedings.',
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
