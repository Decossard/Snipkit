import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/tokens/design_tokens.dart';
import '../../../core/tokens/app_icons.dart';

class AccountLockedScreen extends StatelessWidget {
  const AccountLockedScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF111111),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xxl),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: AppSpacing.xxxl),
              const Icon(
                AppIcons.lockClosed,
                size: 32,
                color: Colors.white,
              ),
              const SizedBox(height: AppSpacing.xxl),
              Text(
                'Account locked.',
                style: AppTextStyles.displayStyle.copyWith(
                  color: Colors.white,
                  height: 1.15,
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              Text(
                'Your account has been locked on all devices. Use your username and recovery code to sign back in.',
                style: AppTextStyles.bodyLarge.copyWith(
                  color: const Color(0xFF888888),
                  height: 1.6,
                ),
              ),
              const Expanded(child: SizedBox()),
              GestureDetector(
                onTap: () => context.go('/login'),
                child: Container(
                  height: 52,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: AppRadius.fullRadius,
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    'Sign in',
                    style: AppTextStyles.bodyLarge.copyWith(
                      color: Colors.black,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.xxxl),
            ],
          ),
        ),
      ),
    );
  }
}
