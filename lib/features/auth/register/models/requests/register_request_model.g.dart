// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'register_request_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_RegisterRequestModel _$RegisterRequestModelFromJson(
  Map<String, dynamic> json,
) => _RegisterRequestModel(
  fullName: json['full_name'] as String,
  phoneNumber: json['phone_number'] as String,
  email: json['email'] as String,
  password: json['password'] as String,
  registrationToken: json['registration_token'] as String,
  referralCode: json['referral_code'] as String?,
);

Map<String, dynamic> _$RegisterRequestModelToJson(
  _RegisterRequestModel instance,
) => <String, dynamic>{
  'full_name': instance.fullName,
  'phone_number': instance.phoneNumber,
  'email': instance.email,
  'password': instance.password,
  'registration_token': instance.registrationToken,
  'referral_code': ?instance.referralCode,
};
