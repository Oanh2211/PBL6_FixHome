import 'package:easy_localization/easy_localization.dart';
import 'package:fixhome/common/constants/app_color.dart';
import 'package:fixhome/features/auth/register/cubit/register_cubit.dart';
import 'package:fixhome/features/auth/register/cubit/register_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../api/register_api.dart';

class RegisterPage extends StatefulWidget {
  final RegisterApi registerApi;

  const RegisterPage({super.key, required this.registerApi});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  // Form Step 2 Controllers
  final _fullNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();

  final List<TextEditingController> _otpControllers = List.generate(
    6,
    (_) => TextEditingController(),
  );

  final List<FocusNode> _otpFocusNodes = List.generate(6, (_) => FocusNode());

  // Form Step 3 Controllers
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _referralController = TextEditingController();

  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  @override
  void dispose() {
    _fullNameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();

    for (var c in _otpControllers) {
      c.dispose();
    }

    for (var f in _otpFocusNodes) {
      f.dispose();
    }

    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _referralController.dispose();

    super.dispose();
  }

  String _getOtpCode() {
    return _otpControllers.map((e) => e.text).join();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => RegisterCubit(widget.registerApi),
      child: BlocConsumer<RegisterCubit, RegisterState>(
        listener: (context, state) {
          if (state.errorMessage != null) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.errorMessage!),
                backgroundColor: AppColors.error,
              ),
            );
          }

          if (state.successMessage != null) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.successMessage!),
                backgroundColor: AppColors.success,
              ),
            );
          }
        },
        builder: (context, state) {
          return Scaffold(
            backgroundColor: AppColors.background,
            appBar: AppBar(
              toolbarHeight: 44,
              backgroundColor: AppColors.background,
              surfaceTintColor: Colors.transparent,
              elevation: 0,
              leadingWidth: 44,
              leading: IconButton(
                icon: const Icon(
                  Icons.arrow_back_ios_new,
                  size: 18,
                  color: AppColors.textPrimary,
                ),
                onPressed: () {
                  if (state.currentStep > 1) {
                    context.read<RegisterCubit>().previousStep();
                  } else {
                    Navigator.maybePop(context);
                  }
                },
              ),
              title: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Image.asset('assets/images/logo_fixhome.png', width: 25),
                  const SizedBox(width: 10),
                  Text(
                    'app_name'.tr(),
                    style: const TextStyle(
                      color: AppColors.primary,
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
              ),
              centerTitle: true,
            ),
            body: SafeArea(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(14, 10, 14, 18),
                child: Column(
                  children: [
                    if (state.currentStep == 1) _buildStep1(context, state),

                    if (state.currentStep == 2) ...[
                      const SizedBox(height: 20),
                      Text(
                        'register.title'.tr(),
                        style: const TextStyle(
                          fontSize: 25,
                          color: AppColors.textPrimary,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 30),
                      _buildFormPanel(child: _buildStep2(context, state)),
                      const SizedBox(height: 10),
                      _buildSocialLoginAndFooter(context),
                    ],

                    if (state.currentStep == 3) ...[
                      const SizedBox(height: 10),
                      Text(
                        'register.title'.tr(),
                        style: const TextStyle(
                          fontSize: 18,
                          color: AppColors.textPrimary,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 20),
                      _buildFormPanel(child: _buildStep3(context, state)),
                    ],
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildFormPanel({required Widget child}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(12, 16, 12, 14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF243B70).withValues(alpha: 0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: child,
    );
  }

  // ==================== STEP 1: CHỌN VAI TRÒ ====================

  Widget _buildStep1(BuildContext context, RegisterState state) {
    return Column(
      children: [
        const SizedBox(height: 30),

        Text(
          'register.welcome'.tr(),
          style: const TextStyle(
            fontSize: 25,
            color: AppColors.textPrimary,
            fontWeight: FontWeight.w800,
          ),
        ),

        const SizedBox(height: 40),

        // Khách hàng Card
        _buildRoleOption(
          context: context,
          role: UserRole.customer,
          selectedRole: state.role,
          title: 'register.customer_role'.tr(),
          subtitle: 'register.customer_description'.tr(),
          icon: Icons.work_outline,
          iconBgColor: AppColors.primaryLight.withValues(alpha: 0.1),
          iconColor: AppColors.primary,
        ),

        const SizedBox(height: 35),

        // Kỹ thuật viên Card
        _buildRoleOption(
          context: context,
          role: UserRole.technician,
          selectedRole: state.role,
          title: 'register.technician_role'.tr(),
          subtitle: 'register.technician_description'.tr(),
          icon: Icons.build_outlined,
          iconBgColor: Colors.orange.shade50,
          iconColor: Colors.orange,
        ),

        const SizedBox(height: 55),

        // Nút tiếp tục
        SizedBox(
          width: double.infinity,
          height: 50,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(7),
              ),
              elevation: 2,
              shadowColor: AppColors.primary.withValues(alpha: 0.25),
            ),
            onPressed: () => context.read<RegisterCubit>().nextStep(),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  (state.role == UserRole.customer
                          ? 'register.continue_customer'
                          : 'register.continue_technician')
                      .tr(),
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: AppColors.surface,
                  ),
                ),
                const SizedBox(width: 8),
                const Icon(
                  Icons.arrow_forward,
                  size: 18,
                  color: AppColors.surface,
                ),
              ],
            ),
          ),
        ),

        const SizedBox(height: 24),

        _buildLoginFooter(context),
      ],
    );
  }

  Widget _buildRoleOption({
    required BuildContext context,
    required UserRole role,
    required UserRole selectedRole,
    required String title,
    required String subtitle,
    required IconData icon,
    required Color iconBgColor,
    required Color iconColor,
  }) {
    final isSelected = role == selectedRole;

    return GestureDetector(
      onTap: () => context.read<RegisterCubit>().selectRole(role),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.primaryLight.withValues(alpha: 0.05)
              : AppColors.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.border,
            width: isSelected ? 1.6 : 1,
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: iconBgColor,
                borderRadius: BorderRadius.circular(6),
              ),
              child: Icon(icon, color: iconColor, size: 22),
            ),

            const SizedBox(width: 15),

            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          title,
                          style: const TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ),

                      if (isSelected)
                        Container(
                          padding: const EdgeInsets.all(2),
                          decoration: const BoxDecoration(
                            color: AppColors.primary,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.check,
                            size: 14,
                            color: AppColors.surface,
                          ),
                        ),
                    ],
                  ),

                  const SizedBox(height: 5),

                  Text(
                    subtitle,
                    style: const TextStyle(
                      fontSize: 14,
                      color: AppColors.textSecondary,
                      height: 1.28,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ==================== STEP 2: THÔNG TIN & OTP ====================

  Widget _buildStep2(BuildContext context, RegisterState state) {
    return Column(
      children: [
        _buildTextField(
          label: 'register.full_name'.tr(),
          isRequired: true,
          controller: _fullNameController,
          hintText: 'register.full_name_hint'.tr(),
          prefixIcon: Icons.person_outline,
          errorText: state.fullNameError,
        ),

        const SizedBox(height: 12),

        _buildTextField(
          label: 'register.email'.tr(),
          isRequired: true,
          controller: _emailController,
          keyboardType: TextInputType.emailAddress,
          hintText: 'register.email_hint'.tr(),
          prefixIcon: Icons.email_outlined,
          errorText: state.emailError,
        ),

        const SizedBox(height: 12),

        // Số điện thoại & Nút gửi OTP
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            RichText(
              text: TextSpan(
                text: '${'register.phone'.tr()} ',
                style: const TextStyle(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
                children: const [
                  TextSpan(
                    text: '*',
                    style: TextStyle(color: AppColors.error),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 6),

            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _phoneController,
                    keyboardType: TextInputType.phone,
                    decoration: InputDecoration(
                      hintText: 'register.phone_hint'.tr(),
                      hintStyle: const TextStyle(
                        color: AppColors.textHint,
                        fontSize: 13,
                      ),
                      prefixIcon: const Icon(
                        Icons.phone_outlined,
                        color: AppColors.textHint,
                        size: 18,
                      ),
                      fillColor: AppColors.surfaceMuted,
                      filled: true,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 12,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(6),
                        borderSide: BorderSide.none,
                      ),
                      errorText: state.phoneError,
                    ),
                  ),
                ),

                const SizedBox(width: 12),

                SizedBox(
                  height: 48,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryLight.withValues(
                        alpha: 0.15,
                      ),
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(6),
                      ),
                    ),
                    onPressed: state.otpStatus == OtpStatus.countingDown
                        ? null
                        : () {
                            context.read<RegisterCubit>().sendOtp(
                              _phoneController.text,
                            );
                          },
                    child: state.otpStatus == OtpStatus.sending
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: AppColors.primary,
                            ),
                          )
                        : Text(
                            state.otpStatus == OtpStatus.countingDown
                                ? '${state.countdown}s'
                                : 'register.send_otp'.tr(),
                            style: const TextStyle(
                              color: AppColors.primary,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                  ),
                ),
              ],
            ),
          ],
        ),

        const SizedBox(height: 12),

        // Mã OTP 6 chữ số
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: RichText(
                    text: TextSpan(
                      text: '${'register.otp_title'.tr()} ',
                      style: const TextStyle(
                        color: AppColors.textPrimary,
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                      children: const [
                        TextSpan(
                          text: '*',
                          style: TextStyle(color: AppColors.error),
                        ),
                      ],
                    ),
                  ),
                ),

                TextButton(
                  onPressed: () {
                    context.read<RegisterCubit>().sendOtp(
                      _phoneController.text,
                    );
                  },
                  child: Text(
                    'register.resend_otp'.tr(),
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ),
              ],
            ),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: List.generate(
                6,
                (index) => SizedBox(
                  width: 48,
                  height: 48,
                  child: TextField(
                    controller: _otpControllers[index],
                    focusNode: _otpFocusNodes[index],
                    textAlign: TextAlign.center,
                    keyboardType: TextInputType.number,
                    maxLength: 1,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                    decoration: InputDecoration(
                      counterText: '',
                      fillColor: AppColors.surfaceMuted,
                      filled: true,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(6),
                        borderSide: BorderSide.none,
                      ),
                    ),
                    onChanged: (value) {
                      if (value.isNotEmpty && index < 5) {
                        _otpFocusNodes[index + 1].requestFocus();
                      } else if (value.isEmpty && index > 0) {
                        _otpFocusNodes[index - 1].requestFocus();
                      }
                    },
                  ),
                ),
              ),
            ),

            if (state.otpError != null)
              Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: Text(
                  state.otpError!,
                  style: const TextStyle(color: AppColors.error, fontSize: 12),
                ),
              ),
          ],
        ),

        const SizedBox(height: 18),

        // Nút Tiếp tục
        SizedBox(
          width: double.infinity,
          height: 50,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(6),
              ),
            ),
            onPressed: state.isVerifying
                ? null
                : () {
                    context.read<RegisterCubit>().verifyOtp(
                      fullName: _fullNameController.text,
                      email: _emailController.text,
                      phoneNumber: _phoneController.text,
                      otp: _getOtpCode(),
                    );
                  },
            child: state.isVerifying
                ? const CircularProgressIndicator(color: AppColors.surface)
                : Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'common.continue'.tr(),
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: AppColors.surface,
                        ),
                      ),
                      const SizedBox(width: 8),
                      const Icon(
                        Icons.arrow_forward,
                        size: 18,
                        color: AppColors.surface,
                      ),
                    ],
                  ),
          ),
        ),

        const SizedBox(height: 10),
      ],
    );
  }

  // ==================== STEP 3: MẬT KHẨU & MÃ GIỚI THIỆU ====================

  Widget _buildStep3(BuildContext context, RegisterState state) {
    return Column(
      children: [
        Text(
          'register.title'.tr(),
          style: const TextStyle(
            fontSize: 18,
            color: AppColors.textPrimary,
            fontWeight: FontWeight.w800,
          ),
        ),

        const SizedBox(height: 18),

        // Mật khẩu
        _buildTextField(
          label: 'register.password'.tr(),
          isRequired: true,
          controller: _passwordController,
          obscureText: _obscurePassword,
          hintText: 'register.password_hint'.tr(),
          prefixIcon: Icons.lock_outline,
          suffixIcon: IconButton(
            icon: Icon(
              _obscurePassword
                  ? Icons.visibility_off_outlined
                  : Icons.visibility_outlined,
              color: AppColors.textHint,
            ),
            onPressed: () {
              setState(() {
                _obscurePassword = !_obscurePassword;
              });
            },
          ),
          errorText: state.passError,
        ),

        const SizedBox(height: 12),

        // Xác nhận mật khẩu
        _buildTextField(
          label: 'register.confirm_password'.tr(),
          isRequired: true,
          controller: _confirmPasswordController,
          obscureText: _obscureConfirmPassword,
          hintText: 'register.confirm_password_hint'.tr(),
          prefixIcon: Icons.lock_outline,
          suffixIcon: IconButton(
            icon: Icon(
              _obscureConfirmPassword
                  ? Icons.visibility_off_outlined
                  : Icons.visibility_outlined,
              color: AppColors.textHint,
            ),
            onPressed: () {
              setState(() {
                _obscureConfirmPassword = !_obscureConfirmPassword;
              });
            },
          ),
          errorText: state.confirmPassError,
        ),

        const SizedBox(height: 12),

        // Mã giới thiệu
        _buildTextField(
          label: 'register.referral_code'.tr(),
          isRequired: false,
          controller: _referralController,
          hintText: 'register.referral_hint'.tr(),
          prefixIcon: Icons.card_giftcard_outlined,
        ),

        const SizedBox(height: 20),

        // Nút Đăng ký ngay
        SizedBox(
          width: double.infinity,
          height: 50,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(6),
              ),
            ),
            onPressed: state.isSubmitting
                ? null
                : () {
                    context.read<RegisterCubit>().registerCustomer(
                      fullName: _fullNameController.text,
                      phoneNumber: _phoneController.text,
                      email: _emailController.text,
                      password: _passwordController.text,
                      confirmPassword: _confirmPasswordController.text,
                      referralCode: _referralController.text,
                    );
                  },
            child: state.isSubmitting
                ? const CircularProgressIndicator(color: AppColors.surface)
                : Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Flexible(
                        child: Text(
                          'register.submit'.tr(),
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: AppColors.surface,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      const Icon(
                        Icons.arrow_forward,
                        size: 18,
                        color: AppColors.surface,
                      ),
                    ],
                  ),
          ),
        ),

        const SizedBox(height: 24),
      ],
    );
  }

  // ==================== HELPER CUSTOM TEXTFIELD ====================

  Widget _buildTextField({
    required String label,
    required bool isRequired,
    required TextEditingController controller,
    String? hintText,
    IconData? prefixIcon,
    Widget? suffixIcon,
    bool obscureText = false,
    TextInputType? keyboardType,
    String? errorText,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        RichText(
          text: TextSpan(
            text: label,
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w600,
              fontSize: 15,
            ),
            children: isRequired
                ? const [
                    TextSpan(
                      text: ' *',
                      style: TextStyle(color: AppColors.error),
                    ),
                  ]
                : [],
          ),
        ),

        const SizedBox(height: 8),

        TextField(
          controller: controller,
          obscureText: obscureText,
          keyboardType: keyboardType,
          decoration: InputDecoration(
            isDense: true,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 12,
            ),
            hintText: hintText,
            hintStyle: const TextStyle(color: AppColors.textHint, fontSize: 12),
            prefixIcon: prefixIcon != null
                ? Icon(prefixIcon, color: AppColors.textHint, size: 18)
                : null,
            suffixIcon: suffixIcon,
            fillColor: AppColors.surfaceMuted,
            filled: true,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(6),
              borderSide: BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(6),
              borderSide: const BorderSide(
                color: AppColors.borderFocused,
                width: 1.5,
              ),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(6),
              borderSide: const BorderSide(color: AppColors.error),
            ),
            errorText: errorText,
          ),
        ),
      ],
    );
  }

  // ==================== SOCIAL LOGIN & FOOTER ====================

  Widget _buildSocialLoginAndFooter(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            const Expanded(child: Divider(color: AppColors.border)),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: Text(
                'register.social_register'.tr(),
                style: const TextStyle(
                  fontSize: 12,
                  color: AppColors.textSecondary,
                ),
              ),
            ),

            const Expanded(child: Divider(color: AppColors.border)),
          ],
        ),

        const SizedBox(height: 12),

        OutlinedButton(
          style: OutlinedButton.styleFrom(
            minimumSize: const Size(double.infinity, 38),
            side: const BorderSide(color: AppColors.border),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(6),
            ),
            backgroundColor: AppColors.surface,
          ),
          onPressed: () {},
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                'G',
                style: TextStyle(
                  fontSize: 19,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF4285F4),
                ),
              ),

              const SizedBox(width: 8),

              Text(
                'common.google'.tr(),
                style: const TextStyle(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 14),

        _buildLoginFooter(context),
      ],
    );
  }

  Widget _buildLoginFooter(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          '${'register.already_account'.tr()} ',
          style: const TextStyle(color: AppColors.textSecondary, fontSize: 11),
        ),

        GestureDetector(
          onTap: () {
            Navigator.pushReplacementNamed(context, '/login');
          },
          child: Text(
            'register.login_now'.tr(),
            style: const TextStyle(
              color: AppColors.primary,
              fontWeight: FontWeight.bold,
              fontSize: 11,
            ),
          ),
        ),
      ],
    );
  }
}
