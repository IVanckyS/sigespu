// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'sismo_dto.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$SismoDto {
  String get id;
  double get magnitude;
  String? get magType;
  String? get place;
  DateTime get timeUtc;
  double? get depthKm;
  double get latitude;
  double get longitude;
  String? get alert;
  int? get tsunami;
  String? get urlUsgs;

  /// Create a copy of SismoDto
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $SismoDtoCopyWith<SismoDto> get copyWith =>
      _$SismoDtoCopyWithImpl<SismoDto>(this as SismoDto, _$identity);

  /// Serializes this SismoDto to a JSON map.
  Map<String, dynamic> toJson();

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is SismoDto &&
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

  @override
  String toString() {
    return 'SismoDto(id: $id, magnitude: $magnitude, magType: $magType, place: $place, timeUtc: $timeUtc, depthKm: $depthKm, latitude: $latitude, longitude: $longitude, alert: $alert, tsunami: $tsunami, urlUsgs: $urlUsgs)';
  }
}

/// @nodoc
abstract mixin class $SismoDtoCopyWith<$Res> {
  factory $SismoDtoCopyWith(SismoDto value, $Res Function(SismoDto) _then) =
      _$SismoDtoCopyWithImpl;
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
class _$SismoDtoCopyWithImpl<$Res> implements $SismoDtoCopyWith<$Res> {
  _$SismoDtoCopyWithImpl(this._self, this._then);

  final SismoDto _self;
  final $Res Function(SismoDto) _then;

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
    return _then(_self.copyWith(
      id: null == id
          ? _self.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      magnitude: null == magnitude
          ? _self.magnitude
          : magnitude // ignore: cast_nullable_to_non_nullable
              as double,
      magType: freezed == magType
          ? _self.magType
          : magType // ignore: cast_nullable_to_non_nullable
              as String?,
      place: freezed == place
          ? _self.place
          : place // ignore: cast_nullable_to_non_nullable
              as String?,
      timeUtc: null == timeUtc
          ? _self.timeUtc
          : timeUtc // ignore: cast_nullable_to_non_nullable
              as DateTime,
      depthKm: freezed == depthKm
          ? _self.depthKm
          : depthKm // ignore: cast_nullable_to_non_nullable
              as double?,
      latitude: null == latitude
          ? _self.latitude
          : latitude // ignore: cast_nullable_to_non_nullable
              as double,
      longitude: null == longitude
          ? _self.longitude
          : longitude // ignore: cast_nullable_to_non_nullable
              as double,
      alert: freezed == alert
          ? _self.alert
          : alert // ignore: cast_nullable_to_non_nullable
              as String?,
      tsunami: freezed == tsunami
          ? _self.tsunami
          : tsunami // ignore: cast_nullable_to_non_nullable
              as int?,
      urlUsgs: freezed == urlUsgs
          ? _self.urlUsgs
          : urlUsgs // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// Adds pattern-matching-related methods to [SismoDto].
extension SismoDtoPatterns on SismoDto {
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

  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>(
    TResult Function(_SismoDto value)? $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _SismoDto() when $default != null:
        return $default(_that);
      case _:
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

  @optionalTypeArgs
  TResult map<TResult extends Object?>(
    TResult Function(_SismoDto value) $default,
  ) {
    final _that = this;
    switch (_that) {
      case _SismoDto():
        return $default(_that);
      case _:
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

  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>(
    TResult? Function(_SismoDto value)? $default,
  ) {
    final _that = this;
    switch (_that) {
      case _SismoDto() when $default != null:
        return $default(_that);
      case _:
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

  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>(
    TResult Function(
            String id,
            double magnitude,
            String? magType,
            String? place,
            DateTime timeUtc,
            double? depthKm,
            double latitude,
            double longitude,
            String? alert,
            int? tsunami,
            String? urlUsgs)?
        $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _SismoDto() when $default != null:
        return $default(
            _that.id,
            _that.magnitude,
            _that.magType,
            _that.place,
            _that.timeUtc,
            _that.depthKm,
            _that.latitude,
            _that.longitude,
            _that.alert,
            _that.tsunami,
            _that.urlUsgs);
      case _:
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

  @optionalTypeArgs
  TResult when<TResult extends Object?>(
    TResult Function(
            String id,
            double magnitude,
            String? magType,
            String? place,
            DateTime timeUtc,
            double? depthKm,
            double latitude,
            double longitude,
            String? alert,
            int? tsunami,
            String? urlUsgs)
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _SismoDto():
        return $default(
            _that.id,
            _that.magnitude,
            _that.magType,
            _that.place,
            _that.timeUtc,
            _that.depthKm,
            _that.latitude,
            _that.longitude,
            _that.alert,
            _that.tsunami,
            _that.urlUsgs);
      case _:
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

  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>(
    TResult? Function(
            String id,
            double magnitude,
            String? magType,
            String? place,
            DateTime timeUtc,
            double? depthKm,
            double latitude,
            double longitude,
            String? alert,
            int? tsunami,
            String? urlUsgs)?
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _SismoDto() when $default != null:
        return $default(
            _that.id,
            _that.magnitude,
            _that.magType,
            _that.place,
            _that.timeUtc,
            _that.depthKm,
            _that.latitude,
            _that.longitude,
            _that.alert,
            _that.tsunami,
            _that.urlUsgs);
      case _:
        return null;
    }
  }
}

/// @nodoc
@JsonSerializable()
class _SismoDto implements SismoDto {
  const _SismoDto(
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
  factory _SismoDto.fromJson(Map<String, dynamic> json) =>
      _$SismoDtoFromJson(json);

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

  /// Create a copy of SismoDto
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  _$SismoDtoCopyWith<_SismoDto> get copyWith =>
      __$SismoDtoCopyWithImpl<_SismoDto>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$SismoDtoToJson(
      this,
    );
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _SismoDto &&
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

  @override
  String toString() {
    return 'SismoDto(id: $id, magnitude: $magnitude, magType: $magType, place: $place, timeUtc: $timeUtc, depthKm: $depthKm, latitude: $latitude, longitude: $longitude, alert: $alert, tsunami: $tsunami, urlUsgs: $urlUsgs)';
  }
}

/// @nodoc
abstract mixin class _$SismoDtoCopyWith<$Res>
    implements $SismoDtoCopyWith<$Res> {
  factory _$SismoDtoCopyWith(_SismoDto value, $Res Function(_SismoDto) _then) =
      __$SismoDtoCopyWithImpl;
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
class __$SismoDtoCopyWithImpl<$Res> implements _$SismoDtoCopyWith<$Res> {
  __$SismoDtoCopyWithImpl(this._self, this._then);

  final _SismoDto _self;
  final $Res Function(_SismoDto) _then;

  /// Create a copy of SismoDto
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
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
    return _then(_SismoDto(
      id: null == id
          ? _self.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      magnitude: null == magnitude
          ? _self.magnitude
          : magnitude // ignore: cast_nullable_to_non_nullable
              as double,
      magType: freezed == magType
          ? _self.magType
          : magType // ignore: cast_nullable_to_non_nullable
              as String?,
      place: freezed == place
          ? _self.place
          : place // ignore: cast_nullable_to_non_nullable
              as String?,
      timeUtc: null == timeUtc
          ? _self.timeUtc
          : timeUtc // ignore: cast_nullable_to_non_nullable
              as DateTime,
      depthKm: freezed == depthKm
          ? _self.depthKm
          : depthKm // ignore: cast_nullable_to_non_nullable
              as double?,
      latitude: null == latitude
          ? _self.latitude
          : latitude // ignore: cast_nullable_to_non_nullable
              as double,
      longitude: null == longitude
          ? _self.longitude
          : longitude // ignore: cast_nullable_to_non_nullable
              as double,
      alert: freezed == alert
          ? _self.alert
          : alert // ignore: cast_nullable_to_non_nullable
              as String?,
      tsunami: freezed == tsunami
          ? _self.tsunami
          : tsunami // ignore: cast_nullable_to_non_nullable
              as int?,
      urlUsgs: freezed == urlUsgs
          ? _self.urlUsgs
          : urlUsgs // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

// dart format on
