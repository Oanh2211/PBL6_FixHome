import 'dart:async';
import 'package:dio/dio.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'register_state.dart';
import '../api/register_api.dart';
import '../models/requests/send_otp_request_model.dart';
import '../models/requests/verify_otp_request_model.dart';
import '../models/requests/register_customer_request_model.dart';

class RegisterCubit extends Cubit<RegisterState> {
  final RegisterApi _registerApi;
  Timer? _timer;

  RegisterCubit(this._registerApi) : super(const RegisterState());

  void selectRole(UserRole role) {
    emit(state.copyWith(role: role));
  }

  void nextStep() {
    if (state.currentStep < 3) {
      emit(state.copyWith(currentStep: state.currentStep + 1));
    }
  }

  void previousStep() {
    if (state.currentStep > 1) {
      emit(state.copyWith(currentStep: state.currentStep - 1));
    }
  }

  Future<void> sendOtp(String phoneNumber) async {
    final phone = phoneNumber.trim();

    if (phone.isEmpty) {
      emit(
        state.copyWith(
          phoneError: 'Vui lòng nhập số điện thoại',
          otpStatus: OtpStatus.initial,
        ),
      );
      return;
    }

    // Ngăn gửi nhiều request cùng lúc.
    if (state.otpStatus == OtpStatus.sending ||
        state.otpStatus == OtpStatus.countingDown) {
      return;
    }

    emit(
      state.copyWith(
        otpStatus: OtpStatus.sending,
        phoneError: null,
        errorMessage: null,
      ),
    );

    try {
      final roleStr = state.role == UserRole.customer
          ? 'CUSTOMER'
          : 'TECHNICIAN';

      final request = SendOtpRequestModel(role: roleStr, phoneNumber: phone);

      // In thông tin request để kiểm tra trong Debug Console.
      print('========== SEND OTP ==========');
      print('URL: /auth/otp/send');
      print('Phone: $phone');
      print('Role: $roleStr');

      final response = await _registerApi.sendOtp(request);

      print('OTP RESPONSE: $response');

      emit(
        state.copyWith(
          otpStatus: OtpStatus.countingDown,
          countdown: 60,
          errorMessage: null,
        ),
      );

      _startTimer();
    } on DioException catch (e) {
      print('========== OTP API ERROR ==========');
      print('Error type: ${e.type}');
      print('Error message: ${e.message}');
      print('HTTP status: ${e.response?.statusCode}');
      print('Response data: ${e.response?.data}');

      emit(
        state.copyWith(
          otpStatus: OtpStatus.failure,
          errorMessage: _getOtpErrorMessage(e),
        ),
      );
    } catch (e, stackTrace) {
      print('========== OTP UNKNOWN ERROR ==========');
      print(e);
      print(stackTrace);

      emit(
        state.copyWith(
          otpStatus: OtpStatus.failure,
          errorMessage: 'Đã xảy ra lỗi khi gửi OTP. Vui lòng thử lại.',
        ),
      );
    }
  }

  String _getOtpErrorMessage(DioException e) {
    if (e.type == DioExceptionType.connectionTimeout ||
        e.type == DioExceptionType.sendTimeout ||
        e.type == DioExceptionType.receiveTimeout) {
      return 'Máy chủ phản hồi quá lâu. Vui lòng thử lại.';
    }

    if (e.response?.statusCode == 400) {
      return 'Thông tin gửi lên không hợp lệ. Vui lòng kiểm tra số điện thoại.';
    }

    if (e.response?.statusCode == 429) {
      return 'Bạn đã gửi OTP quá nhiều lần. Vui lòng thử lại sau.';
    }

    if (e.response != null) {
      return 'Gửi OTP thất bại (HTTP ${e.response?.statusCode}).';
    }

    return 'Không thể kết nối máy chủ. Vui lòng kiểm tra mạng.';
  }

  void _startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (state.countdown == 0) {
        timer.cancel();
        emit(state.copyWith(otpStatus: OtpStatus.initial));
      } else {
        emit(state.copyWith(countdown: state.countdown - 1));
      }
    });
  }

  Future<void> verifyOtp({
    required String fullName,
    required String email,
    required String phoneNumber,
    required String otp,
  }) async {
    bool hasError = false;
    String? fullNameErr;
    String? emailErr;
    String? phoneErr;
    String? otpErr;

    if (fullName.trim().isEmpty) {
      fullNameErr = 'Vui lòng nhập họ và tên';
      hasError = true;
    }
    if (email.trim().isEmpty || !email.contains('@')) {
      emailErr = 'Email không hợp lệ';
      hasError = true;
    }
    if (phoneNumber.trim().isEmpty) {
      phoneErr = 'Vui lòng nhập số điện thoại';
      hasError = true;
    }
    if (otp.trim().length < 6) {
      otpErr = 'Mã OTP gồm 6 chữ số';
      hasError = true;
    }

    if (hasError) {
      emit(
        state.copyWith(
          fullNameError: fullNameErr,
          emailError: emailErr,
          phoneError: phoneErr,
          otpError: otpErr,
        ),
      );
      return;
    }

    emit(state.copyWith(isVerifying: true, errorMessage: null));

    try {
      final roleStr = state.role == UserRole.customer
          ? 'CUSTOMER'
          : 'TECHNICIAN';
      final response = await _registerApi.verifyOtp(
        VerifyOtpRequestModel(
          role: roleStr,
          phoneNumber: phoneNumber,
          otp: otp,
        ),
      );

      emit(
        state.copyWith(
          isVerifying: false,
          isOtpVerified: true,
          registrationToken: response.registrationToken,
          currentStep: 3, // Chuyển sang Step 3 sau khi xác thực OTP thành công
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          isVerifying: false,
          errorMessage: 'Mã OTP không chính xác hoặc đã hết hạn',
        ),
      );
    }
  }

  Future<void> registerCustomer({
    required String fullName,
    required String phoneNumber,
    required String email,
    required String password,
    required String confirmPassword,
    String? referralCode,
  }) async {
    String? passErr;
    String? confirmPassErr;

    if (password.length < 8) {
      passErr = 'Mật khẩu phải tối thiểu 8 ký tự';
    }
    if (password != confirmPassword) {
      confirmPassErr = 'Mật khẩu xác nhận không khớp';
    }

    if (passErr != null || confirmPassErr != null) {
      emit(
        state.copyWith(passError: passErr, confirmPassError: confirmPassErr),
      );
      return;
    }

    if (state.registrationToken == null) {
      emit(
        state.copyWith(
          errorMessage: 'Thiếu mã xác thực token. Vui lòng thử lại.',
        ),
      );
      return;
    }

    emit(state.copyWith(isSubmitting: true, errorMessage: null));

    try {
      await _registerApi.registerCustomer(
        RegisterCustomerRequestModel(
          fullName: fullName,
          phoneNumber: phoneNumber,
          email: email,
          password: password,
          registrationToken: state.registrationToken!,
          referralCode: referralCode?.isEmpty == true ? null : referralCode,
        ),
      );

      emit(
        state.copyWith(
          isSubmitting: false,
          successMessage: 'Đăng ký tài khoản thành công!',
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          isSubmitting: false,
          errorMessage: 'Đăng ký thất bại. Vui lòng thử lại.',
        ),
      );
    }
  }

  @override
  Future<void> close() {
    _timer?.cancel();
    return super.close();
  }
}
