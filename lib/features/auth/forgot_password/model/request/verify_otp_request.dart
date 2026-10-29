import 'package:freezed_annotation/freezed_annotation.dart';
part 'verify_otp_request.freezed.dart';
part 'verify_otp_request.g.dart';

@freezed
abstract class VerifyOtpRequest with _$VerifyOtpRequest {
  const factory VerifyOtpRequest({required String email, required String otp}) =
      _VerifyOtpRequest;

  factory VerifyOtpRequest.fromJson(dynamic json) =>
      _$VerifyOtpRequestFromJson(json);
}
