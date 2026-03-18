import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/tokens/design_tokens.dart';
import '../../widgets/snipkit_button.dart';
import '../../widgets/top_bar.dart';

class SignupScreen extends StatelessWidget {
  const SignupScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundPrimary,
      appBar: SnipkitTopBar(showBack: true, onBack: () => context.pop()),
      body: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
          child: Stack(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: AppSpacing.giant),
                  Text(
                    'One tap. That is all.',
                    style: AppTextStyles.headingLarge.copyWith(color: AppColors.textPrimary),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  Text(
                    'No email. No phone number.\nWe generate everything.',
                    style: AppTextStyles.bodySmall.copyWith(color: AppColors.textSecondary),
                  ),
                ],
              ),
              Positioned(
                bottom: AppSpacing.xxxl,
                left: 0,
                right: 0,
                child: Column(
                  children: [
                    GestureDetector(
                      onTap: () => context.push('/terms'),
                      child: Text.rich(
                        TextSpan(
                          style: AppTextStyles.caption.copyWith(
                              color: AppColors.textDisabled),
                          children: [
                            const TextSpan(text: 'By continuing you accept our '),
                            TextSpan(
                              text: 'Terms of Service',
                              style: AppTextStyles.caption.copyWith(
                                color: AppColors.textPrimary,
                                decoration: TextDecoration.underline,
                              ),
                            ),
                            const TextSpan(text: ' and '),
                            WidgetSpan(
                              child: GestureDetector(
                                onTap: () => context.push('/privacy'),
                                child: Text(
                                  'Privacy Policy',
                                  style: AppTextStyles.caption.copyWith(
                                    color: AppColors.textPrimary,
                                    decoration: TextDecoration.underline,
                                  ),
                                ),
                              ),
                            ),
                            const TextSpan(text: '.'),
                          ],
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.md),
                    SnipkitButton(
                      label: 'Create my account',
                      onPressed: () => context.push('/account-created'),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
