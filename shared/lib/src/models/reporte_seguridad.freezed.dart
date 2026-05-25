// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'reporte_seguridad.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$ReporteSeguridad {
  String get id;
  String get tipo;
  double get lat;
  double get lng;
  String? get direccion;
  String? get descripcion;
  int? get severidad;
  @JsonKey(name: 'fecha_evento')
  DateTime? get fechaEvento;
  List<String> get fotos;
  String get estado;
  @JsonKey(name: 'derivado_a')
  String? get derivadoA;
  @JsonKey(name: 'reportado_por')
  String? get reportadoPor;
  @JsonKey(name: 'verificado_por')
  String? get verificadoPor;
  @JsonKey(name: 'created_at')
  DateTime? get createdAt;
  @JsonKey(name: 'updated_at')
  DateTime? get updatedAt;

  /// Create a copy of ReporteSeguridad
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $ReporteSeguridadCopyWith<ReporteSeguridad> get copyWith =>
      _$ReporteSeguridadCopyWithImpl<ReporteSeguridad>(
          this as ReporteSeguridad, _$identity);

  /// Serializes this ReporteSeguridad to a JSON map.
  Map<String, dynamic> toJson();

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is ReporteSeguridad &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.tipo, tipo) || other.tipo == tipo) &&
            (identical(other.lat, lat) || other.lat == lat) &&
            (identical(other.lng, lng) || other.lng == lng) &&
            (identical(other.direccion, direccion) ||
                other.direccion == direccion) &&
            (identical(other.descripcion, descripcion) ||
                other.descripcion == descripcion) &&
            (identical(other.severidad, severidad) ||
                other.severidad == severidad) &&
            (identical(other.fechaEvento, fechaEvento) ||
                other.fechaEvento == fechaEvento) &&
            const DeepCollectionEquality().equals(other.fotos, fotos) &&
            (identical(other.estado, estado) || other.estado == estado) &&
            (identical(other.derivadoA, derivadoA) ||
                other.derivadoA == derivadoA) &&
            (identical(other.reportadoPor, reportadoPor) ||
                other.reportadoPor == reportadoPor) &&
            (identical(other.verificadoPor, verificadoPor) ||
                other.verificadoPor == verificadoPor) &&
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
      lat,
      lng,
      direccion,
      descripcion,
      severidad,
      fechaEvento,
      const DeepCollectionEquality().hash(fotos),
      estado,
      derivadoA,
      reportadoPor,
      verificadoPor,
      createdAt,
      updatedAt);

  @override
  String toString() {
    return 'ReporteSeguridad(id: $id, tipo: $tipo, lat: $lat, lng: $lng, direccion: $direccion, descripcion: $descripcion, severidad: $severidad, fechaEvento: $fechaEvento, fotos: $fotos, estado: $estado, derivadoA: $derivadoA, reportadoPor: $reportadoPor, verificadoPor: $verificadoPor, createdAt: $createdAt, updatedAt: $updatedAt)';
  }
}

/// @nodoc
abstract mixin class $ReporteSeguridadCopyWith<$Res> {
  factory $ReporteSeguridadCopyWith(
          ReporteSeguridad value, $Res Function(ReporteSeguridad) _then) =
      _$ReporteSeguridadCopyWithImpl;
  @useResult
  $Res call(
      {String id,
      String tipo,
      double lat,
      double lng,
      String? direccion,
      String? descripcion,
      int? severidad,
      @JsonKey(name: 'fecha_evento') DateTime? fechaEvento,
      List<String> fotos,
      String estado,
      @JsonKey(name: 'derivado_a') String? derivadoA,
      @JsonKey(name: 'reportado_por') String? reportadoPor,
      @JsonKey(name: 'verificado_por') String? verificadoPor,
      @JsonKey(name: 'created_at') DateTime? createdAt,
      @JsonKey(name: 'updated_at') DateTime? updatedAt});
}

/// @nodoc
class _$ReporteSeguridadCopyWithImpl<$Res>
    implements $ReporteSeguridadCopyWith<$Res> {
  _$ReporteSeguridadCopyWithImpl(this._self, this._then);

  final ReporteSeguridad _self;
  final $Res Function(ReporteSeguridad) _then;

  /// Create a copy of ReporteSeguridad
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? tipo = null,
    Object? lat = null,
    Object? lng = null,
    Object? direccion = freezed,
    Object? descripcion = freezed,
    Object? severidad = freezed,
    Object? fechaEvento = freezed,
    Object? fotos = null,
    Object? estado = null,
    Object? derivadoA = freezed,
    Object? reportadoPor = freezed,
    Object? verificadoPor = freezed,
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
      lat: null == lat
          ? _self.lat
          : lat // ignore: cast_nullable_to_non_nullable
              as double,
      lng: null == lng
          ? _self.lng
          : lng // ignore: cast_nullable_to_non_nullable
              as double,
      direccion: freezed == direccion
          ? _self.direccion
          : direccion // ignore: cast_nullable_to_non_nullable
              as String?,
      descripcion: freezed == descripcion
          ? _self.descripcion
          : descripcion // ignore: cast_nullable_to_non_nullable
              as String?,
      severidad: freezed == severidad
          ? _self.severidad
          : severidad // ignore: cast_nullable_to_non_nullable
              as int?,
      fechaEvento: freezed == fechaEvento
          ? _self.fechaEvento
          : fechaEvento // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      fotos: null == fotos
          ? _self.fotos
          : fotos // ignore: cast_nullable_to_non_nullable
              as List<String>,
      estado: null == estado
          ? _self.estado
          : estado // ignore: cast_nullable_to_non_nullable
              as String,
      derivadoA: freezed == derivadoA
          ? _self.derivadoA
          : derivadoA // ignore: cast_nullable_to_non_nullable
              as String?,
      reportadoPor: freezed == reportadoPor
          ? _self.reportadoPor
          : reportadoPor // ignore: cast_nullable_to_non_nullable
              as String?,
      verificadoPor: freezed == verificadoPor
          ? _self.verificadoPor
          : verificadoPor // ignore: cast_nullable_to_non_nullable
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

/// Adds pattern-matching-related methods to [ReporteSeguridad].
extension ReporteSeguridadPatterns on ReporteSeguridad {
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
    TResult Function(_ReporteSeguridad value)? $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _ReporteSeguridad() when $default != null:
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
    TResult Function(_ReporteSeguridad value) $default,
  ) {
    final _that = this;
    switch (_that) {
      case _ReporteSeguridad():
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
    TResult? Function(_ReporteSeguridad value)? $default,
  ) {
    final _that = this;
    switch (_that) {
      case _ReporteSeguridad() when $default != null:
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
            double lat,
            double lng,
            String? direccion,
            String? descripcion,
            int? severidad,
            @JsonKey(name: 'fecha_evento') DateTime? fechaEvento,
            List<String> fotos,
            String estado,
            @JsonKey(name: 'derivado_a') String? derivadoA,
            @JsonKey(name: 'reportado_por') String? reportadoPor,
            @JsonKey(name: 'verificado_por') String? verificadoPor,
            @JsonKey(name: 'created_at') DateTime? createdAt,
            @JsonKey(name: 'updated_at') DateTime? updatedAt)?
        $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _ReporteSeguridad() when $default != null:
        return $default(
            _that.id,
            _that.tipo,
            _that.lat,
            _that.lng,
            _that.direccion,
            _that.descripcion,
            _that.severidad,
            _that.fechaEvento,
            _that.fotos,
            _that.estado,
            _that.derivadoA,
            _that.reportadoPor,
            _that.verificadoPor,
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
            double lat,
            double lng,
            String? direccion,
            String? descripcion,
            int? severidad,
            @JsonKey(name: 'fecha_evento') DateTime? fechaEvento,
            List<String> fotos,
            String estado,
            @JsonKey(name: 'derivado_a') String? derivadoA,
            @JsonKey(name: 'reportado_por') String? reportadoPor,
            @JsonKey(name: 'verificado_por') String? verificadoPor,
            @JsonKey(name: 'created_at') DateTime? createdAt,
            @JsonKey(name: 'updated_at') DateTime? updatedAt)
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _ReporteSeguridad():
        return $default(
            _that.id,
            _that.tipo,
            _that.lat,
            _that.lng,
            _that.direccion,
            _that.descripcion,
            _that.severidad,
            _that.fechaEvento,
            _that.fotos,
            _that.estado,
            _that.derivadoA,
            _that.reportadoPor,
            _that.verificadoPor,
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
            double lat,
            double lng,
            String? direccion,
            String? descripcion,
            int? severidad,
            @JsonKey(name: 'fecha_evento') DateTime? fechaEvento,
            List<String> fotos,
            String estado,
            @JsonKey(name: 'derivado_a') String? derivadoA,
            @JsonKey(name: 'reportado_por') String? reportadoPor,
            @JsonKey(name: 'verificado_por') String? verificadoPor,
            @JsonKey(name: 'created_at') DateTime? createdAt,
            @JsonKey(name: 'updated_at') DateTime? updatedAt)?
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _ReporteSeguridad() when $default != null:
        return $default(
            _that.id,
            _that.tipo,
            _that.lat,
            _that.lng,
            _that.direccion,
            _that.descripcion,
            _that.severidad,
            _that.fechaEvento,
            _that.fotos,
            _that.estado,
            _that.derivadoA,
            _that.reportadoPor,
            _that.verificadoPor,
            _that.createdAt,
            _that.updatedAt);
      case _:
        return null;
    }
  }
}

/// @nodoc
@JsonSerializable()
class _ReporteSeguridad implements ReporteSeguridad {
  const _ReporteSeguridad(
      {required this.id,
      required this.tipo,
      required this.lat,
      required this.lng,
      this.direccion,
      this.descripcion,
      this.severidad,
      @JsonKey(name: 'fecha_evento') this.fechaEvento,
      final List<String> fotos = const [],
      this.estado = 'reportado',
      @JsonKey(name: 'derivado_a') this.derivadoA,
      @JsonKey(name: 'reportado_por') this.reportadoPor,
      @JsonKey(name: 'verificado_por') this.verificadoPor,
      @JsonKey(name: 'created_at') this.createdAt,
      @JsonKey(name: 'updated_at') this.updatedAt})
      : _fotos = fotos;
  factory _ReporteSeguridad.fromJson(Map<String, dynamic> json) =>
      _$ReporteSeguridadFromJson(json);

  @override
  final String id;
  @override
  final String tipo;
  @override
  final double lat;
  @override
  final double lng;
  @override
  final String? direccion;
  @override
  final String? descripcion;
  @override
  final int? severidad;
  @override
  @JsonKey(name: 'fecha_evento')
  final DateTime? fechaEvento;
  final List<String> _fotos;
  @override
  @JsonKey()
  List<String> get fotos {
    if (_fotos is EqualUnmodifiableListView) return _fotos;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_fotos);
  }

  @override
  @JsonKey()
  final String estado;
  @override
  @JsonKey(name: 'derivado_a')
  final String? derivadoA;
  @override
  @JsonKey(name: 'reportado_por')
  final String? reportadoPor;
  @override
  @JsonKey(name: 'verificado_por')
  final String? verificadoPor;
  @override
  @JsonKey(name: 'created_at')
  final DateTime? createdAt;
  @override
  @JsonKey(name: 'updated_at')
  final DateTime? updatedAt;

  /// Create a copy of ReporteSeguridad
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  _$ReporteSeguridadCopyWith<_ReporteSeguridad> get copyWith =>
      __$ReporteSeguridadCopyWithImpl<_ReporteSeguridad>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$ReporteSeguridadToJson(
      this,
    );
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _ReporteSeguridad &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.tipo, tipo) || other.tipo == tipo) &&
            (identical(other.lat, lat) || other.lat == lat) &&
            (identical(other.lng, lng) || other.lng == lng) &&
            (identical(other.direccion, direccion) ||
                other.direccion == direccion) &&
            (identical(other.descripcion, descripcion) ||
                other.descripcion == descripcion) &&
            (identical(other.severidad, severidad) ||
                other.severidad == severidad) &&
            (identical(other.fechaEvento, fechaEvento) ||
                other.fechaEvento == fechaEvento) &&
            const DeepCollectionEquality().equals(other._fotos, _fotos) &&
            (identical(other.estado, estado) || other.estado == estado) &&
            (identical(other.derivadoA, derivadoA) ||
                other.derivadoA == derivadoA) &&
            (identical(other.reportadoPor, reportadoPor) ||
                other.reportadoPor == reportadoPor) &&
            (identical(other.verificadoPor, verificadoPor) ||
                other.verificadoPor == verificadoPor) &&
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
      lat,
      lng,
      direccion,
      descripcion,
      severidad,
      fechaEvento,
      const DeepCollectionEquality().hash(_fotos),
      estado,
      derivadoA,
      reportadoPor,
      verificadoPor,
      createdAt,
      updatedAt);

  @override
  String toString() {
    return 'ReporteSeguridad(id: $id, tipo: $tipo, lat: $lat, lng: $lng, direccion: $direccion, descripcion: $descripcion, severidad: $severidad, fechaEvento: $fechaEvento, fotos: $fotos, estado: $estado, derivadoA: $derivadoA, reportadoPor: $reportadoPor, verificadoPor: $verificadoPor, createdAt: $createdAt, updatedAt: $updatedAt)';
  }
}

/// @nodoc
abstract mixin class _$ReporteSeguridadCopyWith<$Res>
    implements $ReporteSeguridadCopyWith<$Res> {
  factory _$ReporteSeguridadCopyWith(
          _ReporteSeguridad value, $Res Function(_ReporteSeguridad) _then) =
      __$ReporteSeguridadCopyWithImpl;
  @override
  @useResult
  $Res call(
      {String id,
      String tipo,
      double lat,
      double lng,
      String? direccion,
      String? descripcion,
      int? severidad,
      @JsonKey(name: 'fecha_evento') DateTime? fechaEvento,
      List<String> fotos,
      String estado,
      @JsonKey(name: 'derivado_a') String? derivadoA,
      @JsonKey(name: 'reportado_por') String? reportadoPor,
      @JsonKey(name: 'verificado_por') String? verificadoPor,
      @JsonKey(name: 'created_at') DateTime? createdAt,
      @JsonKey(name: 'updated_at') DateTime? updatedAt});
}

/// @nodoc
class __$ReporteSeguridadCopyWithImpl<$Res>
    implements _$ReporteSeguridadCopyWith<$Res> {
  __$ReporteSeguridadCopyWithImpl(this._self, this._then);

  final _ReporteSeguridad _self;
  final $Res Function(_ReporteSeguridad) _then;

  /// Create a copy of ReporteSeguridad
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $Res call({
    Object? id = null,
    Object? tipo = null,
    Object? lat = null,
    Object? lng = null,
    Object? direccion = freezed,
    Object? descripcion = freezed,
    Object? severidad = freezed,
    Object? fechaEvento = freezed,
    Object? fotos = null,
    Object? estado = null,
    Object? derivadoA = freezed,
    Object? reportadoPor = freezed,
    Object? verificadoPor = freezed,
    Object? createdAt = freezed,
    Object? updatedAt = freezed,
  }) {
    return _then(_ReporteSeguridad(
      id: null == id
          ? _self.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      tipo: null == tipo
          ? _self.tipo
          : tipo // ignore: cast_nullable_to_non_nullable
              as String,
      lat: null == lat
          ? _self.lat
          : lat // ignore: cast_nullable_to_non_nullable
              as double,
      lng: null == lng
          ? _self.lng
          : lng // ignore: cast_nullable_to_non_nullable
              as double,
      direccion: freezed == direccion
          ? _self.direccion
          : direccion // ignore: cast_nullable_to_non_nullable
              as String?,
      descripcion: freezed == descripcion
          ? _self.descripcion
          : descripcion // ignore: cast_nullable_to_non_nullable
              as String?,
      severidad: freezed == severidad
          ? _self.severidad
          : severidad // ignore: cast_nullable_to_non_nullable
              as int?,
      fechaEvento: freezed == fechaEvento
          ? _self.fechaEvento
          : fechaEvento // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      fotos: null == fotos
          ? _self._fotos
          : fotos // ignore: cast_nullable_to_non_nullable
              as List<String>,
      estado: null == estado
          ? _self.estado
          : estado // ignore: cast_nullable_to_non_nullable
              as String,
      derivadoA: freezed == derivadoA
          ? _self.derivadoA
          : derivadoA // ignore: cast_nullable_to_non_nullable
              as String?,
      reportadoPor: freezed == reportadoPor
          ? _self.reportadoPor
          : reportadoPor // ignore: cast_nullable_to_non_nullable
              as String?,
      verificadoPor: freezed == verificadoPor
          ? _self.verificadoPor
          : verificadoPor // ignore: cast_nullable_to_non_nullable
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
