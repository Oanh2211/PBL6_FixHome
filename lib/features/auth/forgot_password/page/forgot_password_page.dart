import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:fixhome/common/constants/app_color.dart';

import '../api/forgot_password_api.dart';
import '../cubit/forgot_password_cubit.dart';
import '../cubit/forgot_password_state.dart';
import 'reset_password_page.dart';

class ForgotPasswordPage extends StatelessWidget {
  final ForgotPasswordApi api;
  final VoidCallback? onBackToLogin;

  const ForgotPasswordPage({super.key, required this.api, this.onBackToLogin});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => ForgotPasswordCubit(api),
      child: ForgotPasswordView(onBackToLogin: onBackToLogin),
    );
  }
}

class ForgotPasswordView extends StatefulWidget {
  final VoidCallback? onBackToLogin;

  const ForgotPasswordView({super.key, this.onBackToLogin});

  @override
  State<ForgotPasswordView> createState() => _ForgotPasswordViewState();
}

class _ForgotPasswordViewState extends State<ForgotPasswordView> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _otpController = TextEditingController();

  bool _isVerifying = false;

  @override
  void dispose() {
    _emailController.dispose();
    _otpController.dispose();
    super.dispose();
  }

  Future<void> _verifyOtp() async {
    if (_isVerifying) return;

    FocusScope.of(context).unfocus();

    setState(() {
      _isVerifying = true;
    });

    try {
      final cubit = context.read<ForgotPasswordCubit>();

      final success = await cubit.verifyOtp(
        email: _emailController.text.trim(),
        otp: _otpController.text.trim(),
      );

      if (!mounted || !success) return;

      // Navigator.push(
      //   context,
      //   MaterialPageRoute(
      //     builder: (_) => BlocProvider.value(
      //       value: cubit,
      //       child: ResetPasswordPage(onBackToLogin: widget.onBackToLogin),
      //     ),
      //   ),
      // );

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => BlocProvider.value(
            value: cubit,
            child: ResetPasswordPage(
              onBackToLogin: () {
                Navigator.pushNamedAndRemoveUntil(
                  context,
                  '/login',
                  (route) => false,
                );
              },
            ),
          ),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isVerifying = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<ForgotPasswordCubit, ForgotPasswordState>(
      listenWhen: (previous, current) =>
          previous.errorMessage != current.errorMessage ||
          previous.successMessage != current.successMessage,
      listener: (context, state) {
        if (state.errorMessage != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.errorMessage!.tr()),
              backgroundColor: AppColors.error,
            ),
          );
        }

        if (state.successMessage != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.successMessage!.tr()),
              backgroundColor: AppColors.success,
            ),
          );
        }
      },
      builder: (context, state) {
        final cubit = context.read<ForgotPasswordCubit>();

        return Scaffold(
          backgroundColor: AppColors.background,
          appBar: AppBar(
            backgroundColor: AppColors.surface,
            surfaceTintColor: AppColors.surface,
            elevation: 0,
            centerTitle: true,
            leading: IconButton(
              onPressed: () {
                if (widget.onBackToLogin != null) {
                  widget.onBackToLogin!();
                } else {
                  Navigator.maybePop(context);
                }
              },
              icon: const Icon(
                Icons.arrow_back_ios_new,
                size: 19,
                color: AppColors.textPrimary,
              ),
            ),
            title: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 25,
                  height: 25,
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(7),
                  ),
                  child: const Icon(
                    Icons.home_repair_service,
                    size: 16,
                    color: AppColors.surface,
                  ),
                ),
                const SizedBox(width: 8),
                const Text(
                  'FixHome',
                  style: TextStyle(
                    color: AppColors.primary,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          body: SafeArea(
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 440),
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(20, 28, 20, 28),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const SizedBox(height: 12),

                      // Biểu tượng quên mật khẩu
                      Center(
                        child: Container(
                          width: 86,
                          height: 86,
                          decoration: BoxDecoration(
                            color: AppColors.primaryLight.withOpacity(0.12),
                            borderRadius: BorderRadius.circular(24),
                          ),
                          child: Center(
                            child: Container(
                              width: 61,
                              height: 61,
                              decoration: BoxDecoration(
                                color: AppColors.primaryDark,
                                borderRadius: BorderRadius.circular(17),
                              ),
                              child: const Icon(
                                Icons.lock_reset,
                                size: 35,
                                color: AppColors.surface,
                              ),
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 22),

                      Text(
                        'forgot.title'.tr(),
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 25,
                          fontWeight: FontWeight.w800,
                          color: AppColors.textPrimary,
                        ),
                      ),

                      const SizedBox(height: 9),

                      Text(
                        'forgot.subtitle'.tr(),
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppColors.textSecondary,
                        ),
                      ),

                      const SizedBox(height: 30),

                      // Khung nhập email và OTP
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: AppColors.surface,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: AppColors.border),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildLabel('forgot.registered_email'.tr()),

                            const SizedBox(height: 10),

                            TextField(
                              controller: _emailController,
                              keyboardType: TextInputType.emailAddress,
                              textInputAction: TextInputAction.next,
                              autocorrect: false,
                              enabled: !state.isLoading && !_isVerifying,
                              decoration: _buildInputDecoration(
                                hint: 'forgot.email_hint'.tr(),
                                prefixIcon: Icons.mail_outline,
                              ),
                            ),

                            const SizedBox(height: 24),

                            Row(
                              children: [
                                Expanded(
                                  child: _buildLabel('forgot.otp_label'.tr()),
                                ),
                                if (state.isLoading || _isVerifying)
                                  const SizedBox(
                                    width: 16,
                                    height: 16,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: AppColors.primary,
                                    ),
                                  ),
                              ],
                            ),

                            const SizedBox(height: 10),

                            TextField(
                              controller: _otpController,
                              keyboardType: TextInputType.number,
                              textInputAction: TextInputAction.done,
                              maxLength: 6,
                              inputFormatters: [
                                FilteringTextInputFormatter.digitsOnly,
                                LengthLimitingTextInputFormatter(6),
                              ],
                              onSubmitted: (_) => _verifyOtp(),
                              decoration: _buildInputDecoration(
                                hint: 'forgot.otp_hint'.tr(),
                                prefixIcon: Icons.verified_user_outlined,
                              ).copyWith(counterText: ''),
                            ),

                            const SizedBox(height: 12),

                            SizedBox(
                              width: double.infinity,
                              height: 46,
                              child: OutlinedButton(
                                onPressed: state.isLoading || _isVerifying
                                    ? null
                                    : () async {
                                        FocusScope.of(context).unfocus();

                                        await cubit.sendForgotPasswordOtp(
                                          _emailController.text.trim(),
                                        );
                                      },
                                style: OutlinedButton.styleFrom(
                                  foregroundColor: AppColors.primary,
                                  disabledForegroundColor: AppColors.textHint,
                                  side: const BorderSide(
                                    color: AppColors.primary,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                ),
                                child: Text(
                                  'forgot.send_otp'.tr(),
                                  style: const TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ),

                            const SizedBox(height: 12),

                            Text(
                              'forgot.otp_note'.tr(),
                              style: const TextStyle(
                                fontSize: 11,
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 30),

                      SizedBox(
                        height: 49,
                        child: ElevatedButton(
                          onPressed: state.isLoading || _isVerifying
                              ? null
                              : _verifyOtp,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            foregroundColor: AppColors.surface,
                            disabledBackgroundColor: AppColors.primaryLight,
                            elevation: 2,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(11),
                            ),
                          ),
                          child: _isVerifying
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
                                      'forgot.verify_and_continue'.tr(),
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
          ),
        );
      },
    );
  }

  Widget _buildLabel(String text) {
    return RichText(
      text: TextSpan(
        style: const TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          color: AppColors.textPrimary,
        ),
        children: [
          TextSpan(text: text),
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
  }) {
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(color: AppColors.textHint, fontSize: 12),
      prefixIcon:
          const IconTheme(
                data: IconThemeData(color: AppColors.textSecondary),
                child: Icon(Icons.circle_outlined, size: 0),
              ).data.size ==
              0
          ? Icon(prefixIcon, size: 19, color: AppColors.textSecondary)
          : null,
      filled: true,
      fillColor: AppColors.surfaceMuted,
      contentPadding: const EdgeInsets.symmetric(horizontal: 13, vertical: 14),
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
}
