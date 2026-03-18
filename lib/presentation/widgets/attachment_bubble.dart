import 'package:flutter/material.dart';
import '../../core/tokens/design_tokens.dart';
import '../../core/tokens/app_icons.dart';

enum AttachmentType { picture, voice, article }

class AttachmentBubble extends StatelessWidget {
  const AttachmentBubble({
    super.key,
    required this.type,
    this.caption,
    this.isViewed = false,
    this.onTap,
  });

  final AttachmentType type;
  final String? caption;
  final bool isViewed;
  final VoidCallback? onTap;

  IconData get _icon {
    switch (type) {
      case AttachmentType.picture:
        return AppIcons.imagePhoto;
      case AttachmentType.voice:
        return AppIcons.microphone;
      case AttachmentType.article:
        return AppIcons.articlePage;
    }
  }

  String get _defaultCaption {
    switch (type) {
      case AttachmentType.picture:
        return isViewed ? 'Photo opened' : 'Photo';
      case AttachmentType.voice:
        return isViewed ? 'Voice opened' : 'Voice message';
      case AttachmentType.article:
        return isViewed ? 'Article opened' : 'Article';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: isViewed ? 0.4 : 1.0,
      child: GestureDetector(
        onTap: isViewed ? null : onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.lg,
            vertical: AppSpacing.md,
          ),
          decoration: BoxDecoration(
            color: AppColors.bubbleReceived,
            borderRadius: AppRadius.mediumRadius,
            border: Border.all(color: AppColors.bubbleReceivedBorder, width: 1),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(_icon, size: AppIcons.large, color: AppColors.textSecondary),
              const SizedBox(width: AppSpacing.md),
              Flexible(
                child: Text(
                  caption ?? _defaultCaption,
                  style: AppTextStyles.bodySmall.copyWith(
                    color: isViewed ? AppColors.textDisabled : AppColors.textPrimary,
                  ),
                ),
              ),
              if (!isViewed) ...[
                const SizedBox(width: AppSpacing.md),
                Text(
                  'Tap to open',
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.accentInteractive,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
