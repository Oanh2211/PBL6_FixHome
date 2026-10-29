// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'login_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_LoginResponse _$LoginResponseFromJson(Map<String, dynamic> json) =>
    _LoginResponse(
      tokens: Tokens.fromJson(json['tokens'] as Map<String, dynamic>),
      account: Account.fromJson(json['account'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$LoginResponseToJson(_LoginResponse instance) =>
    <String, dynamic>{'tokens': instance.tokens, 'account': instance.account};

_Tokens _$TokensFromJson(Map<String, dynamic> json) => _Tokens(
  accessToken: json['access_token'] as String,
  refreshToken: json['refresh_token'] as String,
  tokenType: json['token_type'] as String,
  expiresIn: (json['expires_in'] as num).toInt(),
);

Map<String, dynamic> _$TokensToJson(_Tokens instance) => <String, dynamic>{
  'access_token': instance.accessToken,
  'refresh_token': instance.refreshToken,
  'token_type': instance.tokenType,
  'expires_in': instance.expiresIn,
};

_Account _$AccountFromJson(Map<String, dynamic> json) => _Account(
  id: (json['id'] as num).toInt(),
  role: json['role'] as String,
  status: json['status'] as String,
  fullName: json['full_name'] as String,
  email: json['email'] as String,
  phoneNumber: json['phone_number'] as String,
  phoneVerifiedAt: json['phone_verified_at'] == null
      ? null
      : DateTime.parse(json['phone_verified_at'] as String),
  createdAt: json['created_at'] == null
      ? null
      : DateTime.parse(json['created_at'] as String),
);

Map<String, dynamic> _$AccountToJson(_Account instance) => <String, dynamic>{
  'id': instance.id,
  'role': instance.role,
  'status': instance.status,
  'full_name': instance.fullName,
  'email': instance.email,
  'phone_number': instance.phoneNumber,
  'phone_verified_at': instance.phoneVerifiedAt?.toIso8601String(),
  'created_at': instance.createdAt?.toIso8601String(),
};
