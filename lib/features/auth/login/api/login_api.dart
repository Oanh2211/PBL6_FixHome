import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';
import 'package:fixhome/features/auth/login/models/login_request.dart';
import 'package:fixhome/features/auth/login/models/login_response.dart';

part 'login_api.g.dart';

@RestApi(baseUrl: "https://fixhome-api-gateway.onrender.com/api/v1")
abstract class LoginApi {
  factory LoginApi(Dio dio, {String baseUrl}) = _LoginApi;

  @POST('/auth/login')
  Future<LoginResponse> login(@Body() LoginRequest request);
}
