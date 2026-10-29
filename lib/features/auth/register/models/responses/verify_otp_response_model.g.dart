// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'verify_otp_response_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_VerifyOtpResponseModel _$VerifyOtpResponseModelFromJson(
  Map<String, dynamic> json,
) => _VerifyOtpResponseModel(
  registrationToken: json['registration_token'] as String,
  expiresIn: (json['expires_in'] as num?)?.toInt() ?? 0,
);

Map<String, dynamic> _$VerifyOtpResponseModelToJson(
  _VerifyOtpResponseModel instance,
) => <String, dynamic>{
  'registration_token': instance.registrationToken,
  'expires_in': instance.expiresIn,
};
