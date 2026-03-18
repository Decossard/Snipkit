import 'package:flutter/material.dart';
import '../../core/tokens/design_tokens.dart';
import '../../core/tokens/app_icons.dart';

class GroupPostCard extends StatelessWidget {
  const GroupPostCard({
    super.key,
    this.caption,
    this.viewCount,
    this.totalCount,
    this.isExpired = false,
    this.isFullyViewed = false,
    this.onTap,
  });

  final String? caption;
  final int? viewCount;
  final int? totalCount;
  final bool isExpired;
  final bool isFullyViewed;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    if (isExpired) {
      return _buildExpired();
    }

    return Opacity(
      opacity: isFullyViewed ? 0.7 : 1.0,
      child: GestureDetector(
        onTap: onTap,
        child: AspectRatio(
          aspectRatio: 1,
          child: Container(
            decoration: BoxDecoration(
              color: AppColors.backgroundSecondary,
              borderRadius: AppRadius.mediumRadius,
            ),
            child: Stack(
              children: [
                // Placeholder fill
                Container(
                  decoration: BoxDecoration(
                    color: AppColors.backgroundElevated,
                    borderRadius: AppRadius.mediumRadius,
                  ),
                  alignment: Alignment.center,
                  child: Text('Photo', style: AppTextStyles.caption.copyWith(color: AppColors.textDisabled)),
                ),
                // Bottom overlay
                Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  child: Container(
                    padding: const EdgeInsets.all(AppSpacing.lg),
                    decoration: const BoxDecoration(
                      borderRadius: BorderRadius.only(
                        bottomLeft: Radius.circular(AppRadius.medium),
                        bottomRight: Radius.circular(AppRadius.medium),
                      ),
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [Colors.transparent, Color(0x80000000)],
                      ),
                    ),
                    child: Row(
                      children: [
                        if (caption != null)
                          Expanded(
                            child: Text(
                              caption!,
                              style: AppTextStyles.bodySmall.copyWith(color: AppColors.backgroundPrimary),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        if (viewCount != null && totalCount != null)
                          Text(
                            isFullyViewed
                                ? '$viewCount of $totalCount viewed'
                                : '$viewCount of $totalCount viewed',
                            style: AppTextStyles.caption.copyWith(
                              color: isFullyViewed ? AppColors.accentSuccess : AppColors.textSecondary,
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildExpired() {
    return AspectRatio(
      aspectRatio: 1,
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.backgroundElevated,
          borderRadius: AppRadius.mediumRadius,
          border: Border.all(
            color: AppColors.borderDefault,
            width: 1,
            style: BorderStyle.solid,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(AppIcons.clock, size: AppIcons.large, color: AppColors.textDisabled),
            const SizedBox(height: AppSpacing.sm),
            Text('Expired', style: AppTextStyles.caption.copyWith(color: AppColors.textDisabled)),
          ],
        ),
      ),
    );
  }
}
