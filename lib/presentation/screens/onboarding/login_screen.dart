import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/services/auth_service.dart';
import '../../../core/tokens/design_tokens.dart';
import '../../widgets/snipkit_button.dart';
import '../../widgets/snipkit_input.dart';
import '../../widgets/top_bar.dart';
import '../../widgets/screen_shell.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _usernameController = TextEditingController();

  bool get _canContinue => _usernameController.text.trim().isNotEmpty;

  @override
  void initState() {
    super.initState();
    _usernameController.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _usernameController.dispose();
    super.dispose();
  }

  void _showLostAccessSheet() {
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
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 36,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.borderDefault,
                  borderRadius: AppRadius.fullRadius,
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.xxl),
            Text(
              'Can\'t access your account?',
              style: AppTextStyles.headingSmall
                  .copyWith(color: AppColors.textPrimary),
            ),
            const SizedBox(height: AppSpacing.md),
            Text(
              'Snipkit is end-to-end encrypted with zero server knowledge. Your username and recovery code are the only way in — we have no backup and cannot reset your access.',
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.textSecondary,
                height: 1.6,
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            Text(
              'If you have your username, tap Continue and enter your recovery code on the next screen.',
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.textSecondary,
                height: 1.6,
              ),
            ),
            const SizedBox(height: AppSpacing.xxl),
            GestureDetector(
              onTap: () => Navigator.of(context).pop(),
              child: Container(
                height: 52,
                decoration: BoxDecoration(
                  color: AppColors.textPrimary,
                  borderRadius: AppRadius.fullRadius,
                ),
                alignment: Alignment.center,
                child: Text(
                  'Got it',
                  style: AppTextStyles.bodyLarge.copyWith(
                    color: AppColors.backgroundPrimary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundPrimary,
      appBar: SnipkitTopBar(showBack: true, onBack: () => context.pop()),
      body: SafeArea(
        top: false,
        child: ScreenShell(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xxl),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: AppSpacing.xxxl),
                Text('Welcome back.', style: AppTextStyles.headingLarge),
                const SizedBox(height: AppSpacing.sm),
                Text(
                  'Enter your username to continue.',
                  style: AppTextStyles.bodyMedium
                      .copyWith(color: AppColors.textSecondary),
                ),
                const SizedBox(height: AppSpacing.xxl),
                SnipkitInput(
                  label: 'Username',
                  placeholder: 'e.g. cedar.hayes',
                  controller: _usernameController,
                ),
                const SizedBox(height: AppSpacing.lg),
                GestureDetector(
                  onTap: _showLostAccessSheet,
                  child: Text(
                    'Can\'t access your account?',
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.textSecondary,
                      decoration: TextDecoration.underline,
                      decorationColor: AppColors.textSecondary,
                    ),
                  ),
                ),
                const Expanded(child: SizedBox()),
                SnipkitButton(
                  label: 'Continue',
                  isDisabled: !_canContinue,
                  onPressed: _canContinue
                      ? () {
                          // Store username for the recovery screen
                          ref
                              .read(pendingLoginUsernameProvider.notifier)
                              .state = _usernameController.text.trim();
                          context.push('/recovery');
                        }
                      : null,
                ),
                const SizedBox(height: AppSpacing.xxxl),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
