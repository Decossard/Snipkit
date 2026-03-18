import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/tokens/design_tokens.dart';
import '../../widgets/snipkit_button.dart';
import '../../widgets/screen_shell.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundPrimary,
      body: SafeArea(
        child: ScreenShell(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xxl),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: AppSpacing.giant),
                // ── Value proposition ────────────────────────────
                Text(
                  'Slow down\nyour messages.',
                  style: AppTextStyles.displayStyle.copyWith(
                    color: AppColors.textPrimary,
                    height: 1.15,
                  ),
                ),
                const SizedBox(height: AppSpacing.lg),
                Text(
                  'Snipkit is a messaging app built around turns. You send, they reply — one at a time. Media opens once and disappears.',
                  style: AppTextStyles.bodyLarge.copyWith(
                    color: AppColors.textSecondary,
                    height: 1.6,
                  ),
                ),
                const SizedBox(height: AppSpacing.xxl),
                // ── Pin callout ──────────────────────────────────
                // Introduces the no-password model before the user
                // hits account creation — progressive disclosure.
                Text(
                  'No email. No password. No phone number.',
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.textDisabled,
                    height: 1.5,
                  ),
                ),
                const Expanded(child: SizedBox()),
                // ── CTAs ─────────────────────────────────────────
                SnipkitButton(
                  label: 'Create my account',
                  onPressed: () => context.push('/account-created'),
                ),
                const SizedBox(height: AppSpacing.md),
                GestureDetector(
                  onTap: () => context.push('/login'),
                  child: SizedBox(
                    height: 44,
                    child: Center(
                      child: Text(
                        'Sign in',
                        style: AppTextStyles.bodyMedium.copyWith(
                          color: AppColors.textSecondary,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: AppSpacing.xxxl),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
