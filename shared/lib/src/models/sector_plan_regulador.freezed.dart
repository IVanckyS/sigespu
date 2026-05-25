// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'sector_plan_regulador.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$SectorPlanRegulador {
  String get id;
  String? get codigo;
  String? get nombre;
  @JsonKey(name: 'sector_padre')
  String? get sectorPadre;
  List<List<double>> get polygonCoords;
  @JsonKey(name: 'usos_permitidos')
  Map<String, dynamic>? get usosPermitidos;
  @JsonKey(name: 'usos_prohibidos')
  Map<String, dynamic>? get usosProhibidos;
  String? get fuente;
  bool get vigente;
  @JsonKey(name: 'created_at')
  DateTime? get createdAt;

  /// Create a copy of SectorPlanRegulador
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $SectorPlanReguladorCopyWith<SectorPlanRegulador> get copyWith =>
      _$SectorPlanReguladorCopyWithImpl<SectorPlanRegulador>(
          this as SectorPlanRegulador, _$identity);

  /// Serializes this SectorPlanRegulador to a JSON map.
  Map<String, dynamic> toJson();

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is SectorPlanRegulador &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.codigo, codigo) || other.codigo == codigo) &&
            (identical(other.nombre, nombre) || other.nombre == nombre) &&
            (identical(other.sectorPadre, sectorPadre) ||
                other.sectorPadre == sectorPadre) &&
            const DeepCollectionEquality()
                .equals(other.polygonCoords, polygonCoords) &&
            const DeepCollectionEquality()
                .equals(other.usosPermitidos, usosPermitidos) &&
            const DeepCollectionEquality()
                .equals(other.usosProhibidos, usosProhibidos) &&
            (identical(other.fuente, fuente) || other.fuente == fuente) &&
            (identical(other.vigente, vigente) || other.vigente == vigente) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      id,
      codigo,
      nombre,
      sectorPadre,
      const DeepCollectionEquality().hash(polygonCoords),
      const DeepCollectionEquality().hash(usosPermitidos),
      const DeepCollectionEquality().hash(usosProhibidos),
      fuente,
      vigente,
      createdAt);

  @override
  String toString() {
    return 'SectorPlanRegulador(id: $id, codigo: $codigo, nombre: $nombre, sectorPadre: $sectorPadre, polygonCoords: $polygonCoords, usosPermitidos: $usosPermitidos, usosProhibidos: $usosProhibidos, fuente: $fuente, vigente: $vigente, createdAt: $createdAt)';
  }
}

/// @nodoc
abstract mixin class $SectorPlanReguladorCopyWith<$Res> {
  factory $SectorPlanReguladorCopyWith(
          SectorPlanRegulador value, $Res Function(SectorPlanRegulador) _then) =
      _$SectorPlanReguladorCopyWithImpl;
  @useResult
  $Res call(
      {String id,
      String? codigo,
      String? nombre,
      @JsonKey(name: 'sector_padre') String? sectorPadre,
      List<List<double>> polygonCoords,
      @JsonKey(name: 'usos_permitidos') Map<String, dynamic>? usosPermitidos,
      @JsonKey(name: 'usos_prohibidos') Map<String, dynamic>? usosProhibidos,
      String? fuente,
      bool vigente,
      @JsonKey(name: 'created_at') DateTime? createdAt});
}

/// @nodoc
class _$SectorPlanReguladorCopyWithImpl<$Res>
    implements $SectorPlanReguladorCopyWith<$Res> {
  _$SectorPlanReguladorCopyWithImpl(this._self, this._then);

  final SectorPlanRegulador _self;
  final $Res Function(SectorPlanRegulador) _then;

  /// Create a copy of SectorPlanRegulador
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? codigo = freezed,
    Object? nombre = freezed,
    Object? sectorPadre = freezed,
    Object? polygonCoords = null,
    Object? usosPermitidos = freezed,
    Object? usosProhibidos = freezed,
    Object? fuente = freezed,
    Object? vigente = null,
    Object? createdAt = freezed,
  }) {
    return _then(_self.copyWith(
      id: null == id
          ? _self.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      codigo: freezed == codigo
          ? _self.codigo
          : codigo // ignore: cast_nullable_to_non_nullable
              as String?,
      nombre: freezed == nombre
          ? _self.nombre
          : nombre // ignore: cast_nullable_to_non_nullable
              as String?,
      sectorPadre: freezed == sectorPadre
          ? _self.sectorPadre
          : sectorPadre // ignore: cast_nullable_to_non_nullable
              as String?,
      polygonCoords: null == polygonCoords
          ? _self.polygonCoords
          : polygonCoords // ignore: cast_nullable_to_non_nullable
              as List<List<double>>,
      usosPermitidos: freezed == usosPermitidos
          ? _self.usosPermitidos
          : usosPermitidos // ignore: cast_nullable_to_non_nullable
              as Map<String, dynamic>?,
      usosProhibidos: freezed == usosProhibidos
          ? _self.usosProhibidos
          : usosProhibidos // ignore: cast_nullable_to_non_nullable
              as Map<String, dynamic>?,
      fuente: freezed == fuente
          ? _self.fuente
          : fuente // ignore: cast_nullable_to_non_nullable
              as String?,
      vigente: null == vigente
          ? _self.vigente
          : vigente // ignore: cast_nullable_to_non_nullable
              as bool,
      createdAt: freezed == createdAt
          ? _self.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
    ));
  }
}

/// Adds pattern-matching-related methods to [SectorPlanRegulador].
extension SectorPlanReguladorPatterns on SectorPlanRegulador {
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
    TResult Function(_SectorPlanRegulador value)? $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _SectorPlanRegulador() when $default != null:
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
    TResult Function(_SectorPlanRegulador value) $default,
  ) {
    final _that = this;
    switch (_that) {
      case _SectorPlanRegulador():
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
    TResult? Function(_SectorPlanRegulador value)? $default,
  ) {
    final _that = this;
    switch (_that) {
      case _SectorPlanRegulador() when $default != null:
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
            String? codigo,
            String? nombre,
            @JsonKey(name: 'sector_padre') String? sectorPadre,
            List<List<double>> polygonCoords,
            @JsonKey(name: 'usos_permitidos')
            Map<String, dynamic>? usosPermitidos,
            @JsonKey(name: 'usos_prohibidos')
            Map<String, dynamic>? usosProhibidos,
            String? fuente,
            bool vigente,
            @JsonKey(name: 'created_at') DateTime? createdAt)?
        $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _SectorPlanRegulador() when $default != null:
        return $default(
            _that.id,
            _that.codigo,
            _that.nombre,
            _that.sectorPadre,
            _that.polygonCoords,
            _that.usosPermitidos,
            _that.usosProhibidos,
            _that.fuente,
            _that.vigente,
            _that.createdAt);
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
            String? codigo,
            String? nombre,
            @JsonKey(name: 'sector_padre') String? sectorPadre,
            List<List<double>> polygonCoords,
            @JsonKey(name: 'usos_permitidos')
            Map<String, dynamic>? usosPermitidos,
            @JsonKey(name: 'usos_prohibidos')
            Map<String, dynamic>? usosProhibidos,
            String? fuente,
            bool vigente,
            @JsonKey(name: 'created_at') DateTime? createdAt)
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _SectorPlanRegulador():
        return $default(
            _that.id,
            _that.codigo,
            _that.nombre,
            _that.sectorPadre,
            _that.polygonCoords,
            _that.usosPermitidos,
            _that.usosProhibidos,
            _that.fuente,
            _that.vigente,
            _that.createdAt);
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
            String? codigo,
            String? nombre,
            @JsonKey(name: 'sector_padre') String? sectorPadre,
            List<List<double>> polygonCoords,
            @JsonKey(name: 'usos_permitidos')
            Map<String, dynamic>? usosPermitidos,
            @JsonKey(name: 'usos_prohibidos')
            Map<String, dynamic>? usosProhibidos,
            String? fuente,
            bool vigente,
            @JsonKey(name: 'created_at') DateTime? createdAt)?
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _SectorPlanRegulador() when $default != null:
        return $default(
            _that.id,
            _that.codigo,
            _that.nombre,
            _that.sectorPadre,
            _that.polygonCoords,
            _that.usosPermitidos,
            _that.usosProhibidos,
            _that.fuente,
            _that.vigente,
            _that.createdAt);
      case _:
        return null;
    }
  }
}

/// @nodoc
@JsonSerializable()
class _SectorPlanRegulador implements SectorPlanRegulador {
  const _SectorPlanRegulador(
      {required this.id,
      this.codigo,
      this.nombre,
      @JsonKey(name: 'sector_padre') this.sectorPadre,
      required final List<List<double>> polygonCoords,
      @JsonKey(name: 'usos_permitidos')
      final Map<String, dynamic>? usosPermitidos,
      @JsonKey(name: 'usos_prohibidos')
      final Map<String, dynamic>? usosProhibidos,
      this.fuente,
      this.vigente = true,
      @JsonKey(name: 'created_at') this.createdAt})
      : _polygonCoords = polygonCoords,
        _usosPermitidos = usosPermitidos,
        _usosProhibidos = usosProhibidos;
  factory _SectorPlanRegulador.fromJson(Map<String, dynamic> json) =>
      _$SectorPlanReguladorFromJson(json);

  @override
  final String id;
  @override
  final String? codigo;
  @override
  final String? nombre;
  @override
  @JsonKey(name: 'sector_padre')
  final String? sectorPadre;
  final List<List<double>> _polygonCoords;
  @override
  List<List<double>> get polygonCoords {
    if (_polygonCoords is EqualUnmodifiableListView) return _polygonCoords;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_polygonCoords);
  }

  final Map<String, dynamic>? _usosPermitidos;
  @override
  @JsonKey(name: 'usos_permitidos')
  Map<String, dynamic>? get usosPermitidos {
    final value = _usosPermitidos;
    if (value == null) return null;
    if (_usosPermitidos is EqualUnmodifiableMapView) return _usosPermitidos;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(value);
  }

  final Map<String, dynamic>? _usosProhibidos;
  @override
  @JsonKey(name: 'usos_prohibidos')
  Map<String, dynamic>? get usosProhibidos {
    final value = _usosProhibidos;
    if (value == null) return null;
    if (_usosProhibidos is EqualUnmodifiableMapView) return _usosProhibidos;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(value);
  }

  @override
  final String? fuente;
  @override
  @JsonKey()
  final bool vigente;
  @override
  @JsonKey(name: 'created_at')
  final DateTime? createdAt;

  /// Create a copy of SectorPlanRegulador
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  _$SectorPlanReguladorCopyWith<_SectorPlanRegulador> get copyWith =>
      __$SectorPlanReguladorCopyWithImpl<_SectorPlanRegulador>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$SectorPlanReguladorToJson(
      this,
    );
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _SectorPlanRegulador &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.codigo, codigo) || other.codigo == codigo) &&
            (identical(other.nombre, nombre) || other.nombre == nombre) &&
            (identical(other.sectorPadre, sectorPadre) ||
                other.sectorPadre == sectorPadre) &&
            const DeepCollectionEquality()
                .equals(other._polygonCoords, _polygonCoords) &&
            const DeepCollectionEquality()
                .equals(other._usosPermitidos, _usosPermitidos) &&
            const DeepCollectionEquality()
                .equals(other._usosProhibidos, _usosProhibidos) &&
            (identical(other.fuente, fuente) || other.fuente == fuente) &&
            (identical(other.vigente, vigente) || other.vigente == vigente) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      id,
      codigo,
      nombre,
      sectorPadre,
      const DeepCollectionEquality().hash(_polygonCoords),
      const DeepCollectionEquality().hash(_usosPermitidos),
      const DeepCollectionEquality().hash(_usosProhibidos),
      fuente,
      vigente,
      createdAt);

  @override
  String toString() {
    return 'SectorPlanRegulador(id: $id, codigo: $codigo, nombre: $nombre, sectorPadre: $sectorPadre, polygonCoords: $polygonCoords, usosPermitidos: $usosPermitidos, usosProhibidos: $usosProhibidos, fuente: $fuente, vigente: $vigente, createdAt: $createdAt)';
  }
}

/// @nodoc
abstract mixin class _$SectorPlanReguladorCopyWith<$Res>
    implements $SectorPlanReguladorCopyWith<$Res> {
  factory _$SectorPlanReguladorCopyWith(_SectorPlanRegulador value,
          $Res Function(_SectorPlanRegulador) _then) =
      __$SectorPlanReguladorCopyWithImpl;
  @override
  @useResult
  $Res call(
      {String id,
      String? codigo,
      String? nombre,
      @JsonKey(name: 'sector_padre') String? sectorPadre,
      List<List<double>> polygonCoords,
      @JsonKey(name: 'usos_permitidos') Map<String, dynamic>? usosPermitidos,
      @JsonKey(name: 'usos_prohibidos') Map<String, dynamic>? usosProhibidos,
      String? fuente,
      bool vigente,
      @JsonKey(name: 'created_at') DateTime? createdAt});
}

/// @nodoc
class __$SectorPlanReguladorCopyWithImpl<$Res>
    implements _$SectorPlanReguladorCopyWith<$Res> {
  __$SectorPlanReguladorCopyWithImpl(this._self, this._then);

  final _SectorPlanRegulador _self;
  final $Res Function(_SectorPlanRegulador) _then;

  /// Create a copy of SectorPlanRegulador
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $Res call({
    Object? id = null,
    Object? codigo = freezed,
    Object? nombre = freezed,
    Object? sectorPadre = freezed,
    Object? polygonCoords = null,
    Object? usosPermitidos = freezed,
    Object? usosProhibidos = freezed,
    Object? fuente = freezed,
    Object? vigente = null,
    Object? createdAt = freezed,
  }) {
    return _then(_SectorPlanRegulador(
      id: null == id
          ? _self.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      codigo: freezed == codigo
          ? _self.codigo
          : codigo // ignore: cast_nullable_to_non_nullable
              as String?,
      nombre: freezed == nombre
          ? _self.nombre
          : nombre // ignore: cast_nullable_to_non_nullable
              as String?,
      sectorPadre: freezed == sectorPadre
          ? _self.sectorPadre
          : sectorPadre // ignore: cast_nullable_to_non_nullable
              as String?,
      polygonCoords: null == polygonCoords
          ? _self._polygonCoords
          : polygonCoords // ignore: cast_nullable_to_non_nullable
              as List<List<double>>,
      usosPermitidos: freezed == usosPermitidos
          ? _self._usosPermitidos
          : usosPermitidos // ignore: cast_nullable_to_non_nullable
              as Map<String, dynamic>?,
      usosProhibidos: freezed == usosProhibidos
          ? _self._usosProhibidos
          : usosProhibidos // ignore: cast_nullable_to_non_nullable
              as Map<String, dynamic>?,
      fuente: freezed == fuente
          ? _self.fuente
          : fuente // ignore: cast_nullable_to_non_nullable
              as String?,
      vigente: null == vigente
          ? _self.vigente
          : vigente // ignore: cast_nullable_to_non_nullable
              as bool,
      createdAt: freezed == createdAt
          ? _self.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
    ));
  }
}

// dart format on
