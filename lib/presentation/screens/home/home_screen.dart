import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/tokens/design_tokens.dart';
import '../../../core/tokens/app_icons.dart';
import '../../../core/models/app_models.dart';
import '../../../core/services/conversations_service.dart';
import '../../../core/services/contacts_service.dart';
import '../../widgets/searchable_top_bar.dart';
import '../../widgets/new_conversation_sheet.dart';

// ─── Local state wrappers ─────────────────────────────────────────────────────
enum _TurnState { yourTurn, waiting, none }

class _PendingAction {
  const _PendingAction({required this.label, required this.onUndo});
  final String label;
  final VoidCallback onUndo;
}

// Per-conversation local state (pin/mute)
class _LocalConvState {
  bool isPinned;
  bool isMuted;
  _LocalConvState({this.isPinned = false, this.isMuted = false});
}

// ─── Screen ───────────────────────────────────────────────────────────────────
class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  String _searchQuery = '';
  _PendingAction? _pendingAction;
  final _searchController = TextEditingController();
  Timer? _debounceTimer;
  final Map<String, _LocalConvState> _localState = {};

  _LocalConvState _localFor(String convId) =>
      _localState.putIfAbsent(convId, _LocalConvState.new);

  void _onSearchChanged(String query) {
    _debounceTimer?.cancel();
    _debounceTimer = Timer(const Duration(milliseconds: 250), () {
      if (mounted) setState(() => _searchQuery = query);
    });
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  void _openNewConversation() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => const NewConversationSheet(),
    );
  }

  Future<void> _acceptRequest(ContactRequest r) async {
    await ref.read(contactsProvider.notifier).acceptRequest(r.id);
    await ref.read(contactRequestsProvider.notifier).refresh();
  }

  Future<void> _declineRequest(ContactRequest r) async {
    await ref.read(contactsProvider.notifier).deleteRequest(r.id);
    await ref.read(contactRequestsProvider.notifier).refresh();
  }

  void _showUndoSnackbar({required String label, required VoidCallback onUndo}) {
    setState(() => _pendingAction = _PendingAction(label: label, onUndo: onUndo));
  }

  void _handleUndo() {
    _pendingAction?.onUndo();
    setState(() => _pendingAction = null);
  }

  void _dismissSnackbar() => setState(() => _pendingAction = null);

  Future<bool> _confirmDelete(Conversation c) async {
    bool confirmed = false;
    await showModalBottomSheet(
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
            Text(
              'Delete conversation\nwith ${c.displayName}?',
              style: AppTextStyles.headingSmall.copyWith(color: AppColors.textPrimary),
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              '${c.displayName} stays in your contacts.\nOnly this thread will be removed.',
              style: AppTextStyles.bodyMedium
                  .copyWith(color: AppColors.textSecondary, height: 1.5),
            ),
            const SizedBox(height: AppSpacing.xxl),
            GestureDetector(
              onTap: () {
                confirmed = true;
                Navigator.of(context).pop();
              },
              child: Container(
                height: 52,
                decoration: BoxDecoration(
                    color: AppColors.accentDestructive,
                    borderRadius: AppRadius.fullRadius),
                alignment: Alignment.center,
                child: Text('Delete',
                    style: AppTextStyles.bodyLarge
                        .copyWith(color: Colors.white, fontWeight: FontWeight.w600)),
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
                    style: AppTextStyles.bodyLarge
                        .copyWith(color: AppColors.textPrimary, fontWeight: FontWeight.w500)),
              ),
            ),
          ],
        ),
      ),
    );
    return confirmed;
  }

  void _showConversationActions(Conversation c) {
    final local = _localFor(c.id);
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
            width: 36, height: 4,
            decoration: BoxDecoration(
                color: AppColors.borderDefault, borderRadius: AppRadius.fullRadius),
          ),
          const SizedBox(height: AppSpacing.lg),
          _SheetAction(
            icon: AppIcons.pin,
            label: local.isPinned ? 'Unpin' : 'Pin',
            onTap: () {
              Navigator.of(context).pop();
              setState(() => local.isPinned = !local.isPinned);
            },
          ),
          _SheetAction(
            icon: local.isMuted ? AppIcons.bell : AppIcons.bellOff,
            label: local.isMuted ? 'Unmute' : 'Mute',
            onTap: () {
              Navigator.of(context).pop();
              if (local.isMuted) {
                setState(() => local.isMuted = false);
                _showUndoSnackbar(
                  label: 'Unmuted',
                  onUndo: () => setState(() => local.isMuted = true),
                );
              } else {
                _showMuteOptions(c);
              }
            },
          ),
          _SheetAction(
            icon: AppIcons.block,
            label: 'Block',
            destructive: true,
            onTap: () {
              Navigator.of(context).pop();
              context.push('/contact/${c.otherUsername}');
            },
          ),
          SizedBox(height: MediaQuery.of(context).padding.bottom + AppSpacing.md),
        ],
      ),
    );
  }

  void _showMuteOptions(Conversation c) {
    final local = _localFor(c.id);
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
            width: 36, height: 4,
            decoration: BoxDecoration(
                color: AppColors.borderDefault, borderRadius: AppRadius.fullRadius),
          ),
          const SizedBox(height: AppSpacing.lg),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xxl),
            child: Text('Mute notifications',
                style: AppTextStyles.headingSmall.copyWith(color: AppColors.textPrimary)),
          ),
          const SizedBox(height: AppSpacing.md),
          _SheetAction(
            icon: AppIcons.clock,
            label: '1 hour',
            onTap: () {
              Navigator.of(context).pop();
              setState(() => local.isMuted = true);
              _showUndoSnackbar(
                  label: 'Muted for 1 hour',
                  onUndo: () => setState(() => local.isMuted = false));
            },
          ),
          _SheetAction(
            icon: AppIcons.clock,
            label: '8 hours',
            onTap: () {
              Navigator.of(context).pop();
              setState(() => local.isMuted = true);
              _showUndoSnackbar(
                  label: 'Muted for 8 hours',
                  onUndo: () => setState(() => local.isMuted = false));
            },
          ),
          _SheetAction(
            icon: AppIcons.bellOff,
            label: 'Always',
            onTap: () {
              Navigator.of(context).pop();
              setState(() => local.isMuted = true);
              _showUndoSnackbar(
                  label: 'Notifications muted',
                  onUndo: () => setState(() => local.isMuted = false));
            },
          ),
          SizedBox(height: MediaQuery.of(context).padding.bottom + AppSpacing.md),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final convsAsync = ref.watch(conversationsProvider);
    final requests = ref.watch(contactRequestsProvider);

    return Scaffold(
      backgroundColor: AppColors.backgroundPrimary,
      body: Stack(
        children: [
          Column(
            children: [
              // ── Top bar ──────────────────────────────────────
              SearchableTopBar(
                title: 'Snipkit',
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    GestureDetector(
                      onTap: _openNewConversation,
                      child: const SizedBox(
                        width: 40, height: 44,
                        child: Icon(AppIcons.plus,
                            size: AppIcons.medium, color: AppColors.textPrimary),
                      ),
                    ),
                    GestureDetector(
                      onTap: () => context.push('/settings'),
                      child: const SizedBox(
                        width: 40, height: 44,
                        child: Icon(AppIcons.settings,
                            size: AppIcons.medium, color: AppColors.textPrimary),
                      ),
                    ),
                  ],
                ),
              ),
              // ── Unified list ─────────────────────────────────
              Expanded(
                child: convsAsync.when(
                  loading: () =>
                      const Center(child: CircularProgressIndicator()),
                  error: (e, _) => Center(
                    child: Text('Error loading conversations',
                        style: AppTextStyles.bodyLarge
                            .copyWith(color: AppColors.textSecondary)),
                  ),
                  data: (conversations) {
                    // Sort: pinned first
                    final sorted = [
                      ...conversations.where((c) => _localFor(c.id).isPinned),
                      ...conversations.where((c) => !_localFor(c.id).isPinned),
                    ];

                    final filtered = _searchQuery.isEmpty
                        ? sorted
                        : sorted.where((c) {
                            final q = _searchQuery.toLowerCase();
                            return c.displayName.toLowerCase().contains(q) ||
                                c.otherUsername.toLowerCase().contains(q);
                          }).toList();

                    final isEmpty = conversations.isEmpty;
                    final noResults =
                        _searchQuery.isNotEmpty && filtered.isEmpty;

                    return isEmpty
                        ? _EmptyState(onNewConversation: _openNewConversation)
                        : ListView(
                            padding: EdgeInsets.zero,
                            children: [
                              // Search field — scrolls with content
                              _SearchField(
                                controller: _searchController,
                                onChanged: _onSearchChanged,
                              ),
                              // Requests banner
                              if (requests.value?.isNotEmpty == true)
                                _RequestsBanner(
                                  requests: requests.value!,
                                  onAccept: _acceptRequest,
                                  onDecline: _declineRequest,
                                ),
                              // No results
                              if (noResults)
                                _NoResults(query: _searchQuery)
                              else
                                ...filtered.map(
                                  (c) => _ConversationItem(
                                    key: ValueKey(c.id),
                                    conversation: c,
                                    localState: _localFor(c.id),
                                    onTap: () => context.push(
                                        '/conversation/${c.otherUsername}'),
                                    onDelete: () async {
                                      final ok = await _confirmDelete(c);
                                      if (ok) {
                                        // Remove from local display by not
                                        // tracking (server-side TBD)
                                      }
                                    },
                                    onLongPress: () =>
                                        _showConversationActions(c),
                                    showDivider: true,
                                  ),
                                ),
                            ],
                          );
                  },
                ),
              ),
            ],
          ),
          // ── Undo snackbar overlay ─────────────────────────────
          if (_pendingAction != null)
            Positioned(
              left: AppSpacing.lg,
              right: AppSpacing.lg,
              bottom: AppSpacing.lg,
              child: _UndoSnackbar(
                label: _pendingAction!.label,
                onUndo: _handleUndo,
                onDismiss: _dismissSnackbar,
              ),
            ),
        ],
      ),
    );
  }
}

// ─── Search field ─────────────────────────────────────────────────────────────
class _SearchField extends StatelessWidget {
  const _SearchField({required this.controller, required this.onChanged});
  final TextEditingController controller;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
          AppSpacing.lg, AppSpacing.md, AppSpacing.lg, AppSpacing.sm),
      child: Container(
        height: 40,
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
                controller: controller,
                onChanged: onChanged,
                style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textPrimary),
                decoration: InputDecoration(
                  border: InputBorder.none,
                  isDense: true,
                  hintText: 'Search',
                  hintStyle: AppTextStyles.bodyMedium
                      .copyWith(color: AppColors.textPlaceholder),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Requests banner ──────────────────────────────────────────────────────────
class _RequestsBanner extends StatefulWidget {
  const _RequestsBanner({
    required this.requests,
    required this.onAccept,
    required this.onDecline,
  });
  final List<ContactRequest> requests;
  final void Function(ContactRequest) onAccept;
  final void Function(ContactRequest) onDecline;

  @override
  State<_RequestsBanner> createState() => _RequestsBannerState();
}

class _RequestsBannerState extends State<_RequestsBanner> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    final count = widget.requests.length;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        GestureDetector(
          onTap: () => setState(() => _expanded = !_expanded),
          behavior: HitTestBehavior.opaque,
          child: Container(
            height: 48,
            color: AppColors.backgroundSecondary,
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
            child: Row(
              children: [
                const Icon(AppIcons.person,
                    size: AppIcons.small, color: AppColors.textSecondary),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: Text(
                    '$count contact ${count == 1 ? 'request' : 'requests'}',
                    style: AppTextStyles.bodyMedium.copyWith(
                        color: AppColors.textSecondary,
                        fontWeight: FontWeight.w500),
                  ),
                ),
                AnimatedRotation(
                  turns: _expanded ? 0.25 : 0,
                  duration: AppDurations.enter,
                  child: const Icon(AppIcons.chevronRight,
                      size: AppIcons.small, color: AppColors.textDisabled),
                ),
              ],
            ),
          ),
        ),
        if (_expanded)
          ...widget.requests.map(
            (r) => _RequestRow(
              request: r,
              onAccept: () => widget.onAccept(r),
              onDecline: () => widget.onDecline(r),
            ),
          ),
        const Divider(height: 1, thickness: 1, color: AppColors.borderSubtle),
      ],
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
    return Container(
      color: AppColors.backgroundSecondary,
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
                Text('Wants to connect',
                    style: AppTextStyles.bodySmall
                        .copyWith(color: AppColors.textSecondary)),
              ],
            ),
          ),
          GestureDetector(
            onTap: onDecline,
            child: Container(
              height: 34,
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
              decoration: BoxDecoration(
                  border: Border.all(color: AppColors.borderDefault, width: 1),
                  borderRadius: AppRadius.fullRadius),
              alignment: Alignment.center,
              child: Text('Decline',
                  style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.textSecondary,
                      fontWeight: FontWeight.w500)),
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          GestureDetector(
            onTap: onAccept,
            child: Container(
              height: 34,
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
              decoration: BoxDecoration(
                  color: AppColors.textPrimary,
                  borderRadius: AppRadius.fullRadius),
              alignment: Alignment.center,
              child: Text('Accept',
                  style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.backgroundPrimary,
                      fontWeight: FontWeight.w600)),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Conversation item ────────────────────────────────────────────────────────
class _ConversationItem extends StatelessWidget {
  const _ConversationItem({
    super.key,
    required this.conversation,
    required this.localState,
    required this.onTap,
    required this.onDelete,
    required this.onLongPress,
    required this.showDivider,
  });

  final Conversation conversation;
  final _LocalConvState localState;
  final VoidCallback onTap;
  final Future<void> Function() onDelete;
  final VoidCallback onLongPress;
  final bool showDivider;

  @override
  Widget build(BuildContext context) {
    final c = conversation;
    return Dismissible(
      key: ValueKey(c.id),
      direction: DismissDirection.endToStart,
      confirmDismiss: (_) => onDelete().then((_) => false),
      background: Container(
        alignment: Alignment.centerRight,
        color: AppColors.accentDestructive,
        padding: const EdgeInsets.only(right: AppSpacing.xxl),
        child: Text('Delete',
            style: AppTextStyles.bodyMedium
                .copyWith(color: Colors.white, fontWeight: FontWeight.w600)),
      ),
      child: GestureDetector(
        onTap: onTap,
        onLongPress: onLongPress,
        behavior: HitTestBehavior.opaque,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              height: 68,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
                child: Row(
                  children: [
                    const _StateIcon(turn: _TurnState.none),
                    const SizedBox(width: AppSpacing.md),
                    Expanded(
                      child: Row(
                        children: [
                          if (localState.isPinned)
                            const Padding(
                              padding: EdgeInsets.only(right: 4),
                              child: Icon(AppIcons.pin,
                                  size: AppIcons.small,
                                  color: AppColors.textDisabled),
                            ),
                          Expanded(
                            child: Text(
                              c.displayName,
                              style: AppTextStyles.bodyLarge.copyWith(
                                fontWeight: FontWeight.w400,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (localState.isMuted)
                      const Padding(
                        padding: EdgeInsets.only(right: AppSpacing.xs),
                        child: Icon(AppIcons.bellOff,
                            size: AppIcons.small,
                            color: AppColors.textDisabled),
                      ),
                    if (c.lastMessageAt != null)
                      Text(
                        _formatTimestamp(c.lastMessageAt!),
                        style: AppTextStyles.caption
                            .copyWith(color: AppColors.textDisabled),
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
        ),
      ),
    );
  }

  String _formatTimestamp(DateTime dt) {
    final now = DateTime.now();
    final diff = now.difference(dt);
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    return '${diff.inDays}d ago';
  }
}

// ─── State icon ───────────────────────────────────────────────────────────────
class _StateIcon extends StatelessWidget {
  const _StateIcon({required this.turn});
  final _TurnState turn;

  @override
  Widget build(BuildContext context) {
    final IconData icon;
    final Color color;
    switch (turn) {
      case _TurnState.yourTurn:
        icon = AppIcons.chatBubble;
        color = AppColors.textPrimary;
        break;
      case _TurnState.waiting:
        icon = AppIcons.sendArrow;
        color = AppColors.textDisabled;
        break;
      case _TurnState.none:
        icon = AppIcons.chatBubble;
        color = AppColors.borderDefault;
        break;
    }
    return SizedBox(
      width: 44, height: 44,
      child: Icon(icon, size: AppIcons.large, color: color),
    );
  }
}

// ─── Sheet action ─────────────────────────────────────────────────────────────
class _SheetAction extends StatelessWidget {
  const _SheetAction({
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
        height: 56,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xxl),
          child: Row(
            children: [
              Icon(icon, size: AppIcons.medium, color: color),
              const SizedBox(width: AppSpacing.md),
              Text(label,
                  style: AppTextStyles.bodyLarge.copyWith(color: color)),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Undo snackbar ────────────────────────────────────────────────────────────
class _UndoSnackbar extends StatefulWidget {
  const _UndoSnackbar({
    required this.label,
    required this.onUndo,
    required this.onDismiss,
  });
  final String label;
  final VoidCallback onUndo;
  final VoidCallback onDismiss;

  @override
  State<_UndoSnackbar> createState() => _UndoSnackbarState();
}

class _UndoSnackbarState extends State<_UndoSnackbar>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 4000),
    )
      ..addStatusListener((s) {
        if (s == AnimationStatus.completed) widget.onDismiss();
      })
      ..forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.textPrimary,
          borderRadius: AppRadius.largeRadius,
        ),
        clipBehavior: Clip.hardEdge,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.lg, vertical: AppSpacing.md),
              child: Row(
                children: [
                  Expanded(
                    child: Text(widget.label,
                        style: AppTextStyles.bodyMedium.copyWith(
                            color: AppColors.backgroundPrimary,
                            fontWeight: FontWeight.w500)),
                  ),
                  GestureDetector(
                    onTap: () {
                      _controller.stop();
                      widget.onUndo();
                    },
                    child: Padding(
                      padding: const EdgeInsets.only(left: AppSpacing.lg),
                      child: Text('Undo',
                          style: AppTextStyles.bodyMedium.copyWith(
                              color: AppColors.backgroundPrimary,
                              fontWeight: FontWeight.w700)),
                    ),
                  ),
                ],
              ),
            ),
            AnimatedBuilder(
              animation: _controller,
              builder: (context, _) => LayoutBuilder(
                builder: (context, constraints) => Align(
                  alignment: Alignment.centerLeft,
                  child: Container(
                    height: 2,
                    width: constraints.maxWidth * (1.0 - _controller.value),
                    color: AppColors.backgroundPrimary.withValues(alpha: 0.35),
                  ),
                ),
              ),
            ),
          ],
        ),
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
      child: Text('No results for "$query"',
          style:
              AppTextStyles.bodyLarge.copyWith(color: AppColors.textSecondary)),
    );
  }
}

// ─── Empty state ──────────────────────────────────────────────────────────────
class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.onNewConversation});
  final VoidCallback onNewConversation;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xxl),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Spacer(flex: 2),
          Text('Say something\nworth keeping.',
              style: AppTextStyles.displayStyle
                  .copyWith(color: AppColors.textPrimary, height: 1.15)),
          const SizedBox(height: AppSpacing.lg),
          Text(
              'Snipkit is for conversations that matter.\nAdd someone to start.',
              style: AppTextStyles.bodyLarge
                  .copyWith(color: AppColors.textSecondary, height: 1.5)),
          const Spacer(flex: 3),
          GestureDetector(
            onTap: onNewConversation,
            child: Container(
              height: 52,
              decoration: BoxDecoration(
                  color: AppColors.textPrimary,
                  borderRadius: AppRadius.fullRadius),
              alignment: Alignment.center,
              child: Text('Start a conversation',
                  style: AppTextStyles.bodyLarge.copyWith(
                      color: AppColors.backgroundPrimary,
                      fontWeight: FontWeight.w600)),
            ),
          ),
          const SizedBox(height: AppSpacing.xxxl),
        ],
      ),
    );
  }
}
