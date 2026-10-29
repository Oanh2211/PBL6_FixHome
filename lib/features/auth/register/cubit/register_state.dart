import 'package:freezed_annotation/freezed_annotation.dart';

part 'register_state.freezed.dart';

enum UserRole { customer, technician }

enum OtpStatus { initial, sending, countingDown, failure }

@freezed
abstract class RegisterState with _$RegisterState {
  const factory RegisterState({
    @Default(1)
    int
    currentStep, // Step 1: Chọn role, Step 2: Thông tin & OTP, Step 3: Mật khẩu & Mã giới thiệu
    @Default(UserRole.customer) UserRole role,
    @Default(OtpStatus.initial) OtpStatus otpStatus,
    @Default(60) int countdown,
    @Default(false) bool isVerifying,
    @Default(false) bool isSubmitting,
    @Default(false) bool isOtpVerified,
    String? registrationToken,
    String? fullNameError,
    String? emailError,
    String? phoneError,
    String? otpError,
    String? passError,
    String? confirmPassError,
    String? errorMessage,
    String? successMessage,
  }) = _RegisterState;
}
