import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/tokens/design_tokens.dart';
import '../../core/tokens/app_icons.dart';

// Mock contacts — username + optional local nickname
class _SheetContact {
  const _SheetContact({required this.username, this.nickname});
  final String username;
  final String? nickname;
  String get displayName => nickname ?? username;
}

const _sheetContacts = [
  _SheetContact(username: 'jade.miller', nickname: 'Jade'),
  _SheetContact(username: 'marco.ross'),
  _SheetContact(username: 'sofia.novak', nickname: 'Sofia'),
  _SheetContact(username: 'alex.kim'),
];

/// Bottom sheet opened by the + button on the home screen.
/// Shows the user's contacts so they can start a conversation,
/// with an "Add new contact" escape hatch at the top.
class NewConversationSheet extends StatefulWidget {
  const NewConversationSheet({super.key});

  @override
  State<NewConversationSheet> createState() => _NewConversationSheetState();
}

class _NewConversationSheetState extends State<NewConversationSheet> {
  String _query = '';

  List<_SheetContact> get _filtered {
    if (_query.isEmpty) return _sheetContacts;
    final q = _query.toLowerCase();
    return _sheetContacts
        .where((c) =>
            c.displayName.toLowerCase().contains(q) ||
            c.username.toLowerCase().contains(q))
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    final filtered = _filtered;

    return Container(
      decoration: const BoxDecoration(
        color: AppColors.backgroundPrimary,
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.82,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // ── Handle ────────────────────────────────────────
          const SizedBox(height: AppSpacing.md),
          Container(
            width: 36, height: 4,
            decoration: BoxDecoration(
              color: AppColors.borderDefault,
              borderRadius: AppRadius.fullRadius,
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          // ── Header ────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xxl),
            child: Row(
              children: [
                Text(
                  'New conversation',
                  style: AppTextStyles.headingSmall
                      .copyWith(color: AppColors.textPrimary),
                ),
                const Spacer(),
                Semantics(
                  label: 'Close',
                  button: true,
                  child: GestureDetector(
                    onTap: () => Navigator.of(context).pop(),
                    child: const SizedBox(
                      width: 40, height: 40,
                      child: Icon(AppIcons.xClose,
                          size: AppIcons.medium, color: AppColors.textPrimary),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          // ── Search ────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xxl),
            child: Container(
              height: 44,
              decoration: BoxDecoration(
                color: AppColors.backgroundInput,
                borderRadius: AppRadius.xlargeRadius,
              ),
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
              child: Row(
                children: [
                  const Icon(AppIcons.search,
                      size: AppIcons.small, color: AppColors.textDisabled),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: TextField(
                      onChanged: (v) => setState(() => _query = v),
                      style: AppTextStyles.bodyMedium
                          .copyWith(color: AppColors.textPrimary),
                      decoration: InputDecoration(
                        border: InputBorder.none,
                        isDense: true,
                        hintText: 'Search contacts',
                        hintStyle: AppTextStyles.bodyMedium
                            .copyWith(color: AppColors.textPlaceholder),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          const Divider(height: 1, thickness: 1, color: AppColors.borderSubtle),
          // ── List ──────────────────────────────────────────
          Flexible(
            child: ListView(
              padding: EdgeInsets.zero,
              shrinkWrap: true,
              children: [
                // "Add new contact" always at top
                _AddNewContactRow(
                  onTap: () {
                    Navigator.of(context).pop();
                    context.push('/add-contact');
                  },
                ),
                const Divider(
                    height: 1, thickness: 1, color: AppColors.borderSubtle),
                if (filtered.isEmpty)
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.xxl, vertical: AppSpacing.xxl),
                    child: Text(
                      'No results for "$_query"',
                      style: AppTextStyles.bodyLarge
                          .copyWith(color: AppColors.textSecondary),
                    ),
                  )
                else
                  ...filtered.asMap().entries.map(
                        (e) => _ContactRow(
                          contact: e.value,
                          showDivider: e.key < filtered.length - 1,
                          onTap: () {
                            Navigator.of(context).pop();
                            context.push('/conversation/${e.value.username}');
                          },
                        ),
                      ),
              ],
            ),
          ),
          SizedBox(
              height: MediaQuery.of(context).padding.bottom + AppSpacing.md),
        ],
      ),
    );
  }
}

// ─── Add new contact row ──────────────────────────────────────────────────────
class _AddNewContactRow extends StatelessWidget {
  const _AddNewContactRow({required this.onTap});
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: SizedBox(
        height: 64,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xxl),
          child: Row(
            children: [
              Container(
                width: 44, height: 44,
                decoration: BoxDecoration(
                  color: AppColors.backgroundSecondary,
                  shape: BoxShape.circle,
                  border: Border.all(color: AppColors.borderDefault, width: 1),
                ),
                child: const Icon(AppIcons.plus,
                    size: AppIcons.medium, color: AppColors.textPrimary),
              ),
              const SizedBox(width: AppSpacing.md),
              Text(
                'Add new contact',
                style: AppTextStyles.bodyLarge.copyWith(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Contact row ─────────────────────────────────────────────────────────────
class _ContactRow extends StatelessWidget {
  const _ContactRow({
    required this.contact,
    required this.showDivider,
    required this.onTap,
  });

  final _SheetContact contact;
  final bool showDivider;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            height: 64,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xxl),
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
                    child: Text(
                      contact.displayName,
                      style: AppTextStyles.bodyLarge.copyWith(
                        fontWeight: FontWeight.w500,
                      ),
                      overflow: TextOverflow.ellipsis,
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
              indent: AppSpacing.xxl + 44 + AppSpacing.md,
              endIndent: 0,
            ),
        ],
      ),
    );
  }
}
