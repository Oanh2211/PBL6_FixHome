import 'package:freezed_annotation/freezed_annotation.dart';

part 'verify_otp_request_model.freezed.dart';
part 'verify_otp_request_model.g.dart';

@freezed
abstract class VerifyOtpRequestModel with _$VerifyOtpRequestModel {
  const factory VerifyOtpRequestModel({
    @Default('CUSTOMER') String role,
    @JsonKey(name: 'phone_number') required String phoneNumber,
    required String otp,
  }) = _VerifyOtpRequestModel;

  factory VerifyOtpRequestModel.fromJson(Map<String, dynamic> json) =>
      _$VerifyOtpRequestModelFromJson(json);
}
