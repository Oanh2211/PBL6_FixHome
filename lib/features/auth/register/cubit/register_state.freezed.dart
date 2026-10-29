// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'register_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$RegisterState {

 int get currentStep;// Step 1: Chọn role, Step 2: Thông tin & OTP, Step 3: Mật khẩu & Mã giới thiệu
 UserRole get role; OtpStatus get otpStatus; int get countdown; bool get isVerifying; bool get isSubmitting; bool get isOtpVerified; String? get registrationToken; String? get fullNameError; String? get emailError; String? get phoneError; String? get otpError; String? get passError; String? get confirmPassError; String? get errorMessage; String? get successMessage;
/// Create a copy of RegisterState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$RegisterStateCopyWith<RegisterState> get copyWith => _$RegisterStateCopyWithImpl<RegisterState>(this as RegisterState, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is RegisterState&&(identical(other.currentStep, currentStep) || other.currentStep == currentStep)&&(identical(other.role, role) || other.role == role)&&(identical(other.otpStatus, otpStatus) || other.otpStatus == otpStatus)&&(identical(other.countdown, countdown) || other.countdown == countdown)&&(identical(other.isVerifying, isVerifying) || other.isVerifying == isVerifying)&&(identical(other.isSubmitting, isSubmitting) || other.isSubmitting == isSubmitting)&&(identical(other.isOtpVerified, isOtpVerified) || other.isOtpVerified == isOtpVerified)&&(identical(other.registrationToken, registrationToken) || other.registrationToken == registrationToken)&&(identical(other.fullNameError, fullNameError) || other.fullNameError == fullNameError)&&(identical(other.emailError, emailError) || other.emailError == emailError)&&(identical(other.phoneError, phoneError) || other.phoneError == phoneError)&&(identical(other.otpError, otpError) || other.otpError == otpError)&&(identical(other.passError, passError) || other.passError == passError)&&(identical(other.confirmPassError, confirmPassError) || other.confirmPassError == confirmPassError)&&(identical(other.errorMessage, errorMessage) || other.errorMessage == errorMessage)&&(identical(other.successMessage, successMessage) || other.successMessage == successMessage));
}


@override
int get hashCode => Object.hash(runtimeType,currentStep,role,otpStatus,countdown,isVerifying,isSubmitting,isOtpVerified,registrationToken,fullNameError,emailError,phoneError,otpError,passError,confirmPassError,errorMessage,successMessage);

@override
String toString() {
  return 'RegisterState(currentStep: $currentStep, role: $role, otpStatus: $otpStatus, countdown: $countdown, isVerifying: $isVerifying, isSubmitting: $isSubmitting, isOtpVerified: $isOtpVerified, registrationToken: $registrationToken, fullNameError: $fullNameError, emailError: $emailError, phoneError: $phoneError, otpError: $otpError, passError: $passError, confirmPassError: $confirmPassError, errorMessage: $errorMessage, successMessage: $successMessage)';
}


}

/// @nodoc
abstract mixin class $RegisterStateCopyWith<$Res>  {
  factory $RegisterStateCopyWith(RegisterState value, $Res Function(RegisterState) _then) = _$RegisterStateCopyWithImpl;
@useResult
$Res call({
 int currentStep, UserRole role, OtpStatus otpStatus, int countdown, bool isVerifying, bool isSubmitting, bool isOtpVerified, String? registrationToken, String? fullNameError, String? emailError, String? phoneError, String? otpError, String? passError, String? confirmPassError, String? errorMessage, String? successMessage
});




}
/// @nodoc
class _$RegisterStateCopyWithImpl<$Res>
    implements $RegisterStateCopyWith<$Res> {
  _$RegisterStateCopyWithImpl(this._self, this._then);

  final RegisterState _self;
  final $Res Function(RegisterState) _then;

/// Create a copy of RegisterState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? currentStep = null,Object? role = null,Object? otpStatus = null,Object? countdown = null,Object? isVerifying = null,Object? isSubmitting = null,Object? isOtpVerified = null,Object? registrationToken = freezed,Object? fullNameError = freezed,Object? emailError = freezed,Object? phoneError = freezed,Object? otpError = freezed,Object? passError = freezed,Object? confirmPassError = freezed,Object? errorMessage = freezed,Object? successMessage = freezed,}) {
  return _then(_self.copyWith(
currentStep: null == currentStep ? _self.currentStep : currentStep // ignore: cast_nullable_to_non_nullable
as int,role: null == role ? _self.role : role // ignore: cast_nullable_to_non_nullable
as UserRole,otpStatus: null == otpStatus ? _self.otpStatus : otpStatus // ignore: cast_nullable_to_non_nullable
as OtpStatus,countdown: null == countdown ? _self.countdown : countdown // ignore: cast_nullable_to_non_nullable
as int,isVerifying: null == isVerifying ? _self.isVerifying : isVerifying // ignore: cast_nullable_to_non_nullable
as bool,isSubmitting: null == isSubmitting ? _self.isSubmitting : isSubmitting // ignore: cast_nullable_to_non_nullable
as bool,isOtpVerified: null == isOtpVerified ? _self.isOtpVerified : isOtpVerified // ignore: cast_nullable_to_non_nullable
as bool,registrationToken: freezed == registrationToken ? _self.registrationToken : registrationToken // ignore: cast_nullable_to_non_nullable
as String?,fullNameError: freezed == fullNameError ? _self.fullNameError : fullNameError // ignore: cast_nullable_to_non_nullable
as String?,emailError: freezed == emailError ? _self.emailError : emailError // ignore: cast_nullable_to_non_nullable
as String?,phoneError: freezed == phoneError ? _self.phoneError : phoneError // ignore: cast_nullable_to_non_nullable
as String?,otpError: freezed == otpError ? _self.otpError : otpError // ignore: cast_nullable_to_non_nullable
as String?,passError: freezed == passError ? _self.passError : passError // ignore: cast_nullable_to_non_nullable
as String?,confirmPassError: freezed == confirmPassError ? _self.confirmPassError : confirmPassError // ignore: cast_nullable_to_non_nullable
as String?,errorMessage: freezed == errorMessage ? _self.errorMessage : errorMessage // ignore: cast_nullable_to_non_nullable
as String?,successMessage: freezed == successMessage ? _self.successMessage : successMessage // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [RegisterState].
extension RegisterStatePatterns on RegisterState {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _RegisterState value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _RegisterState() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _RegisterState value)  $default,){
final _that = this;
switch (_that) {
case _RegisterState():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _RegisterState value)?  $default,){
final _that = this;
switch (_that) {
case _RegisterState() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int currentStep,  UserRole role,  OtpStatus otpStatus,  int countdown,  bool isVerifying,  bool isSubmitting,  bool isOtpVerified,  String? registrationToken,  String? fullNameError,  String? emailError,  String? phoneError,  String? otpError,  String? passError,  String? confirmPassError,  String? errorMessage,  String? successMessage)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _RegisterState() when $default != null:
return $default(_that.currentStep,_that.role,_that.otpStatus,_that.countdown,_that.isVerifying,_that.isSubmitting,_that.isOtpVerified,_that.registrationToken,_that.fullNameError,_that.emailError,_that.phoneError,_that.otpError,_that.passError,_that.confirmPassError,_that.errorMessage,_that.successMessage);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int currentStep,  UserRole role,  OtpStatus otpStatus,  int countdown,  bool isVerifying,  bool isSubmitting,  bool isOtpVerified,  String? registrationToken,  String? fullNameError,  String? emailError,  String? phoneError,  String? otpError,  String? passError,  String? confirmPassError,  String? errorMessage,  String? successMessage)  $default,) {final _that = this;
switch (_that) {
case _RegisterState():
return $default(_that.currentStep,_that.role,_that.otpStatus,_that.countdown,_that.isVerifying,_that.isSubmitting,_that.isOtpVerified,_that.registrationToken,_that.fullNameError,_that.emailError,_that.phoneError,_that.otpError,_that.passError,_that.confirmPassError,_that.errorMessage,_that.successMessage);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int currentStep,  UserRole role,  OtpStatus otpStatus,  int countdown,  bool isVerifying,  bool isSubmitting,  bool isOtpVerified,  String? registrationToken,  String? fullNameError,  String? emailError,  String? phoneError,  String? otpError,  String? passError,  String? confirmPassError,  String? errorMessage,  String? successMessage)?  $default,) {final _that = this;
switch (_that) {
case _RegisterState() when $default != null:
return $default(_that.currentStep,_that.role,_that.otpStatus,_that.countdown,_that.isVerifying,_that.isSubmitting,_that.isOtpVerified,_that.registrationToken,_that.fullNameError,_that.emailError,_that.phoneError,_that.otpError,_that.passError,_that.confirmPassError,_that.errorMessage,_that.successMessage);case _:
  return null;

}
}

}

/// @nodoc


class _RegisterState implements RegisterState {
  const _RegisterState({this.currentStep = 1, this.role = UserRole.customer, this.otpStatus = OtpStatus.initial, this.countdown = 60, this.isVerifying = false, this.isSubmitting = false, this.isOtpVerified = false, this.registrationToken, this.fullNameError, this.emailError, this.phoneError, this.otpError, this.passError, this.confirmPassError, this.errorMessage, this.successMessage});
  

@override@JsonKey() final  int currentStep;
// Step 1: Chọn role, Step 2: Thông tin & OTP, Step 3: Mật khẩu & Mã giới thiệu
@override@JsonKey() final  UserRole role;
@override@JsonKey() final  OtpStatus otpStatus;
@override@JsonKey() final  int countdown;
@override@JsonKey() final  bool isVerifying;
@override@JsonKey() final  bool isSubmitting;
@override@JsonKey() final  bool isOtpVerified;
@override final  String? registrationToken;
@override final  String? fullNameError;
@override final  String? emailError;
@override final  String? phoneError;
@override final  String? otpError;
@override final  String? passError;
@override final  String? confirmPassError;
@override final  String? errorMessage;
@override final  String? successMessage;

/// Create a copy of RegisterState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$RegisterStateCopyWith<_RegisterState> get copyWith => __$RegisterStateCopyWithImpl<_RegisterState>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _RegisterState&&(identical(other.currentStep, currentStep) || other.currentStep == currentStep)&&(identical(other.role, role) || other.role == role)&&(identical(other.otpStatus, otpStatus) || other.otpStatus == otpStatus)&&(identical(other.countdown, countdown) || other.countdown == countdown)&&(identical(other.isVerifying, isVerifying) || other.isVerifying == isVerifying)&&(identical(other.isSubmitting, isSubmitting) || other.isSubmitting == isSubmitting)&&(identical(other.isOtpVerified, isOtpVerified) || other.isOtpVerified == isOtpVerified)&&(identical(other.registrationToken, registrationToken) || other.registrationToken == registrationToken)&&(identical(other.fullNameError, fullNameError) || other.fullNameError == fullNameError)&&(identical(other.emailError, emailError) || other.emailError == emailError)&&(identical(other.phoneError, phoneError) || other.phoneError == phoneError)&&(identical(other.otpError, otpError) || other.otpError == otpError)&&(identical(other.passError, passError) || other.passError == passError)&&(identical(other.confirmPassError, confirmPassError) || other.confirmPassError == confirmPassError)&&(identical(other.errorMessage, errorMessage) || other.errorMessage == errorMessage)&&(identical(other.successMessage, successMessage) || other.successMessage == successMessage));
}


@override
int get hashCode => Object.hash(runtimeType,currentStep,role,otpStatus,countdown,isVerifying,isSubmitting,isOtpVerified,registrationToken,fullNameError,emailError,phoneError,otpError,passError,confirmPassError,errorMessage,successMessage);

@override
String toString() {
  return 'RegisterState(currentStep: $currentStep, role: $role, otpStatus: $otpStatus, countdown: $countdown, isVerifying: $isVerifying, isSubmitting: $isSubmitting, isOtpVerified: $isOtpVerified, registrationToken: $registrationToken, fullNameError: $fullNameError, emailError: $emailError, phoneError: $phoneError, otpError: $otpError, passError: $passError, confirmPassError: $confirmPassError, errorMessage: $errorMessage, successMessage: $successMessage)';
}


}

/// @nodoc
abstract mixin class _$RegisterStateCopyWith<$Res> implements $RegisterStateCopyWith<$Res> {
  factory _$RegisterStateCopyWith(_RegisterState value, $Res Function(_RegisterState) _then) = __$RegisterStateCopyWithImpl;
@override @useResult
$Res call({
 int currentStep, UserRole role, OtpStatus otpStatus, int countdown, bool isVerifying, bool isSubmitting, bool isOtpVerified, String? registrationToken, String? fullNameError, String? emailError, String? phoneError, String? otpError, String? passError, String? confirmPassError, String? errorMessage, String? successMessage
});




}
/// @nodoc
class __$RegisterStateCopyWithImpl<$Res>
    implements _$RegisterStateCopyWith<$Res> {
  __$RegisterStateCopyWithImpl(this._self, this._then);

  final _RegisterState _self;
  final $Res Function(_RegisterState) _then;

/// Create a copy of RegisterState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? currentStep = null,Object? role = null,Object? otpStatus = null,Object? countdown = null,Object? isVerifying = null,Object? isSubmitting = null,Object? isOtpVerified = null,Object? registrationToken = freezed,Object? fullNameError = freezed,Object? emailError = freezed,Object? phoneError = freezed,Object? otpError = freezed,Object? passError = freezed,Object? confirmPassError = freezed,Object? errorMessage = freezed,Object? successMessage = freezed,}) {
  return _then(_RegisterState(
currentStep: null == currentStep ? _self.currentStep : currentStep // ignore: cast_nullable_to_non_nullable
as int,role: null == role ? _self.role : role // ignore: cast_nullable_to_non_nullable
as UserRole,otpStatus: null == otpStatus ? _self.otpStatus : otpStatus // ignore: cast_nullable_to_non_nullable
as OtpStatus,countdown: null == countdown ? _self.countdown : countdown // ignore: cast_nullable_to_non_nullable
as int,isVerifying: null == isVerifying ? _self.isVerifying : isVerifying // ignore: cast_nullable_to_non_nullable
as bool,isSubmitting: null == isSubmitting ? _self.isSubmitting : isSubmitting // ignore: cast_nullable_to_non_nullable
as bool,isOtpVerified: null == isOtpVerified ? _self.isOtpVerified : isOtpVerified // ignore: cast_nullable_to_non_nullable
as bool,registrationToken: freezed == registrationToken ? _self.registrationToken : registrationToken // ignore: cast_nullable_to_non_nullable
as String?,fullNameError: freezed == fullNameError ? _self.fullNameError : fullNameError // ignore: cast_nullable_to_non_nullable
as String?,emailError: freezed == emailError ? _self.emailError : emailError // ignore: cast_nullable_to_non_nullable
as String?,phoneError: freezed == phoneError ? _self.phoneError : phoneError // ignore: cast_nullable_to_non_nullable
as String?,otpError: freezed == otpError ? _self.otpError : otpError // ignore: cast_nullable_to_non_nullable
as String?,passError: freezed == passError ? _self.passError : passError // ignore: cast_nullable_to_non_nullable
as String?,confirmPassError: freezed == confirmPassError ? _self.confirmPassError : confirmPassError // ignore: cast_nullable_to_non_nullable
as String?,errorMessage: freezed == errorMessage ? _self.errorMessage : errorMessage // ignore: cast_nullable_to_non_nullable
as String?,successMessage: freezed == successMessage ? _self.successMessage : successMessage // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

// dart format on
