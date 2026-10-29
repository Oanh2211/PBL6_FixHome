import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';

import 'package:fixhome/features/auth/forgot_password/model/request/forgot_password_request.dart';
import 'package:fixhome/features/auth/forgot_password/model/request/reset_password_request.dart';
import 'package:fixhome/features/auth/forgot_password/model/request/verify_otp_request.dart';
import 'package:fixhome/features/auth/forgot_password/model/response/verify_otp_response.dart';

part 'forgot_password_api.g.dart';

@RestApi(baseUrl: 'https://fixhome-api-gateway.onrender.com/api/v1')
abstract class ForgotPasswordApi {
  factory ForgotPasswordApi(Dio dio, {String? baseUrl}) = _ForgotPasswordApi;

  @POST('/auth/password/forgot')
  Future<dynamic> forgotPassword(@Body() ForgotPasswordRequest request);

  @POST('/auth/password/verify-otp')
  Future<VerifyOtpResponse> verifyOtp(@Body() VerifyOtpRequest request);

  @POST('/auth/password/reset')
  Future<dynamic> resetPassword(@Body() ResetPasswordRequest request);
}
