import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:fixhome/common/constants/app_color.dart';

import '../cubit/forgot_password_cubit.dart';
import '../cubit/forgot_password_state.dart';

class ResetPasswordPage extends StatefulWidget {
  final VoidCallback? onBackToLogin;

  const ResetPasswordPage({super.key, this.onBackToLogin});

  @override
  State<ResetPasswordPage> createState() => _ResetPasswordViewState();
}

class _ResetPasswordViewState extends State<ResetPasswordPage> {
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();

  bool _isPasswordValid = false;
  bool _isConfirmPasswordValid = false;

  @override
  void dispose() {
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _validatePasswords() {
    final password = _passwordController.text;
    final confirmPassword = _confirmPasswordController.text;

    setState(() {
      _isPasswordValid =
          password.length >= 8 &&
          RegExp(r'[A-Z]').hasMatch(password) &&
          RegExp(r'[a-z]').hasMatch(password) &&
          RegExp(r'[0-9]').hasMatch(password) &&
          RegExp(r"""[^A-Za-z0-9\s]""").hasMatch(password);

      _isConfirmPasswordValid =
          confirmPassword.isNotEmpty && password == confirmPassword;
    });
  }

  Future<void> _submit() async {
    FocusScope.of(context).unfocus();

    final cubit = context.read<ForgotPasswordCubit>();

    await cubit.resetPassword(
      newPassword: _passwordController.text,
      confirmPassword: _confirmPasswordController.text,
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<ForgotPasswordCubit, ForgotPasswordState>(
      listenWhen: (previous, current) =>
          previous.errorMessage != current.errorMessage ||
          previous.isPasswordChanged != current.isPasswordChanged,
      listener: (context, state) {
        if (state.errorMessage != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.errorMessage!.tr()),
              backgroundColor: AppColors.error,
            ),
          );
        }

        if (state.isPasswordChanged) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('forgot.reset_success'.tr()),
              backgroundColor: AppColors.success,
            ),
          );

          if (widget.onBackToLogin != null) {
            widget.onBackToLogin!();
          } else {
            Navigator.of(context).popUntil((route) => route.isFirst);
          }
        }
      },
      builder: (context, state) {
        return Scaffold(
          backgroundColor: AppColors.background,
          appBar: AppBar(
            backgroundColor: AppColors.surface,
            surfaceTintColor: AppColors.surface,
            elevation: 0,
            leading: IconButton(
              onPressed: () => Navigator.maybePop(context),
              icon: const Icon(
                Icons.arrow_back_ios_new,
                size: 19,
                color: AppColors.textPrimary,
              ),
            ),
            title: Text(
              'forgot.reset_title'.tr(),
              style: const TextStyle(
                color: AppColors.textPrimary,
                fontSize: 17,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          body: SafeArea(
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 500),
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(16, 20, 16, 30),
                  children: [
                    // Mật khẩu mới
                    _buildCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildLabel('forgot.new_password'.tr()),
                          const SizedBox(height: 11),
                          TextField(
                            controller: _passwordController,
                            obscureText: state.obscurePassword,
                            onChanged: (_) => _validatePasswords(),
                            decoration: _buildInputDecoration(
                              hint: 'forgot.new_password_hint'.tr(),
                              prefixIcon: Icons.lock_outline,
                              suffixIcon: IconButton(
                                onPressed: context
                                    .read<ForgotPasswordCubit>()
                                    .togglePasswordVisibility,
                                icon: Icon(
                                  state.obscurePassword
                                      ? Icons.visibility_outlined
                                      : Icons.visibility_off_outlined,
                                  color: AppColors.textSecondary,
                                  size: 19,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 18),
                          Text(
                            'forgot.security_requirements'.tr(),
                            style: const TextStyle(
                              color: AppColors.textSecondary,
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 11),
                          _buildRequirement(
                            'forgot.min_length'.tr(),
                            _passwordController.text.length >= 8,
                          ),
                          _buildRequirement(
                            'forgot.uppercase_required'.tr(),
                            RegExp(r'[A-Z]').hasMatch(_passwordController.text),
                          ),
                          _buildRequirement(
                            'forgot.lowercase_required'.tr(),
                            RegExp(r'[a-z]').hasMatch(_passwordController.text),
                          ),
                          _buildRequirement(
                            'forgot.number_required'.tr(),
                            RegExp(r'[0-9]').hasMatch(_passwordController.text),
                          ),
                          _buildRequirement(
                            'forgot.special_required'.tr(),
                            RegExp(
                              r"""[^A-Za-z0-9\s]""",
                            ).hasMatch(_passwordController.text),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 18),

                    // Xác nhận mật khẩu
                    _buildCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildLabel('forgot.confirm_new_password'.tr()),
                          const SizedBox(height: 11),
                          TextField(
                            controller: _confirmPasswordController,
                            obscureText: state.obscureConfirmPassword,
                            onChanged: (_) => _validatePasswords(),
                            decoration: _buildInputDecoration(
                              hint: 'forgot.confirm_password_hint'.tr(),
                              prefixIcon: Icons.shield_outlined,
                              suffixIcon: IconButton(
                                onPressed: context
                                    .read<ForgotPasswordCubit>()
                                    .toggleConfirmPasswordVisibility,
                                icon: Icon(
                                  state.obscureConfirmPassword
                                      ? Icons.visibility_outlined
                                      : Icons.visibility_off_outlined,
                                  color: AppColors.textSecondary,
                                  size: 19,
                                ),
                              ),
                            ),
                          ),
                          if (_confirmPasswordController.text.isNotEmpty &&
                              !_isConfirmPasswordValid) ...[
                            const SizedBox(height: 8),
                            Text(
                              'forgot.password_not_match'.tr(),
                              style: const TextStyle(
                                color: AppColors.error,
                                fontSize: 11,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),

                    const SizedBox(height: 40),

                    SizedBox(
                      height: 49,
                      child: ElevatedButton(
                        onPressed: state.isLoading ? null : _submit,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: AppColors.surface,
                          disabledBackgroundColor: AppColors.primaryLight,
                          elevation: 3,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(11),
                          ),
                        ),
                        child: state.isLoading
                            ? const SizedBox(
                                width: 21,
                                height: 21,
                                child: CircularProgressIndicator(
                                  color: AppColors.surface,
                                  strokeWidth: 2,
                                ),
                              )
                            : Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    'forgot.update_and_login'.tr(),
                                    style: const TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  const Icon(Icons.arrow_forward, size: 17),
                                ],
                              ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildCard({required Widget child}) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
      ),
      child: child,
    );
  }

  Widget _buildLabel(String text) {
    return RichText(
      text: TextSpan(
        style: const TextStyle(
          color: AppColors.textPrimary,
          fontSize: 11,
          fontWeight: FontWeight.w700,
        ),
        children: [
          TextSpan(text: text.toUpperCase()),
          const TextSpan(
            text: ' *',
            style: TextStyle(color: AppColors.error),
          ),
        ],
      ),
    );
  }

  InputDecoration _buildInputDecoration({
    required String hint,
    required IconData prefixIcon,
    Widget? suffixIcon,
  }) {
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(color: AppColors.textHint, fontSize: 12),
      prefixIcon: Icon(prefixIcon, color: AppColors.textSecondary, size: 19),
      suffixIcon: suffixIcon,
      filled: true,
      fillColor: AppColors.surfaceMuted,
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 13),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: AppColors.border),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: AppColors.border),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(
          color: AppColors.borderFocused,
          width: 1.4,
        ),
      ),
    );
  }

  Widget _buildRequirement(String text, bool passed) {
    return Container(
      margin: const EdgeInsets.only(bottom: 7),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 9),
      decoration: BoxDecoration(
        color: passed
            ? AppColors.success.withOpacity(0.10)
            : AppColors.surfaceMuted,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(
            passed ? Icons.check_circle : Icons.info,
            size: 13,
            color: passed ? AppColors.success : AppColors.textSecondary,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                color: passed ? AppColors.success : AppColors.textSecondary,
                fontSize: 10,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
