import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/tokens/design_tokens.dart';
import '../../widgets/snipkit_button.dart';
import '../../widgets/snipkit_input.dart';
import '../../widgets/top_bar.dart';
import '../../widgets/screen_shell.dart';

class RecoveryEntryScreen extends StatefulWidget {
  const RecoveryEntryScreen({super.key});

  @override
  State<RecoveryEntryScreen> createState() => _RecoveryEntryScreenState();
}

class _RecoveryEntryScreenState extends State<RecoveryEntryScreen> {
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
                Text('Recovery code.', style: AppTextStyles.headingLarge),
                const SizedBox(height: AppSpacing.sm),
                Text(
                  'Enter your 5 words separated by spaces.',
                  style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary),
                ),
                const SizedBox(height: AppSpacing.xxl),
                SnipkitInput(
                  label: 'Recovery code',
                  placeholder: 'e.g. word1 word2 word3 word4 word5',
                  controller: _controller,
                  keyboardType: TextInputType.text,
                  textInputAction: TextInputAction.done,
                ),
                const Expanded(child: SizedBox()),
                Text(
                  'Lost your code? Your account cannot be recovered.',
                  style: AppTextStyles.caption.copyWith(color: AppColors.textDisabled),
                ),
                const SizedBox(height: AppSpacing.md),
                SnipkitButton(
                  label: 'Sign in',
                  onPressed: _canSubmit ? () => context.go('/home') : null,
                  isDisabled: !_canSubmit,
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
