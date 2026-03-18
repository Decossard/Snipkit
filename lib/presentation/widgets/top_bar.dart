import 'package:flutter/material.dart';
import '../../core/tokens/design_tokens.dart';
import '../../core/tokens/app_icons.dart';

class SnipkitTopBar extends StatelessWidget implements PreferredSizeWidget {
  const SnipkitTopBar({
    super.key,
    this.title,
    this.titleWidget,
    this.showBack = false,
    this.onBack,
    this.action,
  });

  final String? title;
  final Widget? titleWidget;
  final bool showBack;
  final VoidCallback? onBack;
  final Widget? action;

  @override
  Size get preferredSize => const Size.fromHeight(56);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.backgroundPrimary,
        border: Border(bottom: BorderSide(color: AppColors.borderSubtle, width: 1)),
      ),
      child: SafeArea(
        bottom: false,
        child: SizedBox(
          height: 56,
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Back button left
              if (showBack)
                Positioned(
                  left: 0,
                  child: GestureDetector(
                    onTap: onBack ?? () => Navigator.of(context).pop(),
                    child: const SizedBox(
                      width: 48,
                      height: 48,
                      child: Icon(AppIcons.arrowLeft, size: AppIcons.large, color: AppColors.textPrimary),
                    ),
                  ),
                ),
              // Title center
              if (titleWidget != null)
                titleWidget!
              else if (title != null)
                Text(title!, style: AppTextStyles.headingSmall.copyWith(color: AppColors.textPrimary)),
              // Action right
              if (action != null)
                Positioned(
                  right: 0,
                  child: SizedBox(width: 48, height: 48, child: action),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
