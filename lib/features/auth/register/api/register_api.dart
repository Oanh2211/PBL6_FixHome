import 'package:dio/dio.dart';
import 'package:fixhome/features/auth/register/models/responses/register_response_model.dart';
import 'package:retrofit/retrofit.dart';

import '../models/requests/send_otp_request_model.dart';
import '../models/requests/verify_otp_request_model.dart';
import '../models/requests/register_request_model.dart';
import '../models/responses/verify_otp_response_model.dart';

part 'register_api.g.dart';

@RestApi()
abstract class RegisterApi {
  factory RegisterApi(
    Dio dio, {
    String? baseUrl,
    ParseErrorLogger? errorLogger,
  }) = _RegisterApi;

  @POST('/auth/otp/send')
  @Extra({'skipAuth': true})
  Future<dynamic> sendOtp(@Body() SendOtpRequestModel body);

  @POST('/auth/otp/verify')
  @Extra({'skipAuth': true})
  Future<VerifyOtpResponseModel> verifyOtp(@Body() VerifyOtpRequestModel body);

  @POST('/auth/register/customer')
  @Extra({'skipAuth': true})
  Future<RegisterResponse> registerCustomer(@Body() RegisterRequestModel body);

  @POST('/auth/register/technician')
  @Extra({'skipAuth': true})
  Future<RegisterResponse> registerTechnician(
    @Body() RegisterRequestModel body,
  );
}
