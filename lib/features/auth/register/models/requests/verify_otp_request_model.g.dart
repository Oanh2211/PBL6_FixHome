// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'verify_otp_request_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_VerifyOtpRequestModel _$VerifyOtpRequestModelFromJson(
  Map<String, dynamic> json,
) => _VerifyOtpRequestModel(
  role: json['role'] as String? ?? 'CUSTOMER',
  phoneNumber: json['phone_number'] as String,
  otp: json['otp'] as String,
);

Map<String, dynamic> _$VerifyOtpRequestModelToJson(
  _VerifyOtpRequestModel instance,
) => <String, dynamic>{
  'role': instance.role,
  'phone_number': instance.phoneNumber,
  'otp': instance.otp,
};
