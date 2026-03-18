import 'package:flutter/material.dart';
import '../../core/tokens/design_tokens.dart';
import 'snipkit_button.dart';

class EmptyState extends StatelessWidget {
  const EmptyState({
    super.key,
    required this.icon,
    required this.heading,
    this.body,
    this.buttonLabel,
    this.onButtonTap,
  });

  final IconData icon;
  final String heading;
  final String? body;
  final String? buttonLabel;
  final VoidCallback? onButtonTap;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xxxl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 64, color: AppColors.borderDefault),
            const SizedBox(height: AppSpacing.lg),
            Text(
              heading,
              style: AppTextStyles.headingSmall.copyWith(color: AppColors.textDisabled),
              textAlign: TextAlign.center,
            ),
            if (body != null) ...[
              const SizedBox(height: AppSpacing.sm),
              Text(
                body!,
                style: AppTextStyles.bodySmall.copyWith(color: AppColors.textSecondary),
                textAlign: TextAlign.center,
              ),
            ],
            if (buttonLabel != null && onButtonTap != null) ...[
              const SizedBox(height: AppSpacing.xxl),
              SnipkitButton(label: buttonLabel!, onPressed: onButtonTap),
            ],
          ],
        ),
      ),
    );
  }
}
