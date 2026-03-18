import 'package:flutter/material.dart';
import '../../core/tokens/design_tokens.dart';
import '../../core/tokens/app_icons.dart';

/// Persistent search bar pinned above the bottom nav bar.
/// Replaces the top-bar search pattern — lives in the thumb zone.
class BottomSearchBar extends StatelessWidget {
  const BottomSearchBar({
    super.key,
    required this.onChanged,
    this.hint = 'Search',
  });

  final ValueChanged<String> onChanged;
  final String hint;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.backgroundPrimary,
        border: Border(
          top: BorderSide(color: AppColors.borderSubtle, width: 1),
        ),
      ),
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.lg,
        AppSpacing.sm,
        AppSpacing.lg,
        AppSpacing.sm,
      ),
      child: Container(
        height: 44,
        decoration: BoxDecoration(
          color: AppColors.backgroundInput,
          borderRadius: AppRadius.xlargeRadius,
        ),
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
        child: Row(
          children: [
            const Icon(
              AppIcons.search,
              size: AppIcons.small,
              color: AppColors.textDisabled,
            ),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: TextField(
                onChanged: onChanged,
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.textPrimary,
                ),
                decoration: InputDecoration(
                  border: InputBorder.none,
                  isDense: true,
                  hintText: hint,
                  hintStyle: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.textPlaceholder,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
