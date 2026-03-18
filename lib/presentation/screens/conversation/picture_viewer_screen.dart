import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/tokens/design_tokens.dart';
import '../../../core/tokens/app_icons.dart';

class PictureViewerScreen extends StatelessWidget {
  const PictureViewerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Stack(
          fit: StackFit.expand,
          children: [
            // Photo placeholder
            const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(AppIcons.imagePhoto, size: 64, color: Color(0xFF555555)),
                ],
              ),
            ),
            // Top bar
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.lg,
                  vertical: AppSpacing.sm,
                ),
                child: Row(
                  children: [
                    GestureDetector(
                      onTap: () => context.pop(),
                      child: const SizedBox(
                        width: 44,
                        height: 44,
                        child: Icon(
                          AppIcons.xClose,
                          size: AppIcons.medium,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    const Spacer(),
                    // Media is view-once — saving is intentionally disabled
                    Semantics(
                      label: 'View only — cannot be saved',
                      child: const SizedBox(
                        width: 44,
                        height: 44,
                        child: Icon(
                          AppIcons.lockClosed,
                          size: AppIcons.small,
                          color: Color(0x66FFFFFF),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
