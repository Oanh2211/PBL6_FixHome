import 'package:freezed_annotation/freezed_annotation.dart';

part 'register_request_model.freezed.dart';
part 'register_request_model.g.dart';

@freezed
abstract class RegisterRequestModel with _$RegisterRequestModel {
  const factory RegisterRequestModel({
    @JsonKey(name: 'full_name') required String fullName,
    @JsonKey(name: 'phone_number') required String phoneNumber,
    required String email,
    required String password,
    @JsonKey(name: 'registration_token') required String registrationToken,
    @JsonKey(name: 'referral_code', includeIfNull: false) String? referralCode,
  }) = _RegisterRequestModel;

  factory RegisterRequestModel.fromJson(Map<String, dynamic> json) =>
      _$RegisterRequestModelFromJson(json);
}
