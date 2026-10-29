// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'send_otp_request_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_SendOtpRequestModel _$SendOtpRequestModelFromJson(Map<String, dynamic> json) =>
    _SendOtpRequestModel(
      role: json['role'] as String? ?? 'CUSTOMER',
      phoneNumber: json['phone_number'] as String,
    );

Map<String, dynamic> _$SendOtpRequestModelToJson(
  _SendOtpRequestModel instance,
) => <String, dynamic>{
  'role': instance.role,
  'phone_number': instance.phoneNumber,
};
