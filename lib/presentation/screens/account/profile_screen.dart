import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import '../../../core/tokens/design_tokens.dart';
import '../../../core/tokens/app_icons.dart';

const _mockUsername = 'cedar.hayes';
const _appVersion = '1.0.0 (1)';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool _usernameCopied = false;
  String _autoDelete = 'Off';

  void _copyUsername() async {
    await Clipboard.setData(const ClipboardData(text: _mockUsername));
    setState(() => _usernameCopied = true);
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) setState(() => _usernameCopied = false);
    });
  }

  void _showAutoDelete() {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.backgroundPrimary,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (_) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: AppSpacing.md),
          Container(
              width: 36,
              height: 4,
              decoration: BoxDecoration(
                  color: AppColors.borderDefault,
                  borderRadius: AppRadius.fullRadius)),
          const SizedBox(height: AppSpacing.lg),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xxl),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Auto-delete messages',
                    style: AppTextStyles.headingSmall
                        .copyWith(color: AppColors.textPrimary)),
                const SizedBox(height: AppSpacing.xs),
                Text('Messages disappear after the chosen time.',
                    style: AppTextStyles.bodySmall
                        .copyWith(color: AppColors.textSecondary)),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          for (final option in ['Off', '1 day', '1 week', '1 month'])
            _OptionRow(
              label: option,
              isSelected: _autoDelete == option,
              onTap: () {
                Navigator.of(context).pop();
                setState(() => _autoDelete = option);
              },
            ),
          SizedBox(
              height: MediaQuery.of(context).padding.bottom + AppSpacing.md),
        ],
      ),
    );
  }

  void _confirmClearMessages() {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.backgroundPrimary,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (_) => Padding(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.xxl,
          AppSpacing.xxl,
          AppSpacing.xxl,
          AppSpacing.xxxl,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Clear all messages?',
              style: AppTextStyles.headingSmall.copyWith(
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              'Every message in every conversation\nwill be deleted. This can\'t be undone.',
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.textSecondary,
                height: 1.5,
              ),
            ),
            const SizedBox(height: AppSpacing.xxl),
            GestureDetector(
              onTap: () => Navigator.of(context).pop(),
              child: Container(
                height: 52,
                decoration: BoxDecoration(
                  color: AppColors.textPrimary,
                  borderRadius: AppRadius.fullRadius,
                ),
                alignment: Alignment.center,
                child: Text(
                  'Clear all messages',
                  style: AppTextStyles.bodyLarge.copyWith(
                    color: AppColors.backgroundPrimary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            GestureDetector(
              onTap: () => Navigator.of(context).pop(),
              child: Container(
                height: 52,
                decoration: BoxDecoration(
                  border: Border.all(color: AppColors.borderDefault, width: 1),
                  borderRadius: AppRadius.fullRadius,
                ),
                alignment: Alignment.center,
                child: Text(
                  'Cancel',
                  style: AppTextStyles.bodyLarge.copyWith(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _confirmDeleteConversations() {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.backgroundPrimary,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (_) => Padding(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.xxl,
          AppSpacing.xxl,
          AppSpacing.xxl,
          AppSpacing.xxxl,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Delete all conversations?',
              style: AppTextStyles.headingSmall.copyWith(
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              'Every conversation thread and all messages\nwill be permanently removed. Your contacts\nwon\'t be affected.',
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.textSecondary,
                height: 1.5,
              ),
            ),
            const SizedBox(height: AppSpacing.xxl),
            GestureDetector(
              onTap: () {
                Navigator.of(context).pop();
                context.go('/home');
              },
              child: Container(
                height: 52,
                decoration: BoxDecoration(
                  color: AppColors.accentDestructive,
                  borderRadius: AppRadius.fullRadius,
                ),
                alignment: Alignment.center,
                child: Text(
                  'Delete all conversations',
                  style: AppTextStyles.bodyLarge.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            GestureDetector(
              onTap: () => Navigator.of(context).pop(),
              child: Container(
                height: 52,
                decoration: BoxDecoration(
                  border: Border.all(color: AppColors.borderDefault, width: 1),
                  borderRadius: AppRadius.fullRadius,
                ),
                alignment: Alignment.center,
                child: Text(
                  'Cancel',
                  style: AppTextStyles.bodyLarge.copyWith(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _confirmSignOut() {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.backgroundPrimary,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (_) => Padding(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.xxl,
          AppSpacing.xxl,
          AppSpacing.xxl,
          AppSpacing.xxxl,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Sign out of Snipkit?',
              style: AppTextStyles.headingSmall.copyWith(
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              'You can sign back in anytime\nwith your username and recovery code.',
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.textSecondary,
                height: 1.5,
              ),
            ),
            const SizedBox(height: AppSpacing.xxl),
            GestureDetector(
              onTap: () {
                Navigator.of(context).pop();
                context.go('/welcome');
              },
              child: Container(
                height: 52,
                decoration: BoxDecoration(
                  color: AppColors.textPrimary,
                  borderRadius: AppRadius.fullRadius,
                ),
                alignment: Alignment.center,
                child: Text(
                  'Sign out',
                  style: AppTextStyles.bodyLarge.copyWith(
                    color: AppColors.backgroundPrimary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            GestureDetector(
              onTap: () => Navigator.of(context).pop(),
              child: Container(
                height: 52,
                decoration: BoxDecoration(
                  border: Border.all(color: AppColors.borderDefault, width: 1),
                  borderRadius: AppRadius.fullRadius,
                ),
                alignment: Alignment.center,
                child: Text(
                  'Cancel',
                  style: AppTextStyles.bodyLarge.copyWith(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _confirmDeleteAccount() {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.backgroundPrimary,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (_) => Padding(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.xxl,
          AppSpacing.xxl,
          AppSpacing.xxl,
          AppSpacing.xxxl,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Icon(
              AppIcons.warningTriangle,
              size: 28,
              color: AppColors.accentDestructive,
            ),
            const SizedBox(height: AppSpacing.lg),
            Text(
              'Delete your account?',
              style: AppTextStyles.headingSmall.copyWith(
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              'This will permanently delete your account, all messages, and your username. This action cannot be undone.',
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.textSecondary,
                height: 1.5,
              ),
            ),
            const SizedBox(height: AppSpacing.xxl),
            GestureDetector(
              onTap: () {
                Navigator.of(context).pop();
                context.go('/welcome');
              },
              child: Container(
                height: 52,
                decoration: BoxDecoration(
                  color: AppColors.accentDestructive,
                  borderRadius: AppRadius.fullRadius,
                ),
                alignment: Alignment.center,
                child: Text(
                  'Delete my account',
                  style: AppTextStyles.bodyLarge.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            GestureDetector(
              onTap: () => Navigator.of(context).pop(),
              child: Container(
                height: 52,
                decoration: BoxDecoration(
                  border: Border.all(color: AppColors.borderDefault, width: 1),
                  borderRadius: AppRadius.fullRadius,
                ),
                alignment: Alignment.center,
                child: Text(
                  'Cancel',
                  style: AppTextStyles.bodyLarge.copyWith(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundPrimary,
      body: Column(
        children: [
          _ProfileTopBar(),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xxl),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: AppSpacing.xxxl),
                  // Username section
                  Text(
                    'YOUR USERNAME',
                    style: AppTextStyles.caption.copyWith(
                      color: const Color(0xFF555555),
                      letterSpacing: 1.5,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Row(
                    children: [
                      Text(
                        _mockUsername,
                        style: AppTextStyles.headingMedium.copyWith(
                          color: AppColors.textPrimary,
                          letterSpacing: -0.2,
                        ),
                      ),
                      const Spacer(),
                      GestureDetector(
                        onTap: _copyUsername,
                        child: Row(
                          children: [
                            Icon(
                              _usernameCopied
                                  ? AppIcons.checkCircle
                                  : AppIcons.copy,
                              size: AppIcons.small,
                              color: _usernameCopied
                                  ? AppColors.accentSuccess
                                  : AppColors.textSecondary,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              _usernameCopied ? 'Copied' : 'Copy',
                              style: AppTextStyles.bodySmall.copyWith(
                                color: _usernameCopied
                                    ? AppColors.accentSuccess
                                    : AppColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  // ── Section 1: Account ────────────────────────
                  const _SectionLabel('ACCOUNT'),
                  _SettingsRow(
                    icon: AppIcons.saveNotification,
                    label: 'Recovery reminder',
                    onTap: () => context.push('/recovery-reminder'),
                  ),

                  // ── Section 2: Preferences ────────────────────
                  const _SectionLabel('PREFERENCES'),
                  _SettingsRow(
                    icon: AppIcons.clock,
                    label: 'Auto-delete messages',
                    value: _autoDelete,
                    onTap: _showAutoDelete,
                  ),
                  _SettingsRow(
                    icon: AppIcons.block,
                    label: 'Blocked contacts',
                    onTap: () => context.push('/blocked-contacts'),
                  ),

                  // ── Section 3: Data ───────────────────────────
                  const _SectionLabel('DATA'),
                  _SettingsRow(
                    icon: AppIcons.archive,
                    label: 'Clear all messages',
                    onTap: _confirmClearMessages,
                    showChevron: false,
                  ),
                  _SettingsRow(
                    icon: AppIcons.trashDelete,
                    label: 'Delete all conversations',
                    onTap: _confirmDeleteConversations,
                    destructive: true,
                    showChevron: false,
                  ),

                  // ── Section 4: Legal ──────────────────────────
                  const _SectionLabel('LEGAL'),
                  _SettingsRow(
                    icon: AppIcons.fileDocument,
                    label: 'Terms of Service',
                    onTap: () => context.push('/terms'),
                  ),
                  _SettingsRow(
                    icon: AppIcons.fileDocument,
                    label: 'Privacy Policy',
                    onTap: () => context.push('/privacy'),
                  ),

                  // ── Section 5: Session ────────────────────────
                  const _SectionLabel('SESSION'),
                  _SettingsRow(
                    icon: AppIcons.logOut,
                    label: 'Sign out',
                    onTap: _confirmSignOut,
                    showChevron: false,
                  ),
                  _SettingsRow(
                    icon: AppIcons.trashDelete,
                    label: 'Delete account',
                    onTap: _confirmDeleteAccount,
                    destructive: true,
                    showChevron: false,
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  _SwipeToLock(
                    onConfirm: () => context.go('/account-locked'),
                  ),
                  const SizedBox(height: AppSpacing.xxl),

                  // ── App version ───────────────────────────────
                  Center(
                    child: Text(
                      'Snipkit $_appVersion',
                      style: AppTextStyles.caption.copyWith(
                        color: AppColors.textDisabled,
                      ),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xxxl),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ProfileTopBar extends StatelessWidget {
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
            Semantics(
              label: 'Go back',
              button: true,
              child: GestureDetector(
                onTap: () => Navigator.of(context).pop(),
                child: const SizedBox(
                  width: 44,
                  height: 44,
                  child: Icon(AppIcons.arrowLeft,
                      size: AppIcons.large, color: AppColors.textPrimary),
                ),
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            Text(
              'Settings',
              style: AppTextStyles.headingSmall.copyWith(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w700,
                letterSpacing: -0.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SettingsRow extends StatelessWidget {
  const _SettingsRow({
    required this.icon,
    required this.label,
    required this.onTap,
    this.value,
    this.destructive = false,
    this.showChevron = true,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final String? value;
  final bool destructive;
  final bool showChevron;

  @override
  Widget build(BuildContext context) {
    final color =
        destructive ? AppColors.accentDestructive : AppColors.textPrimary;
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: SizedBox(
        height: 56,
        child: Row(
          children: [
            Icon(icon, size: AppIcons.medium, color: color),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child:
                  Text(label, style: AppTextStyles.bodyLarge.copyWith(color: color)),
            ),
            if (value != null)
              Text(value!,
                  style: AppTextStyles.bodyMedium
                      .copyWith(color: AppColors.textSecondary)),
            if (showChevron) ...[
              const SizedBox(width: AppSpacing.sm),
              const Icon(AppIcons.chevronRight,
                  size: AppIcons.medium, color: AppColors.textDisabled),
            ],
          ],
        ),
      ),
    );
  }
}

class _SwipeToLock extends StatefulWidget {
  const _SwipeToLock({required this.onConfirm});
  final VoidCallback onConfirm;

  @override
  State<_SwipeToLock> createState() => _SwipeToLockState();
}

class _SwipeToLockState extends State<_SwipeToLock> {
  static const double _thumbSize = 48.0;
  static const double _trackHeight = 60.0;
  static const double _padding = 6.0;
  double _dragFraction = 0.0; // 0.0 → 1.0

  void _onDragUpdate(DragUpdateDetails d, double trackWidth) {
    final travel = trackWidth - _thumbSize - _padding * 2;
    if (travel <= 0) return;
    setState(() {
      _dragFraction =
          (_dragFraction + d.delta.dx / travel).clamp(0.0, 1.0);
    });
  }

  void _onDragEnd(DragEndDetails _) {
    if (_dragFraction >= 0.8) {
      _showLockDialog();
    } else {
      setState(() => _dragFraction = 0.0);
    }
  }

  void _showLockDialog() {
    setState(() => _dragFraction = 0.0);
    showDialog(
      context: context,
      barrierColor: Colors.black54,
      builder: (_) => Dialog(
        backgroundColor: AppColors.backgroundPrimary,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        insetPadding:
            const EdgeInsets.symmetric(horizontal: AppSpacing.xxl),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.xxl),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(
                AppIcons.warningTriangle,
                size: 32,
                color: AppColors.accentDestructive,
              ),
              const SizedBox(height: AppSpacing.lg),
              Text(
                'Lock your account?',
                style: AppTextStyles.headingSmall.copyWith(
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(
                'You\'ll be signed out on this device. To recover access you\'ll need your username and recovery code.',
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.textSecondary,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: AppSpacing.xxl),
              GestureDetector(
                onTap: () {
                  Navigator.of(context).pop();
                  widget.onConfirm();
                },
                child: Container(
                  height: 52,
                  decoration: BoxDecoration(
                    color: AppColors.accentDestructive,
                    borderRadius: AppRadius.fullRadius,
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    'Lock my account',
                    style: AppTextStyles.bodyLarge.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              GestureDetector(
                onTap: () => Navigator.of(context).pop(),
                child: SizedBox(
                  height: 44,
                  child: Center(
                    child: Text(
                      'Keep it open',
                      style: AppTextStyles.bodyLarge.copyWith(
                        color: AppColors.textSecondary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: 'Slide to lock account',
      child: LayoutBuilder(
        builder: (context, constraints) {
          final trackWidth = constraints.maxWidth;
          final travel = trackWidth - _thumbSize - _padding * 2;
          final thumbLeft = _padding + _dragFraction * travel;
          final labelOpacity = (1.0 - _dragFraction * 2.0).clamp(0.0, 1.0);

          return GestureDetector(
            onHorizontalDragUpdate: (d) => _onDragUpdate(d, trackWidth),
            onHorizontalDragEnd: _onDragEnd,
            child: Container(
              height: _trackHeight,
              decoration: BoxDecoration(
                color: AppColors.backgroundSecondary,
                borderRadius: AppRadius.fullRadius,
                border: Border.all(color: AppColors.borderDefault, width: 1),
              ),
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  Positioned.fill(
                    child: Opacity(
                      opacity: labelOpacity,
                      child: Center(
                        child: Text(
                          'Slide to lock account',
                          style: AppTextStyles.bodyMedium.copyWith(
                            color: AppColors.textSecondary,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    left: thumbLeft,
                    top: (_trackHeight - _thumbSize) / 2,
                    child: Container(
                      width: _thumbSize,
                      height: _thumbSize,
                      decoration: const BoxDecoration(
                        color: AppColors.textPrimary,
                        shape: BoxShape.circle,
                      ),
                      alignment: Alignment.center,
                      child: Icon(
                        _dragFraction >= 0.8
                            ? AppIcons.lockClosed
                            : AppIcons.chevronRight,
                        size: AppIcons.medium,
                        color: AppColors.backgroundPrimary,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  const _SectionLabel(this.label);
  final String label;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(
        top: AppSpacing.xxl,
        bottom: AppSpacing.sm,
      ),
      child: Text(
        label,
        style: AppTextStyles.caption.copyWith(
          color: AppColors.textDisabled,
          letterSpacing: 1.5,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

class _OptionRow extends StatelessWidget {
  const _OptionRow({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: SizedBox(
        height: 52,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xxl),
          child: Row(
            children: [
              Expanded(
                child: Text(label,
                    style: AppTextStyles.bodyLarge.copyWith(
                      color: AppColors.textPrimary,
                      fontWeight:
                          isSelected ? FontWeight.w600 : FontWeight.w400,
                    )),
              ),
              if (isSelected)
                const Icon(AppIcons.checkCircle,
                    size: AppIcons.medium, color: AppColors.textPrimary),
            ],
          ),
        ),
      ),
    );
  }
}
