import 'dart:async';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/tokens/design_tokens.dart';
import '../../../core/tokens/app_icons.dart';
import '../../widgets/searchable_top_bar.dart';
import '../../widgets/new_conversation_sheet.dart';

// ─── Models ───────────────────────────────────────────────────────────────────
enum _TurnState { yourTurn, waiting, none }

class _Conversation {
  _Conversation({
    required this.username,
    this.nickname,
    required this.turn,
    required this.timestamp,
    this.isPinned = false,
    this.isMuted = false,
  });
  final String username;   // their unique handle e.g. "jade.miller"
  final String? nickname;  // local name e.g. "Jade" — only you see it
  final _TurnState turn;
  final String timestamp;
  bool isPinned;
  bool isMuted;

  String get displayName => nickname ?? username;
}

class _ContactRequest {
  const _ContactRequest({required this.username});
  final String username; // their handle e.g. "oak.river"
}

class _PendingAction {
  const _PendingAction({required this.label, required this.onUndo});
  final String label;
  final VoidCallback onUndo;
}

// ─── Screen ───────────────────────────────────────────────────────────────────
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String _searchQuery = '';
  _PendingAction? _pendingAction;
  final _searchController = TextEditingController();
  Timer? _debounceTimer;

  final List<_Conversation> _conversations = [
    _Conversation(
      username: 'jade.miller',
      nickname: 'Jade',
      turn: _TurnState.yourTurn,
      timestamp: '2h ago',
      isPinned: true,
    ),
    _Conversation(
      username: 'marco.ross',
      turn: _TurnState.waiting,
      timestamp: '5h ago',
      isMuted: true,
    ),
    _Conversation(
      username: 'sofia.novak',
      nickname: 'Sofia',
      turn: _TurnState.none,
      timestamp: '1d ago',
    ),
    _Conversation(
      username: 'alex.kim',
      turn: _TurnState.none,
      timestamp: '3d ago',
    ),
  ];

  final List<_ContactRequest> _requests = [
    const _ContactRequest(username: 'oak.river'),
  ];

  List<_Conversation> get _sortedConversations => [
        ..._conversations.where((c) => c.isPinned),
        ..._conversations.where((c) => !c.isPinned),
      ];

  List<_Conversation> get _filteredConversations {
    if (_searchQuery.isEmpty) return _sortedConversations;
    final q = _searchQuery.toLowerCase();
    return _sortedConversations.where((c) =>
        c.displayName.toLowerCase().contains(q) ||
        c.username.toLowerCase().contains(q)).toList();
  }

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

  void _acceptRequest(_ContactRequest r) {
    _showNamingSheet(r);
  }

  void _declineRequest(_ContactRequest r) => setState(() => _requests.remove(r));
  void _deleteConversation(_Conversation c) => setState(() => _conversations.remove(c));

  void _showNamingSheet(_ContactRequest r) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.backgroundPrimary,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (_) => _NamingSheet(
        username: r.username,
        onSave: (nickname) {
          setState(() {
            _requests.remove(r);
            _conversations.insert(
              0,
              _Conversation(
                username: r.username,
                nickname: nickname.isEmpty ? null : nickname,
                turn: _TurnState.none,
                timestamp: 'Just now',
              ),
            );
          });
        },
      ),
    );
  }

  void _showUndoSnackbar({required String label, required VoidCallback onUndo}) {
    setState(() => _pendingAction = _PendingAction(label: label, onUndo: onUndo));
  }

  void _handleUndo() {
    _pendingAction?.onUndo();
    setState(() => _pendingAction = null);
  }

  void _dismissSnackbar() => setState(() => _pendingAction = null);

  Future<bool> _confirmDelete(_Conversation c) async {
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

  void _showConversationActions(_Conversation c) {
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
            label: c.isPinned ? 'Unpin' : 'Pin',
            onTap: () {
              Navigator.of(context).pop();
              setState(() => c.isPinned = !c.isPinned);
            },
          ),
          _SheetAction(
            icon: c.isMuted ? AppIcons.bell : AppIcons.bellOff,
            label: c.isMuted ? 'Unmute' : 'Mute',
            onTap: () {
              Navigator.of(context).pop();
              if (c.isMuted) {
                setState(() => c.isMuted = false);
                _showUndoSnackbar(
                  label: 'Unmuted',
                  onUndo: () => setState(() => c.isMuted = true),
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
              context.push('/contact/${c.username}');
            },
          ),
          SizedBox(height: MediaQuery.of(context).padding.bottom + AppSpacing.md),
        ],
      ),
    );
  }

  void _showMuteOptions(_Conversation c) {
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
              setState(() => c.isMuted = true);
              _showUndoSnackbar(
                  label: 'Muted for 1 hour',
                  onUndo: () => setState(() => c.isMuted = false));
            },
          ),
          _SheetAction(
            icon: AppIcons.clock,
            label: '8 hours',
            onTap: () {
              Navigator.of(context).pop();
              setState(() => c.isMuted = true);
              _showUndoSnackbar(
                  label: 'Muted for 8 hours',
                  onUndo: () => setState(() => c.isMuted = false));
            },
          ),
          _SheetAction(
            icon: AppIcons.bellOff,
            label: 'Always',
            onTap: () {
              Navigator.of(context).pop();
              setState(() => c.isMuted = true);
              _showUndoSnackbar(
                  label: 'Notifications muted',
                  onUndo: () => setState(() => c.isMuted = false));
            },
          ),
          SizedBox(height: MediaQuery.of(context).padding.bottom + AppSpacing.md),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final convs = _filteredConversations;
    final isEmpty = _conversations.isEmpty;
    final noResults = _searchQuery.isNotEmpty && convs.isEmpty;

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
                child: isEmpty
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
                          if (_requests.isNotEmpty)
                            _RequestsBanner(
                              requests: _requests,
                              onAccept: _acceptRequest,
                              onDecline: _declineRequest,
                            ),
                          // No results
                          if (noResults)
                            _NoResults(query: _searchQuery)
                          else
                            ...convs.asMap().entries.map(
                                  (e) => _ConversationItem(
                                    key: ValueKey(e.value.username),
                                    conversation: e.value,
                                    onTap: () =>
                                        context.push('/conversation/${e.value.username}'),
                                    onDelete: () async {
                                      final ok = await _confirmDelete(e.value);
                                      if (ok) _deleteConversation(e.value);
                                    },
                                    onLongPress: () =>
                                        _showConversationActions(e.value),
                                    showDivider: true,
                                  ),
                                ),
                        ],
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
          // Handle
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
            style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary, height: 1.4),
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
                hintStyle: AppTextStyles.bodyLarge.copyWith(color: AppColors.textPlaceholder),
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
                    color: AppColors.textPrimary, borderRadius: AppRadius.fullRadius),
                alignment: Alignment.center,
                child: Text('Save name',
                    style: AppTextStyles.bodyLarge.copyWith(
                        color: AppColors.backgroundPrimary, fontWeight: FontWeight.w600)),
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
  final List<_ContactRequest> requests;
  final void Function(_ContactRequest) onAccept;
  final void Function(_ContactRequest) onDecline;

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
  final _ContactRequest request;
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
                  request.username,
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
    required this.onTap,
    required this.onDelete,
    required this.onLongPress,
    required this.showDivider,
  });

  final _Conversation conversation;
  final VoidCallback onTap;
  final Future<void> Function() onDelete;
  final VoidCallback onLongPress;
  final bool showDivider;

  @override
  Widget build(BuildContext context) {
    final c = conversation;
    return Dismissible(
      key: ValueKey(c.username),
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
                    _StateIcon(turn: c.turn),
                    const SizedBox(width: AppSpacing.md),
                    Expanded(
                      child: Row(
                        children: [
                          if (c.isPinned)
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
                                fontWeight: c.turn == _TurnState.yourTurn
                                    ? FontWeight.w600
                                    : FontWeight.w400,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (c.isMuted)
                      const Padding(
                        padding: EdgeInsets.only(right: AppSpacing.xs),
                        child: Icon(AppIcons.bellOff,
                            size: AppIcons.small,
                            color: AppColors.textDisabled),
                      ),
                    Text(c.timestamp,
                        style: AppTextStyles.caption
                            .copyWith(color: AppColors.textDisabled)),
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
