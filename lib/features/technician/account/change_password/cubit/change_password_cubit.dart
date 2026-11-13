import 'package:bloc/bloc.dart';
import 'package:dio/dio.dart';
import 'package:fixhome/features/customer/account/change_password/model/change_password_request.dart';

import '../api/change_password_api.dart';
import 'change_password_state.dart';

class ChangePasswordCubit extends Cubit<ChangePasswordState> {
  final ChangePasswordApi _api;

  ChangePasswordCubit(this._api) : super(const ChangePasswordState());

  // Hiển thị / ẩn mật khẩu hiện tại
  void toggleCurrentPasswordVisibility() {
    emit(
      state.copyWith(isCurrentPasswordVisible: !state.isCurrentPasswordVisible),
    );
  }

  // Hiển thị / ẩn mật khẩu mới
  void toggleNewPasswordVisibility() {
    emit(state.copyWith(isNewPasswordVisible: !state.isNewPasswordVisible));
  }

  // Hiển thị / ẩn mật khẩu xác nhận
  void toggleConfirmPasswordVisibility() {
    emit(
      state.copyWith(isConfirmPasswordVisible: !state.isConfirmPasswordVisible),
    );
  }

  // Kiểm tra mật khẩu
  bool isValidPassword(String password) {
    final hasMinLength = password.length >= 8;
    final hasUppercase = RegExp(r'[A-Z]').hasMatch(password);
    final hasLowercase = RegExp(r'[a-z]').hasMatch(password);
    final hasNumber = RegExp(r'[0-9]').hasMatch(password);
    final hasSpecialCharacter = RegExp(
      r'''[^A-Za-z0-9\s]''',
    ).hasMatch(password);

    return hasMinLength &&
        hasUppercase &&
        hasLowercase &&
        hasNumber &&
        hasSpecialCharacter;
  }

  // Đổi mật khẩu
  Future<bool> changePassword({
    required String currentPassword,
    required String newPassword,
    required String confirmPassword,
  }) async {
    // Kiểm tra dữ liệu
    if (currentPassword.trim().isEmpty ||
        newPassword.isEmpty ||
        confirmPassword.isEmpty) {
      emit(
        state.copyWith(
          status: ChangePasswordStatus.failure,
          errorMessage: 'change_password.required_fields',
        ),
      );
      return false;
    }

    if (!isValidPassword(newPassword)) {
      emit(
        state.copyWith(
          status: ChangePasswordStatus.failure,
          errorMessage: 'change_password.invalid_password',
        ),
      );
      return false;
    }

    if (currentPassword == newPassword) {
      emit(
        state.copyWith(
          status: ChangePasswordStatus.failure,
          errorMessage: 'change_password.same_password',
        ),
      );
      return false;
    }

    if (newPassword != confirmPassword) {
      emit(
        state.copyWith(
          status: ChangePasswordStatus.failure,
          errorMessage: 'change_password.password_mismatch',
        ),
      );
      return false;
    }

    // Bắt đầu loading
    emit(
      state.copyWith(status: ChangePasswordStatus.loading, clearError: true),
    );

    try {
      final request = ChangePasswordRequest(
        currentPassword: currentPassword,
        newPassword: newPassword,
      );

      await _api.changePassword(request);

      emit(
        state.copyWith(status: ChangePasswordStatus.success, clearError: true),
      );

      return true;
    } on DioException catch (e) {
      final data = e.response?.data;

      String message = 'change_password.server_error';

      if (data is Map) {
        final serverMessage =
            data['message'] ?? data['detail'] ?? data['error'];

        if (serverMessage != null) {
          message = serverMessage.toString();
        }
      }

      emit(
        state.copyWith(
          status: ChangePasswordStatus.failure,
          errorMessage: message,
        ),
      );

      return false;
    } catch (_) {
      emit(
        state.copyWith(
          status: ChangePasswordStatus.failure,
          errorMessage: 'change_password.server_error',
        ),
      );

      return false;
    }
  }

  void resetStatus() {
    emit(
      state.copyWith(status: ChangePasswordStatus.initial, clearError: true),
    );
  }
}
