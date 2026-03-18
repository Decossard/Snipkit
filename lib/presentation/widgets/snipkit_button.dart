import 'package:flutter/material.dart';
import '../../core/tokens/design_tokens.dart';

enum SnipkitButtonVariant { primary, secondary, destructive }

class SnipkitButton extends StatelessWidget {
  const SnipkitButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.variant = SnipkitButtonVariant.primary,
    this.isDisabled = false,
    this.isLoading = false,
  });

  final String label;
  final VoidCallback? onPressed;
  final SnipkitButtonVariant variant;
  final bool isDisabled;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    final bool enabled = !isDisabled && !isLoading && onPressed != null;

    Color bgColor;
    Color textColor;
    Border? border;

    switch (variant) {
      case SnipkitButtonVariant.primary:
        bgColor = AppColors.accentPrimary;
        textColor = AppColors.backgroundPrimary;
        border = null;
        break;
      case SnipkitButtonVariant.secondary:
        bgColor = Colors.transparent;
        textColor = AppColors.textPrimary;
        border = Border.all(color: AppColors.borderDefault, width: 1);
        break;
      case SnipkitButtonVariant.destructive:
        bgColor = AppColors.accentDestructive;
        textColor = AppColors.backgroundPrimary;
        border = null;
        break;
    }

    return Opacity(
      opacity: isDisabled ? 0.35 : 1.0,
      child: GestureDetector(
        onTap: enabled ? onPressed : null,
        child: Container(
          width: double.infinity,
          height: 52,
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: AppRadius.fullRadius,
            border: border,
          ),
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
          alignment: Alignment.center,
          child: isLoading
              ? SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(textColor),
                  ),
                )
              : Text(
                  label,
                  style: AppTextStyles.bodyLarge.copyWith(
                    color: textColor,
                    fontWeight: FontWeight.w600,
                  ),
                ),
        ),
      ),
    );
  }
}
