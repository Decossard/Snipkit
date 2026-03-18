import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/tokens/design_tokens.dart';
import '../../../core/tokens/app_icons.dart';

// Mock article data passed via state in a real app
const _mockTitle = 'The Art of Slow Messaging';
const _mockBody = """
In a world of instant replies, there's something radical about taking your time.

Snipkit is built around the idea that not every message needs an immediate response. That some conversations are worth sitting with.

When you receive a message here, you're encouraged to think before you reply. Read it twice. Let it settle. Then — only when you're ready — craft something worth sending back.

This isn't just a messaging app. It's a practice in intentional communication.""";

class ArticleViewerScreen extends StatelessWidget {
  const ArticleViewerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundPrimary,
      appBar: _ViewerAppBar(onClose: () => context.pop()),
      body: SafeArea(
        top: false,
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.xxl,
            vertical: AppSpacing.xxl,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                _mockTitle,
                style: AppTextStyles.headingLarge.copyWith(
                  color: AppColors.textPrimary,
                  height: 1.3,
                ),
              ),
              const SizedBox(height: AppSpacing.xxl),
              Text(
                _mockBody,
                style: AppTextStyles.bodyLarge.copyWith(
                  color: AppColors.textPrimary,
                  height: 1.7,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ViewerAppBar extends StatelessWidget implements PreferredSizeWidget {
  const _ViewerAppBar({required this.onClose});
  final VoidCallback onClose;

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
                  AppIcons.arrowLeft,
                  size: AppIcons.medium,
                  color: AppColors.textPrimary,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
