import 'package:freezed_annotation/freezed_annotation.dart';

part 'send_otp_request_model.freezed.dart';
part 'send_otp_request_model.g.dart';

@freezed
abstract class SendOtpRequestModel with _$SendOtpRequestModel {
  const factory SendOtpRequestModel({
    @Default('CUSTOMER') String role,
    @JsonKey(name: 'phone_number') required String phoneNumber,
  }) = _SendOtpRequestModel;

  factory SendOtpRequestModel.fromJson(Map<String, dynamic> json) =>
      _$SendOtpRequestModelFromJson(json);
}
