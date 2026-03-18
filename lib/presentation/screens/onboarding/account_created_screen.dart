import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/services/auth_service.dart';
import '../../../core/tokens/design_tokens.dart';
import '../../../core/tokens/app_icons.dart';
import '../../widgets/snipkit_button.dart';
import '../../widgets/screen_shell.dart';

class AccountCreatedScreen extends ConsumerStatefulWidget {
  const AccountCreatedScreen({super.key});

  @override
  ConsumerState<AccountCreatedScreen> createState() =>
      _AccountCreatedScreenState();
}

class _AccountCreatedScreenState extends ConsumerState<AccountCreatedScreen> {
  bool _savedCode = false;
  bool _copied = false;
  bool _wordsVisible = false;

  void _copyAll(String username, List<String> words) {
    final text = 'Username: $username\nRecovery: ${words.join(' ')}';
    Clipboard.setData(ClipboardData(text: text));
    setState(() => _copied = true);
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) setState(() => _copied = false);
    });
  }

  @override
  Widget build(BuildContext context) {
    final pending = ref.watch(authProvider).pendingSignup;

    // Fallback if we land here without pending data
    if (pending == null) {
      return const Scaffold(
        backgroundColor: Color(0xFF111111),
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final username = pending.username;
    final recoveryWords = pending.recoveryWords;

    return Scaffold(
      backgroundColor: const Color(0xFF111111),
      body: SafeArea(
        child: ScreenShell(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xxl),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: AppSpacing.giant),

                Text(
                  'Save this.',
                  style: AppTextStyles.displayStyle.copyWith(
                    color: Colors.white,
                    height: 1.1,
                  ),
                ),
                const SizedBox(height: AppSpacing.sm),
                Text(
                  'This is the only way to access your account.',
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: const Color(0xFF888888),
                  ),
                ),

                const SizedBox(height: AppSpacing.giant),

                // USERNAME
                Text(
                  'USERNAME',
                  style: AppTextStyles.caption.copyWith(
                    color: const Color(0xFF555555),
                    letterSpacing: 1.5,
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
                Text(
                  username,
                  style: AppTextStyles.headingLarge.copyWith(
                    color: Colors.white,
                    letterSpacing: -0.3,
                  ),
                ),

                const SizedBox(height: AppSpacing.xxl),
                const _Divider(),
                const SizedBox(height: AppSpacing.xxl),

                // Recovery code header row
                Row(
                  children: [
                    Text(
                      'RECOVERY CODE',
                      style: AppTextStyles.caption.copyWith(
                        color: const Color(0xFF555555),
                        letterSpacing: 1.5,
                      ),
                    ),
                    const Spacer(),
                    Semantics(
                      label: _wordsVisible
                          ? 'Hide recovery code'
                          : 'Show recovery code',
                      button: true,
                      child: GestureDetector(
                        onTap: () =>
                            setState(() => _wordsVisible = !_wordsVisible),
                        child: Row(
                          children: [
                            Icon(
                              _wordsVisible ? AppIcons.eyeOff : AppIcons.eye,
                              size: AppIcons.small,
                              color: const Color(0xFF555555),
                            ),
                            const SizedBox(width: 4),
                            Text(
                              _wordsVisible ? 'Hide' : 'Reveal',
                              style: AppTextStyles.caption.copyWith(
                                color: const Color(0xFF555555),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.md),

                // Numbered recovery words (or obscured)
                AnimatedSwitcher(
                  duration: AppDurations.standard,
                  child: _wordsVisible
                      ? Column(
                          key: const ValueKey('visible'),
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: recoveryWords
                              .asMap()
                              .entries
                              .map(
                                (e) => Padding(
                                  padding: const EdgeInsets.only(
                                      bottom: AppSpacing.xs),
                                  child: Row(
                                    children: [
                                      SizedBox(
                                        width: 20,
                                        child: Text(
                                          '${e.key + 1}.',
                                          style:
                                              AppTextStyles.bodySmall.copyWith(
                                            color: const Color(0xFF555555),
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: AppSpacing.sm),
                                      Text(
                                        e.value,
                                        style:
                                            AppTextStyles.bodyLarge.copyWith(
                                          color: Colors.white,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              )
                              .toList(),
                        )
                      : Column(
                          key: const ValueKey('hidden'),
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: List.generate(
                            recoveryWords.length,
                            (i) => Padding(
                              padding:
                                  const EdgeInsets.only(bottom: AppSpacing.xs),
                              child: Row(
                                children: [
                                  SizedBox(
                                    width: 20,
                                    child: Text(
                                      '${i + 1}.',
                                      style: AppTextStyles.bodySmall.copyWith(
                                        color: const Color(0xFF555555),
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: AppSpacing.sm),
                                  Text(
                                    '••••••',
                                    style: AppTextStyles.bodyLarge.copyWith(
                                      color: const Color(0xFF444444),
                                      letterSpacing: 2,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                ),

                const SizedBox(height: AppSpacing.lg),

                // Copy all
                GestureDetector(
                  onTap: () => _copyAll(username, recoveryWords),
                  child: Container(
                    height: 48,
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: _copied
                            ? AppColors.accentSuccess
                            : const Color(0xFF333333),
                        width: 1,
                      ),
                      borderRadius: AppRadius.fullRadius,
                    ),
                    alignment: Alignment.center,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          _copied ? AppIcons.checkCircle : AppIcons.copy,
                          size: AppIcons.small,
                          color: _copied
                              ? AppColors.accentSuccess
                              : const Color(0xFF888888),
                        ),
                        const SizedBox(width: AppSpacing.xs),
                        Text(
                          _copied ? 'Copied' : 'Copy all to clipboard',
                          style: AppTextStyles.bodySmall.copyWith(
                            color: _copied
                                ? AppColors.accentSuccess
                                : const Color(0xFF888888),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const Expanded(child: SizedBox()),

                // Checkbox
                GestureDetector(
                  onTap: () => setState(() => _savedCode = !_savedCode),
                  child: Row(
                    children: [
                      AnimatedContainer(
                        duration: AppDurations.micro,
                        width: 22,
                        height: 22,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: _savedCode
                              ? AppColors.accentInteractive
                              : Colors.transparent,
                          border: Border.all(
                            color: _savedCode
                                ? AppColors.accentInteractive
                                : const Color(0xFF444444),
                            width: 1.5,
                          ),
                        ),
                        child: _savedCode
                            ? const Icon(AppIcons.check,
                                size: 13, color: Colors.white)
                            : null,
                      ),
                      const SizedBox(width: AppSpacing.md),
                      Text(
                        'I have saved my credentials',
                        style: AppTextStyles.bodySmall
                            .copyWith(color: const Color(0xFF888888)),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: AppSpacing.lg),
                SnipkitButton(
                  label: 'Continue',
                  isDisabled: !_savedCode,
                  onPressed: _savedCode
                      ? () {
                          ref.read(authProvider.notifier).clearPendingSignup();
                          context.go('/home');
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

class _Divider extends StatelessWidget {
  const _Divider();

  @override
  Widget build(BuildContext context) {
    return Container(height: 1, color: const Color(0xFF222222));
  }
}
