import 'package:flutter/material.dart';
import '../../core/tokens/design_tokens.dart';
import '../../core/tokens/app_icons.dart';

class SnipkitInput extends StatefulWidget {
  const SnipkitInput({
    super.key,
    this.label,
    this.placeholder,
    this.controller,
    this.isPassword = false,
    this.errorText,
    this.onChanged,
    this.keyboardType,
    this.textInputAction,
    this.focusNode,
    this.readOnly = false,
    this.maxLength,
    this.maxLines = 1,
    this.style,
  });

  final String? label;
  final String? placeholder;
  final TextEditingController? controller;
  final bool isPassword;
  final String? errorText;
  final ValueChanged<String>? onChanged;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final FocusNode? focusNode;
  final bool readOnly;
  final int? maxLength;
  final int? maxLines;
  final TextStyle? style;

  @override
  State<SnipkitInput> createState() => _SnipkitInputState();
}

class _SnipkitInputState extends State<SnipkitInput> {
  bool _obscure = true;
  bool _focused = false;
  late FocusNode _focusNode;

  @override
  void initState() {
    super.initState();
    _focusNode = widget.focusNode ?? FocusNode();
    _focusNode.addListener(() {
      setState(() => _focused = _focusNode.hasFocus);
    });
  }

  @override
  void dispose() {
    if (widget.focusNode == null) _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bool hasError = widget.errorText != null && widget.errorText!.isNotEmpty;

    BorderSide borderSide;
    if (hasError) {
      borderSide = const BorderSide(color: AppColors.accentDestructive, width: 1);
    } else if (_focused) {
      borderSide = const BorderSide(color: AppColors.accentInteractive, width: 1.5);
    } else {
      borderSide = const BorderSide(color: AppColors.borderSubtle, width: 1);
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (widget.label != null) ...[
          Text(
            widget.label!,
            style: AppTextStyles.bodySmall.copyWith(color: AppColors.textSecondary),
          ),
          const SizedBox(height: AppSpacing.xs),
        ],
        Container(
          height: widget.maxLines == 1 ? 52 : null,
          decoration: BoxDecoration(
            color: AppColors.backgroundInput,
            borderRadius: AppRadius.mediumRadius,
            border: Border.fromBorderSide(borderSide),
          ),
          child: TextField(
            controller: widget.controller,
            focusNode: _focusNode,
            obscureText: widget.isPassword && _obscure,
            onChanged: widget.onChanged,
            keyboardType: widget.keyboardType,
            textInputAction: widget.textInputAction,
            readOnly: widget.readOnly,
            maxLength: widget.maxLength,
            maxLines: widget.maxLines,
            style: widget.style ?? AppTextStyles.bodyLarge.copyWith(color: AppColors.textPrimary),
            decoration: InputDecoration(
              hintText: widget.placeholder,
              hintStyle: AppTextStyles.bodyLarge.copyWith(color: AppColors.textPlaceholder),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.lg,
                vertical: AppSpacing.md,
              ),
              counterText: '',
              suffixIcon: widget.isPassword
                  ? GestureDetector(
                      onTap: () => setState(() => _obscure = !_obscure),
                      child: SizedBox(
                        width: 48,
                        height: 48,
                        child: Icon(
                          _obscure ? AppIcons.eyeOff : AppIcons.eye,
                          size: AppIcons.medium,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    )
                  : null,
            ),
          ),
        ),
        if (hasError) ...[
          const SizedBox(height: AppSpacing.xs),
          Text(
            widget.errorText!,
            style: AppTextStyles.caption.copyWith(color: AppColors.accentDestructive),
          ),
        ],
      ],
    );
  }
}
