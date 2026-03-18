import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/tokens/design_tokens.dart';
import '../../widgets/snipkit_button.dart';
import '../../widgets/top_bar.dart';

/// Shown when you accept a contact request.
/// Lets you give the person a local nickname — only you see it.
class NameContactScreen extends StatefulWidget {
  final String username;
  const NameContactScreen({super.key, required this.username});

  @override
  State<NameContactScreen> createState() => _NameContactScreenState();
}

class _NameContactScreenState extends State<NameContactScreen> {
  final _controller = TextEditingController();
  final _focusNode = FocusNode();
  bool _isFocused = false;

  bool get _canSubmit => _controller.text.trim().isNotEmpty;

  @override
  void initState() {
    super.initState();
    _controller.addListener(() => setState(() {}));
    _focusNode.addListener(() => setState(() => _isFocused = _focusNode.hasFocus));
    WidgetsBinding.instance.addPostFrameCallback((_) => _focusNode.requestFocus());
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
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
                'What do you want\nto call them?',
                style: AppTextStyles.displayStyle.copyWith(
                  color: AppColors.textPrimary,
                  height: 1.15,
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(
                'Just for you — ${widget.username} won\'t see it.',
                style: AppTextStyles.bodyLarge.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: AppSpacing.giant),
              // Nickname input
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'NAME',
                    style: AppTextStyles.caption.copyWith(
                      color: AppColors.textDisabled,
                      letterSpacing: 1.5,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  AnimatedContainer(
                    duration: AppDurations.micro,
                    decoration: BoxDecoration(
                      border: Border(
                        bottom: BorderSide(
                          color: _isFocused
                              ? AppColors.textPrimary
                              : AppColors.borderSubtle,
                          width: _isFocused ? 2 : 1,
                        ),
                      ),
                    ),
                    child: TextField(
                      controller: _controller,
                      focusNode: _focusNode,
                      style: AppTextStyles.headingSmall.copyWith(
                        color: AppColors.textPrimary,
                      ),
                      textCapitalization: TextCapitalization.words,
                      decoration: InputDecoration(
                        border: InputBorder.none,
                        hintText: 'e.g. Jade',
                        hintStyle: AppTextStyles.headingSmall.copyWith(
                          color: AppColors.textDisabled,
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          vertical: AppSpacing.md,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const Expanded(child: SizedBox()),
              SnipkitButton(
                label: 'Add contact',
                onPressed: _canSubmit ? () => context.go('/home') : null,
                isDisabled: !_canSubmit,
              ),
              const SizedBox(height: AppSpacing.md),
              // Skip — use their username as display name
              GestureDetector(
                onTap: () => context.go('/home'),
                child: SizedBox(
                  height: 44,
                  child: Center(
                    child: Text(
                      'Skip, use ${widget.username}',
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: AppColors.textSecondary,
                        fontWeight: FontWeight.w500,
                      ),
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
