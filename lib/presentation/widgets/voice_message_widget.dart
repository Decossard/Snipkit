import 'package:flutter/material.dart';
import '../../core/tokens/design_tokens.dart';
import '../../core/tokens/app_icons.dart';

class VoiceMessageWidget extends StatelessWidget {
  const VoiceMessageWidget({
    super.key,
    required this.duration,
    this.progress = 0.0,
    this.isPlaying = false,
    this.onTap,
  });

  final String duration;
  final double progress; // 0.0 to 1.0
  final bool isPlaying;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
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
          children: [
            const Icon(
              AppIcons.playCircle,
              size: 40,
              color: AppColors.accentInteractive,
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(child: _Waveform(progress: progress)),
            const SizedBox(width: AppSpacing.md),
            Text(
              duration,
              style: AppTextStyles.caption.copyWith(color: AppColors.textSecondary),
            ),
          ],
        ),
      ),
    );
  }
}

class _Waveform extends StatelessWidget {
  const _Waveform({required this.progress});
  final double progress;

  static const List<double> _heights = [
    0.4, 0.6, 0.8, 1.0, 0.7, 0.5, 0.9, 0.6, 0.8, 0.4,
    0.7, 1.0, 0.5, 0.8, 0.6, 0.9, 0.4, 0.7, 0.6, 0.5,
  ];

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 28,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: List.generate(_heights.length, (i) {
          final ratio = i / _heights.length;
          final played = ratio <= progress;
          return Container(
            width: 4,
            height: 28 * _heights[i],
            decoration: BoxDecoration(
              color: played ? AppColors.accentInteractive : AppColors.turnWaitingIndicator,
              borderRadius: AppRadius.fullRadius,
            ),
          );
        }),
      ),
    );
  }
}
