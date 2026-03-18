import 'package:flutter/material.dart';
import '../../core/tokens/design_tokens.dart';

class CharacterCounter extends StatelessWidget {
  const CharacterCounter({
    super.key,
    required this.current,
    required this.max,
  });

  final int current;
  final int max;

  @override
  Widget build(BuildContext context) {
    final double ratio = max > 0 ? current / max : 0;

    Color color;
    if (current >= max) {
      color = AppColors.accentDestructive;
    } else if (ratio >= 0.875) {
      color = AppColors.accentWarning;
    } else {
      color = AppColors.textDisabled;
    }

    return Text(
      '$current/$max',
      style: AppTextStyles.caption.copyWith(color: color),
      textAlign: TextAlign.right,
    );
  }
}
