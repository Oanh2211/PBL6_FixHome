import 'package:freezed_annotation/freezed_annotation.dart';

part 'forgot_password_state.freezed.dart';

@freezed
abstract class ForgotPasswordState with _$ForgotPasswordState {
  const factory ForgotPasswordState({
    @Default(false) bool isLoading,
    @Default(false) bool isOtpVerified,
    @Default(false) bool isPasswordChanged,
    @Default(60) int remainingSeconds,
    @Default(true) bool obscurePassword,
    @Default(true) bool obscureConfirmPassword,
    String? errorMessage,
    String? successMessage,
  }) = _ForgotPasswordState;
}
