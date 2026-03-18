import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/tokens/design_tokens.dart';
import '../../../core/tokens/app_icons.dart';
import '../../widgets/top_bar.dart';

class BlockedContactsScreen extends StatefulWidget {
  const BlockedContactsScreen({super.key});

  @override
  State<BlockedContactsScreen> createState() => _BlockedContactsScreenState();
}

class _BlockedContactsScreenState extends State<BlockedContactsScreen> {
  // Mock blocked contacts
  final List<String> _blocked = ['oak.river', 'frost.peak'];

  void _unblock(String contact) {
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
            Text('Unblock $contact?',
                style: AppTextStyles.headingSmall.copyWith(color: AppColors.textPrimary)),
            const SizedBox(height: AppSpacing.sm),
            Text(
              'They\'ll be able to send you a contact request again.',
              style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary, height: 1.5),
            ),
            const SizedBox(height: AppSpacing.xxl),
            GestureDetector(
              onTap: () {
                Navigator.of(context).pop();
                setState(() => _blocked.remove(contact));
              },
              child: Container(
                height: 52,
                decoration: BoxDecoration(
                    color: AppColors.textPrimary, borderRadius: AppRadius.fullRadius),
                alignment: Alignment.center,
                child: Text('Unblock',
                    style: AppTextStyles.bodyLarge.copyWith(
                        color: AppColors.backgroundPrimary, fontWeight: FontWeight.w600)),
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            GestureDetector(
              onTap: () => Navigator.of(context).pop(),
              child: Container(
                height: 52,
                decoration: BoxDecoration(
                    border: Border.all(color: AppColors.borderDefault, width: 1),
                    borderRadius: AppRadius.fullRadius),
                alignment: Alignment.center,
                child: Text('Cancel',
                    style: AppTextStyles.bodyLarge.copyWith(
                        color: AppColors.textPrimary, fontWeight: FontWeight.w500)),
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
      appBar: SnipkitTopBar(showBack: true, onBack: () => context.pop()),
      body: SafeArea(
        top: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(
                  AppSpacing.xxl, AppSpacing.xxxl, AppSpacing.xxl, AppSpacing.xxl),
              child: Text('Blocked contacts',
                  style: AppTextStyles.headingLarge.copyWith(
                      color: AppColors.textPrimary)),
            ),
            if (_blocked.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xxl),
                child: Text('No one here — good.',
                    style: AppTextStyles.bodyLarge.copyWith(color: AppColors.textSecondary)),
              )
            else
              Expanded(
                child: ListView.builder(
                  padding: EdgeInsets.zero,
                  itemCount: _blocked.length,
                  itemBuilder: (context, i) => _BlockedRow(
                    contact: _blocked[i],
                    onUnblock: () => _unblock(_blocked[i]),
                    showDivider: i < _blocked.length - 1,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _BlockedRow extends StatelessWidget {
  const _BlockedRow({
    required this.contact,
    required this.onUnblock,
    required this.showDivider,
  });

  final String contact;
  final VoidCallback onUnblock;
  final bool showDivider;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          height: 68,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: const BoxDecoration(
                    color: AppColors.backgroundSecondary,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(AppIcons.person,
                      size: AppIcons.medium, color: AppColors.textSecondary),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Text(contact,
                      style: AppTextStyles.bodyLarge.copyWith(
                          color: AppColors.textPrimary, fontWeight: FontWeight.w500)),
                ),
                GestureDetector(
                  onTap: onUnblock,
                  child: Container(
                    height: 34,
                    padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
                    decoration: BoxDecoration(
                      border: Border.all(color: AppColors.borderDefault, width: 1),
                      borderRadius: AppRadius.fullRadius,
                    ),
                    alignment: Alignment.center,
                    child: Text('Unblock',
                        style: AppTextStyles.bodySmall.copyWith(
                            color: AppColors.textPrimary, fontWeight: FontWeight.w500)),
                  ),
                ),
              ],
            ),
          ),
        ),
        if (showDivider)
          const Divider(
            height: 1, thickness: 1,
            color: AppColors.borderSubtle,
            indent: AppSpacing.lg + 44 + AppSpacing.md,
            endIndent: 0,
          ),
      ],
    );
  }
}
