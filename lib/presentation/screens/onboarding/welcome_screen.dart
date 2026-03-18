import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/services/auth_service.dart';
import '../../../core/tokens/design_tokens.dart';
import '../../widgets/snipkit_button.dart';
import '../../widgets/screen_shell.dart';

class WelcomeScreen extends ConsumerWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);

    // Navigate to account-created only on the first appearance of pendingSignup
    // (guards against firing twice if auth state changes again while it's set)
    ref.listen(authProvider, (prev, next) {
      if (prev?.pendingSignup == null && next.pendingSignup != null) {
        context.push('/account-created');
      }
    });

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
                Text(
                  'No email. No password. No phone number.',
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.textDisabled,
                    height: 1.5,
                  ),
                ),
                if (authState.errorMessage != null) ...[
                  const SizedBox(height: AppSpacing.lg),
                  Text(
                    authState.errorMessage!,
                    style: AppTextStyles.bodySmall
                        .copyWith(color: AppColors.accentDestructive),
                  ),
                ],
                const Expanded(child: SizedBox()),
                SnipkitButton(
                  label: authState.isLoading
                      ? 'Creating account…'
                      : 'Create my account',
                  isDisabled: authState.isLoading,
                  onPressed: authState.isLoading
                      ? null
                      : () => ref.read(authProvider.notifier).signUp(),
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
