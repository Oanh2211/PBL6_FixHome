import 'package:bloc/bloc.dart';
import 'package:dio/dio.dart';
import 'package:fixhome/core/storage/storage.dart';
import 'package:fixhome/features/auth/login/api/login_api.dart';
import 'package:fixhome/features/auth/login/models/login_request.dart';
import 'package:fixhome/features/auth/login/models/login_response.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'login_state.dart';
part 'login_cubit.freezed.dart';

class LoginCubit extends Cubit<LoginState> {
  final LoginApi _api;

  LoginCubit(this._api) : super(LoginState.initial());

  void touchIconHiden() {
    emit(state.copyWith(touchHiden: !state.touchHiden));
  }

  void touchIconRemember() {
    emit(state.copyWith(touchRemember: !state.touchRemember));
  }

  Future<void> login(String email, String password) async {
    emit(state.copyWith(isLoading: true, errorMessage: null));

    final LoginRequest request = LoginRequest(email: email, password: password);

    try {
      // Gọi API đăng nhập
      final LoginResponse response = await _api.login(request);

      final String userRole = response.account.role;
      final String status = response.account.status;

      final String accessToken = response.tokens.accessToken;
      final String refreshToken = response.tokens.refreshToken;

      if (status != 'UNVERIFIED') {
        // Lưu token khi tài khoản hợp lệ
        await Storage.saveTokens(accessToken, refreshToken);

        emit(state.copyWith(isLoading: false, isSuccess: true, role: userRole));
      } else {
        emit(
          state.copyWith(
            isLoading: false,
            isSuccess: false,
            role: userRole,
            errorMessage: 'Tài khoản bị khoá do vi phạm hệ thống!',
          ),
        );
      }
    } on DioException catch (dioError) {
      String errorMsg = 'Đăng nhập thất bại, vui lòng thử lại';

      switch (dioError.type) {
        case DioExceptionType.connectionTimeout:
          errorMsg = 'Kết nối đến máy chủ quá thời gian chờ.';

        case DioExceptionType.sendTimeout:
          errorMsg = 'Gửi yêu cầu thất bại. Vui lòng thử lại.';

        case DioExceptionType.receiveTimeout:
          errorMsg = 'Máy chủ phản hồi quá lâu. Vui lòng thử lại.';

        case DioExceptionType.connectionError:
          errorMsg =
              'Không thể kết nối đến máy chủ. Vui lòng kiểm tra kết nối Internet.';

        case DioExceptionType.badResponse:
          final statusCode = dioError.response?.statusCode;
          final serverData = dioError.response?.data;

          final String? serverMessage = serverData is Map
              ? serverData['message']?.toString()
              : null;

          if (statusCode == 401) {
            errorMsg = serverMessage ?? 'Email hoặc mật khẩu không chính xác.';
          } else if (statusCode == 429) {
            errorMsg =
                serverMessage ??
                'Bạn đã gửi yêu cầu quá nhiều lần. Vui lòng thử lại sau!';
          } else if (statusCode == 500) {
            errorMsg = 'Lỗi hệ thống máy chủ, vui lòng thử lại sau.';
          } else {
            errorMsg = serverMessage ?? 'Đã xảy ra lỗi. Vui lòng thử lại.';
          }

        case DioExceptionType.cancel:
          errorMsg = 'Yêu cầu đăng nhập đã bị hủy.';

        case DioExceptionType.badCertificate:
          errorMsg = 'Chứng chỉ bảo mật máy chủ không hợp lệ.';

        case DioExceptionType.unknown:
          errorMsg = 'Đã xảy ra lỗi kết nối. Vui lòng thử lại.';
        case DioExceptionType.transformTimeout:
          // TODO: Handle this case.
          throw UnimplementedError();
      }

      emit(
        state.copyWith(
          isLoading: false,
          isSuccess: false,
          errorMessage: errorMsg,
        ),
      );
    }
  }
}
