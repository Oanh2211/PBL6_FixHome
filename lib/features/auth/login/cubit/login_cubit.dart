import 'package:bloc/bloc.dart';
import 'package:dio/dio.dart';
import 'package:fixhome/features/auth/login/api/login_api.dart';
import 'package:fixhome/features/auth/login/models/login_request.dart';
import 'package:fixhome/features/auth/login/models/login_response.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'login_state.dart';
part 'login_cubit.freezed.dart';

class LoginCubit extends Cubit<LoginState> {
  LoginCubit() : super(LoginState.initial());

  void touchIconHiden() {
    emit(state.copyWith(touchHiden: !state.touchHiden));
  }

  void touchIconRemember() {
    emit(state.copyWith(touchRemember: !state.touchRemember));
  }

  final Dio dio = Dio();

  Future<void> login(String email, String password) async {
    emit(state.copyWith(isLoading: true, errorMessage: null));

    final LoginRequest request = LoginRequest(email: email, password: password);

    try {
      // Gọi API đăng nhập
      final LoginResponse response = await LoginApi(dio).login(request);

      final String accessToken = response.tokens.accessToken;
      final String userRole = response.account.role;
      final String userName = response.account.fullName;
      final String status = response.account.status;

      // TODO: Lưu accessToken vào SharedPreferences hoặc FlutterSecureStorage ở đây
      // await storage.write(key: 'access_token', value: accessToken);

      // 3. Đăng nhập thành công, cập nhật state kèm role hoặc cờ success
      emit(state.copyWith(isLoading: false, isSuccess: true, role: userRole));
    } on DioException catch (dioError) {
      final int? statusCode = dioError.response?.statusCode;
      String errorMsg = 'Đăng nhập thất bại, vui lòng thử lại';

      final serverData = dioError.response?.data;
      final String? serverMessage = serverData is Map
          ? serverData['message']
          : null;

      if (statusCode == 401) {
        errorMsg = serverMessage ?? 'Email hoặc mật khẩu không chính xác.';
      } else if (statusCode == 429) {
        errorMsg =
            serverMessage ??
            'Bạn đã gửi yêu cầu quá nhiều lần. Vui lòng chờ lát rồi thử lại!';
      } else if (statusCode == 500) {
        errorMsg = 'Lỗi hệ thống máy chủ, vui lòng thử lại sau.';
      } else {
        errorMsg = serverMessage ?? 'Lỗi kết nối mạng: ${dioError.message}';
      }

      emit(state.copyWith(isLoading: false, errorMessage: errorMsg));
    } catch (e) {
      emit(
        state.copyWith(
          isLoading: false,
          errorMessage: 'Lỗi không xác định: $e',
        ),
      );
    }
  }
}
