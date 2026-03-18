import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../core/tokens/design_tokens.dart';
import '../../core/tokens/app_icons.dart';

class RecoveryCodeDisplay extends StatelessWidget {
  const RecoveryCodeDisplay({super.key, required this.words});

  final List<String> words;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.xl),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF8F6),
        borderRadius: AppRadius.mediumRadius,
        border: Border.all(color: AppColors.accentInteractive, width: 1),
      ),
      child: Column(
        children: [
          const Icon(AppIcons.warningTriangle, size: AppIcons.large, color: AppColors.accentWarning),
          const SizedBox(height: AppSpacing.md),
          Text(
            words.join('  '),
            style: AppTextStyles.headingMedium.copyWith(color: AppColors.textPrimary),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppSpacing.md),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Write this down',
                style: AppTextStyles.caption.copyWith(color: AppColors.accentWarning),
              ),
              const SizedBox(width: AppSpacing.md),
              GestureDetector(
                onTap: () => Clipboard.setData(ClipboardData(text: words.join(' '))),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(AppIcons.copy, size: AppIcons.small, color: AppColors.accentInteractive),
                    const SizedBox(width: AppSpacing.xs),
                    Text(
                      'Copy',
                      style: AppTextStyles.caption.copyWith(color: AppColors.accentInteractive),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
