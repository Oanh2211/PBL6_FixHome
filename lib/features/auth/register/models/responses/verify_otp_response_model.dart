import 'package:freezed_annotation/freezed_annotation.dart';

part 'verify_otp_response_model.freezed.dart';
part 'verify_otp_response_model.g.dart';

@freezed
abstract class VerifyOtpResponseModel with _$VerifyOtpResponseModel {
  const factory VerifyOtpResponseModel({
    @JsonKey(name: 'registration_token') required String registrationToken,
    @JsonKey(name: 'expires_in') @Default(0) int expiresIn,
  }) = _VerifyOtpResponseModel;

  factory VerifyOtpResponseModel.fromJson(Map<String, dynamic> json) =>
      _$VerifyOtpResponseModelFromJson(json);
}
