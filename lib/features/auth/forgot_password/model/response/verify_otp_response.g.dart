// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'verify_otp_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_VerifyOtpResponse _$VerifyOtpResponseFromJson(Map<String, dynamic> json) =>
    _VerifyOtpResponse(
      resetToken: json['reset_token'] as String,
      expiresIn: (json['expires_in'] as num).toInt(),
    );

Map<String, dynamic> _$VerifyOtpResponseToJson(_VerifyOtpResponse instance) =>
    <String, dynamic>{
      'reset_token': instance.resetToken,
      'expires_in': instance.expiresIn,
    };
