import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';
import 'package:fixhome/features/auth/login/models/login_request.dart';
import 'package:fixhome/features/auth/login/models/login_response.dart';

part 'login_api.g.dart';

@RestApi()
abstract class LoginApi {
  factory LoginApi(Dio dio, {String? baseUrl, ParseErrorLogger? errorLogger}) =
      _LoginApi;

  @POST('/auth/login')
  @Extra({'skipAuth': true})
  Future<LoginResponse> login(@Body() LoginRequest request);
}
