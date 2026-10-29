// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'login_cubit.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$LoginState {

 String get errorEmail; String get errorPassword; bool get isLoading; bool get isSuccess; String get role; bool get touchHiden; bool get touchRemember; String? get errorMessage;
/// Create a copy of LoginState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$LoginStateCopyWith<LoginState> get copyWith => _$LoginStateCopyWithImpl<LoginState>(this as LoginState, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is LoginState&&(identical(other.errorEmail, errorEmail) || other.errorEmail == errorEmail)&&(identical(other.errorPassword, errorPassword) || other.errorPassword == errorPassword)&&(identical(other.isLoading, isLoading) || other.isLoading == isLoading)&&(identical(other.isSuccess, isSuccess) || other.isSuccess == isSuccess)&&(identical(other.role, role) || other.role == role)&&(identical(other.touchHiden, touchHiden) || other.touchHiden == touchHiden)&&(identical(other.touchRemember, touchRemember) || other.touchRemember == touchRemember)&&(identical(other.errorMessage, errorMessage) || other.errorMessage == errorMessage));
}


@override
int get hashCode => Object.hash(runtimeType,errorEmail,errorPassword,isLoading,isSuccess,role,touchHiden,touchRemember,errorMessage);

@override
String toString() {
  return 'LoginState(errorEmail: $errorEmail, errorPassword: $errorPassword, isLoading: $isLoading, isSuccess: $isSuccess, role: $role, touchHiden: $touchHiden, touchRemember: $touchRemember, errorMessage: $errorMessage)';
}


}

/// @nodoc
abstract mixin class $LoginStateCopyWith<$Res>  {
  factory $LoginStateCopyWith(LoginState value, $Res Function(LoginState) _then) = _$LoginStateCopyWithImpl;
@useResult
$Res call({
 String errorEmail, String errorPassword, bool isLoading, bool isSuccess, String role, bool touchHiden, bool touchRemember, String? errorMessage
});




}
/// @nodoc
class _$LoginStateCopyWithImpl<$Res>
    implements $LoginStateCopyWith<$Res> {
  _$LoginStateCopyWithImpl(this._self, this._then);

  final LoginState _self;
  final $Res Function(LoginState) _then;

/// Create a copy of LoginState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? errorEmail = null,Object? errorPassword = null,Object? isLoading = null,Object? isSuccess = null,Object? role = null,Object? touchHiden = null,Object? touchRemember = null,Object? errorMessage = freezed,}) {
  return _then(_self.copyWith(
errorEmail: null == errorEmail ? _self.errorEmail : errorEmail // ignore: cast_nullable_to_non_nullable
as String,errorPassword: null == errorPassword ? _self.errorPassword : errorPassword // ignore: cast_nullable_to_non_nullable
as String,isLoading: null == isLoading ? _self.isLoading : isLoading // ignore: cast_nullable_to_non_nullable
as bool,isSuccess: null == isSuccess ? _self.isSuccess : isSuccess // ignore: cast_nullable_to_non_nullable
as bool,role: null == role ? _self.role : role // ignore: cast_nullable_to_non_nullable
as String,touchHiden: null == touchHiden ? _self.touchHiden : touchHiden // ignore: cast_nullable_to_non_nullable
as bool,touchRemember: null == touchRemember ? _self.touchRemember : touchRemember // ignore: cast_nullable_to_non_nullable
as bool,errorMessage: freezed == errorMessage ? _self.errorMessage : errorMessage // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [LoginState].
extension LoginStatePatterns on LoginState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>({TResult Function( _Initial value)?  initial,required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Initial() when initial != null:
return initial(_that);case _:
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

@optionalTypeArgs TResult map<TResult extends Object?>({required TResult Function( _Initial value)  initial,}){
final _that = this;
switch (_that) {
case _Initial():
return initial(_that);case _:
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>({TResult? Function( _Initial value)?  initial,}){
final _that = this;
switch (_that) {
case _Initial() when initial != null:
return initial(_that);case _:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>({TResult Function( String errorEmail,  String errorPassword,  bool isLoading,  bool isSuccess,  String role,  bool touchHiden,  bool touchRemember,  String? errorMessage)?  initial,required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Initial() when initial != null:
return initial(_that.errorEmail,_that.errorPassword,_that.isLoading,_that.isSuccess,_that.role,_that.touchHiden,_that.touchRemember,_that.errorMessage);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>({required TResult Function( String errorEmail,  String errorPassword,  bool isLoading,  bool isSuccess,  String role,  bool touchHiden,  bool touchRemember,  String? errorMessage)  initial,}) {final _that = this;
switch (_that) {
case _Initial():
return initial(_that.errorEmail,_that.errorPassword,_that.isLoading,_that.isSuccess,_that.role,_that.touchHiden,_that.touchRemember,_that.errorMessage);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>({TResult? Function( String errorEmail,  String errorPassword,  bool isLoading,  bool isSuccess,  String role,  bool touchHiden,  bool touchRemember,  String? errorMessage)?  initial,}) {final _that = this;
switch (_that) {
case _Initial() when initial != null:
return initial(_that.errorEmail,_that.errorPassword,_that.isLoading,_that.isSuccess,_that.role,_that.touchHiden,_that.touchRemember,_that.errorMessage);case _:
  return null;

}
}

}

/// @nodoc


class _Initial implements LoginState {
  const _Initial({this.errorEmail = '', this.errorPassword = '', this.isLoading = false, this.isSuccess = false, this.role = '', this.touchHiden = false, this.touchRemember = false, this.errorMessage});
  

@override@JsonKey() final  String errorEmail;
@override@JsonKey() final  String errorPassword;
@override@JsonKey() final  bool isLoading;
@override@JsonKey() final  bool isSuccess;
@override@JsonKey() final  String role;
@override@JsonKey() final  bool touchHiden;
@override@JsonKey() final  bool touchRemember;
@override final  String? errorMessage;

/// Create a copy of LoginState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$InitialCopyWith<_Initial> get copyWith => __$InitialCopyWithImpl<_Initial>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Initial&&(identical(other.errorEmail, errorEmail) || other.errorEmail == errorEmail)&&(identical(other.errorPassword, errorPassword) || other.errorPassword == errorPassword)&&(identical(other.isLoading, isLoading) || other.isLoading == isLoading)&&(identical(other.isSuccess, isSuccess) || other.isSuccess == isSuccess)&&(identical(other.role, role) || other.role == role)&&(identical(other.touchHiden, touchHiden) || other.touchHiden == touchHiden)&&(identical(other.touchRemember, touchRemember) || other.touchRemember == touchRemember)&&(identical(other.errorMessage, errorMessage) || other.errorMessage == errorMessage));
}


@override
int get hashCode => Object.hash(runtimeType,errorEmail,errorPassword,isLoading,isSuccess,role,touchHiden,touchRemember,errorMessage);

@override
String toString() {
  return 'LoginState.initial(errorEmail: $errorEmail, errorPassword: $errorPassword, isLoading: $isLoading, isSuccess: $isSuccess, role: $role, touchHiden: $touchHiden, touchRemember: $touchRemember, errorMessage: $errorMessage)';
}


}

/// @nodoc
abstract mixin class _$InitialCopyWith<$Res> implements $LoginStateCopyWith<$Res> {
  factory _$InitialCopyWith(_Initial value, $Res Function(_Initial) _then) = __$InitialCopyWithImpl;
@override @useResult
$Res call({
 String errorEmail, String errorPassword, bool isLoading, bool isSuccess, String role, bool touchHiden, bool touchRemember, String? errorMessage
});




}
/// @nodoc
class __$InitialCopyWithImpl<$Res>
    implements _$InitialCopyWith<$Res> {
  __$InitialCopyWithImpl(this._self, this._then);

  final _Initial _self;
  final $Res Function(_Initial) _then;

/// Create a copy of LoginState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? errorEmail = null,Object? errorPassword = null,Object? isLoading = null,Object? isSuccess = null,Object? role = null,Object? touchHiden = null,Object? touchRemember = null,Object? errorMessage = freezed,}) {
  return _then(_Initial(
errorEmail: null == errorEmail ? _self.errorEmail : errorEmail // ignore: cast_nullable_to_non_nullable
as String,errorPassword: null == errorPassword ? _self.errorPassword : errorPassword // ignore: cast_nullable_to_non_nullable
as String,isLoading: null == isLoading ? _self.isLoading : isLoading // ignore: cast_nullable_to_non_nullable
as bool,isSuccess: null == isSuccess ? _self.isSuccess : isSuccess // ignore: cast_nullable_to_non_nullable
as bool,role: null == role ? _self.role : role // ignore: cast_nullable_to_non_nullable
as String,touchHiden: null == touchHiden ? _self.touchHiden : touchHiden // ignore: cast_nullable_to_non_nullable
as bool,touchRemember: null == touchRemember ? _self.touchRemember : touchRemember // ignore: cast_nullable_to_non_nullable
as bool,errorMessage: freezed == errorMessage ? _self.errorMessage : errorMessage // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

// dart format on
