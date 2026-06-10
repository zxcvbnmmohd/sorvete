// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'outbox_event.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$OutboxEvent {

 String get id; String get type; String get aggregateId; DateTime get occurredAt; Map<String, dynamic> get payload; DateTime? get publishedAt;
/// Create a copy of OutboxEvent
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$OutboxEventCopyWith<OutboxEvent> get copyWith => _$OutboxEventCopyWithImpl<OutboxEvent>(this as OutboxEvent, _$identity);

  /// Serializes this OutboxEvent to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is OutboxEvent&&(identical(other.id, id) || other.id == id)&&(identical(other.type, type) || other.type == type)&&(identical(other.aggregateId, aggregateId) || other.aggregateId == aggregateId)&&(identical(other.occurredAt, occurredAt) || other.occurredAt == occurredAt)&&const DeepCollectionEquality().equals(other.payload, payload)&&(identical(other.publishedAt, publishedAt) || other.publishedAt == publishedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,type,aggregateId,occurredAt,const DeepCollectionEquality().hash(payload),publishedAt);

@override
String toString() {
  return 'OutboxEvent(id: $id, type: $type, aggregateId: $aggregateId, occurredAt: $occurredAt, payload: $payload, publishedAt: $publishedAt)';
}


}

/// @nodoc
abstract mixin class $OutboxEventCopyWith<$Res>  {
  factory $OutboxEventCopyWith(OutboxEvent value, $Res Function(OutboxEvent) _then) = _$OutboxEventCopyWithImpl;
@useResult
$Res call({
 String id, String type, String aggregateId, DateTime occurredAt, Map<String, dynamic> payload, DateTime? publishedAt
});




}
/// @nodoc
class _$OutboxEventCopyWithImpl<$Res>
    implements $OutboxEventCopyWith<$Res> {
  _$OutboxEventCopyWithImpl(this._self, this._then);

  final OutboxEvent _self;
  final $Res Function(OutboxEvent) _then;

/// Create a copy of OutboxEvent
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? type = null,Object? aggregateId = null,Object? occurredAt = null,Object? payload = null,Object? publishedAt = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as String,aggregateId: null == aggregateId ? _self.aggregateId : aggregateId // ignore: cast_nullable_to_non_nullable
as String,occurredAt: null == occurredAt ? _self.occurredAt : occurredAt // ignore: cast_nullable_to_non_nullable
as DateTime,payload: null == payload ? _self.payload : payload // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>,publishedAt: freezed == publishedAt ? _self.publishedAt : publishedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}

}


/// Adds pattern-matching-related methods to [OutboxEvent].
extension OutboxEventPatterns on OutboxEvent {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _OutboxEvent value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _OutboxEvent() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _OutboxEvent value)  $default,){
final _that = this;
switch (_that) {
case _OutboxEvent():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _OutboxEvent value)?  $default,){
final _that = this;
switch (_that) {
case _OutboxEvent() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String type,  String aggregateId,  DateTime occurredAt,  Map<String, dynamic> payload,  DateTime? publishedAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _OutboxEvent() when $default != null:
return $default(_that.id,_that.type,_that.aggregateId,_that.occurredAt,_that.payload,_that.publishedAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String type,  String aggregateId,  DateTime occurredAt,  Map<String, dynamic> payload,  DateTime? publishedAt)  $default,) {final _that = this;
switch (_that) {
case _OutboxEvent():
return $default(_that.id,_that.type,_that.aggregateId,_that.occurredAt,_that.payload,_that.publishedAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String type,  String aggregateId,  DateTime occurredAt,  Map<String, dynamic> payload,  DateTime? publishedAt)?  $default,) {final _that = this;
switch (_that) {
case _OutboxEvent() when $default != null:
return $default(_that.id,_that.type,_that.aggregateId,_that.occurredAt,_that.payload,_that.publishedAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _OutboxEvent implements OutboxEvent {
  const _OutboxEvent({required this.id, required this.type, required this.aggregateId, required this.occurredAt, required final  Map<String, dynamic> payload, this.publishedAt}): _payload = payload;
  factory _OutboxEvent.fromJson(Map<String, dynamic> json) => _$OutboxEventFromJson(json);

@override final  String id;
@override final  String type;
@override final  String aggregateId;
@override final  DateTime occurredAt;
 final  Map<String, dynamic> _payload;
@override Map<String, dynamic> get payload {
  if (_payload is EqualUnmodifiableMapView) return _payload;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(_payload);
}

@override final  DateTime? publishedAt;

/// Create a copy of OutboxEvent
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$OutboxEventCopyWith<_OutboxEvent> get copyWith => __$OutboxEventCopyWithImpl<_OutboxEvent>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$OutboxEventToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _OutboxEvent&&(identical(other.id, id) || other.id == id)&&(identical(other.type, type) || other.type == type)&&(identical(other.aggregateId, aggregateId) || other.aggregateId == aggregateId)&&(identical(other.occurredAt, occurredAt) || other.occurredAt == occurredAt)&&const DeepCollectionEquality().equals(other._payload, _payload)&&(identical(other.publishedAt, publishedAt) || other.publishedAt == publishedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,type,aggregateId,occurredAt,const DeepCollectionEquality().hash(_payload),publishedAt);

@override
String toString() {
  return 'OutboxEvent(id: $id, type: $type, aggregateId: $aggregateId, occurredAt: $occurredAt, payload: $payload, publishedAt: $publishedAt)';
}


}

/// @nodoc
abstract mixin class _$OutboxEventCopyWith<$Res> implements $OutboxEventCopyWith<$Res> {
  factory _$OutboxEventCopyWith(_OutboxEvent value, $Res Function(_OutboxEvent) _then) = __$OutboxEventCopyWithImpl;
@override @useResult
$Res call({
 String id, String type, String aggregateId, DateTime occurredAt, Map<String, dynamic> payload, DateTime? publishedAt
});




}
/// @nodoc
class __$OutboxEventCopyWithImpl<$Res>
    implements _$OutboxEventCopyWith<$Res> {
  __$OutboxEventCopyWithImpl(this._self, this._then);

  final _OutboxEvent _self;
  final $Res Function(_OutboxEvent) _then;

/// Create a copy of OutboxEvent
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? type = null,Object? aggregateId = null,Object? occurredAt = null,Object? payload = null,Object? publishedAt = freezed,}) {
  return _then(_OutboxEvent(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as String,aggregateId: null == aggregateId ? _self.aggregateId : aggregateId // ignore: cast_nullable_to_non_nullable
as String,occurredAt: null == occurredAt ? _self.occurredAt : occurredAt // ignore: cast_nullable_to_non_nullable
as DateTime,payload: null == payload ? _self._payload : payload // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>,publishedAt: freezed == publishedAt ? _self.publishedAt : publishedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}


}

// dart format on
