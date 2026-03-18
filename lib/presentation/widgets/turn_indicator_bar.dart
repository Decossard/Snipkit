import 'package:flutter/material.dart';
import '../../core/tokens/design_tokens.dart';
import '../../core/tokens/app_icons.dart';

enum TurnIndicatorVariant { yourTurn, waiting }

class TurnIndicatorBar extends StatelessWidget {
  const TurnIndicatorBar({
    super.key,
    required this.variant,
  });

  final TurnIndicatorVariant variant;

  @override
  Widget build(BuildContext context) {
    final isYourTurn = variant == TurnIndicatorVariant.yourTurn;

    return Container(
      width: double.infinity,
      height: 44,
      decoration: BoxDecoration(
        color: isYourTurn
            ? const Color(0x0FE8572A) // rgba(232,87,42,0.06)
            : Colors.transparent,
        border: Border(
          left: BorderSide(
            color: isYourTurn
                ? AppColors.turnActiveIndicator
                : AppColors.turnWaitingIndicator,
            width: 3,
          ),
        ),
      ),
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
      child: Row(
        children: [
          Icon(
            isYourTurn ? AppIcons.chatBubble : AppIcons.clock,
            size: AppIcons.small,
            color: isYourTurn ? AppColors.accentInteractive : AppColors.textDisabled,
          ),
          const SizedBox(width: AppSpacing.sm),
          Text(
            isYourTurn ? 'Your turn' : 'Waiting for reply...',
            style: AppTextStyles.bodySmall.copyWith(
              color: isYourTurn ? AppColors.accentInteractive : AppColors.textDisabled,
            ),
          ),
        ],
      ),
    );
  }
}
