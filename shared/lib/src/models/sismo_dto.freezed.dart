// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'sismo_dto.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

SismoDto _$SismoDtoFromJson(Map<String, dynamic> json) {
  return _SismoDto.fromJson(json);
}

/// @nodoc
mixin _$SismoDto {
  String get id => throw _privateConstructorUsedError;
  double get magnitude => throw _privateConstructorUsedError;
  String? get magType => throw _privateConstructorUsedError;
  String? get place => throw _privateConstructorUsedError;
  DateTime get timeUtc => throw _privateConstructorUsedError;
  double? get depthKm => throw _privateConstructorUsedError;
  double get latitude => throw _privateConstructorUsedError;
  double get longitude => throw _privateConstructorUsedError;
  String? get alert => throw _privateConstructorUsedError;
  int? get tsunami => throw _privateConstructorUsedError;
  String? get urlUsgs => throw _privateConstructorUsedError;

  /// Serializes this SismoDto to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of SismoDto
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $SismoDtoCopyWith<SismoDto> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $SismoDtoCopyWith<$Res> {
  factory $SismoDtoCopyWith(SismoDto value, $Res Function(SismoDto) then) =
      _$SismoDtoCopyWithImpl<$Res, SismoDto>;
  @useResult
  $Res call(
      {String id,
      double magnitude,
      String? magType,
      String? place,
      DateTime timeUtc,
      double? depthKm,
      double latitude,
      double longitude,
      String? alert,
      int? tsunami,
      String? urlUsgs});
}

/// @nodoc
class _$SismoDtoCopyWithImpl<$Res, $Val extends SismoDto>
    implements $SismoDtoCopyWith<$Res> {
  _$SismoDtoCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of SismoDto
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? magnitude = null,
    Object? magType = freezed,
    Object? place = freezed,
    Object? timeUtc = null,
    Object? depthKm = freezed,
    Object? latitude = null,
    Object? longitude = null,
    Object? alert = freezed,
    Object? tsunami = freezed,
    Object? urlUsgs = freezed,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      magnitude: null == magnitude
          ? _value.magnitude
          : magnitude // ignore: cast_nullable_to_non_nullable
              as double,
      magType: freezed == magType
          ? _value.magType
          : magType // ignore: cast_nullable_to_non_nullable
              as String?,
      place: freezed == place
          ? _value.place
          : place // ignore: cast_nullable_to_non_nullable
              as String?,
      timeUtc: null == timeUtc
          ? _value.timeUtc
          : timeUtc // ignore: cast_nullable_to_non_nullable
              as DateTime,
      depthKm: freezed == depthKm
          ? _value.depthKm
          : depthKm // ignore: cast_nullable_to_non_nullable
              as double?,
      latitude: null == latitude
          ? _value.latitude
          : latitude // ignore: cast_nullable_to_non_nullable
              as double,
      longitude: null == longitude
          ? _value.longitude
          : longitude // ignore: cast_nullable_to_non_nullable
              as double,
      alert: freezed == alert
          ? _value.alert
          : alert // ignore: cast_nullable_to_non_nullable
              as String?,
      tsunami: freezed == tsunami
          ? _value.tsunami
          : tsunami // ignore: cast_nullable_to_non_nullable
              as int?,
      urlUsgs: freezed == urlUsgs
          ? _value.urlUsgs
          : urlUsgs // ignore: cast_nullable_to_non_nullable
              as String?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$SismoDtoImplCopyWith<$Res>
    implements $SismoDtoCopyWith<$Res> {
  factory _$$SismoDtoImplCopyWith(
          _$SismoDtoImpl value, $Res Function(_$SismoDtoImpl) then) =
      __$$SismoDtoImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      double magnitude,
      String? magType,
      String? place,
      DateTime timeUtc,
      double? depthKm,
      double latitude,
      double longitude,
      String? alert,
      int? tsunami,
      String? urlUsgs});
}

/// @nodoc
class __$$SismoDtoImplCopyWithImpl<$Res>
    extends _$SismoDtoCopyWithImpl<$Res, _$SismoDtoImpl>
    implements _$$SismoDtoImplCopyWith<$Res> {
  __$$SismoDtoImplCopyWithImpl(
      _$SismoDtoImpl _value, $Res Function(_$SismoDtoImpl) _then)
      : super(_value, _then);

  /// Create a copy of SismoDto
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? magnitude = null,
    Object? magType = freezed,
    Object? place = freezed,
    Object? timeUtc = null,
    Object? depthKm = freezed,
    Object? latitude = null,
    Object? longitude = null,
    Object? alert = freezed,
    Object? tsunami = freezed,
    Object? urlUsgs = freezed,
  }) {
    return _then(_$SismoDtoImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      magnitude: null == magnitude
          ? _value.magnitude
          : magnitude // ignore: cast_nullable_to_non_nullable
              as double,
      magType: freezed == magType
          ? _value.magType
          : magType // ignore: cast_nullable_to_non_nullable
              as String?,
      place: freezed == place
          ? _value.place
          : place // ignore: cast_nullable_to_non_nullable
              as String?,
      timeUtc: null == timeUtc
          ? _value.timeUtc
          : timeUtc // ignore: cast_nullable_to_non_nullable
              as DateTime,
      depthKm: freezed == depthKm
          ? _value.depthKm
          : depthKm // ignore: cast_nullable_to_non_nullable
              as double?,
      latitude: null == latitude
          ? _value.latitude
          : latitude // ignore: cast_nullable_to_non_nullable
              as double,
      longitude: null == longitude
          ? _value.longitude
          : longitude // ignore: cast_nullable_to_non_nullable
              as double,
      alert: freezed == alert
          ? _value.alert
          : alert // ignore: cast_nullable_to_non_nullable
              as String?,
      tsunami: freezed == tsunami
          ? _value.tsunami
          : tsunami // ignore: cast_nullable_to_non_nullable
              as int?,
      urlUsgs: freezed == urlUsgs
          ? _value.urlUsgs
          : urlUsgs // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$SismoDtoImpl implements _SismoDto {
  const _$SismoDtoImpl(
      {required this.id,
      required this.magnitude,
      this.magType,
      this.place,
      required this.timeUtc,
      this.depthKm,
      required this.latitude,
      required this.longitude,
      this.alert,
      this.tsunami,
      this.urlUsgs});

  factory _$SismoDtoImpl.fromJson(Map<String, dynamic> json) =>
      _$$SismoDtoImplFromJson(json);

  @override
  final String id;
  @override
  final double magnitude;
  @override
  final String? magType;
  @override
  final String? place;
  @override
  final DateTime timeUtc;
  @override
  final double? depthKm;
  @override
  final double latitude;
  @override
  final double longitude;
  @override
  final String? alert;
  @override
  final int? tsunami;
  @override
  final String? urlUsgs;

  @override
  String toString() {
    return 'SismoDto(id: $id, magnitude: $magnitude, magType: $magType, place: $place, timeUtc: $timeUtc, depthKm: $depthKm, latitude: $latitude, longitude: $longitude, alert: $alert, tsunami: $tsunami, urlUsgs: $urlUsgs)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$SismoDtoImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.magnitude, magnitude) ||
                other.magnitude == magnitude) &&
            (identical(other.magType, magType) || other.magType == magType) &&
            (identical(other.place, place) || other.place == place) &&
            (identical(other.timeUtc, timeUtc) || other.timeUtc == timeUtc) &&
            (identical(other.depthKm, depthKm) || other.depthKm == depthKm) &&
            (identical(other.latitude, latitude) ||
                other.latitude == latitude) &&
            (identical(other.longitude, longitude) ||
                other.longitude == longitude) &&
            (identical(other.alert, alert) || other.alert == alert) &&
            (identical(other.tsunami, tsunami) || other.tsunami == tsunami) &&
            (identical(other.urlUsgs, urlUsgs) || other.urlUsgs == urlUsgs));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, id, magnitude, magType, place,
      timeUtc, depthKm, latitude, longitude, alert, tsunami, urlUsgs);

  /// Create a copy of SismoDto
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$SismoDtoImplCopyWith<_$SismoDtoImpl> get copyWith =>
      __$$SismoDtoImplCopyWithImpl<_$SismoDtoImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$SismoDtoImplToJson(
      this,
    );
  }
}

abstract class _SismoDto implements SismoDto {
  const factory _SismoDto(
      {required final String id,
      required final double magnitude,
      final String? magType,
      final String? place,
      required final DateTime timeUtc,
      final double? depthKm,
      required final double latitude,
      required final double longitude,
      final String? alert,
      final int? tsunami,
      final String? urlUsgs}) = _$SismoDtoImpl;

  factory _SismoDto.fromJson(Map<String, dynamic> json) =
      _$SismoDtoImpl.fromJson;

  @override
  String get id;
  @override
  double get magnitude;
  @override
  String? get magType;
  @override
  String? get place;
  @override
  DateTime get timeUtc;
  @override
  double? get depthKm;
  @override
  double get latitude;
  @override
  double get longitude;
  @override
  String? get alert;
  @override
  int? get tsunami;
  @override
  String? get urlUsgs;

  /// Create a copy of SismoDto
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$SismoDtoImplCopyWith<_$SismoDtoImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
