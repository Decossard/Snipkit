import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/tokens/design_tokens.dart';
import '../../../core/tokens/app_icons.dart';

class ArticleComposerScreen extends StatefulWidget {
  const ArticleComposerScreen({super.key});

  @override
  State<ArticleComposerScreen> createState() => _ArticleComposerScreenState();
}

class _ArticleComposerScreenState extends State<ArticleComposerScreen> {
  final _titleController = TextEditingController();
  final _bodyController = TextEditingController();

  bool get _canSend =>
      _titleController.text.trim().isNotEmpty &&
      _bodyController.text.trim().isNotEmpty;

  @override
  void initState() {
    super.initState();
    _titleController.addListener(() => setState(() {}));
    _bodyController.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _titleController.dispose();
    _bodyController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundPrimary,
      appBar: _ArticleAppBar(
        onClose: () => context.pop(),
        canSend: _canSend,
        onSend: () => context.pop(),
      ),
      body: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xxl),
          child: Column(
            children: [
              const SizedBox(height: AppSpacing.lg),
              // Title
              TextField(
                controller: _titleController,
                style: AppTextStyles.headingLarge.copyWith(
                  color: AppColors.textPrimary,
                ),
                maxLines: null,
                textCapitalization: TextCapitalization.sentences,
                decoration: InputDecoration(
                  border: InputBorder.none,
                  isDense: true,
                  hintText: 'Title',
                  hintStyle: AppTextStyles.headingLarge.copyWith(
                    color: AppColors.textDisabled,
                  ),
                ),
              ),
              const Divider(height: 1, thickness: 1, color: AppColors.borderSubtle),
              const SizedBox(height: AppSpacing.lg),
              // Body
              Expanded(
                child: TextField(
                  controller: _bodyController,
                  maxLines: null,
                  expands: true,
                  textCapitalization: TextCapitalization.sentences,
                  style: AppTextStyles.bodyLarge.copyWith(
                    color: AppColors.textPrimary,
                    height: 1.6,
                  ),
                  decoration: InputDecoration(
                    border: InputBorder.none,
                    isDense: true,
                    hintText: 'Write something...',
                    hintStyle: AppTextStyles.bodyLarge.copyWith(
                      color: AppColors.textDisabled,
                      height: 1.6,
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
}

class _ArticleAppBar extends StatelessWidget implements PreferredSizeWidget {
  const _ArticleAppBar({
    required this.onClose,
    required this.canSend,
    required this.onSend,
  });

  final VoidCallback onClose;
  final bool canSend;
  final VoidCallback onSend;

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
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
        child: Row(
          children: [
            GestureDetector(
              onTap: onClose,
              child: const SizedBox(
                width: 44,
                height: 44,
                child: Icon(
                  AppIcons.xClose,
                  size: AppIcons.medium,
                  color: AppColors.textPrimary,
                ),
              ),
            ),
            const Spacer(),
            Text(
              'Article',
              style: AppTextStyles.headingSmall.copyWith(
                color: AppColors.textPrimary,
              ),
            ),
            const Spacer(),
            GestureDetector(
              onTap: canSend ? onSend : null,
              child: Opacity(
                opacity: canSend ? 1.0 : 0.35,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.lg,
                    vertical: AppSpacing.sm,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.textPrimary,
                    borderRadius: AppRadius.fullRadius,
                  ),
                  child: Text(
                    'Send',
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.backgroundPrimary,
                      fontWeight: FontWeight.w600,
                    ),
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
