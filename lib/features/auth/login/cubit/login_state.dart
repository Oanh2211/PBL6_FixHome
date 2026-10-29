part of 'login_cubit.dart';

@freezed
abstract class LoginState with _$LoginState {
  const factory LoginState.initial({
    @Default('') String errorEmail,
    @Default('') String errorPassword,
    @Default(false) bool isLoading,
    @Default(false) bool isSuccess,
    @Default('') String role,
    @Default(false) bool touchHiden,
    @Default(false) bool touchRemember,
    String? errorMessage,
  }) = _Initial;
}
