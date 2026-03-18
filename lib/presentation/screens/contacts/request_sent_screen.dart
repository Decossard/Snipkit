import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/tokens/design_tokens.dart';
import '../../../core/tokens/app_icons.dart';
import '../../widgets/snipkit_button.dart';

class RequestSentScreen extends StatelessWidget {
  const RequestSentScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundPrimary,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xxl),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: AppSpacing.xxxl),
              // Success icon
              Container(
                width: 48,
                height: 48,
                decoration: const BoxDecoration(
                  color: AppColors.textPrimary,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  AppIcons.checkCircle,
                  color: AppColors.backgroundPrimary,
                  size: AppIcons.medium,
                ),
              ),
              const SizedBox(height: AppSpacing.xxl),
              Text(
                'Request sent.',
                style: AppTextStyles.displayStyle.copyWith(
                  color: AppColors.textPrimary,
                  height: 1.15,
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(
                "They'll get a notification. Once they\naccept, you can start a conversation.",
                style: AppTextStyles.bodyLarge.copyWith(
                  color: AppColors.textSecondary,
                  height: 1.5,
                ),
              ),
              const Expanded(child: SizedBox()),
              SnipkitButton(
                label: 'Back to Chats',
                onPressed: () => context.go('/home'),
              ),
              const SizedBox(height: AppSpacing.md),
              SnipkitButton(
                label: 'Add Another',
                onPressed: () => context.go('/add-contact'),
                variant: SnipkitButtonVariant.secondary,
              ),
              const SizedBox(height: AppSpacing.xxxl),
            ],
          ),
        ),
      ),
    );
  }
}
