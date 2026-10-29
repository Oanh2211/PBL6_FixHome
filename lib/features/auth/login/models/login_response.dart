import 'package:freezed_annotation/freezed_annotation.dart';

part 'login_response.freezed.dart';
part 'login_response.g.dart';

@freezed
abstract class LoginResponse with _$LoginResponse {
  const factory LoginResponse({
    required Tokens tokens,
    required Account account,
  }) = _LoginResponse;

  factory LoginResponse.fromJson(Map<String, dynamic> json) =>
      _$LoginResponseFromJson(json);
}

@freezed
abstract class Tokens with _$Tokens {
  const factory Tokens({
    @JsonKey(name: 'access_token') required String accessToken,
    @JsonKey(name: 'refresh_token') required String refreshToken,
    @JsonKey(name: 'token_type') required String tokenType,
    @JsonKey(name: 'expires_in') required int expiresIn,
  }) = _Tokens;

  factory Tokens.fromJson(Map<String, dynamic> json) => _$TokensFromJson(json);
}

@freezed
abstract class Account with _$Account {
  const factory Account({
    required int id,
    required String role,
    required String status,
    @JsonKey(name: 'full_name') required String fullName,
    required String email,
    @JsonKey(name: 'phone_number') required String phoneNumber,
    @JsonKey(name: 'phone_verified_at') DateTime? phoneVerifiedAt,
    @JsonKey(name: 'created_at') DateTime? createdAt,
  }) = _Account;

  factory Account.fromJson(Map<String, dynamic> json) =>
      _$AccountFromJson(json);
}
