import 'package:flutter/material.dart';
import '../../core/tokens/design_tokens.dart';
import '../../core/tokens/app_icons.dart';

enum ToastVariant { success, error, warning, neutral }

class ToastNotification extends StatefulWidget {
  const ToastNotification({
    super.key,
    required this.message,
    required this.variant,
    this.icon,
    this.onDismissed,
  });

  final String message;
  final ToastVariant variant;
  final IconData? icon;
  final VoidCallback? onDismissed;

  static void show(
    BuildContext context, {
    required String message,
    required ToastVariant variant,
    IconData? icon,
  }) {
    final overlay = Overlay.of(context);
    late OverlayEntry entry;
    entry = OverlayEntry(
      builder: (_) => ToastNotification(
        message: message,
        variant: variant,
        icon: icon,
        onDismissed: () => entry.remove(),
      ),
    );
    overlay.insert(entry);
  }

  @override
  State<ToastNotification> createState() => _ToastNotificationState();
}

class _ToastNotificationState extends State<ToastNotification>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<Offset> _slide;
  late final Animation<double> _fade;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2500),
    );

    _slide = Tween<Offset>(
      begin: const Offset(0, 1),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: const Interval(0, 0.4, curve: Cubic(0.16, 1.0, 0.3, 1.0)),
    ));

    _fade = Tween<double>(begin: 1, end: 0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.8, 1.0, curve: Curves.easeOut),
      ),
    );

    _controller.forward().then((_) => widget.onDismissed?.call());
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Color get _bgColor {
    switch (widget.variant) {
      case ToastVariant.success:
        return AppColors.accentSuccess;
      case ToastVariant.error:
        return AppColors.accentDestructive;
      case ToastVariant.warning:
        return AppColors.accentWarning;
      case ToastVariant.neutral:
        return AppColors.backgroundPrimary;
    }
  }

  Color get _textColor {
    return widget.variant == ToastVariant.neutral
        ? AppColors.textPrimary
        : AppColors.backgroundPrimary;
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
      bottom: MediaQuery.of(context).padding.bottom + AppSpacing.lg,
      left: AppSpacing.xl,
      right: AppSpacing.xl,
      child: SlideTransition(
        position: _slide,
        child: FadeTransition(
          opacity: _fade,
          child: Material(
            color: Colors.transparent,
            child: Container(
              height: 44,
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.xl,
                vertical: AppSpacing.sm,
              ),
              decoration: BoxDecoration(
                color: _bgColor,
                borderRadius: AppRadius.fullRadius,
                border: widget.variant == ToastVariant.neutral
                    ? Border.all(color: AppColors.borderSubtle, width: 1)
                    : null,
                boxShadow: widget.variant == ToastVariant.neutral ? AppShadows.low : null,
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (widget.icon != null) ...[
                    Icon(widget.icon, size: AppIcons.small, color: _textColor),
                    const SizedBox(width: AppSpacing.sm),
                  ],
                  Flexible(
                    child: Text(
                      widget.message,
                      style: AppTextStyles.bodySmall.copyWith(color: _textColor),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
