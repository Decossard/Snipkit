import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/tokens/design_tokens.dart';
import '../../../core/tokens/app_icons.dart';
import '../../../core/models/app_models.dart';
import '../../../core/services/contacts_service.dart';
import '../../widgets/searchable_top_bar.dart';
import '../../widgets/bottom_search_bar.dart';

// ─── Screen ───────────────────────────────────────────────────────────────────
class ContactsScreen extends ConsumerStatefulWidget {
  const ContactsScreen({super.key});

  @override
  ConsumerState<ContactsScreen> createState() => _ContactsScreenState();
}

class _ContactsScreenState extends ConsumerState<ContactsScreen> {
  String _searchQuery = '';

  List<Contact> _filteredContacts(List<Contact> contacts) {
    if (_searchQuery.isEmpty) return contacts;
    final q = _searchQuery.toLowerCase();
    return contacts
        .where((c) =>
            c.displayName.toLowerCase().contains(q) ||
            c.username.toLowerCase().contains(q))
        .toList();
  }

  void _acceptRequest(ContactRequest request) {
    _showNamingSheet(request);
  }

  Future<void> _declineRequest(ContactRequest request) async {
    await ref.read(contactsProvider.notifier).deleteRequest(request.id);
    await ref.read(contactRequestsProvider.notifier).refresh();
  }

  void _showNamingSheet(ContactRequest request) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.backgroundPrimary,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (_) => _NamingSheet(
        username: request.fromUsername,
        onSave: (nickname) async {
          await ref
              .read(contactsProvider.notifier)
              .acceptRequest(request.id);
          await ref.read(contactRequestsProvider.notifier).refresh();
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final contactsAsync = ref.watch(contactsProvider);
    final requestsAsync = ref.watch(contactRequestsProvider);

    return Scaffold(
      backgroundColor: AppColors.backgroundPrimary,
      body: Column(
        children: [
          SearchableTopBar(
            title: 'Contacts',
            trailing: GestureDetector(
              onTap: () => context.push('/add-contact'),
              child: const SizedBox(
                width: 44, height: 44,
                child: Icon(AppIcons.plus,
                    size: AppIcons.large, color: AppColors.textPrimary),
              ),
            ),
          ),
          Expanded(
            child: contactsAsync.when(
              loading: () =>
                  const Center(child: CircularProgressIndicator()),
              error: (e, _) => Center(
                child: Text('Error loading contacts',
                    style: AppTextStyles.bodyLarge
                        .copyWith(color: AppColors.textSecondary)),
              ),
              data: (contacts) {
                final requests = requestsAsync.value ?? [];
                final hasRequests = requests.isNotEmpty;
                final hasContacts = contacts.isNotEmpty;
                final filtered = _filteredContacts(contacts);
                final isSearching = _searchQuery.isNotEmpty;

                return (!hasRequests && !hasContacts)
                    ? _EmptyState(
                        onAddContact: () => context.push('/add-contact'))
                    : isSearching
                        ? filtered.isEmpty
                            ? _NoResults(query: _searchQuery)
                            : _contactsListView(filtered)
                        : ListView(
                            padding: EdgeInsets.zero,
                            children: [
                              if (hasRequests) ...[
                                _SectionHeader(
                                  label: 'REQUESTS',
                                  count: requests.length,
                                ),
                                ...requests.map(
                                  (r) => _RequestRow(
                                    request: r,
                                    onAccept: () => _acceptRequest(r),
                                    onDecline: () => _declineRequest(r),
                                  ),
                                ),
                                const _SectionDivider(),
                              ],
                              if (hasContacts) ...[
                                const _SectionHeader(label: 'CONTACTS'),
                                ...contacts.asMap().entries.map(
                                      (e) => _ContactRow(
                                        contact: e.value,
                                        showDivider:
                                            e.key < contacts.length - 1,
                                        onTap: () => context.push(
                                          '/contact/${e.value.username}',
                                        ),
                                        onMessage: () => context.push(
                                          '/conversation/${e.value.username}',
                                        ),
                                      ),
                                    ),
                              ],
                            ],
                          );
              },
            ),
          ),
          BottomSearchBar(
            hint: 'Search contacts',
            onChanged: (q) => setState(() => _searchQuery = q),
          ),
        ],
      ),
    );
  }

  Widget _contactsListView(List<Contact> contacts) {
    return ListView.builder(
      padding: EdgeInsets.zero,
      itemCount: contacts.length,
      itemBuilder: (context, i) => _ContactRow(
        contact: contacts[i],
        showDivider: i < contacts.length - 1,
        onTap: () => context.push('/contact/${contacts[i].username}'),
        onMessage: () =>
            context.push('/conversation/${contacts[i].username}'),
      ),
    );
  }
}

// ─── Naming sheet ─────────────────────────────────────────────────────────────
class _NamingSheet extends StatefulWidget {
  const _NamingSheet({required this.username, required this.onSave});
  final String username;
  final void Function(String nickname) onSave;

  @override
  State<_NamingSheet> createState() => _NamingSheetState();
}

class _NamingSheetState extends State<_NamingSheet> {
  final _controller = TextEditingController();
  final _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _controller.addListener(() => setState(() {}));
    WidgetsBinding.instance.addPostFrameCallback((_) => _focusNode.requestFocus());
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _save(String nickname) {
    widget.onSave(nickname);
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;
    return Padding(
      padding: EdgeInsets.fromLTRB(
          AppSpacing.xxl, AppSpacing.xxl, AppSpacing.xxl,
          AppSpacing.xxxl + bottomInset),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 36, height: 4,
              decoration: BoxDecoration(
                  color: AppColors.borderDefault, borderRadius: AppRadius.fullRadius),
            ),
          ),
          const SizedBox(height: AppSpacing.xxl),
          Text(
            'Give ${widget.username} a name?',
            style: AppTextStyles.headingSmall.copyWith(color: AppColors.textPrimary),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            'Just for you — they won\'t see it.',
            style: AppTextStyles.bodyMedium
                .copyWith(color: AppColors.textSecondary, height: 1.4),
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
              style: AppTextStyles.bodyLarge.copyWith(color: AppColors.textPrimary),
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
                ? () => _save(_controller.text.trim())
                : null,
            child: Opacity(
              opacity: _controller.text.trim().isNotEmpty ? 1.0 : 0.35,
              child: Container(
                height: 52,
                decoration: BoxDecoration(
                    color: AppColors.textPrimary,
                    borderRadius: AppRadius.fullRadius),
                alignment: Alignment.center,
                child: Text('Save name',
                    style: AppTextStyles.bodyLarge.copyWith(
                        color: AppColors.backgroundPrimary,
                        fontWeight: FontWeight.w600)),
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          GestureDetector(
            onTap: () => _save(''),
            child: SizedBox(
              height: 44,
              child: Center(
                child: Text(
                  'Skip, use ${widget.username}',
                  style: AppTextStyles.bodyMedium.copyWith(
                      color: AppColors.textSecondary, fontWeight: FontWeight.w500),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── No results ───────────────────────────────────────────────────────────────
class _NoResults extends StatelessWidget {
  const _NoResults({required this.query});
  final String query;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.xxl, vertical: AppSpacing.xxl),
      child: Text(
        'No results for "$query"',
        style: AppTextStyles.bodyLarge.copyWith(color: AppColors.textSecondary),
      ),
    );
  }
}

// ─── Section header ───────────────────────────────────────────────────────────
class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.label, this.count});
  final String label;
  final int? count;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
          AppSpacing.lg, AppSpacing.lg, AppSpacing.lg, AppSpacing.sm),
      child: Row(
        children: [
          Text(
            label,
            style: AppTextStyles.caption.copyWith(
              color: AppColors.textDisabled,
              letterSpacing: 1.5,
              fontWeight: FontWeight.w600,
            ),
          ),
          if (count != null) ...[
            const SizedBox(width: AppSpacing.sm),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
              decoration: BoxDecoration(
                color: AppColors.accentInteractive,
                borderRadius: AppRadius.fullRadius,
              ),
              child: Text(
                '$count',
                style: AppTextStyles.caption.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _SectionDivider extends StatelessWidget {
  const _SectionDivider();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.symmetric(vertical: AppSpacing.md),
      child: Divider(height: 1, thickness: 1, color: AppColors.borderSubtle),
    );
  }
}

// ─── Request row ──────────────────────────────────────────────────────────────
class _RequestRow extends StatelessWidget {
  const _RequestRow({
    required this.request,
    required this.onAccept,
    required this.onDecline,
  });

  final ContactRequest request;
  final VoidCallback onAccept;
  final VoidCallback onDecline;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.lg, vertical: AppSpacing.sm),
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
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  request.fromUsername,
                  style: AppTextStyles.bodyLarge.copyWith(
                      color: AppColors.textPrimary, fontWeight: FontWeight.w500),
                ),
                const SizedBox(height: 2),
                Text(
                  'Wants to connect',
                  style: AppTextStyles.bodySmall
                      .copyWith(color: AppColors.textSecondary),
                ),
              ],
            ),
          ),
          GestureDetector(
            onTap: onDecline,
            child: Container(
              height: 36,
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
              decoration: BoxDecoration(
                border: Border.all(color: AppColors.borderDefault, width: 1),
                borderRadius: AppRadius.fullRadius,
              ),
              alignment: Alignment.center,
              child: Text(
                'Decline',
                style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.textSecondary, fontWeight: FontWeight.w500),
              ),
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          GestureDetector(
            onTap: onAccept,
            child: Container(
              height: 36,
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
              decoration: BoxDecoration(
                color: AppColors.textPrimary,
                borderRadius: AppRadius.fullRadius,
              ),
              alignment: Alignment.center,
              child: Text(
                'Accept',
                style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.backgroundPrimary,
                    fontWeight: FontWeight.w600),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Contact row ──────────────────────────────────────────────────────────────
class _ContactRow extends StatelessWidget {
  const _ContactRow({
    required this.contact,
    required this.showDivider,
    required this.onTap,
    required this.onMessage,
  });

  final Contact contact;
  final bool showDivider;
  final VoidCallback onTap;
  final VoidCallback onMessage;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            height: 72,
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
                    child: Text(
                      contact.displayName,
                      style: AppTextStyles.bodyLarge
                          .copyWith(fontWeight: FontWeight.w500),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  GestureDetector(
                    onTap: onMessage,
                    child: Container(
                      width: 40, height: 40,
                      decoration: const BoxDecoration(
                        color: AppColors.backgroundSecondary,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(AppIcons.chatBubble,
                          size: AppIcons.medium, color: AppColors.textPrimary),
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
              indent: AppSpacing.lg + 48 + AppSpacing.md,
              endIndent: 0,
            ),
        ],
      ),
    );
  }
}

// ─── Empty state ──────────────────────────────────────────────────────────────
class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.onAddContact});
  final VoidCallback onAddContact;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xxl),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Spacer(flex: 2),
          Text(
            'Your people\nlive here.',
            style: AppTextStyles.displayStyle.copyWith(
              color: AppColors.textPrimary,
              height: 1.15,
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          Text(
            'Add someone with their Snipkit username.\nThey\'ll show up here once they accept.',
            style: AppTextStyles.bodyLarge.copyWith(
              color: AppColors.textSecondary,
              height: 1.5,
            ),
          ),
          const Spacer(flex: 3),
          GestureDetector(
            onTap: onAddContact,
            child: Container(
              height: 52,
              decoration: BoxDecoration(
                color: AppColors.textPrimary,
                borderRadius: AppRadius.fullRadius,
              ),
              alignment: Alignment.center,
              child: Text(
                'Add someone',
                style: AppTextStyles.bodyLarge.copyWith(
                  color: AppColors.backgroundPrimary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.xxxl),
        ],
      ),
    );
  }
}
