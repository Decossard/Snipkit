import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/tokens/design_tokens.dart';
import '../../../core/tokens/app_icons.dart';
import '../../../core/services/contacts_service.dart';
import '../../widgets/snipkit_button.dart';
import '../../widgets/top_bar.dart';

class AddContactScreen extends ConsumerStatefulWidget {
  const AddContactScreen({super.key});

  @override
  ConsumerState<AddContactScreen> createState() => _AddContactScreenState();
}

class _AddContactScreenState extends ConsumerState<AddContactScreen> {
  final _controller = TextEditingController();
  final _focusNode = FocusNode();
  bool _isFocused = false;
  bool _hasAttempted = false; // true after first submit attempt
  bool _isLoading = false;
  String? _errorText;

  // Valid username: lowercase letters, digits, and dots — at least 3 chars
  bool get _formatValid {
    final v = _controller.text.trim();
    return v.length >= 3 && RegExp(r'^[a-z0-9.]+$').hasMatch(v);
  }

  bool get _canSubmit => _formatValid && !_isLoading;

  Future<void> _submit() async {
    setState(() => _hasAttempted = true);
    final value = _controller.text.trim();
    if (!_formatValid) return;
    setState(() {
      _errorText = null;
      _isLoading = true;
    });
    final error = await ref.read(contactsProvider.notifier).sendRequest(value);
    if (!mounted) return;
    setState(() => _isLoading = false);
    if (error != null) {
      setState(() => _errorText = error);
      return;
    }
    context.push('/request-sent');
  }

  @override
  void initState() {
    super.initState();
    _controller.addListener(() {
      setState(() {
        // Clear error when user changes input
        if (_errorText != null) _errorText = null;
      });
    });
    _focusNode.addListener(
        () => setState(() => _isFocused = _focusNode.hasFocus));
    WidgetsBinding.instance
        .addPostFrameCallback((_) => _focusNode.requestFocus());
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final showFormatError = _hasAttempted &&
        _controller.text.trim().isNotEmpty &&
        !_formatValid;
    final displayError =
        _errorText ?? (showFormatError ? 'Enter a valid username.' : null);

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
                'Add someone.',
                style: AppTextStyles.displayStyle.copyWith(
                  color: AppColors.textPrimary,
                  height: 1.15,
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(
                'Ask them for their Snipkit username.',
                style: AppTextStyles.bodyLarge.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: AppSpacing.xxxl),
              _UsernameInput(
                controller: _controller,
                focusNode: _focusNode,
                isFocused: _isFocused,
                hasError: displayError != null,
              ),
              const SizedBox(height: AppSpacing.sm),
              // Inline error or hint
              AnimatedSwitcher(
                duration: AppDurations.micro,
                child: displayError != null
                    ? Row(
                        key: const ValueKey('error'),
                        children: [
                          const Icon(
                            AppIcons.warningTriangle,
                            size: AppIcons.small,
                            color: AppColors.accentDestructive,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            displayError,
                            style: AppTextStyles.bodySmall.copyWith(
                              color: AppColors.accentDestructive,
                            ),
                          ),
                        ],
                      )
                    : Text(
                        key: const ValueKey('hint'),
                        'They\'ll get a request and can choose whether to accept.',
                        style: AppTextStyles.bodySmall.copyWith(
                          color: AppColors.textDisabled,
                          height: 1.5,
                        ),
                      ),
              ),
              const Expanded(child: SizedBox()),
              SnipkitButton(
                label: 'Send request',
                onPressed: _canSubmit ? _submit : null,
                isDisabled: !_canSubmit,
                isLoading: _isLoading,
              ),
              const SizedBox(height: AppSpacing.xxxl),
            ],
          ),
        ),
      ),
    );
  }
}

class _UsernameInput extends StatelessWidget {
  const _UsernameInput({
    required this.controller,
    required this.focusNode,
    required this.isFocused,
    required this.hasError,
  });

  final TextEditingController controller;
  final FocusNode focusNode;
  final bool isFocused;
  final bool hasError;

  @override
  Widget build(BuildContext context) {
    final borderColor = hasError
        ? AppColors.accentDestructive
        : isFocused
            ? AppColors.textPrimary
            : AppColors.borderSubtle;
    final borderWidth = isFocused || hasError ? 2.0 : 1.0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'THEIR USERNAME',
          style: AppTextStyles.caption.copyWith(
            color: const Color(0xFF555555),
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
                color: borderColor,
                width: borderWidth,
              ),
            ),
          ),
          child: TextField(
            controller: controller,
            focusNode: focusNode,
            style: AppTextStyles.headingSmall.copyWith(
              color: AppColors.textPrimary,
              letterSpacing: -0.2,
            ),
            keyboardType: TextInputType.text,
            textInputAction: TextInputAction.done,
            autocorrect: false,
            enableSuggestions: false,
            decoration: InputDecoration(
              border: InputBorder.none,
              hintText: 'e.g. jade.miller',
              hintStyle: AppTextStyles.headingSmall.copyWith(
                color: AppColors.textDisabled,
                letterSpacing: -0.2,
              ),
              contentPadding: const EdgeInsets.symmetric(
                  vertical: AppSpacing.md),
            ),
          ),
        ),
      ],
    );
  }
}
