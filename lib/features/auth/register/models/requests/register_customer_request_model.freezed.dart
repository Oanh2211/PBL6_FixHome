// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'register_customer_request_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$RegisterCustomerRequestModel {

@JsonKey(name: 'full_name') String get fullName;@JsonKey(name: 'phone_number') String get phoneNumber; String get email; String get password;@JsonKey(name: 'registration_token') String get registrationToken;@JsonKey(name: 'referral_code', includeIfNull: false) String? get referralCode;
/// Create a copy of RegisterCustomerRequestModel
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$RegisterCustomerRequestModelCopyWith<RegisterCustomerRequestModel> get copyWith => _$RegisterCustomerRequestModelCopyWithImpl<RegisterCustomerRequestModel>(this as RegisterCustomerRequestModel, _$identity);

  /// Serializes this RegisterCustomerRequestModel to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is RegisterCustomerRequestModel&&(identical(other.fullName, fullName) || other.fullName == fullName)&&(identical(other.phoneNumber, phoneNumber) || other.phoneNumber == phoneNumber)&&(identical(other.email, email) || other.email == email)&&(identical(other.password, password) || other.password == password)&&(identical(other.registrationToken, registrationToken) || other.registrationToken == registrationToken)&&(identical(other.referralCode, referralCode) || other.referralCode == referralCode));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,fullName,phoneNumber,email,password,registrationToken,referralCode);

@override
String toString() {
  return 'RegisterCustomerRequestModel(fullName: $fullName, phoneNumber: $phoneNumber, email: $email, password: $password, registrationToken: $registrationToken, referralCode: $referralCode)';
}


}

/// @nodoc
abstract mixin class $RegisterCustomerRequestModelCopyWith<$Res>  {
  factory $RegisterCustomerRequestModelCopyWith(RegisterCustomerRequestModel value, $Res Function(RegisterCustomerRequestModel) _then) = _$RegisterCustomerRequestModelCopyWithImpl;
@useResult
$Res call({
@JsonKey(name: 'full_name') String fullName,@JsonKey(name: 'phone_number') String phoneNumber, String email, String password,@JsonKey(name: 'registration_token') String registrationToken,@JsonKey(name: 'referral_code', includeIfNull: false) String? referralCode
});




}
/// @nodoc
class _$RegisterCustomerRequestModelCopyWithImpl<$Res>
    implements $RegisterCustomerRequestModelCopyWith<$Res> {
  _$RegisterCustomerRequestModelCopyWithImpl(this._self, this._then);

  final RegisterCustomerRequestModel _self;
  final $Res Function(RegisterCustomerRequestModel) _then;

/// Create a copy of RegisterCustomerRequestModel
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? fullName = null,Object? phoneNumber = null,Object? email = null,Object? password = null,Object? registrationToken = null,Object? referralCode = freezed,}) {
  return _then(_self.copyWith(
fullName: null == fullName ? _self.fullName : fullName // ignore: cast_nullable_to_non_nullable
as String,phoneNumber: null == phoneNumber ? _self.phoneNumber : phoneNumber // ignore: cast_nullable_to_non_nullable
as String,email: null == email ? _self.email : email // ignore: cast_nullable_to_non_nullable
as String,password: null == password ? _self.password : password // ignore: cast_nullable_to_non_nullable
as String,registrationToken: null == registrationToken ? _self.registrationToken : registrationToken // ignore: cast_nullable_to_non_nullable
as String,referralCode: freezed == referralCode ? _self.referralCode : referralCode // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [RegisterCustomerRequestModel].
extension RegisterCustomerRequestModelPatterns on RegisterCustomerRequestModel {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _RegisterCustomerRequestModel value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _RegisterCustomerRequestModel() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _RegisterCustomerRequestModel value)  $default,){
final _that = this;
switch (_that) {
case _RegisterCustomerRequestModel():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _RegisterCustomerRequestModel value)?  $default,){
final _that = this;
switch (_that) {
case _RegisterCustomerRequestModel() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@JsonKey(name: 'full_name')  String fullName, @JsonKey(name: 'phone_number')  String phoneNumber,  String email,  String password, @JsonKey(name: 'registration_token')  String registrationToken, @JsonKey(name: 'referral_code', includeIfNull: false)  String? referralCode)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _RegisterCustomerRequestModel() when $default != null:
return $default(_that.fullName,_that.phoneNumber,_that.email,_that.password,_that.registrationToken,_that.referralCode);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@JsonKey(name: 'full_name')  String fullName, @JsonKey(name: 'phone_number')  String phoneNumber,  String email,  String password, @JsonKey(name: 'registration_token')  String registrationToken, @JsonKey(name: 'referral_code', includeIfNull: false)  String? referralCode)  $default,) {final _that = this;
switch (_that) {
case _RegisterCustomerRequestModel():
return $default(_that.fullName,_that.phoneNumber,_that.email,_that.password,_that.registrationToken,_that.referralCode);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@JsonKey(name: 'full_name')  String fullName, @JsonKey(name: 'phone_number')  String phoneNumber,  String email,  String password, @JsonKey(name: 'registration_token')  String registrationToken, @JsonKey(name: 'referral_code', includeIfNull: false)  String? referralCode)?  $default,) {final _that = this;
switch (_that) {
case _RegisterCustomerRequestModel() when $default != null:
return $default(_that.fullName,_that.phoneNumber,_that.email,_that.password,_that.registrationToken,_that.referralCode);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _RegisterCustomerRequestModel implements RegisterCustomerRequestModel {
  const _RegisterCustomerRequestModel({@JsonKey(name: 'full_name') required this.fullName, @JsonKey(name: 'phone_number') required this.phoneNumber, required this.email, required this.password, @JsonKey(name: 'registration_token') required this.registrationToken, @JsonKey(name: 'referral_code', includeIfNull: false) this.referralCode});
  factory _RegisterCustomerRequestModel.fromJson(Map<String, dynamic> json) => _$RegisterCustomerRequestModelFromJson(json);

@override@JsonKey(name: 'full_name') final  String fullName;
@override@JsonKey(name: 'phone_number') final  String phoneNumber;
@override final  String email;
@override final  String password;
@override@JsonKey(name: 'registration_token') final  String registrationToken;
@override@JsonKey(name: 'referral_code', includeIfNull: false) final  String? referralCode;

/// Create a copy of RegisterCustomerRequestModel
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$RegisterCustomerRequestModelCopyWith<_RegisterCustomerRequestModel> get copyWith => __$RegisterCustomerRequestModelCopyWithImpl<_RegisterCustomerRequestModel>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$RegisterCustomerRequestModelToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _RegisterCustomerRequestModel&&(identical(other.fullName, fullName) || other.fullName == fullName)&&(identical(other.phoneNumber, phoneNumber) || other.phoneNumber == phoneNumber)&&(identical(other.email, email) || other.email == email)&&(identical(other.password, password) || other.password == password)&&(identical(other.registrationToken, registrationToken) || other.registrationToken == registrationToken)&&(identical(other.referralCode, referralCode) || other.referralCode == referralCode));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,fullName,phoneNumber,email,password,registrationToken,referralCode);

@override
String toString() {
  return 'RegisterCustomerRequestModel(fullName: $fullName, phoneNumber: $phoneNumber, email: $email, password: $password, registrationToken: $registrationToken, referralCode: $referralCode)';
}


}

/// @nodoc
abstract mixin class _$RegisterCustomerRequestModelCopyWith<$Res> implements $RegisterCustomerRequestModelCopyWith<$Res> {
  factory _$RegisterCustomerRequestModelCopyWith(_RegisterCustomerRequestModel value, $Res Function(_RegisterCustomerRequestModel) _then) = __$RegisterCustomerRequestModelCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(name: 'full_name') String fullName,@JsonKey(name: 'phone_number') String phoneNumber, String email, String password,@JsonKey(name: 'registration_token') String registrationToken,@JsonKey(name: 'referral_code', includeIfNull: false) String? referralCode
});




}
/// @nodoc
class __$RegisterCustomerRequestModelCopyWithImpl<$Res>
    implements _$RegisterCustomerRequestModelCopyWith<$Res> {
  __$RegisterCustomerRequestModelCopyWithImpl(this._self, this._then);

  final _RegisterCustomerRequestModel _self;
  final $Res Function(_RegisterCustomerRequestModel) _then;

/// Create a copy of RegisterCustomerRequestModel
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? fullName = null,Object? phoneNumber = null,Object? email = null,Object? password = null,Object? registrationToken = null,Object? referralCode = freezed,}) {
  return _then(_RegisterCustomerRequestModel(
fullName: null == fullName ? _self.fullName : fullName // ignore: cast_nullable_to_non_nullable
as String,phoneNumber: null == phoneNumber ? _self.phoneNumber : phoneNumber // ignore: cast_nullable_to_non_nullable
as String,email: null == email ? _self.email : email // ignore: cast_nullable_to_non_nullable
as String,password: null == password ? _self.password : password // ignore: cast_nullable_to_non_nullable
as String,registrationToken: null == registrationToken ? _self.registrationToken : registrationToken // ignore: cast_nullable_to_non_nullable
as String,referralCode: freezed == referralCode ? _self.referralCode : referralCode // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

// dart format on
