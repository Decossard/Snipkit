import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/tokens/design_tokens.dart';
import '../../../core/tokens/app_icons.dart';
import '../../widgets/snipkit_button.dart';
import '../../widgets/top_bar.dart';

class ContactProfileScreen extends StatefulWidget {
  final String username;

  const ContactProfileScreen({super.key, required this.username});

  @override
  State<ContactProfileScreen> createState() => _ContactProfileScreenState();
}

class _ContactProfileScreenState extends State<ContactProfileScreen> {
  // In a real app this comes from state/provider.
  // For the prototype we derive a mock nickname from the username.
  late String? _nickname = _mockNickname(widget.username);

  String? _mockNickname(String username) {
    const nicknames = {
      'jade.miller': 'Jade',
      'sofia.novak': 'Sofia',
    };
    return nicknames[username];
  }

  String get _displayName => _nickname ?? widget.username;

  void _showEditName() {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.backgroundPrimary,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (_) => _EditNameSheet(
        currentName: _nickname ?? '',
        username: widget.username,
        onSave: (name) => setState(() => _nickname = name.isEmpty ? null : name),
      ),
    );
  }

  void _showReport(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.backgroundPrimary,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (_) => _ReportSheet(username: widget.username),
    );
  }

  void _confirmBlock(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.backgroundPrimary,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (_) => Padding(
        padding: const EdgeInsets.fromLTRB(
            AppSpacing.xxl, AppSpacing.xxl, AppSpacing.xxl, AppSpacing.xxxl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Block ${widget.username}?',
                style: AppTextStyles.headingSmall
                    .copyWith(color: AppColors.textPrimary)),
            const SizedBox(height: AppSpacing.sm),
            Text(
              'They won\'t be able to message you or send\na contact request. They won\'t know they\'re blocked.',
              style: AppTextStyles.bodyMedium
                  .copyWith(color: AppColors.textSecondary, height: 1.5),
            ),
            const SizedBox(height: AppSpacing.xxl),
            SnipkitButton(
              label: 'Block',
              variant: SnipkitButtonVariant.destructive,
              onPressed: () {
                Navigator.of(context).pop();
                context.go('/home');
              },
            ),
            const SizedBox(height: AppSpacing.md),
            SnipkitButton(
              label: 'Cancel',
              variant: SnipkitButtonVariant.secondary,
              onPressed: () => Navigator.of(context).pop(),
            ),
          ],
        ),
      ),
    );
  }

  void _confirmRemove(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.backgroundPrimary,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (_) => Padding(
        padding: const EdgeInsets.fromLTRB(
            AppSpacing.xxl, AppSpacing.xxl, AppSpacing.xxl, AppSpacing.xxxl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Remove $_displayName?',
                style: AppTextStyles.headingSmall
                    .copyWith(color: AppColors.textPrimary)),
            const SizedBox(height: AppSpacing.sm),
            Text(
              'This will delete your conversation history\nand cannot be undone.',
              style: AppTextStyles.bodyMedium
                  .copyWith(color: AppColors.textSecondary, height: 1.5),
            ),
            const SizedBox(height: AppSpacing.xxl),
            SnipkitButton(
              label: 'Remove',
              variant: SnipkitButtonVariant.destructive,
              onPressed: () {
                Navigator.of(context).pop();
                context.go('/home');
              },
            ),
            const SizedBox(height: AppSpacing.md),
            SnipkitButton(
              label: 'Cancel',
              variant: SnipkitButtonVariant.secondary,
              onPressed: () => Navigator.of(context).pop(),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final hasNickname = _nickname != null;
    return Scaffold(
      backgroundColor: AppColors.backgroundPrimary,
      appBar: SnipkitTopBar(showBack: true, onBack: () => context.pop()),
      body: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xxl),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: AppSpacing.xxxl),
              // Avatar circle
              Container(
                width: 96,
                height: 96,
                decoration: const BoxDecoration(
                  color: AppColors.backgroundSecondary,
                  shape: BoxShape.circle,
                ),
                child: const Icon(AppIcons.person,
                    size: 48, color: AppColors.textSecondary),
              ),
              const SizedBox(height: AppSpacing.lg),
              // Display name (nickname if set)
              Text(
                _displayName,
                style: AppTextStyles.headingLarge
                    .copyWith(color: AppColors.textPrimary),
              ),
              // Username below if nickname differs
              if (hasNickname) ...[
                const SizedBox(height: AppSpacing.xs),
                Text(
                  widget.username,
                  style: AppTextStyles.bodyMedium
                      .copyWith(color: AppColors.textSecondary),
                ),
              ],
              const SizedBox(height: AppSpacing.xxxl),
              const Divider(height: 1, thickness: 1, color: AppColors.borderSubtle),
              const SizedBox(height: AppSpacing.xxl),
              // Edit name
              _ActionRow(
                icon: AppIcons.pencilEdit,
                label: hasNickname ? 'Edit name' : 'Give a name',
                onTap: _showEditName,
              ),
              const Divider(height: 1, thickness: 1, color: AppColors.borderSubtle),
              const SizedBox(height: AppSpacing.sm),
              // Report (non-destructive)
              _ActionRow(
                icon: AppIcons.warningTriangle,
                label: 'Report',
                onTap: () => _showReport(context),
              ),
              // Block
              _ActionRow(
                icon: AppIcons.block,
                label: 'Block',
                destructive: true,
                onTap: () => _confirmBlock(context),
              ),
              // Remove
              _ActionRow(
                icon: AppIcons.trashDelete,
                label: 'Remove contact',
                destructive: true,
                onTap: () => _confirmRemove(context),
              ),
              const Expanded(child: SizedBox()),
              SnipkitButton(
                label: 'Send Message',
                onPressed: () =>
                    context.go('/conversation/${widget.username}'),
              ),
              const SizedBox(height: AppSpacing.xxxl),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Report sheet ─────────────────────────────────────────────────────────────
class _ReportSheet extends StatefulWidget {
  const _ReportSheet({required this.username});
  final String username;

  @override
  State<_ReportSheet> createState() => _ReportSheetState();
}

class _ReportSheetState extends State<_ReportSheet> {
  String? _selected;
  bool _submitted = false;

  static const _reasons = [
    'Spam or unwanted messages',
    'Harassment or threats',
    'Impersonation',
    'Inappropriate content',
    'Other',
  ];

  @override
  Widget build(BuildContext context) {
    if (_submitted) {
      return Padding(
        padding: const EdgeInsets.fromLTRB(
            AppSpacing.xxl, AppSpacing.xxl, AppSpacing.xxl, AppSpacing.xxxl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Icon(AppIcons.checkCircle,
                size: 32, color: AppColors.accentSuccess),
            const SizedBox(height: AppSpacing.lg),
            Text('Report submitted',
                style: AppTextStyles.headingSmall
                    .copyWith(color: AppColors.textPrimary)),
            const SizedBox(height: AppSpacing.sm),
            Text(
              'Thanks for letting us know. We\'ll review this and take action if needed.',
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
                child: Text('Done',
                    style: AppTextStyles.bodyLarge.copyWith(
                        color: AppColors.backgroundPrimary,
                        fontWeight: FontWeight.w600)),
              ),
            ),
          ],
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.fromLTRB(
          AppSpacing.xxl, AppSpacing.xxl, AppSpacing.xxl, AppSpacing.xxxl),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 36,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.borderDefault,
                borderRadius: AppRadius.fullRadius,
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.xxl),
          Text('Report ${widget.username}',
              style: AppTextStyles.headingSmall
                  .copyWith(color: AppColors.textPrimary)),
          const SizedBox(height: AppSpacing.xs),
          Text('What\'s the issue?',
              style: AppTextStyles.bodyMedium
                  .copyWith(color: AppColors.textSecondary)),
          const SizedBox(height: AppSpacing.lg),
          for (final reason in _reasons) ...[
            GestureDetector(
              onTap: () => setState(() => _selected = reason),
              behavior: HitTestBehavior.opaque,
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(reason,
                          style: AppTextStyles.bodyLarge
                              .copyWith(color: AppColors.textPrimary)),
                    ),
                    AnimatedContainer(
                      duration: AppDurations.micro,
                      width: 20,
                      height: 20,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: _selected == reason
                            ? AppColors.textPrimary
                            : Colors.transparent,
                        border: Border.all(
                          color: _selected == reason
                              ? AppColors.textPrimary
                              : AppColors.borderDefault,
                          width: 1.5,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            if (reason != _reasons.last)
              const Divider(height: 1, thickness: 1, color: AppColors.borderSubtle),
          ],
          const SizedBox(height: AppSpacing.xxl),
          GestureDetector(
            onTap: _selected != null
                ? () => setState(() => _submitted = true)
                : null,
            child: Opacity(
              opacity: _selected != null ? 1.0 : 0.35,
              child: Container(
                height: 52,
                decoration: BoxDecoration(
                  color: AppColors.textPrimary,
                  borderRadius: AppRadius.fullRadius,
                ),
                alignment: Alignment.center,
                child: Text('Submit report',
                    style: AppTextStyles.bodyLarge.copyWith(
                        color: AppColors.backgroundPrimary,
                        fontWeight: FontWeight.w600)),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Edit name sheet ──────────────────────────────────────────────────────────
class _EditNameSheet extends StatefulWidget {
  const _EditNameSheet({
    required this.currentName,
    required this.username,
    required this.onSave,
  });
  final String currentName;
  final String username;
  final void Function(String name) onSave;

  @override
  State<_EditNameSheet> createState() => _EditNameSheetState();
}

class _EditNameSheetState extends State<_EditNameSheet> {
  late final TextEditingController _controller;
  final _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.currentName);
    _controller.addListener(() => setState(() {}));
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _focusNode.requestFocus();
      _controller.selection =
          TextSelection(baseOffset: 0, extentOffset: _controller.text.length);
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;
    return Padding(
      padding: EdgeInsets.fromLTRB(AppSpacing.xxl, AppSpacing.xxl,
          AppSpacing.xxl, AppSpacing.xxxl + bottomInset),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 36,
              height: 4,
              decoration: BoxDecoration(
                  color: AppColors.borderDefault,
                  borderRadius: AppRadius.fullRadius),
            ),
          ),
          const SizedBox(height: AppSpacing.xxl),
          Text(
            'Edit name',
            style:
                AppTextStyles.headingSmall.copyWith(color: AppColors.textPrimary),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            'Only visible to you.',
            style:
                AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary),
          ),
          const SizedBox(height: AppSpacing.xxl),
          Container(
            height: 52,
            decoration: BoxDecoration(
              color: AppColors.backgroundInput,
              borderRadius: AppRadius.mediumRadius,
              border: Border.all(color: AppColors.borderSubtle, width: 1),
            ),
            child: TextField(
              controller: _controller,
              focusNode: _focusNode,
              textCapitalization: TextCapitalization.words,
              style:
                  AppTextStyles.bodyLarge.copyWith(color: AppColors.textPrimary),
              decoration: InputDecoration(
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.lg, vertical: AppSpacing.md),
                hintText: 'e.g. Jade',
                hintStyle: AppTextStyles.bodyLarge
                    .copyWith(color: AppColors.textPlaceholder),
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          GestureDetector(
            onTap: _controller.text.trim().isNotEmpty
                ? () {
                    widget.onSave(_controller.text.trim());
                    Navigator.of(context).pop();
                  }
                : null,
            child: Opacity(
              opacity: _controller.text.trim().isNotEmpty ? 1.0 : 0.35,
              child: Container(
                height: 52,
                decoration: BoxDecoration(
                    color: AppColors.textPrimary,
                    borderRadius: AppRadius.fullRadius),
                alignment: Alignment.center,
                child: Text('Save',
                    style: AppTextStyles.bodyLarge.copyWith(
                        color: AppColors.backgroundPrimary,
                        fontWeight: FontWeight.w600)),
              ),
            ),
          ),
          if (widget.currentName.isNotEmpty) ...[
            const SizedBox(height: AppSpacing.md),
            GestureDetector(
              onTap: () {
                widget.onSave('');
                Navigator.of(context).pop();
              },
              child: SizedBox(
                height: 44,
                child: Center(
                  child: Text(
                    'Remove name, use ${widget.username}',
                    style: AppTextStyles.bodyMedium.copyWith(
                        color: AppColors.textSecondary,
                        fontWeight: FontWeight.w500),
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

// ─── Action row ───────────────────────────────────────────────────────────────
class _ActionRow extends StatelessWidget {
  const _ActionRow({
    required this.icon,
    required this.label,
    required this.onTap,
    this.destructive = false,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool destructive;

  @override
  Widget build(BuildContext context) {
    final color =
        destructive ? AppColors.accentDestructive : AppColors.textPrimary;
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: SizedBox(
        height: 52,
        child: Row(
          children: [
            Icon(icon, size: AppIcons.medium, color: color),
            const SizedBox(width: AppSpacing.md),
            Text(label,
                style: AppTextStyles.bodyLarge.copyWith(color: color)),
          ],
        ),
      ),
    );
  }
}
