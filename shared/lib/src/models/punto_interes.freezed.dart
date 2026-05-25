// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'punto_interes.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$PuntoInteres {
  String get id;
  String get tipo;
  String? get nombre;
  String? get descripcion;
  String? get direccion;
  double get lat;
  double get lng;
  Map<String, dynamic>? get metadata;
  String get estado;
  String get origen;
  @JsonKey(name: 'fuente_origen')
  String? get fuenteOrigen;
  @JsonKey(name: 'created_by')
  String? get createdBy;
  @JsonKey(name: 'created_at')
  DateTime? get createdAt;
  @JsonKey(name: 'updated_at')
  DateTime? get updatedAt;

  /// Create a copy of PuntoInteres
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $PuntoInteresCopyWith<PuntoInteres> get copyWith =>
      _$PuntoInteresCopyWithImpl<PuntoInteres>(
          this as PuntoInteres, _$identity);

  /// Serializes this PuntoInteres to a JSON map.
  Map<String, dynamic> toJson();

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is PuntoInteres &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.tipo, tipo) || other.tipo == tipo) &&
            (identical(other.nombre, nombre) || other.nombre == nombre) &&
            (identical(other.descripcion, descripcion) ||
                other.descripcion == descripcion) &&
            (identical(other.direccion, direccion) ||
                other.direccion == direccion) &&
            (identical(other.lat, lat) || other.lat == lat) &&
            (identical(other.lng, lng) || other.lng == lng) &&
            const DeepCollectionEquality().equals(other.metadata, metadata) &&
            (identical(other.estado, estado) || other.estado == estado) &&
            (identical(other.origen, origen) || other.origen == origen) &&
            (identical(other.fuenteOrigen, fuenteOrigen) ||
                other.fuenteOrigen == fuenteOrigen) &&
            (identical(other.createdBy, createdBy) ||
                other.createdBy == createdBy) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.updatedAt, updatedAt) ||
                other.updatedAt == updatedAt));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      id,
      tipo,
      nombre,
      descripcion,
      direccion,
      lat,
      lng,
      const DeepCollectionEquality().hash(metadata),
      estado,
      origen,
      fuenteOrigen,
      createdBy,
      createdAt,
      updatedAt);

  @override
  String toString() {
    return 'PuntoInteres(id: $id, tipo: $tipo, nombre: $nombre, descripcion: $descripcion, direccion: $direccion, lat: $lat, lng: $lng, metadata: $metadata, estado: $estado, origen: $origen, fuenteOrigen: $fuenteOrigen, createdBy: $createdBy, createdAt: $createdAt, updatedAt: $updatedAt)';
  }
}

/// @nodoc
abstract mixin class $PuntoInteresCopyWith<$Res> {
  factory $PuntoInteresCopyWith(
          PuntoInteres value, $Res Function(PuntoInteres) _then) =
      _$PuntoInteresCopyWithImpl;
  @useResult
  $Res call(
      {String id,
      String tipo,
      String? nombre,
      String? descripcion,
      String? direccion,
      double lat,
      double lng,
      Map<String, dynamic>? metadata,
      String estado,
      String origen,
      @JsonKey(name: 'fuente_origen') String? fuenteOrigen,
      @JsonKey(name: 'created_by') String? createdBy,
      @JsonKey(name: 'created_at') DateTime? createdAt,
      @JsonKey(name: 'updated_at') DateTime? updatedAt});
}

/// @nodoc
class _$PuntoInteresCopyWithImpl<$Res> implements $PuntoInteresCopyWith<$Res> {
  _$PuntoInteresCopyWithImpl(this._self, this._then);

  final PuntoInteres _self;
  final $Res Function(PuntoInteres) _then;

  /// Create a copy of PuntoInteres
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? tipo = null,
    Object? nombre = freezed,
    Object? descripcion = freezed,
    Object? direccion = freezed,
    Object? lat = null,
    Object? lng = null,
    Object? metadata = freezed,
    Object? estado = null,
    Object? origen = null,
    Object? fuenteOrigen = freezed,
    Object? createdBy = freezed,
    Object? createdAt = freezed,
    Object? updatedAt = freezed,
  }) {
    return _then(_self.copyWith(
      id: null == id
          ? _self.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      tipo: null == tipo
          ? _self.tipo
          : tipo // ignore: cast_nullable_to_non_nullable
              as String,
      nombre: freezed == nombre
          ? _self.nombre
          : nombre // ignore: cast_nullable_to_non_nullable
              as String?,
      descripcion: freezed == descripcion
          ? _self.descripcion
          : descripcion // ignore: cast_nullable_to_non_nullable
              as String?,
      direccion: freezed == direccion
          ? _self.direccion
          : direccion // ignore: cast_nullable_to_non_nullable
              as String?,
      lat: null == lat
          ? _self.lat
          : lat // ignore: cast_nullable_to_non_nullable
              as double,
      lng: null == lng
          ? _self.lng
          : lng // ignore: cast_nullable_to_non_nullable
              as double,
      metadata: freezed == metadata
          ? _self.metadata
          : metadata // ignore: cast_nullable_to_non_nullable
              as Map<String, dynamic>?,
      estado: null == estado
          ? _self.estado
          : estado // ignore: cast_nullable_to_non_nullable
              as String,
      origen: null == origen
          ? _self.origen
          : origen // ignore: cast_nullable_to_non_nullable
              as String,
      fuenteOrigen: freezed == fuenteOrigen
          ? _self.fuenteOrigen
          : fuenteOrigen // ignore: cast_nullable_to_non_nullable
              as String?,
      createdBy: freezed == createdBy
          ? _self.createdBy
          : createdBy // ignore: cast_nullable_to_non_nullable
              as String?,
      createdAt: freezed == createdAt
          ? _self.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      updatedAt: freezed == updatedAt
          ? _self.updatedAt
          : updatedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
    ));
  }
}

/// Adds pattern-matching-related methods to [PuntoInteres].
extension PuntoInteresPatterns on PuntoInteres {
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
    TResult Function(_PuntoInteres value)? $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _PuntoInteres() when $default != null:
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
    TResult Function(_PuntoInteres value) $default,
  ) {
    final _that = this;
    switch (_that) {
      case _PuntoInteres():
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
    TResult? Function(_PuntoInteres value)? $default,
  ) {
    final _that = this;
    switch (_that) {
      case _PuntoInteres() when $default != null:
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
            String tipo,
            String? nombre,
            String? descripcion,
            String? direccion,
            double lat,
            double lng,
            Map<String, dynamic>? metadata,
            String estado,
            String origen,
            @JsonKey(name: 'fuente_origen') String? fuenteOrigen,
            @JsonKey(name: 'created_by') String? createdBy,
            @JsonKey(name: 'created_at') DateTime? createdAt,
            @JsonKey(name: 'updated_at') DateTime? updatedAt)?
        $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _PuntoInteres() when $default != null:
        return $default(
            _that.id,
            _that.tipo,
            _that.nombre,
            _that.descripcion,
            _that.direccion,
            _that.lat,
            _that.lng,
            _that.metadata,
            _that.estado,
            _that.origen,
            _that.fuenteOrigen,
            _that.createdBy,
            _that.createdAt,
            _that.updatedAt);
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
            String tipo,
            String? nombre,
            String? descripcion,
            String? direccion,
            double lat,
            double lng,
            Map<String, dynamic>? metadata,
            String estado,
            String origen,
            @JsonKey(name: 'fuente_origen') String? fuenteOrigen,
            @JsonKey(name: 'created_by') String? createdBy,
            @JsonKey(name: 'created_at') DateTime? createdAt,
            @JsonKey(name: 'updated_at') DateTime? updatedAt)
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _PuntoInteres():
        return $default(
            _that.id,
            _that.tipo,
            _that.nombre,
            _that.descripcion,
            _that.direccion,
            _that.lat,
            _that.lng,
            _that.metadata,
            _that.estado,
            _that.origen,
            _that.fuenteOrigen,
            _that.createdBy,
            _that.createdAt,
            _that.updatedAt);
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
            String tipo,
            String? nombre,
            String? descripcion,
            String? direccion,
            double lat,
            double lng,
            Map<String, dynamic>? metadata,
            String estado,
            String origen,
            @JsonKey(name: 'fuente_origen') String? fuenteOrigen,
            @JsonKey(name: 'created_by') String? createdBy,
            @JsonKey(name: 'created_at') DateTime? createdAt,
            @JsonKey(name: 'updated_at') DateTime? updatedAt)?
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _PuntoInteres() when $default != null:
        return $default(
            _that.id,
            _that.tipo,
            _that.nombre,
            _that.descripcion,
            _that.direccion,
            _that.lat,
            _that.lng,
            _that.metadata,
            _that.estado,
            _that.origen,
            _that.fuenteOrigen,
            _that.createdBy,
            _that.createdAt,
            _that.updatedAt);
      case _:
        return null;
    }
  }
}

/// @nodoc
@JsonSerializable()
class _PuntoInteres implements PuntoInteres {
  const _PuntoInteres(
      {required this.id,
      required this.tipo,
      this.nombre,
      this.descripcion,
      this.direccion,
      required this.lat,
      required this.lng,
      final Map<String, dynamic>? metadata,
      this.estado = 'activo',
      this.origen = 'manual',
      @JsonKey(name: 'fuente_origen') this.fuenteOrigen,
      @JsonKey(name: 'created_by') this.createdBy,
      @JsonKey(name: 'created_at') this.createdAt,
      @JsonKey(name: 'updated_at') this.updatedAt})
      : _metadata = metadata;
  factory _PuntoInteres.fromJson(Map<String, dynamic> json) =>
      _$PuntoInteresFromJson(json);

  @override
  final String id;
  @override
  final String tipo;
  @override
  final String? nombre;
  @override
  final String? descripcion;
  @override
  final String? direccion;
  @override
  final double lat;
  @override
  final double lng;
  final Map<String, dynamic>? _metadata;
  @override
  Map<String, dynamic>? get metadata {
    final value = _metadata;
    if (value == null) return null;
    if (_metadata is EqualUnmodifiableMapView) return _metadata;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(value);
  }

  @override
  @JsonKey()
  final String estado;
  @override
  @JsonKey()
  final String origen;
  @override
  @JsonKey(name: 'fuente_origen')
  final String? fuenteOrigen;
  @override
  @JsonKey(name: 'created_by')
  final String? createdBy;
  @override
  @JsonKey(name: 'created_at')
  final DateTime? createdAt;
  @override
  @JsonKey(name: 'updated_at')
  final DateTime? updatedAt;

  /// Create a copy of PuntoInteres
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  _$PuntoInteresCopyWith<_PuntoInteres> get copyWith =>
      __$PuntoInteresCopyWithImpl<_PuntoInteres>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$PuntoInteresToJson(
      this,
    );
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _PuntoInteres &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.tipo, tipo) || other.tipo == tipo) &&
            (identical(other.nombre, nombre) || other.nombre == nombre) &&
            (identical(other.descripcion, descripcion) ||
                other.descripcion == descripcion) &&
            (identical(other.direccion, direccion) ||
                other.direccion == direccion) &&
            (identical(other.lat, lat) || other.lat == lat) &&
            (identical(other.lng, lng) || other.lng == lng) &&
            const DeepCollectionEquality().equals(other._metadata, _metadata) &&
            (identical(other.estado, estado) || other.estado == estado) &&
            (identical(other.origen, origen) || other.origen == origen) &&
            (identical(other.fuenteOrigen, fuenteOrigen) ||
                other.fuenteOrigen == fuenteOrigen) &&
            (identical(other.createdBy, createdBy) ||
                other.createdBy == createdBy) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.updatedAt, updatedAt) ||
                other.updatedAt == updatedAt));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      id,
      tipo,
      nombre,
      descripcion,
      direccion,
      lat,
      lng,
      const DeepCollectionEquality().hash(_metadata),
      estado,
      origen,
      fuenteOrigen,
      createdBy,
      createdAt,
      updatedAt);

  @override
  String toString() {
    return 'PuntoInteres(id: $id, tipo: $tipo, nombre: $nombre, descripcion: $descripcion, direccion: $direccion, lat: $lat, lng: $lng, metadata: $metadata, estado: $estado, origen: $origen, fuenteOrigen: $fuenteOrigen, createdBy: $createdBy, createdAt: $createdAt, updatedAt: $updatedAt)';
  }
}

/// @nodoc
abstract mixin class _$PuntoInteresCopyWith<$Res>
    implements $PuntoInteresCopyWith<$Res> {
  factory _$PuntoInteresCopyWith(
          _PuntoInteres value, $Res Function(_PuntoInteres) _then) =
      __$PuntoInteresCopyWithImpl;
  @override
  @useResult
  $Res call(
      {String id,
      String tipo,
      String? nombre,
      String? descripcion,
      String? direccion,
      double lat,
      double lng,
      Map<String, dynamic>? metadata,
      String estado,
      String origen,
      @JsonKey(name: 'fuente_origen') String? fuenteOrigen,
      @JsonKey(name: 'created_by') String? createdBy,
      @JsonKey(name: 'created_at') DateTime? createdAt,
      @JsonKey(name: 'updated_at') DateTime? updatedAt});
}

/// @nodoc
class __$PuntoInteresCopyWithImpl<$Res>
    implements _$PuntoInteresCopyWith<$Res> {
  __$PuntoInteresCopyWithImpl(this._self, this._then);

  final _PuntoInteres _self;
  final $Res Function(_PuntoInteres) _then;

  /// Create a copy of PuntoInteres
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $Res call({
    Object? id = null,
    Object? tipo = null,
    Object? nombre = freezed,
    Object? descripcion = freezed,
    Object? direccion = freezed,
    Object? lat = null,
    Object? lng = null,
    Object? metadata = freezed,
    Object? estado = null,
    Object? origen = null,
    Object? fuenteOrigen = freezed,
    Object? createdBy = freezed,
    Object? createdAt = freezed,
    Object? updatedAt = freezed,
  }) {
    return _then(_PuntoInteres(
      id: null == id
          ? _self.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      tipo: null == tipo
          ? _self.tipo
          : tipo // ignore: cast_nullable_to_non_nullable
              as String,
      nombre: freezed == nombre
          ? _self.nombre
          : nombre // ignore: cast_nullable_to_non_nullable
              as String?,
      descripcion: freezed == descripcion
          ? _self.descripcion
          : descripcion // ignore: cast_nullable_to_non_nullable
              as String?,
      direccion: freezed == direccion
          ? _self.direccion
          : direccion // ignore: cast_nullable_to_non_nullable
              as String?,
      lat: null == lat
          ? _self.lat
          : lat // ignore: cast_nullable_to_non_nullable
              as double,
      lng: null == lng
          ? _self.lng
          : lng // ignore: cast_nullable_to_non_nullable
              as double,
      metadata: freezed == metadata
          ? _self._metadata
          : metadata // ignore: cast_nullable_to_non_nullable
              as Map<String, dynamic>?,
      estado: null == estado
          ? _self.estado
          : estado // ignore: cast_nullable_to_non_nullable
              as String,
      origen: null == origen
          ? _self.origen
          : origen // ignore: cast_nullable_to_non_nullable
              as String,
      fuenteOrigen: freezed == fuenteOrigen
          ? _self.fuenteOrigen
          : fuenteOrigen // ignore: cast_nullable_to_non_nullable
              as String?,
      createdBy: freezed == createdBy
          ? _self.createdBy
          : createdBy // ignore: cast_nullable_to_non_nullable
              as String?,
      createdAt: freezed == createdAt
          ? _self.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      updatedAt: freezed == updatedAt
          ? _self.updatedAt
          : updatedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
    ));
  }
}

// dart format on
