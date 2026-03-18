import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/services/auth_service.dart';
import '../../../core/tokens/design_tokens.dart';
import '../../widgets/snipkit_button.dart';
import '../../widgets/snipkit_input.dart';
import '../../widgets/top_bar.dart';
import '../../widgets/screen_shell.dart';

class RecoveryEntryScreen extends ConsumerStatefulWidget {
  const RecoveryEntryScreen({super.key});

  @override
  ConsumerState<RecoveryEntryScreen> createState() =>
      _RecoveryEntryScreenState();
}

class _RecoveryEntryScreenState extends ConsumerState<RecoveryEntryScreen> {
  final _controller = TextEditingController();

  bool get _canSubmit {
    final words = _controller.text.trim().split(RegExp(r'\s+'));
    return words.length == 5 && words.every((w) => w.isNotEmpty);
  }

  @override
  void initState() {
    super.initState();
    _controller.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final username = ref.read(pendingLoginUsernameProvider);
    final phrase = _controller.text.trim();
    final success =
        await ref.read(authProvider.notifier).signIn(username, phrase);
    if (success && mounted) {
      context.go('/home');
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);

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
                Text('Recovery code.', style: AppTextStyles.headingLarge),
                const SizedBox(height: AppSpacing.sm),
                Text(
                  'Enter your 5 words separated by spaces.',
                  style: AppTextStyles.bodyMedium
                      .copyWith(color: AppColors.textSecondary),
                ),
                const SizedBox(height: AppSpacing.xxl),
                SnipkitInput(
                  label: 'Recovery code',
                  placeholder: 'e.g. word1 word2 word3 word4 word5',
                  controller: _controller,
                  keyboardType: TextInputType.text,
                  textInputAction: TextInputAction.done,
                ),
                if (authState.errorMessage != null) ...[
                  const SizedBox(height: AppSpacing.md),
                  Text(
                    authState.errorMessage!,
                    style: AppTextStyles.bodySmall
                        .copyWith(color: AppColors.accentDestructive),
                  ),
                ],
                const Expanded(child: SizedBox()),
                Text(
                  'Lost your code? Your account cannot be recovered.',
                  style: AppTextStyles.caption
                      .copyWith(color: AppColors.textDisabled),
                ),
                const SizedBox(height: AppSpacing.md),
                SnipkitButton(
                  label: authState.isLoading ? 'Signing in…' : 'Sign in',
                  isDisabled: !_canSubmit || authState.isLoading,
                  onPressed:
                      _canSubmit && !authState.isLoading ? _submit : null,
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
