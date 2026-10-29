import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';
import '../models/requests/send_otp_request_model.dart';
import '../models/requests/verify_otp_request_model.dart';
import '../models/requests/register_customer_request_model.dart';
import '../models/responses/verify_otp_response_model.dart';

part 'register_api.g.dart';

@RestApi(baseUrl: "https://fixhome-api-gateway.onrender.com/api/v1")
abstract class RegisterApi {
  factory RegisterApi(Dio dio, {String baseUrl}) = _RegisterApi;

  @POST("/auth/otp/send")
  Future<dynamic> sendOtp(@Body() SendOtpRequestModel body);

  @POST("/auth/otp/verify")
  Future<VerifyOtpResponseModel> verifyOtp(@Body() VerifyOtpRequestModel body);

  @POST("/auth/register/customer")
  Future<dynamic> registerCustomer(@Body() RegisterCustomerRequestModel body);
}
