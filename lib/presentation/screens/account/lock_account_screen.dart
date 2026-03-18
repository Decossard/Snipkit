import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/tokens/design_tokens.dart';
import '../../../core/services/auth_service.dart';
import '../../widgets/snipkit_button.dart';
import '../../widgets/top_bar.dart';

class LockAccountScreen extends ConsumerStatefulWidget {
  const LockAccountScreen({super.key});

  @override
  ConsumerState<LockAccountScreen> createState() => _LockAccountScreenState();
}

class _LockAccountScreenState extends ConsumerState<LockAccountScreen> {
  bool _isLocking = false;

  Future<void> _lock() async {
    setState(() => _isLocking = true);
    await ref.read(authProvider.notifier).signOut();
    if (mounted) context.go('/account-locked');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundPrimary,
      appBar: SnipkitTopBar(showBack: true, onBack: () => context.pop()),
      body: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xxl),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: AppSpacing.xxxl),
              Text(
                'Lock account.',
                style: AppTextStyles.displayStyle.copyWith(
                  color: AppColors.textPrimary,
                  height: 1.15,
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              Text(
                'Locking your account will sign you out on all devices. To regain access you\'ll need your username and recovery code.',
                style: AppTextStyles.bodyLarge.copyWith(
                  color: AppColors.textSecondary,
                  height: 1.6,
                ),
              ),
              const SizedBox(height: AppSpacing.xxl),
              Text(
                'This action cannot be undone without your recovery code.',
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.accentDestructive,
                  height: 1.5,
                ),
              ),
              const Expanded(child: SizedBox()),
              SnipkitButton(
                label: 'Lock Account',
                variant: SnipkitButtonVariant.destructive,
                isLoading: _isLocking,
                isDisabled: _isLocking,
                onPressed: _isLocking ? null : _lock,
              ),
              const SizedBox(height: AppSpacing.md),
              SnipkitButton(
                label: 'Cancel',
                variant: SnipkitButtonVariant.secondary,
                onPressed: _isLocking ? null : () => context.pop(),
              ),
              const SizedBox(height: AppSpacing.xxxl),
            ],
          ),
        ),
      ),
    );
  }
}
