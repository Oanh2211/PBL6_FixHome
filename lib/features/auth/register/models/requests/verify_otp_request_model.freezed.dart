// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'verify_otp_request_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$VerifyOtpRequestModel {

 String get role;@JsonKey(name: 'phone_number') String get phoneNumber; String get otp;
/// Create a copy of VerifyOtpRequestModel
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$VerifyOtpRequestModelCopyWith<VerifyOtpRequestModel> get copyWith => _$VerifyOtpRequestModelCopyWithImpl<VerifyOtpRequestModel>(this as VerifyOtpRequestModel, _$identity);

  /// Serializes this VerifyOtpRequestModel to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is VerifyOtpRequestModel&&(identical(other.role, role) || other.role == role)&&(identical(other.phoneNumber, phoneNumber) || other.phoneNumber == phoneNumber)&&(identical(other.otp, otp) || other.otp == otp));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,role,phoneNumber,otp);

@override
String toString() {
  return 'VerifyOtpRequestModel(role: $role, phoneNumber: $phoneNumber, otp: $otp)';
}


}

/// @nodoc
abstract mixin class $VerifyOtpRequestModelCopyWith<$Res>  {
  factory $VerifyOtpRequestModelCopyWith(VerifyOtpRequestModel value, $Res Function(VerifyOtpRequestModel) _then) = _$VerifyOtpRequestModelCopyWithImpl;
@useResult
$Res call({
 String role,@JsonKey(name: 'phone_number') String phoneNumber, String otp
});




}
/// @nodoc
class _$VerifyOtpRequestModelCopyWithImpl<$Res>
    implements $VerifyOtpRequestModelCopyWith<$Res> {
  _$VerifyOtpRequestModelCopyWithImpl(this._self, this._then);

  final VerifyOtpRequestModel _self;
  final $Res Function(VerifyOtpRequestModel) _then;

/// Create a copy of VerifyOtpRequestModel
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? role = null,Object? phoneNumber = null,Object? otp = null,}) {
  return _then(_self.copyWith(
role: null == role ? _self.role : role // ignore: cast_nullable_to_non_nullable
as String,phoneNumber: null == phoneNumber ? _self.phoneNumber : phoneNumber // ignore: cast_nullable_to_non_nullable
as String,otp: null == otp ? _self.otp : otp // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [VerifyOtpRequestModel].
extension VerifyOtpRequestModelPatterns on VerifyOtpRequestModel {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _VerifyOtpRequestModel value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _VerifyOtpRequestModel() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _VerifyOtpRequestModel value)  $default,){
final _that = this;
switch (_that) {
case _VerifyOtpRequestModel():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _VerifyOtpRequestModel value)?  $default,){
final _that = this;
switch (_that) {
case _VerifyOtpRequestModel() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String role, @JsonKey(name: 'phone_number')  String phoneNumber,  String otp)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _VerifyOtpRequestModel() when $default != null:
return $default(_that.role,_that.phoneNumber,_that.otp);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String role, @JsonKey(name: 'phone_number')  String phoneNumber,  String otp)  $default,) {final _that = this;
switch (_that) {
case _VerifyOtpRequestModel():
return $default(_that.role,_that.phoneNumber,_that.otp);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String role, @JsonKey(name: 'phone_number')  String phoneNumber,  String otp)?  $default,) {final _that = this;
switch (_that) {
case _VerifyOtpRequestModel() when $default != null:
return $default(_that.role,_that.phoneNumber,_that.otp);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _VerifyOtpRequestModel implements VerifyOtpRequestModel {
  const _VerifyOtpRequestModel({this.role = 'CUSTOMER', @JsonKey(name: 'phone_number') required this.phoneNumber, required this.otp});
  factory _VerifyOtpRequestModel.fromJson(Map<String, dynamic> json) => _$VerifyOtpRequestModelFromJson(json);

@override@JsonKey() final  String role;
@override@JsonKey(name: 'phone_number') final  String phoneNumber;
@override final  String otp;

/// Create a copy of VerifyOtpRequestModel
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$VerifyOtpRequestModelCopyWith<_VerifyOtpRequestModel> get copyWith => __$VerifyOtpRequestModelCopyWithImpl<_VerifyOtpRequestModel>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$VerifyOtpRequestModelToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _VerifyOtpRequestModel&&(identical(other.role, role) || other.role == role)&&(identical(other.phoneNumber, phoneNumber) || other.phoneNumber == phoneNumber)&&(identical(other.otp, otp) || other.otp == otp));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,role,phoneNumber,otp);

@override
String toString() {
  return 'VerifyOtpRequestModel(role: $role, phoneNumber: $phoneNumber, otp: $otp)';
}


}

/// @nodoc
abstract mixin class _$VerifyOtpRequestModelCopyWith<$Res> implements $VerifyOtpRequestModelCopyWith<$Res> {
  factory _$VerifyOtpRequestModelCopyWith(_VerifyOtpRequestModel value, $Res Function(_VerifyOtpRequestModel) _then) = __$VerifyOtpRequestModelCopyWithImpl;
@override @useResult
$Res call({
 String role,@JsonKey(name: 'phone_number') String phoneNumber, String otp
});




}
/// @nodoc
class __$VerifyOtpRequestModelCopyWithImpl<$Res>
    implements _$VerifyOtpRequestModelCopyWith<$Res> {
  __$VerifyOtpRequestModelCopyWithImpl(this._self, this._then);

  final _VerifyOtpRequestModel _self;
  final $Res Function(_VerifyOtpRequestModel) _then;

/// Create a copy of VerifyOtpRequestModel
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? role = null,Object? phoneNumber = null,Object? otp = null,}) {
  return _then(_VerifyOtpRequestModel(
role: null == role ? _self.role : role // ignore: cast_nullable_to_non_nullable
as String,phoneNumber: null == phoneNumber ? _self.phoneNumber : phoneNumber // ignore: cast_nullable_to_non_nullable
as String,otp: null == otp ? _self.otp : otp // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

// dart format on
