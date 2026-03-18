import 'package:flutter/material.dart';
import '../../core/tokens/design_tokens.dart';

/// Simple top bar: title left, optional trailing actions right.
/// Search has moved to the bottom search bar.
class SearchableTopBar extends StatelessWidget implements PreferredSizeWidget {
  const SearchableTopBar({
    super.key,
    required this.title,
    this.trailing,
  });

  final String title;

  /// Optional widget(s) shown in the trailing position (e.g. + button, profile icon).
  final Widget? trailing;

  @override
  Size get preferredSize => const Size.fromHeight(56);

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      bottom: false,
      child: Container(
        height: 56,
        decoration: const BoxDecoration(
          color: AppColors.backgroundPrimary,
          border: Border(
            bottom: BorderSide(color: AppColors.borderSubtle, width: 1),
          ),
        ),
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
        child: Row(
          children: [
            Text(
              title,
              style: AppTextStyles.headingSmall.copyWith(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w700,
                letterSpacing: -0.5,
              ),
            ),
            const Spacer(),
            if (trailing != null) trailing!,
          ],
        ),
      ),
    );
  }
}
