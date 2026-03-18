import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../core/tokens/design_tokens.dart';
import '../../core/tokens/app_icons.dart';

class PinDisplayChip extends StatelessWidget {
  const PinDisplayChip({super.key, required this.pin});

  final String pin;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.backgroundInput,
        borderRadius: AppRadius.smallRadius,
        border: Border.all(color: AppColors.borderDefault, width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(pin, style: AppTextStyles.monoPin),
          const SizedBox(width: AppSpacing.md),
          GestureDetector(
            onTap: () {
              Clipboard.setData(ClipboardData(text: pin));
            },
            child: const Icon(AppIcons.copy, size: AppIcons.medium, color: AppColors.accentInteractive),
          ),
        ],
      ),
    );
  }
}
