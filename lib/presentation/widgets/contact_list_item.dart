import 'package:flutter/material.dart';
import '../../core/tokens/design_tokens.dart';
import '../../core/tokens/app_icons.dart';

class ContactListItem extends StatelessWidget {
  const ContactListItem({
    super.key,
    required this.username,
    this.subtext,
    this.subtextColor,
    this.subtextIcon,
    this.trailingIcon,
    this.trailingColor,
    this.onTap,
    this.showDivider = true,
    this.showChevron = true,
  });

  final String username;
  final String? subtext;
  final Color? subtextColor;
  final IconData? subtextIcon;
  final IconData? trailingIcon;
  final Color? trailingColor;
  final VoidCallback? onTap;
  final bool showDivider;
  final bool showChevron;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        GestureDetector(
          onTap: onTap,
          behavior: HitTestBehavior.opaque,
          child: SizedBox(
            height: 72,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
              child: Row(
                children: [
                  // Avatar circle
                  Container(
                    width: 40,
                    height: 40,
                    decoration: const BoxDecoration(
                      color: AppColors.backgroundSecondary,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      AppIcons.person,
                      size: AppIcons.medium,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  // Text
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(username, style: AppTextStyles.bodyLarge),
                        if (subtext != null) ...[
                          const SizedBox(height: 2),
                          Row(
                            children: [
                              if (subtextIcon != null) ...[
                                Icon(
                                  subtextIcon,
                                  size: AppIcons.small,
                                  color: subtextColor ?? AppColors.textSecondary,
                                ),
                                const SizedBox(width: 4),
                              ],
                              Text(
                                subtext!,
                                style: AppTextStyles.bodySmall.copyWith(
                                  color: subtextColor ?? AppColors.textSecondary,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ],
                    ),
                  ),
                  // Trailing
                  if (trailingIcon != null)
                    Icon(trailingIcon, size: AppIcons.medium, color: trailingColor ?? AppColors.textDisabled)
                  else if (showChevron)
                    const Icon(AppIcons.chevronRight, size: AppIcons.medium, color: AppColors.textDisabled),
                ],
              ),
            ),
          ),
        ),
        if (showDivider)
          const Divider(
            height: 1,
            thickness: 1,
            color: AppColors.borderSubtle,
            indent: AppSpacing.lg,
            endIndent: AppSpacing.lg,
          ),
      ],
    );
  }
}
