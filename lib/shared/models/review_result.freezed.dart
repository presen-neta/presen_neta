// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'review_result.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$ReviewResult {

/// プレゼンテーションの点数（0-100）
 int get point;/// 良い点のリスト
 List<String> get good;/// 改善点のリスト
 List<String> get improve;
/// Create a copy of ReviewResult
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ReviewResultCopyWith<ReviewResult> get copyWith => _$ReviewResultCopyWithImpl<ReviewResult>(this as ReviewResult, _$identity);

  /// Serializes this ReviewResult to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ReviewResult&&(identical(other.point, point) || other.point == point)&&const DeepCollectionEquality().equals(other.good, good)&&const DeepCollectionEquality().equals(other.improve, improve));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,point,const DeepCollectionEquality().hash(good),const DeepCollectionEquality().hash(improve));

@override
String toString() {
  return 'ReviewResult(point: $point, good: $good, improve: $improve)';
}


}

/// @nodoc
abstract mixin class $ReviewResultCopyWith<$Res>  {
  factory $ReviewResultCopyWith(ReviewResult value, $Res Function(ReviewResult) _then) = _$ReviewResultCopyWithImpl;
@useResult
$Res call({
 int point, List<String> good, List<String> improve
});




}
/// @nodoc
class _$ReviewResultCopyWithImpl<$Res>
    implements $ReviewResultCopyWith<$Res> {
  _$ReviewResultCopyWithImpl(this._self, this._then);

  final ReviewResult _self;
  final $Res Function(ReviewResult) _then;

/// Create a copy of ReviewResult
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? point = null,Object? good = null,Object? improve = null,}) {
  return _then(_self.copyWith(
point: null == point ? _self.point : point // ignore: cast_nullable_to_non_nullable
as int,good: null == good ? _self.good : good // ignore: cast_nullable_to_non_nullable
as List<String>,improve: null == improve ? _self.improve : improve // ignore: cast_nullable_to_non_nullable
as List<String>,
  ));
}

}


/// Adds pattern-matching-related methods to [ReviewResult].
extension ReviewResultPatterns on ReviewResult {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ReviewResult value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ReviewResult() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ReviewResult value)  $default,){
final _that = this;
switch (_that) {
case _ReviewResult():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ReviewResult value)?  $default,){
final _that = this;
switch (_that) {
case _ReviewResult() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int point,  List<String> good,  List<String> improve)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ReviewResult() when $default != null:
return $default(_that.point,_that.good,_that.improve);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int point,  List<String> good,  List<String> improve)  $default,) {final _that = this;
switch (_that) {
case _ReviewResult():
return $default(_that.point,_that.good,_that.improve);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int point,  List<String> good,  List<String> improve)?  $default,) {final _that = this;
switch (_that) {
case _ReviewResult() when $default != null:
return $default(_that.point,_that.good,_that.improve);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _ReviewResult implements ReviewResult {
  const _ReviewResult({required this.point, required final  List<String> good, required final  List<String> improve}): _good = good,_improve = improve;
  factory _ReviewResult.fromJson(Map<String, dynamic> json) => _$ReviewResultFromJson(json);

/// プレゼンテーションの点数（0-100）
@override final  int point;
/// 良い点のリスト
 final  List<String> _good;
/// 良い点のリスト
@override List<String> get good {
  if (_good is EqualUnmodifiableListView) return _good;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_good);
}

/// 改善点のリスト
 final  List<String> _improve;
/// 改善点のリスト
@override List<String> get improve {
  if (_improve is EqualUnmodifiableListView) return _improve;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_improve);
}


/// Create a copy of ReviewResult
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ReviewResultCopyWith<_ReviewResult> get copyWith => __$ReviewResultCopyWithImpl<_ReviewResult>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ReviewResultToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ReviewResult&&(identical(other.point, point) || other.point == point)&&const DeepCollectionEquality().equals(other._good, _good)&&const DeepCollectionEquality().equals(other._improve, _improve));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,point,const DeepCollectionEquality().hash(_good),const DeepCollectionEquality().hash(_improve));

@override
String toString() {
  return 'ReviewResult(point: $point, good: $good, improve: $improve)';
}


}

/// @nodoc
abstract mixin class _$ReviewResultCopyWith<$Res> implements $ReviewResultCopyWith<$Res> {
  factory _$ReviewResultCopyWith(_ReviewResult value, $Res Function(_ReviewResult) _then) = __$ReviewResultCopyWithImpl;
@override @useResult
$Res call({
 int point, List<String> good, List<String> improve
});




}
/// @nodoc
class __$ReviewResultCopyWithImpl<$Res>
    implements _$ReviewResultCopyWith<$Res> {
  __$ReviewResultCopyWithImpl(this._self, this._then);

  final _ReviewResult _self;
  final $Res Function(_ReviewResult) _then;

/// Create a copy of ReviewResult
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? point = null,Object? good = null,Object? improve = null,}) {
  return _then(_ReviewResult(
point: null == point ? _self.point : point // ignore: cast_nullable_to_non_nullable
as int,good: null == good ? _self._good : good // ignore: cast_nullable_to_non_nullable
as List<String>,improve: null == improve ? _self._improve : improve // ignore: cast_nullable_to_non_nullable
as List<String>,
  ));
}


}

// dart format on
