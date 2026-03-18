import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/tokens/design_tokens.dart';
import '../../../core/tokens/app_icons.dart';
import '../../../core/models/app_models.dart';
import '../../../core/services/auth_service.dart';
import '../../../core/services/contacts_service.dart';
import '../../../core/services/conversations_service.dart';
import '../../../core/services/messages_service.dart';
import '../../widgets/turn_indicator_bar.dart';

// ─── Nickname lookup (mock) ────────────────────────────────────────────────────
const Map<String, String> _kNicknames = {
  'jade.miller': 'Jade',
  'sofia.novak': 'Sofia',
  'marco.ross': 'Marco',
  'alex.kim': 'Alex',
};

String _resolveDisplayName(String username) =>
    _kNicknames[username] ?? username;

// ─── Data model ───────────────────────────────────────────────────────────────
enum _MsgDirection { sent, received }

enum _ContentType { text, photo, voice, article }

class _Message {
  _Message({
    required this.direction,
    required this.contentType,
    required this.time,
    this.text,
    bool isOpened = false,
  }) : _isOpened = isOpened;

  final _MsgDirection direction;
  final _ContentType contentType;
  final String time;
  final String? text; // only for contentType.text
  bool _isOpened; // only relevant for received media

  bool get isMedia => contentType != _ContentType.text;
  bool get isSent => direction == _MsgDirection.sent;
  bool get isOpened => _isOpened;

  void open() => _isOpened = true;
}

// ─── Mock thread ──────────────────────────────────────────────────────────────
List<_Message> _buildMockMessages() => [
      _Message(
        direction: _MsgDirection.sent,
        contentType: _ContentType.text,
        text: 'Hey, sent you something.',
        time: '9:41 AM',
      ),
      _Message(
        direction: _MsgDirection.sent,
        contentType: _ContentType.photo,
        time: '9:41 AM',
      ),
      _Message(
        direction: _MsgDirection.received,
        contentType: _ContentType.text,
        text: 'Got it. Here\'s one back.',
        time: '9:44 AM',
      ),
      _Message(
        direction: _MsgDirection.received,
        contentType: _ContentType.photo,
        time: '9:44 AM',
        isOpened: false,
      ),
      _Message(
        direction: _MsgDirection.received,
        contentType: _ContentType.voice,
        time: '9:45 AM',
        isOpened: false,
      ),
      _Message(
        direction: _MsgDirection.received,
        contentType: _ContentType.article,
        time: '9:46 AM',
        isOpened: true,
      ),
    ];

String _mockTime() {
  final now = TimeOfDay.now();
  final h = now.hourOfPeriod == 0 ? 12 : now.hourOfPeriod;
  final m = now.minute.toString().padLeft(2, '0');
  final period = now.period == DayPeriod.am ? 'AM' : 'PM';
  return '$h:$m $period';
}

// ─── Screen ───────────────────────────────────────────────────────────────────
class ConversationScreen extends ConsumerStatefulWidget {
  final String username;

  const ConversationScreen({super.key, required this.username});

  @override
  ConsumerState<ConversationScreen> createState() =>
      _ConversationScreenState();
}

class _ConversationScreenState extends ConsumerState<ConversationScreen> {
  final _controller = TextEditingController();
  final _scrollController = ScrollController();
  final _focusNode = FocusNode();
  final List<_Message> _messages = _buildMockMessages();

  // Turn system
  bool _myTurn = true;
  bool _isTyping = false;
  Timer? _replyTimer;

  // Real conversation ID (looked up / created in initState)
  String? _conversationId;

  String get _displayName => _resolveDisplayName(widget.username);
  bool get _canSend => _controller.text.trim().isNotEmpty && _myTurn;

  @override
  void initState() {
    super.initState();
    _controller.addListener(() => setState(() {}));
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final contacts = ref.read(contactsProvider).value ?? [];
      final contact = contacts.cast<Contact?>().firstWhere(
            (c) => c?.username == widget.username,
            orElse: () => null,
          );
      if (contact != null) {
        final conv = await ref
            .read(conversationsProvider.notifier)
            .getOrCreate(contact.contactId);
        if (mounted) setState(() => _conversationId = conv.id);
      }
    });
  }

  @override
  void dispose() {
    _replyTimer?.cancel();
    _controller.dispose();
    _scrollController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: AppDurations.standard,
          curve: AppCurves.standard,
        );
      }
    });
  }

  void _sendMessage() {
    if (!_canSend) return;
    final text = _controller.text.trim();
    _controller.clear();
    setState(() {
      _messages.add(_Message(
        direction: _MsgDirection.sent,
        contentType: _ContentType.text,
        text: text,
        time: _mockTime(),
      ));
      _myTurn = false;
    });
    _scrollToBottom();

    // Fire real message send (fire and forget)
    if (_conversationId != null) {
      final uid = ref.read(authProvider).user?.id;
      final contacts = ref.read(contactsProvider).value ?? [];
      final contact = contacts.cast<Contact?>().firstWhere(
            (c) => c?.username == widget.username,
            orElse: () => null,
          );
      if (uid != null && contact != null) {
        ref.read(messagesProvider(_conversationId!).notifier).sendMessage(
              conversationId: _conversationId!,
              content: text,
              type: 'text',
              currentUserId: uid,
              otherUserId: contact.contactId,
            );
      }
    }

    // Mock: show typing indicator after 800ms, then reply after 2.5s
    _replyTimer?.cancel();
    _replyTimer = Timer(const Duration(milliseconds: 800), () {
      if (!mounted) return;
      setState(() => _isTyping = true);
      _scrollToBottom();

      _replyTimer = Timer(const Duration(milliseconds: 2200), () {
        if (!mounted) return;
        final replies = [
          'Got it 👍',
          'Makes sense.',
          'On it.',
          'Will do!',
          'Roger that.',
        ];
        final reply =
            replies[math.Random().nextInt(replies.length)];
        setState(() {
          _isTyping = false;
          _myTurn = true;
          _messages.add(_Message(
            direction: _MsgDirection.received,
            contentType: _ContentType.text,
            text: reply,
            time: _mockTime(),
          ));
        });
        _scrollToBottom();
      });
    });
  }

  // Opens a received media bubble — marks it as opened, navigates to viewer
  void _openMedia(_Message message) {
    if (message.isOpened) return;
    setState(() => message.open());
    switch (message.contentType) {
      case _ContentType.photo:
        context.push('/picture-viewer');
        break;
      case _ContentType.voice:
        context.push('/voice-record');
        break;
      case _ContentType.article:
        context.push('/article-viewer');
        break;
      case _ContentType.text:
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final turnVariant =
        _myTurn ? TurnIndicatorVariant.yourTurn : TurnIndicatorVariant.waiting;

    return Scaffold(
      backgroundColor: AppColors.backgroundPrimary,
      appBar: _ConversationAppBar(
        displayName: _displayName,
        username: widget.username,
        onBack: () => context.pop(),
        onInfo: () => context.push('/contact/${widget.username}'),
      ),
      body: SafeArea(
        top: false,
        child: Column(
          children: [
            // Turn state banner
            TurnIndicatorBar(variant: turnVariant),
            Expanded(
              child: ListView.builder(
                controller: _scrollController,
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.lg,
                  vertical: AppSpacing.lg,
                ),
                itemCount: _messages.length + (_isTyping ? 1 : 0),
                itemBuilder: (context, i) {
                  if (_isTyping && i == _messages.length) {
                    return const _TypingIndicator();
                  }
                  final msg = _messages[i];
                  if (msg.contentType == _ContentType.text) {
                    return _TextBubble(message: msg);
                  }
                  return _MediaBubble(
                    message: msg,
                    onOpen: () => _openMedia(msg),
                  );
                },
              ),
            ),
            AnimatedSwitcher(
              duration: AppDurations.standard,
              switchInCurve: AppCurves.enter,
              switchOutCurve: AppCurves.enter,
              transitionBuilder: (child, anim) => FadeTransition(
                opacity: anim,
                child: SlideTransition(
                  position: Tween<Offset>(
                    begin: const Offset(0, 0.15),
                    end: Offset.zero,
                  ).animate(anim),
                  child: child,
                ),
              ),
              child: _myTurn
                  ? _Composer(
                      key: const ValueKey('composer'),
                      controller: _controller,
                      focusNode: _focusNode,
                      canSend: _canSend,
                      onAttach: () => _showAttachMenu(context),
                      onSend: _sendMessage,
                    )
                  : _WaitingBar(
                      key: const ValueKey('waiting'),
                      displayName: _displayName,
                    ),
            ),
          ],
        ),
      ),
    );
  }

  void _showAttachMenu(BuildContext context) {
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
          children: [
            _AttachOption(
              icon: AppIcons.camera,
              label: 'Photo',
              onTap: () {
                Navigator.of(context).pop();
                context.push('/picture-preview');
              },
            ),
            const SizedBox(height: AppSpacing.lg),
            _AttachOption(
              icon: AppIcons.microphone,
              label: 'Voice note',
              onTap: () {
                Navigator.of(context).pop();
                context.push('/voice-record');
              },
            ),
            const SizedBox(height: AppSpacing.lg),
            _AttachOption(
              icon: AppIcons.articlePage,
              label: 'Article',
              onTap: () {
                Navigator.of(context).pop();
                context.push('/article-composer');
              },
            ),
          ],
        ),
      ),
    );
  }
}

// ─── App bar ──────────────────────────────────────────────────────────────────
class _ConversationAppBar extends StatelessWidget
    implements PreferredSizeWidget {
  const _ConversationAppBar({
    required this.displayName,
    required this.username,
    required this.onBack,
    required this.onInfo,
  });

  final String displayName;
  final String username;
  final VoidCallback onBack;
  final VoidCallback onInfo;

  @override
  Size get preferredSize => const Size.fromHeight(56);

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
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
        child: Row(
          children: [
            Semantics(
              label: 'Go back',
              button: true,
              child: GestureDetector(
                onTap: onBack,
                child: const SizedBox(
                  width: 44,
                  height: 44,
                  child: Icon(
                    AppIcons.arrowLeft,
                    size: AppIcons.large,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: Text(
                displayName,
                style: AppTextStyles.headingSmall.copyWith(
                  color: AppColors.textPrimary,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            Semantics(
              label: 'Contact info',
              button: true,
              child: GestureDetector(
                onTap: onInfo,
                child: const SizedBox(
                  width: 44,
                  height: 44,
                  child: Icon(
                    AppIcons.infoCircle,
                    size: AppIcons.medium,
                    color: AppColors.textPrimary,
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

// ─── Typing indicator ─────────────────────────────────────────────────────────
class _TypingIndicator extends StatefulWidget {
  const _TypingIndicator();

  @override
  State<_TypingIndicator> createState() => _TypingIndicatorState();
}

class _TypingIndicatorState extends State<_TypingIndicator>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.md),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.lg,
              vertical: AppSpacing.md,
            ),
            decoration: BoxDecoration(
              color: AppColors.bubbleReceived,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(AppRadius.large),
                topRight: Radius.circular(AppRadius.large),
                bottomLeft: Radius.circular(AppRadius.small),
                bottomRight: Radius.circular(AppRadius.large),
              ),
              border: Border.all(color: AppColors.bubbleReceivedBorder),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: List.generate(3, (i) {
                return AnimatedBuilder(
                  animation: _controller,
                  builder: (_, __) {
                    final phase = ((_controller.value - i * 0.18) % 1.0);
                    final opacity =
                        (math.sin(phase * math.pi * 2) * 0.5 + 0.5)
                            .clamp(0.25, 1.0);
                    return Container(
                      width: 6,
                      height: 6,
                      margin: EdgeInsets.only(right: i < 2 ? 5 : 0),
                      decoration: BoxDecoration(
                        color: AppColors.textDisabled
                            .withValues(alpha: opacity),
                        shape: BoxShape.circle,
                      ),
                    );
                  },
                );
              }),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Text bubble ──────────────────────────────────────────────────────────────
class _TextBubble extends StatelessWidget {
  const _TextBubble({required this.message});
  final _Message message;

  @override
  Widget build(BuildContext context) {
    final isSent = message.isSent;
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.md),
      child: Row(
        mainAxisAlignment:
            isSent ? MainAxisAlignment.end : MainAxisAlignment.start,
        children: [
          Flexible(
            child: Column(
              crossAxisAlignment:
                  isSent ? CrossAxisAlignment.end : CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.lg,
                    vertical: AppSpacing.md,
                  ),
                  decoration: BoxDecoration(
                    color: isSent
                        ? AppColors.bubbleSent
                        : AppColors.bubbleReceived,
                    borderRadius: BorderRadius.only(
                      topLeft: const Radius.circular(AppRadius.large),
                      topRight: const Radius.circular(AppRadius.large),
                      bottomLeft: Radius.circular(
                          isSent ? AppRadius.large : AppRadius.small),
                      bottomRight: Radius.circular(
                          isSent ? AppRadius.small : AppRadius.large),
                    ),
                    border: isSent
                        ? null
                        : Border.all(
                            color: AppColors.bubbleReceivedBorder, width: 1),
                  ),
                  child: Text(
                    message.text ?? '',
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: isSent
                          ? AppColors.bubbleSentText
                          : AppColors.bubbleReceivedText,
                      height: 1.4,
                    ),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  message.time,
                  style: AppTextStyles.caption.copyWith(
                    color: AppColors.textDisabled,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Media bubble ─────────────────────────────────────────────────────────────
class _MediaBubble extends StatelessWidget {
  const _MediaBubble({required this.message, required this.onOpen});

  final _Message message;
  final VoidCallback onOpen;

  IconData get _icon {
    switch (message.contentType) {
      case _ContentType.photo:
        return AppIcons.imagePhoto;
      case _ContentType.voice:
        return AppIcons.microphone;
      case _ContentType.article:
        return AppIcons.articlePage;
      case _ContentType.text:
        return AppIcons.chatBubble;
    }
  }

  String get _label {
    switch (message.contentType) {
      case _ContentType.photo:
        return 'Photo';
      case _ContentType.voice:
        return 'Voice note';
      case _ContentType.article:
        return 'Article';
      case _ContentType.text:
        return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    final isSent = message.isSent;
    final isOpened = !isSent && message.isOpened;
    final canOpen = !isSent && !message.isOpened;

    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.md),
      child: Row(
        mainAxisAlignment:
            isSent ? MainAxisAlignment.end : MainAxisAlignment.start,
        children: [
          Flexible(
            child: Column(
              crossAxisAlignment:
                  isSent ? CrossAxisAlignment.end : CrossAxisAlignment.start,
              children: [
                GestureDetector(
                  onTap: canOpen ? onOpen : null,
                  child: AnimatedContainer(
                    duration: AppDurations.standard,
                    curve: AppCurves.standard,
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.lg,
                      vertical: AppSpacing.md,
                    ),
                    decoration: BoxDecoration(
                      color: isOpened
                          ? Colors.transparent
                          : AppColors.bubbleSent,
                      borderRadius: BorderRadius.only(
                        topLeft: const Radius.circular(AppRadius.large),
                        topRight: const Radius.circular(AppRadius.large),
                        bottomLeft: Radius.circular(
                            isSent ? AppRadius.large : AppRadius.small),
                        bottomRight: Radius.circular(
                            isSent ? AppRadius.small : AppRadius.large),
                      ),
                      border: isOpened
                          ? Border.all(
                              color: AppColors.borderDefault, width: 1)
                          : null,
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          _icon,
                          size: AppIcons.medium,
                          color: isOpened
                              ? AppColors.textDisabled
                              : AppColors.bubbleSentText,
                        ),
                        const SizedBox(width: AppSpacing.sm),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _label,
                              style: AppTextStyles.bodyMedium.copyWith(
                                color: isOpened
                                    ? AppColors.textDisabled
                                    : AppColors.bubbleSentText,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            Text(
                              isSent
                                  ? 'Delivered'
                                  : isOpened
                                      ? 'Opened'
                                      : 'Tap to open',
                              style: AppTextStyles.caption.copyWith(
                                color: isOpened
                                    ? AppColors.textDisabled
                                    : isSent
                                        ? AppColors.bubbleSentText
                                            .withValues(alpha: 0.6)
                                        : AppColors.bubbleSentText
                                            .withValues(alpha: 0.7),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  message.time,
                  style: AppTextStyles.caption.copyWith(
                    color: AppColors.textDisabled,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Waiting bar (shown instead of composer when not your turn) ───────────────
class _WaitingBar extends StatelessWidget {
  const _WaitingBar({super.key, required this.displayName});
  final String displayName;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.backgroundPrimary,
        border: Border(
          top: BorderSide(color: AppColors.borderSubtle, width: 1),
        ),
      ),
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.xxl,
        vertical: AppSpacing.lg,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            AppIcons.clock,
            size: AppIcons.small,
            color: AppColors.textDisabled,
          ),
          const SizedBox(width: AppSpacing.sm),
          Text(
            'Waiting for $displayName to reply',
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.textDisabled,
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Composer ─────────────────────────────────────────────────────────────────
class _Composer extends StatelessWidget {
  const _Composer({
    super.key,
    required this.controller,
    required this.focusNode,
    required this.canSend,
    required this.onAttach,
    required this.onSend,
  });

  static const int _maxLength = 160;

  final TextEditingController controller;
  final FocusNode focusNode;
  final bool canSend;
  final VoidCallback onAttach;
  final VoidCallback onSend;

  Color _ringColor(int count) {
    if (count >= 155) return AppColors.accentDestructive;
    if (count >= 140) return AppColors.accentWarning;
    return AppColors.borderDefault;
  }

  @override
  Widget build(BuildContext context) {
    final int charCount = controller.text.length;
    final int remaining = _maxLength - charCount;
    final bool showRing = charCount > 0;
    final double progress = (charCount / _maxLength).clamp(0.0, 1.0);
    final Color ringColor = _ringColor(charCount);
    final bool showCount = remaining <= 20;

    return Container(
        decoration: const BoxDecoration(
          color: AppColors.backgroundPrimary,
          border: Border(
            top: BorderSide(color: AppColors.borderSubtle, width: 1),
          ),
        ),
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.lg,
          vertical: AppSpacing.sm,
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Semantics(
              label: 'Attach media',
              button: true,
              child: GestureDetector(
                onTap: onAttach,
                child: const SizedBox(
                  width: 44,
                  height: 44,
                  child: Icon(
                    AppIcons.plus,
                    size: AppIcons.medium,
                    color: AppColors.textSecondary,
                  ),
                ),
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: Container(
                constraints:
                    const BoxConstraints(minHeight: 44, maxHeight: 120),
                decoration: BoxDecoration(
                  color: AppColors.backgroundInput,
                  borderRadius: AppRadius.xlargeRadius,
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.lg,
                  vertical: AppSpacing.sm,
                ),
                child: TextField(
                  controller: controller,
                  focusNode: focusNode,
                  maxLines: null,
                  maxLength: _maxLength,
                  keyboardType: TextInputType.multiline,
                  textInputAction: TextInputAction.newline,
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.textPrimary,
                  ),
                  decoration: InputDecoration(
                    border: InputBorder.none,
                    isDense: true,
                    counterText: '',
                    hintText: 'Message',
                    hintStyle: AppTextStyles.bodyMedium.copyWith(
                      color: AppColors.textPlaceholder,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            Semantics(
              label: 'Send message',
              button: true,
              child: GestureDetector(
                onTap: canSend ? onSend : null,
                child: SizedBox(
                  width: 44,
                  height: 44,
                  child: CustomPaint(
                    painter: _RingPainter(
                      progress: showRing ? progress : 0.0,
                      color: ringColor,
                    ),
                    child: AnimatedContainer(
                      duration: AppDurations.micro,
                      margin: const EdgeInsets.all(3),
                      decoration: BoxDecoration(
                        color: canSend
                            ? AppColors.textPrimary
                            : AppColors.backgroundInput,
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: showCount
                            ? AnimatedSwitcher(
                                duration: AppDurations.micro,
                                child: Text(
                                  '$remaining',
                                  key: ValueKey(remaining),
                                  style: AppTextStyles.caption.copyWith(
                                    color: canSend
                                        ? AppColors.backgroundPrimary
                                        : ringColor,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              )
                            : Icon(
                                AppIcons.send,
                                size: AppIcons.small,
                                color: canSend
                                    ? AppColors.backgroundPrimary
                                    : AppColors.textDisabled,
                              ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
    );
  }
}

// ─── Ring painter ─────────────────────────────────────────────────────────────
class _RingPainter extends CustomPainter {
  const _RingPainter({required this.progress, required this.color});

  final double progress;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    if (progress <= 0) return;
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 1.5;
    final paint = Paint()
      ..color = color
      ..strokeWidth = 2.5
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    // Track (background ring) — very subtle
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -1.5708, // start at 12 o'clock (-π/2)
      6.2832, // full circle
      false,
      Paint()
        ..color = color.withValues(alpha: 0.12)
        ..strokeWidth = 2.5
        ..style = PaintingStyle.stroke,
    );

    // Progress arc
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -1.5708,
      6.2832 * progress,
      false,
      paint,
    );
  }

  @override
  bool shouldRepaint(_RingPainter old) =>
      old.progress != progress || old.color != color;
}

class _AttachOption extends StatelessWidget {
  const _AttachOption({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: AppColors.backgroundSecondary,
              borderRadius: AppRadius.mediumRadius,
            ),
            child: Icon(icon,
                size: AppIcons.medium, color: AppColors.textPrimary),
          ),
          const SizedBox(width: AppSpacing.lg),
          Text(
            label,
            style:
                AppTextStyles.bodyLarge.copyWith(color: AppColors.textPrimary),
          ),
        ],
      ),
    );
  }
}
