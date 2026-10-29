import 'package:dio/dio.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../api/forgot_password_api.dart';
import '../model/request/forgot_password_request.dart';
import '../model/request/verify_otp_request.dart';
import '../model/request/reset_password_request.dart';
import 'forgot_password_state.dart';

class ForgotPasswordCubit extends Cubit<ForgotPasswordState> {
  final ForgotPasswordApi _api;

  String? _resetToken;

  ForgotPasswordCubit(this._api) : super(const ForgotPasswordState());

  // Bước 1: Gửi OTP về email.
  Future<void> sendForgotPasswordOtp(String email) async {
    final normalizedEmail = email.trim();

    if (normalizedEmail.isEmpty ||
        !RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(normalizedEmail)) {
      emit(
        state.copyWith(
          errorMessage: 'forgot.invalid_email',
          successMessage: null,
        ),
      );
      return;
    }

    emit(
      state.copyWith(isLoading: true, errorMessage: null, successMessage: null),
    );

    try {
      await _api.forgotPassword(ForgotPasswordRequest(email: normalizedEmail));

      emit(state.copyWith(isLoading: false, successMessage: 'forgot.otp_sent'));
    } on DioException catch (e) {
      emit(state.copyWith(isLoading: false, errorMessage: _getErrorKey(e)));
    } catch (_) {
      emit(
        state.copyWith(isLoading: false, errorMessage: 'forgot.request_failed'),
      );
    }
  }

  // Bước 2: Xác thực OTP và lưu reset_token.
  Future<bool> verifyOtp({required String email, required String otp}) async {
    final normalizedEmail = email.trim();
    final normalizedOtp = otp.trim();

    if (normalizedEmail.isEmpty ||
        !RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(normalizedEmail)) {
      emit(
        state.copyWith(
          errorMessage: 'forgot.invalid_email',
          successMessage: null,
        ),
      );
      return false;
    }

    if (!RegExp(r'^\d{6}$').hasMatch(normalizedOtp)) {
      emit(
        state.copyWith(
          errorMessage: 'forgot.invalid_otp',
          successMessage: null,
        ),
      );
      return false;
    }

    emit(
      state.copyWith(isLoading: true, errorMessage: null, successMessage: null),
    );

    try {
      final response = await _api.verifyOtp(
        VerifyOtpRequest(email: normalizedEmail, otp: normalizedOtp),
      );

      _resetToken = response.resetToken;

      emit(
        state.copyWith(
          isLoading: false,
          isOtpVerified: true,
          errorMessage: null,
          successMessage: 'forgot.otp_verified',
        ),
      );

      return true;
    } on DioException catch (e) {
      emit(
        state.copyWith(
          isLoading: false,
          isOtpVerified: false,
          errorMessage: _getErrorKey(e),
        ),
      );
      return false;
    } catch (_) {
      emit(
        state.copyWith(
          isLoading: false,
          isOtpVerified: false,
          errorMessage: 'forgot.verify_failed',
        ),
      );
      return false;
    }
  }

  // Bước 3: Đổi mật khẩu bằng reset_token.
  Future<bool> resetPassword({
    required String newPassword,
    required String confirmPassword,
  }) async {
    final password = newPassword;
    final confirmation = confirmPassword;

    if (!_isPasswordValid(password)) {
      emit(
        state.copyWith(
          errorMessage: 'forgot.password_invalid',
          successMessage: null,
        ),
      );
      return false;
    }

    if (confirmation.isEmpty || password != confirmation) {
      emit(
        state.copyWith(
          errorMessage: 'forgot.password_not_match',
          successMessage: null,
        ),
      );
      return false;
    }

    if (_resetToken == null || _resetToken!.isEmpty) {
      emit(
        state.copyWith(
          errorMessage: 'forgot.missing_reset_token',
          successMessage: null,
        ),
      );
      return false;
    }

    emit(
      state.copyWith(isLoading: true, errorMessage: null, successMessage: null),
    );

    try {
      await _api.resetPassword(
        ResetPasswordRequest(reset_token: _resetToken!, new_password: password),
      );

      emit(
        state.copyWith(
          isLoading: false,
          isPasswordChanged: true,
          successMessage: 'forgot.reset_success',
        ),
      );

      return true;
    } on DioException catch (e) {
      emit(state.copyWith(isLoading: false, errorMessage: _getErrorKey(e)));
      return false;
    } catch (_) {
      emit(
        state.copyWith(isLoading: false, errorMessage: 'forgot.reset_failed'),
      );
      return false;
    }
  }

  bool _isPasswordValid(String password) {
    return password.length >= 8 &&
        RegExp(r'[A-Z]').hasMatch(password) &&
        RegExp(r'[a-z]').hasMatch(password) &&
        RegExp(r'[0-9]').hasMatch(password) &&
        RegExp(r"""[^A-Za-z0-9\s]""").hasMatch(password);
  }

  String _getErrorKey(DioException e) {
    if (e.type == DioExceptionType.connectionTimeout ||
        e.type == DioExceptionType.sendTimeout ||
        e.type == DioExceptionType.receiveTimeout) {
      return 'forgot.network_timeout';
    }

    switch (e.response?.statusCode) {
      case 400:
        return 'forgot.invalid_request';
      case 401:
      case 403:
        return 'forgot.otp_expired';
      case 404:
        return 'forgot.endpoint_not_found';
      case 429:
        return 'forgot.too_many_requests';
      default:
        if ((e.response?.statusCode ?? 0) >= 500) {
          return 'forgot.server_error';
        }
        return 'forgot.request_failed';
    }
  }

  void togglePasswordVisibility() {
    emit(state.copyWith(obscurePassword: !state.obscurePassword));
  }

  void toggleConfirmPasswordVisibility() {
    emit(state.copyWith(obscureConfirmPassword: !state.obscureConfirmPassword));
  }
}
