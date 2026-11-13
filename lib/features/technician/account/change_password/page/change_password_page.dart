import 'package:easy_localization/easy_localization.dart';
import 'package:fixhome/common/network/dio_client.dart';
import 'package:fixhome/features/auth/forgot_password/api/forgot_password_api.dart';
import 'package:fixhome/features/auth/forgot_password/page/forgot_password_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:fixhome/common/constants/app_color.dart';

import '../api/change_password_api.dart';
import '../cubit/change_password_cubit.dart';
import '../cubit/change_password_state.dart';

class ChangePasswordPage extends StatelessWidget {
  final VoidCallback? onForgotPassword;

  const ChangePasswordPage({super.key, this.onForgotPassword});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => ChangePasswordCubit(ChangePasswordApi()),
      child: _ChangePasswordView(onForgotPassword: onForgotPassword),
    );
  }
}

class _ChangePasswordView extends StatefulWidget {
  final VoidCallback? onForgotPassword;

  const _ChangePasswordView({this.onForgotPassword});

  @override
  State<_ChangePasswordView> createState() => _ChangePasswordViewState();
}

class _ChangePasswordViewState extends State<_ChangePasswordView> {
  final _currentPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool get _hasMinLength => _newPasswordController.text.length >= 8;

  bool get _hasUppercase =>
      RegExp(r'[A-Z]').hasMatch(_newPasswordController.text);

  bool get _hasLowercase =>
      RegExp(r'[a-z]').hasMatch(_newPasswordController.text);

  bool get _hasNumber => RegExp(r'[0-9]').hasMatch(_newPasswordController.text);

  bool get _hasSpecialCharacter =>
      RegExp(r'''[^A-Za-z0-9\s]''').hasMatch(_newPasswordController.text);

  ForgotPasswordApi forgotPasswordApi = ForgotPasswordApi(DioClient.instance);

  @override
  void dispose() {
    _currentPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final cubit = context.read<ChangePasswordCubit>();

    final success = await cubit.changePassword(
      currentPassword: _currentPasswordController.text,
      newPassword: _newPasswordController.text,
      confirmPassword: _confirmPasswordController.text,
    );

    if (!mounted) return;

    if (success) {
      _currentPasswordController.clear();
      _newPasswordController.clear();
      _confirmPasswordController.clear();

      setState(() {});

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('customer.account.change_password_page.success'.tr()),
          backgroundColor: AppColors.success,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<ChangePasswordCubit, ChangePasswordState>(
      listener: (context, state) {
        if (state.status == ChangePasswordStatus.failure &&
            state.errorMessage != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.errorMessage!.tr()),
              backgroundColor: AppColors.error,
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      },
      builder: (context, state) {
        final cubit = context.read<ChangePasswordCubit>();

        return Scaffold(
          backgroundColor: AppColors.background,

          appBar: AppBar(
            backgroundColor: AppColors.surface,
            surfaceTintColor: Colors.transparent,
            elevation: 0,
            leading: IconButton(
              onPressed: () => Navigator.pop(context),
              icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
            ),
            title: Text(
              'customer.account.change_password_page.title'.tr(),
              style: const TextStyle(
                color: AppColors.textPrimary,
                fontSize: 18,
                fontWeight: FontWeight.w700,
              ),
            ),
            centerTitle: false,
          ),

          body: SafeArea(
            child: Column(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // 1. Mật khẩu hiện tại
                        _buildPasswordCard(
                          title:
                              'customer.account.change_password_page.current_password',
                          controller: _currentPasswordController,
                          hint:
                              'customer.account.change_password_page.current_hint',
                          visible: state.isCurrentPasswordVisible,
                          onToggle: cubit.toggleCurrentPasswordVisibility,
                          trailing: TextButton(
                            onPressed: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => ForgotPasswordPage(
                                  api: forgotPasswordApi,
                                  onBackToLogin: () {
                                    Navigator.pop(context);
                                  },
                                ),
                              ),
                            ),
                            style: TextButton.styleFrom(
                              padding: EdgeInsets.zero,
                              minimumSize: Size.zero,
                              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                            ),
                            child: Text(
                              'customer.account.change_password_page.forgot_password'
                                  .tr(),
                              style: const TextStyle(
                                color: AppColors.primary,
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(height: 22),

                        // 2. Mật khẩu mới
                        _buildNewPasswordCard(state, cubit),

                        const SizedBox(height: 22),

                        // 3. Xác nhận mật khẩu
                        _buildPasswordCard(
                          title:
                              'customer.account.change_password_page.confirm_password',
                          controller: _confirmPasswordController,
                          hint:
                              'customer.account.change_password_page.confirm_hint',
                          visible: state.isConfirmPasswordVisible,
                          onToggle: cubit.toggleConfirmPasswordVisibility,
                          leadingIcon: Icons.verified_user_outlined,
                        ),
                      ],
                    ),
                  ),
                ),

                // Nút cập nhật
                Container(
                  color: AppColors.background,
                  padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
                  child: SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton(
                      onPressed: state.status == ChangePasswordStatus.loading
                          ? null
                          : _submit,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        disabledBackgroundColor: AppColors.primaryLight,
                        foregroundColor: Colors.white,
                        elevation: 5,
                        shadowColor: AppColors.primary.withValues(alpha: 0.25),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: state.status == ChangePasswordStatus.loading
                          ? const SizedBox(
                              width: 22,
                              height: 22,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2,
                              ),
                            )
                          : Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(Icons.sync, size: 17),
                                const SizedBox(width: 8),
                                Text(
                                  'customer.account.change_password_page.update_button'
                                      .tr(),
                                  style: const TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ],
                            ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // Card mật khẩu thông thường
  Widget _buildPasswordCard({
    required String title,
    required TextEditingController controller,
    required String hint,
    required bool visible,
    required VoidCallback onToggle,
    Widget? trailing,
    IconData leadingIcon = Icons.key_outlined,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(13),
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.025),
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(child: _buildFieldTitle(title)),
              if (trailing != null) trailing,
            ],
          ),
          const SizedBox(height: 8),
          _buildPasswordInput(
            controller: controller,
            hint: hint,
            visible: visible,
            onToggle: onToggle,
            leadingIcon: leadingIcon,
          ),
        ],
      ),
    );
  }

  // Card mật khẩu mới
  Widget _buildNewPasswordCard(
    ChangePasswordState state,
    ChangePasswordCubit cubit,
  ) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(13),
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.025),
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildFieldTitle(
            'customer.account.change_password_page.new_password',
          ),

          const SizedBox(height: 8),

          _buildPasswordInput(
            controller: _newPasswordController,
            hint: 'customer.account.change_password_page.new_hint',
            visible: state.isNewPasswordVisible,
            onToggle: cubit.toggleNewPasswordVisibility,
            leadingIcon: Icons.lock_outline,
            onChanged: (_) => setState(() {}),
          ),

          const SizedBox(height: 14),

          Text(
            'customer.account.change_password_page.security_requirements'.tr(),
            style: const TextStyle(
              color: AppColors.textHint,
              fontSize: 10,
              fontWeight: FontWeight.w500,
            ),
          ),

          const SizedBox(height: 8),

          _buildRequirement(
            'customer.account.change_password_page.min_length',
            _hasMinLength,
          ),

          _buildRequirement(
            'customer.account.change_password_page.upper_lower',
            _hasUppercase && _hasLowercase,
          ),

          _buildRequirement(
            'customer.account.change_password_page.number',
            _hasNumber,
          ),

          _buildRequirement(
            'customer.account.change_password_page.special_character',
            _hasSpecialCharacter,
          ),
        ],
      ),
    );
  }

  // Tiêu đề trường nhập
  Widget _buildFieldTitle(String key) {
    return RichText(
      text: TextSpan(
        children: [
          TextSpan(
            text: '${key.tr()} ',
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 11,
              fontWeight: FontWeight.w700,
            ),
          ),
          const TextSpan(
            text: '*',
            style: TextStyle(
              color: AppColors.error,
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  // Ô nhập mật khẩu
  Widget _buildPasswordInput({
    required TextEditingController controller,
    required String hint,
    required bool visible,
    required VoidCallback onToggle,
    Key? inputKey,
    Key? toggleKey,
    IconData leadingIcon = Icons.key_outlined,
    ValueChanged<String>? onChanged,
  }) {
    return Container(
      height: 44,
      padding: const EdgeInsets.symmetric(horizontal: 10),
      decoration: BoxDecoration(
        color: AppColors.surfaceMuted,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.border, width: 0.7),
      ),
      child: Row(
        children: [
          Icon(leadingIcon, color: AppColors.textHint, size: 17),

          const SizedBox(width: 9),

          Expanded(
            child: TextField(
              key: inputKey,
              controller: controller,
              obscureText: !visible,
              onChanged: onChanged,
              style: const TextStyle(
                color: AppColors.textPrimary,
                fontSize: 12,
              ),
              decoration: InputDecoration(
                hintText: hint.tr(),
                hintStyle: const TextStyle(
                  color: AppColors.textHint,
                  fontSize: 12,
                ),
                border: InputBorder.none,
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
                isDense: true,
                contentPadding: EdgeInsets.zero,
              ),
            ),
          ),

          IconButton(
            key: toggleKey,
            onPressed: onToggle,
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(minWidth: 28, minHeight: 32),
            icon: Icon(
              visible
                  ? Icons.visibility_off_outlined
                  : Icons.visibility_outlined,
              color: AppColors.textHint,
              size: 17,
            ),
          ),
        ],
      ),
    );
  }

  // Yêu cầu bảo mật
  Widget _buildRequirement(String key, bool isValid) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 5),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 7),
      decoration: BoxDecoration(
        color: AppColors.surfaceMuted,
        borderRadius: BorderRadius.circular(7),
      ),
      child: Row(
        children: [
          Icon(
            isValid ? Icons.check_circle : Icons.info,
            size: 12,
            color: isValid ? AppColors.success : AppColors.textHint,
          ),

          const SizedBox(width: 7),

          Expanded(
            child: Text(
              key.tr(),
              style: TextStyle(
                color: isValid ? AppColors.success : AppColors.textSecondary,
                fontSize: 10,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
