// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'send_otp_request_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$SendOtpRequestModel {

 String get role;@JsonKey(name: 'phone_number') String get phoneNumber;
/// Create a copy of SendOtpRequestModel
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SendOtpRequestModelCopyWith<SendOtpRequestModel> get copyWith => _$SendOtpRequestModelCopyWithImpl<SendOtpRequestModel>(this as SendOtpRequestModel, _$identity);

  /// Serializes this SendOtpRequestModel to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SendOtpRequestModel&&(identical(other.role, role) || other.role == role)&&(identical(other.phoneNumber, phoneNumber) || other.phoneNumber == phoneNumber));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,role,phoneNumber);

@override
String toString() {
  return 'SendOtpRequestModel(role: $role, phoneNumber: $phoneNumber)';
}


}

/// @nodoc
abstract mixin class $SendOtpRequestModelCopyWith<$Res>  {
  factory $SendOtpRequestModelCopyWith(SendOtpRequestModel value, $Res Function(SendOtpRequestModel) _then) = _$SendOtpRequestModelCopyWithImpl;
@useResult
$Res call({
 String role,@JsonKey(name: 'phone_number') String phoneNumber
});




}
/// @nodoc
class _$SendOtpRequestModelCopyWithImpl<$Res>
    implements $SendOtpRequestModelCopyWith<$Res> {
  _$SendOtpRequestModelCopyWithImpl(this._self, this._then);

  final SendOtpRequestModel _self;
  final $Res Function(SendOtpRequestModel) _then;

/// Create a copy of SendOtpRequestModel
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? role = null,Object? phoneNumber = null,}) {
  return _then(_self.copyWith(
role: null == role ? _self.role : role // ignore: cast_nullable_to_non_nullable
as String,phoneNumber: null == phoneNumber ? _self.phoneNumber : phoneNumber // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [SendOtpRequestModel].
extension SendOtpRequestModelPatterns on SendOtpRequestModel {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _SendOtpRequestModel value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _SendOtpRequestModel() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _SendOtpRequestModel value)  $default,){
final _that = this;
switch (_that) {
case _SendOtpRequestModel():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _SendOtpRequestModel value)?  $default,){
final _that = this;
switch (_that) {
case _SendOtpRequestModel() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String role, @JsonKey(name: 'phone_number')  String phoneNumber)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _SendOtpRequestModel() when $default != null:
return $default(_that.role,_that.phoneNumber);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String role, @JsonKey(name: 'phone_number')  String phoneNumber)  $default,) {final _that = this;
switch (_that) {
case _SendOtpRequestModel():
return $default(_that.role,_that.phoneNumber);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String role, @JsonKey(name: 'phone_number')  String phoneNumber)?  $default,) {final _that = this;
switch (_that) {
case _SendOtpRequestModel() when $default != null:
return $default(_that.role,_that.phoneNumber);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _SendOtpRequestModel implements SendOtpRequestModel {
  const _SendOtpRequestModel({this.role = 'CUSTOMER', @JsonKey(name: 'phone_number') required this.phoneNumber});
  factory _SendOtpRequestModel.fromJson(Map<String, dynamic> json) => _$SendOtpRequestModelFromJson(json);

@override@JsonKey() final  String role;
@override@JsonKey(name: 'phone_number') final  String phoneNumber;

/// Create a copy of SendOtpRequestModel
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$SendOtpRequestModelCopyWith<_SendOtpRequestModel> get copyWith => __$SendOtpRequestModelCopyWithImpl<_SendOtpRequestModel>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$SendOtpRequestModelToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _SendOtpRequestModel&&(identical(other.role, role) || other.role == role)&&(identical(other.phoneNumber, phoneNumber) || other.phoneNumber == phoneNumber));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,role,phoneNumber);

@override
String toString() {
  return 'SendOtpRequestModel(role: $role, phoneNumber: $phoneNumber)';
}


}

/// @nodoc
abstract mixin class _$SendOtpRequestModelCopyWith<$Res> implements $SendOtpRequestModelCopyWith<$Res> {
  factory _$SendOtpRequestModelCopyWith(_SendOtpRequestModel value, $Res Function(_SendOtpRequestModel) _then) = __$SendOtpRequestModelCopyWithImpl;
@override @useResult
$Res call({
 String role,@JsonKey(name: 'phone_number') String phoneNumber
});




}
/// @nodoc
class __$SendOtpRequestModelCopyWithImpl<$Res>
    implements _$SendOtpRequestModelCopyWith<$Res> {
  __$SendOtpRequestModelCopyWithImpl(this._self, this._then);

  final _SendOtpRequestModel _self;
  final $Res Function(_SendOtpRequestModel) _then;

/// Create a copy of SendOtpRequestModel
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? role = null,Object? phoneNumber = null,}) {
  return _then(_SendOtpRequestModel(
role: null == role ? _self.role : role // ignore: cast_nullable_to_non_nullable
as String,phoneNumber: null == phoneNumber ? _self.phoneNumber : phoneNumber // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

// dart format on
