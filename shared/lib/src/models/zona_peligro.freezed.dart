// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'zona_peligro.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$ZonaPeligro {
  String get id;
  String? get nombre;
  List<List<double>> get polygonCoords; // [[lat, lng], [lat, lng], ...]
  @JsonKey(name: 'nivel_riesgo')
  int? get nivelRiesgo;
  @JsonKey(name: 'tipo_riesgo')
  String? get tipoRiesgo;
  String? get descripcion;
  @JsonKey(name: 'horario_critico')
  String? get horarioCritico;
  @JsonKey(name: 'vigente_desde')
  DateTime? get vigenteDesde;
  @JsonKey(name: 'vigente_hasta')
  DateTime? get vigenteHasta;
  @JsonKey(name: 'created_by')
  String? get createdBy;
  @JsonKey(name: 'created_at')
  DateTime? get createdAt;
  @JsonKey(name: 'updated_at')
  DateTime? get updatedAt;

  /// Create a copy of ZonaPeligro
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $ZonaPeligroCopyWith<ZonaPeligro> get copyWith =>
      _$ZonaPeligroCopyWithImpl<ZonaPeligro>(this as ZonaPeligro, _$identity);

  /// Serializes this ZonaPeligro to a JSON map.
  Map<String, dynamic> toJson();

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is ZonaPeligro &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.nombre, nombre) || other.nombre == nombre) &&
            const DeepCollectionEquality()
                .equals(other.polygonCoords, polygonCoords) &&
            (identical(other.nivelRiesgo, nivelRiesgo) ||
                other.nivelRiesgo == nivelRiesgo) &&
            (identical(other.tipoRiesgo, tipoRiesgo) ||
                other.tipoRiesgo == tipoRiesgo) &&
            (identical(other.descripcion, descripcion) ||
                other.descripcion == descripcion) &&
            (identical(other.horarioCritico, horarioCritico) ||
                other.horarioCritico == horarioCritico) &&
            (identical(other.vigenteDesde, vigenteDesde) ||
                other.vigenteDesde == vigenteDesde) &&
            (identical(other.vigenteHasta, vigenteHasta) ||
                other.vigenteHasta == vigenteHasta) &&
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
      nombre,
      const DeepCollectionEquality().hash(polygonCoords),
      nivelRiesgo,
      tipoRiesgo,
      descripcion,
      horarioCritico,
      vigenteDesde,
      vigenteHasta,
      createdBy,
      createdAt,
      updatedAt);

  @override
  String toString() {
    return 'ZonaPeligro(id: $id, nombre: $nombre, polygonCoords: $polygonCoords, nivelRiesgo: $nivelRiesgo, tipoRiesgo: $tipoRiesgo, descripcion: $descripcion, horarioCritico: $horarioCritico, vigenteDesde: $vigenteDesde, vigenteHasta: $vigenteHasta, createdBy: $createdBy, createdAt: $createdAt, updatedAt: $updatedAt)';
  }
}

/// @nodoc
abstract mixin class $ZonaPeligroCopyWith<$Res> {
  factory $ZonaPeligroCopyWith(
          ZonaPeligro value, $Res Function(ZonaPeligro) _then) =
      _$ZonaPeligroCopyWithImpl;
  @useResult
  $Res call(
      {String id,
      String? nombre,
      List<List<double>> polygonCoords,
      @JsonKey(name: 'nivel_riesgo') int? nivelRiesgo,
      @JsonKey(name: 'tipo_riesgo') String? tipoRiesgo,
      String? descripcion,
      @JsonKey(name: 'horario_critico') String? horarioCritico,
      @JsonKey(name: 'vigente_desde') DateTime? vigenteDesde,
      @JsonKey(name: 'vigente_hasta') DateTime? vigenteHasta,
      @JsonKey(name: 'created_by') String? createdBy,
      @JsonKey(name: 'created_at') DateTime? createdAt,
      @JsonKey(name: 'updated_at') DateTime? updatedAt});
}

/// @nodoc
class _$ZonaPeligroCopyWithImpl<$Res> implements $ZonaPeligroCopyWith<$Res> {
  _$ZonaPeligroCopyWithImpl(this._self, this._then);

  final ZonaPeligro _self;
  final $Res Function(ZonaPeligro) _then;

  /// Create a copy of ZonaPeligro
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? nombre = freezed,
    Object? polygonCoords = null,
    Object? nivelRiesgo = freezed,
    Object? tipoRiesgo = freezed,
    Object? descripcion = freezed,
    Object? horarioCritico = freezed,
    Object? vigenteDesde = freezed,
    Object? vigenteHasta = freezed,
    Object? createdBy = freezed,
    Object? createdAt = freezed,
    Object? updatedAt = freezed,
  }) {
    return _then(_self.copyWith(
      id: null == id
          ? _self.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      nombre: freezed == nombre
          ? _self.nombre
          : nombre // ignore: cast_nullable_to_non_nullable
              as String?,
      polygonCoords: null == polygonCoords
          ? _self.polygonCoords
          : polygonCoords // ignore: cast_nullable_to_non_nullable
              as List<List<double>>,
      nivelRiesgo: freezed == nivelRiesgo
          ? _self.nivelRiesgo
          : nivelRiesgo // ignore: cast_nullable_to_non_nullable
              as int?,
      tipoRiesgo: freezed == tipoRiesgo
          ? _self.tipoRiesgo
          : tipoRiesgo // ignore: cast_nullable_to_non_nullable
              as String?,
      descripcion: freezed == descripcion
          ? _self.descripcion
          : descripcion // ignore: cast_nullable_to_non_nullable
              as String?,
      horarioCritico: freezed == horarioCritico
          ? _self.horarioCritico
          : horarioCritico // ignore: cast_nullable_to_non_nullable
              as String?,
      vigenteDesde: freezed == vigenteDesde
          ? _self.vigenteDesde
          : vigenteDesde // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      vigenteHasta: freezed == vigenteHasta
          ? _self.vigenteHasta
          : vigenteHasta // ignore: cast_nullable_to_non_nullable
              as DateTime?,
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

/// Adds pattern-matching-related methods to [ZonaPeligro].
extension ZonaPeligroPatterns on ZonaPeligro {
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
    TResult Function(_ZonaPeligro value)? $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _ZonaPeligro() when $default != null:
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
    TResult Function(_ZonaPeligro value) $default,
  ) {
    final _that = this;
    switch (_that) {
      case _ZonaPeligro():
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
    TResult? Function(_ZonaPeligro value)? $default,
  ) {
    final _that = this;
    switch (_that) {
      case _ZonaPeligro() when $default != null:
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
            String? nombre,
            List<List<double>> polygonCoords,
            @JsonKey(name: 'nivel_riesgo') int? nivelRiesgo,
            @JsonKey(name: 'tipo_riesgo') String? tipoRiesgo,
            String? descripcion,
            @JsonKey(name: 'horario_critico') String? horarioCritico,
            @JsonKey(name: 'vigente_desde') DateTime? vigenteDesde,
            @JsonKey(name: 'vigente_hasta') DateTime? vigenteHasta,
            @JsonKey(name: 'created_by') String? createdBy,
            @JsonKey(name: 'created_at') DateTime? createdAt,
            @JsonKey(name: 'updated_at') DateTime? updatedAt)?
        $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _ZonaPeligro() when $default != null:
        return $default(
            _that.id,
            _that.nombre,
            _that.polygonCoords,
            _that.nivelRiesgo,
            _that.tipoRiesgo,
            _that.descripcion,
            _that.horarioCritico,
            _that.vigenteDesde,
            _that.vigenteHasta,
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
            String? nombre,
            List<List<double>> polygonCoords,
            @JsonKey(name: 'nivel_riesgo') int? nivelRiesgo,
            @JsonKey(name: 'tipo_riesgo') String? tipoRiesgo,
            String? descripcion,
            @JsonKey(name: 'horario_critico') String? horarioCritico,
            @JsonKey(name: 'vigente_desde') DateTime? vigenteDesde,
            @JsonKey(name: 'vigente_hasta') DateTime? vigenteHasta,
            @JsonKey(name: 'created_by') String? createdBy,
            @JsonKey(name: 'created_at') DateTime? createdAt,
            @JsonKey(name: 'updated_at') DateTime? updatedAt)
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _ZonaPeligro():
        return $default(
            _that.id,
            _that.nombre,
            _that.polygonCoords,
            _that.nivelRiesgo,
            _that.tipoRiesgo,
            _that.descripcion,
            _that.horarioCritico,
            _that.vigenteDesde,
            _that.vigenteHasta,
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
            String? nombre,
            List<List<double>> polygonCoords,
            @JsonKey(name: 'nivel_riesgo') int? nivelRiesgo,
            @JsonKey(name: 'tipo_riesgo') String? tipoRiesgo,
            String? descripcion,
            @JsonKey(name: 'horario_critico') String? horarioCritico,
            @JsonKey(name: 'vigente_desde') DateTime? vigenteDesde,
            @JsonKey(name: 'vigente_hasta') DateTime? vigenteHasta,
            @JsonKey(name: 'created_by') String? createdBy,
            @JsonKey(name: 'created_at') DateTime? createdAt,
            @JsonKey(name: 'updated_at') DateTime? updatedAt)?
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _ZonaPeligro() when $default != null:
        return $default(
            _that.id,
            _that.nombre,
            _that.polygonCoords,
            _that.nivelRiesgo,
            _that.tipoRiesgo,
            _that.descripcion,
            _that.horarioCritico,
            _that.vigenteDesde,
            _that.vigenteHasta,
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
class _ZonaPeligro implements ZonaPeligro {
  const _ZonaPeligro(
      {required this.id,
      this.nombre,
      required final List<List<double>> polygonCoords,
      @JsonKey(name: 'nivel_riesgo') this.nivelRiesgo,
      @JsonKey(name: 'tipo_riesgo') this.tipoRiesgo,
      this.descripcion,
      @JsonKey(name: 'horario_critico') this.horarioCritico,
      @JsonKey(name: 'vigente_desde') this.vigenteDesde,
      @JsonKey(name: 'vigente_hasta') this.vigenteHasta,
      @JsonKey(name: 'created_by') this.createdBy,
      @JsonKey(name: 'created_at') this.createdAt,
      @JsonKey(name: 'updated_at') this.updatedAt})
      : _polygonCoords = polygonCoords;
  factory _ZonaPeligro.fromJson(Map<String, dynamic> json) =>
      _$ZonaPeligroFromJson(json);

  @override
  final String id;
  @override
  final String? nombre;
  final List<List<double>> _polygonCoords;
  @override
  List<List<double>> get polygonCoords {
    if (_polygonCoords is EqualUnmodifiableListView) return _polygonCoords;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_polygonCoords);
  }

// [[lat, lng], [lat, lng], ...]
  @override
  @JsonKey(name: 'nivel_riesgo')
  final int? nivelRiesgo;
  @override
  @JsonKey(name: 'tipo_riesgo')
  final String? tipoRiesgo;
  @override
  final String? descripcion;
  @override
  @JsonKey(name: 'horario_critico')
  final String? horarioCritico;
  @override
  @JsonKey(name: 'vigente_desde')
  final DateTime? vigenteDesde;
  @override
  @JsonKey(name: 'vigente_hasta')
  final DateTime? vigenteHasta;
  @override
  @JsonKey(name: 'created_by')
  final String? createdBy;
  @override
  @JsonKey(name: 'created_at')
  final DateTime? createdAt;
  @override
  @JsonKey(name: 'updated_at')
  final DateTime? updatedAt;

  /// Create a copy of ZonaPeligro
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  _$ZonaPeligroCopyWith<_ZonaPeligro> get copyWith =>
      __$ZonaPeligroCopyWithImpl<_ZonaPeligro>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$ZonaPeligroToJson(
      this,
    );
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _ZonaPeligro &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.nombre, nombre) || other.nombre == nombre) &&
            const DeepCollectionEquality()
                .equals(other._polygonCoords, _polygonCoords) &&
            (identical(other.nivelRiesgo, nivelRiesgo) ||
                other.nivelRiesgo == nivelRiesgo) &&
            (identical(other.tipoRiesgo, tipoRiesgo) ||
                other.tipoRiesgo == tipoRiesgo) &&
            (identical(other.descripcion, descripcion) ||
                other.descripcion == descripcion) &&
            (identical(other.horarioCritico, horarioCritico) ||
                other.horarioCritico == horarioCritico) &&
            (identical(other.vigenteDesde, vigenteDesde) ||
                other.vigenteDesde == vigenteDesde) &&
            (identical(other.vigenteHasta, vigenteHasta) ||
                other.vigenteHasta == vigenteHasta) &&
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
      nombre,
      const DeepCollectionEquality().hash(_polygonCoords),
      nivelRiesgo,
      tipoRiesgo,
      descripcion,
      horarioCritico,
      vigenteDesde,
      vigenteHasta,
      createdBy,
      createdAt,
      updatedAt);

  @override
  String toString() {
    return 'ZonaPeligro(id: $id, nombre: $nombre, polygonCoords: $polygonCoords, nivelRiesgo: $nivelRiesgo, tipoRiesgo: $tipoRiesgo, descripcion: $descripcion, horarioCritico: $horarioCritico, vigenteDesde: $vigenteDesde, vigenteHasta: $vigenteHasta, createdBy: $createdBy, createdAt: $createdAt, updatedAt: $updatedAt)';
  }
}

/// @nodoc
abstract mixin class _$ZonaPeligroCopyWith<$Res>
    implements $ZonaPeligroCopyWith<$Res> {
  factory _$ZonaPeligroCopyWith(
          _ZonaPeligro value, $Res Function(_ZonaPeligro) _then) =
      __$ZonaPeligroCopyWithImpl;
  @override
  @useResult
  $Res call(
      {String id,
      String? nombre,
      List<List<double>> polygonCoords,
      @JsonKey(name: 'nivel_riesgo') int? nivelRiesgo,
      @JsonKey(name: 'tipo_riesgo') String? tipoRiesgo,
      String? descripcion,
      @JsonKey(name: 'horario_critico') String? horarioCritico,
      @JsonKey(name: 'vigente_desde') DateTime? vigenteDesde,
      @JsonKey(name: 'vigente_hasta') DateTime? vigenteHasta,
      @JsonKey(name: 'created_by') String? createdBy,
      @JsonKey(name: 'created_at') DateTime? createdAt,
      @JsonKey(name: 'updated_at') DateTime? updatedAt});
}

/// @nodoc
class __$ZonaPeligroCopyWithImpl<$Res> implements _$ZonaPeligroCopyWith<$Res> {
  __$ZonaPeligroCopyWithImpl(this._self, this._then);

  final _ZonaPeligro _self;
  final $Res Function(_ZonaPeligro) _then;

  /// Create a copy of ZonaPeligro
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $Res call({
    Object? id = null,
    Object? nombre = freezed,
    Object? polygonCoords = null,
    Object? nivelRiesgo = freezed,
    Object? tipoRiesgo = freezed,
    Object? descripcion = freezed,
    Object? horarioCritico = freezed,
    Object? vigenteDesde = freezed,
    Object? vigenteHasta = freezed,
    Object? createdBy = freezed,
    Object? createdAt = freezed,
    Object? updatedAt = freezed,
  }) {
    return _then(_ZonaPeligro(
      id: null == id
          ? _self.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      nombre: freezed == nombre
          ? _self.nombre
          : nombre // ignore: cast_nullable_to_non_nullable
              as String?,
      polygonCoords: null == polygonCoords
          ? _self._polygonCoords
          : polygonCoords // ignore: cast_nullable_to_non_nullable
              as List<List<double>>,
      nivelRiesgo: freezed == nivelRiesgo
          ? _self.nivelRiesgo
          : nivelRiesgo // ignore: cast_nullable_to_non_nullable
              as int?,
      tipoRiesgo: freezed == tipoRiesgo
          ? _self.tipoRiesgo
          : tipoRiesgo // ignore: cast_nullable_to_non_nullable
              as String?,
      descripcion: freezed == descripcion
          ? _self.descripcion
          : descripcion // ignore: cast_nullable_to_non_nullable
              as String?,
      horarioCritico: freezed == horarioCritico
          ? _self.horarioCritico
          : horarioCritico // ignore: cast_nullable_to_non_nullable
              as String?,
      vigenteDesde: freezed == vigenteDesde
          ? _self.vigenteDesde
          : vigenteDesde // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      vigenteHasta: freezed == vigenteHasta
          ? _self.vigenteHasta
          : vigenteHasta // ignore: cast_nullable_to_non_nullable
              as DateTime?,
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
