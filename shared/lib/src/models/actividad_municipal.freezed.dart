// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'actividad_municipal.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$ActividadMunicipal {
  String get id;
  TipoActividad get tipo;
  EstadoActividad get estado;
  String get titulo;
  String get descripcion;
  DateTime get fechaInicio;
  DateTime? get fechaFin;
  double? get lat;
  double? get lng;
  String? get direccion;
  String? get sector;
  List<String> get participanteIds;
  ActaActividad? get acta;
  String get creadoPor;
  DateTime get creadoEn;
  DateTime? get actualizadoEn;
  double? get presupuestoEstimado;
  String? get direccionMunicipal;
  List<String> get adjuntos;

  /// Create a copy of ActividadMunicipal
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $ActividadMunicipalCopyWith<ActividadMunicipal> get copyWith =>
      _$ActividadMunicipalCopyWithImpl<ActividadMunicipal>(
          this as ActividadMunicipal, _$identity);

  /// Serializes this ActividadMunicipal to a JSON map.
  Map<String, dynamic> toJson();

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is ActividadMunicipal &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.tipo, tipo) || other.tipo == tipo) &&
            (identical(other.estado, estado) || other.estado == estado) &&
            (identical(other.titulo, titulo) || other.titulo == titulo) &&
            (identical(other.descripcion, descripcion) ||
                other.descripcion == descripcion) &&
            (identical(other.fechaInicio, fechaInicio) ||
                other.fechaInicio == fechaInicio) &&
            (identical(other.fechaFin, fechaFin) ||
                other.fechaFin == fechaFin) &&
            (identical(other.lat, lat) || other.lat == lat) &&
            (identical(other.lng, lng) || other.lng == lng) &&
            (identical(other.direccion, direccion) ||
                other.direccion == direccion) &&
            (identical(other.sector, sector) || other.sector == sector) &&
            const DeepCollectionEquality()
                .equals(other.participanteIds, participanteIds) &&
            (identical(other.acta, acta) || other.acta == acta) &&
            (identical(other.creadoPor, creadoPor) ||
                other.creadoPor == creadoPor) &&
            (identical(other.creadoEn, creadoEn) ||
                other.creadoEn == creadoEn) &&
            (identical(other.actualizadoEn, actualizadoEn) ||
                other.actualizadoEn == actualizadoEn) &&
            (identical(other.presupuestoEstimado, presupuestoEstimado) ||
                other.presupuestoEstimado == presupuestoEstimado) &&
            (identical(other.direccionMunicipal, direccionMunicipal) ||
                other.direccionMunicipal == direccionMunicipal) &&
            const DeepCollectionEquality().equals(other.adjuntos, adjuntos));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hashAll([
        runtimeType,
        id,
        tipo,
        estado,
        titulo,
        descripcion,
        fechaInicio,
        fechaFin,
        lat,
        lng,
        direccion,
        sector,
        const DeepCollectionEquality().hash(participanteIds),
        acta,
        creadoPor,
        creadoEn,
        actualizadoEn,
        presupuestoEstimado,
        direccionMunicipal,
        const DeepCollectionEquality().hash(adjuntos)
      ]);

  @override
  String toString() {
    return 'ActividadMunicipal(id: $id, tipo: $tipo, estado: $estado, titulo: $titulo, descripcion: $descripcion, fechaInicio: $fechaInicio, fechaFin: $fechaFin, lat: $lat, lng: $lng, direccion: $direccion, sector: $sector, participanteIds: $participanteIds, acta: $acta, creadoPor: $creadoPor, creadoEn: $creadoEn, actualizadoEn: $actualizadoEn, presupuestoEstimado: $presupuestoEstimado, direccionMunicipal: $direccionMunicipal, adjuntos: $adjuntos)';
  }
}

/// @nodoc
abstract mixin class $ActividadMunicipalCopyWith<$Res> {
  factory $ActividadMunicipalCopyWith(
          ActividadMunicipal value, $Res Function(ActividadMunicipal) _then) =
      _$ActividadMunicipalCopyWithImpl;
  @useResult
  $Res call(
      {String id,
      TipoActividad tipo,
      EstadoActividad estado,
      String titulo,
      String descripcion,
      DateTime fechaInicio,
      DateTime? fechaFin,
      double? lat,
      double? lng,
      String? direccion,
      String? sector,
      List<String> participanteIds,
      ActaActividad? acta,
      String creadoPor,
      DateTime creadoEn,
      DateTime? actualizadoEn,
      double? presupuestoEstimado,
      String? direccionMunicipal,
      List<String> adjuntos});

  $ActaActividadCopyWith<$Res>? get acta;
}

/// @nodoc
class _$ActividadMunicipalCopyWithImpl<$Res>
    implements $ActividadMunicipalCopyWith<$Res> {
  _$ActividadMunicipalCopyWithImpl(this._self, this._then);

  final ActividadMunicipal _self;
  final $Res Function(ActividadMunicipal) _then;

  /// Create a copy of ActividadMunicipal
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? tipo = null,
    Object? estado = null,
    Object? titulo = null,
    Object? descripcion = null,
    Object? fechaInicio = null,
    Object? fechaFin = freezed,
    Object? lat = freezed,
    Object? lng = freezed,
    Object? direccion = freezed,
    Object? sector = freezed,
    Object? participanteIds = null,
    Object? acta = freezed,
    Object? creadoPor = null,
    Object? creadoEn = null,
    Object? actualizadoEn = freezed,
    Object? presupuestoEstimado = freezed,
    Object? direccionMunicipal = freezed,
    Object? adjuntos = null,
  }) {
    return _then(_self.copyWith(
      id: null == id
          ? _self.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      tipo: null == tipo
          ? _self.tipo
          : tipo // ignore: cast_nullable_to_non_nullable
              as TipoActividad,
      estado: null == estado
          ? _self.estado
          : estado // ignore: cast_nullable_to_non_nullable
              as EstadoActividad,
      titulo: null == titulo
          ? _self.titulo
          : titulo // ignore: cast_nullable_to_non_nullable
              as String,
      descripcion: null == descripcion
          ? _self.descripcion
          : descripcion // ignore: cast_nullable_to_non_nullable
              as String,
      fechaInicio: null == fechaInicio
          ? _self.fechaInicio
          : fechaInicio // ignore: cast_nullable_to_non_nullable
              as DateTime,
      fechaFin: freezed == fechaFin
          ? _self.fechaFin
          : fechaFin // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      lat: freezed == lat
          ? _self.lat
          : lat // ignore: cast_nullable_to_non_nullable
              as double?,
      lng: freezed == lng
          ? _self.lng
          : lng // ignore: cast_nullable_to_non_nullable
              as double?,
      direccion: freezed == direccion
          ? _self.direccion
          : direccion // ignore: cast_nullable_to_non_nullable
              as String?,
      sector: freezed == sector
          ? _self.sector
          : sector // ignore: cast_nullable_to_non_nullable
              as String?,
      participanteIds: null == participanteIds
          ? _self.participanteIds
          : participanteIds // ignore: cast_nullable_to_non_nullable
              as List<String>,
      acta: freezed == acta
          ? _self.acta
          : acta // ignore: cast_nullable_to_non_nullable
              as ActaActividad?,
      creadoPor: null == creadoPor
          ? _self.creadoPor
          : creadoPor // ignore: cast_nullable_to_non_nullable
              as String,
      creadoEn: null == creadoEn
          ? _self.creadoEn
          : creadoEn // ignore: cast_nullable_to_non_nullable
              as DateTime,
      actualizadoEn: freezed == actualizadoEn
          ? _self.actualizadoEn
          : actualizadoEn // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      presupuestoEstimado: freezed == presupuestoEstimado
          ? _self.presupuestoEstimado
          : presupuestoEstimado // ignore: cast_nullable_to_non_nullable
              as double?,
      direccionMunicipal: freezed == direccionMunicipal
          ? _self.direccionMunicipal
          : direccionMunicipal // ignore: cast_nullable_to_non_nullable
              as String?,
      adjuntos: null == adjuntos
          ? _self.adjuntos
          : adjuntos // ignore: cast_nullable_to_non_nullable
              as List<String>,
    ));
  }

  /// Create a copy of ActividadMunicipal
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $ActaActividadCopyWith<$Res>? get acta {
    if (_self.acta == null) {
      return null;
    }

    return $ActaActividadCopyWith<$Res>(_self.acta!, (value) {
      return _then(_self.copyWith(acta: value));
    });
  }
}

/// Adds pattern-matching-related methods to [ActividadMunicipal].
extension ActividadMunicipalPatterns on ActividadMunicipal {
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
    TResult Function(_ActividadMunicipal value)? $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _ActividadMunicipal() when $default != null:
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
    TResult Function(_ActividadMunicipal value) $default,
  ) {
    final _that = this;
    switch (_that) {
      case _ActividadMunicipal():
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
    TResult? Function(_ActividadMunicipal value)? $default,
  ) {
    final _that = this;
    switch (_that) {
      case _ActividadMunicipal() when $default != null:
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
            TipoActividad tipo,
            EstadoActividad estado,
            String titulo,
            String descripcion,
            DateTime fechaInicio,
            DateTime? fechaFin,
            double? lat,
            double? lng,
            String? direccion,
            String? sector,
            List<String> participanteIds,
            ActaActividad? acta,
            String creadoPor,
            DateTime creadoEn,
            DateTime? actualizadoEn,
            double? presupuestoEstimado,
            String? direccionMunicipal,
            List<String> adjuntos)?
        $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _ActividadMunicipal() when $default != null:
        return $default(
            _that.id,
            _that.tipo,
            _that.estado,
            _that.titulo,
            _that.descripcion,
            _that.fechaInicio,
            _that.fechaFin,
            _that.lat,
            _that.lng,
            _that.direccion,
            _that.sector,
            _that.participanteIds,
            _that.acta,
            _that.creadoPor,
            _that.creadoEn,
            _that.actualizadoEn,
            _that.presupuestoEstimado,
            _that.direccionMunicipal,
            _that.adjuntos);
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
            TipoActividad tipo,
            EstadoActividad estado,
            String titulo,
            String descripcion,
            DateTime fechaInicio,
            DateTime? fechaFin,
            double? lat,
            double? lng,
            String? direccion,
            String? sector,
            List<String> participanteIds,
            ActaActividad? acta,
            String creadoPor,
            DateTime creadoEn,
            DateTime? actualizadoEn,
            double? presupuestoEstimado,
            String? direccionMunicipal,
            List<String> adjuntos)
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _ActividadMunicipal():
        return $default(
            _that.id,
            _that.tipo,
            _that.estado,
            _that.titulo,
            _that.descripcion,
            _that.fechaInicio,
            _that.fechaFin,
            _that.lat,
            _that.lng,
            _that.direccion,
            _that.sector,
            _that.participanteIds,
            _that.acta,
            _that.creadoPor,
            _that.creadoEn,
            _that.actualizadoEn,
            _that.presupuestoEstimado,
            _that.direccionMunicipal,
            _that.adjuntos);
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
            TipoActividad tipo,
            EstadoActividad estado,
            String titulo,
            String descripcion,
            DateTime fechaInicio,
            DateTime? fechaFin,
            double? lat,
            double? lng,
            String? direccion,
            String? sector,
            List<String> participanteIds,
            ActaActividad? acta,
            String creadoPor,
            DateTime creadoEn,
            DateTime? actualizadoEn,
            double? presupuestoEstimado,
            String? direccionMunicipal,
            List<String> adjuntos)?
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _ActividadMunicipal() when $default != null:
        return $default(
            _that.id,
            _that.tipo,
            _that.estado,
            _that.titulo,
            _that.descripcion,
            _that.fechaInicio,
            _that.fechaFin,
            _that.lat,
            _that.lng,
            _that.direccion,
            _that.sector,
            _that.participanteIds,
            _that.acta,
            _that.creadoPor,
            _that.creadoEn,
            _that.actualizadoEn,
            _that.presupuestoEstimado,
            _that.direccionMunicipal,
            _that.adjuntos);
      case _:
        return null;
    }
  }
}

/// @nodoc
@JsonSerializable()
class _ActividadMunicipal implements ActividadMunicipal {
  const _ActividadMunicipal(
      {required this.id,
      required this.tipo,
      required this.estado,
      required this.titulo,
      required this.descripcion,
      required this.fechaInicio,
      this.fechaFin,
      this.lat,
      this.lng,
      this.direccion,
      this.sector,
      final List<String> participanteIds = const [],
      this.acta,
      required this.creadoPor,
      required this.creadoEn,
      this.actualizadoEn,
      this.presupuestoEstimado,
      this.direccionMunicipal,
      final List<String> adjuntos = const []})
      : _participanteIds = participanteIds,
        _adjuntos = adjuntos;
  factory _ActividadMunicipal.fromJson(Map<String, dynamic> json) =>
      _$ActividadMunicipalFromJson(json);

  @override
  final String id;
  @override
  final TipoActividad tipo;
  @override
  final EstadoActividad estado;
  @override
  final String titulo;
  @override
  final String descripcion;
  @override
  final DateTime fechaInicio;
  @override
  final DateTime? fechaFin;
  @override
  final double? lat;
  @override
  final double? lng;
  @override
  final String? direccion;
  @override
  final String? sector;
  final List<String> _participanteIds;
  @override
  @JsonKey()
  List<String> get participanteIds {
    if (_participanteIds is EqualUnmodifiableListView) return _participanteIds;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_participanteIds);
  }

  @override
  final ActaActividad? acta;
  @override
  final String creadoPor;
  @override
  final DateTime creadoEn;
  @override
  final DateTime? actualizadoEn;
  @override
  final double? presupuestoEstimado;
  @override
  final String? direccionMunicipal;
  final List<String> _adjuntos;
  @override
  @JsonKey()
  List<String> get adjuntos {
    if (_adjuntos is EqualUnmodifiableListView) return _adjuntos;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_adjuntos);
  }

  /// Create a copy of ActividadMunicipal
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  _$ActividadMunicipalCopyWith<_ActividadMunicipal> get copyWith =>
      __$ActividadMunicipalCopyWithImpl<_ActividadMunicipal>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$ActividadMunicipalToJson(
      this,
    );
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _ActividadMunicipal &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.tipo, tipo) || other.tipo == tipo) &&
            (identical(other.estado, estado) || other.estado == estado) &&
            (identical(other.titulo, titulo) || other.titulo == titulo) &&
            (identical(other.descripcion, descripcion) ||
                other.descripcion == descripcion) &&
            (identical(other.fechaInicio, fechaInicio) ||
                other.fechaInicio == fechaInicio) &&
            (identical(other.fechaFin, fechaFin) ||
                other.fechaFin == fechaFin) &&
            (identical(other.lat, lat) || other.lat == lat) &&
            (identical(other.lng, lng) || other.lng == lng) &&
            (identical(other.direccion, direccion) ||
                other.direccion == direccion) &&
            (identical(other.sector, sector) || other.sector == sector) &&
            const DeepCollectionEquality()
                .equals(other._participanteIds, _participanteIds) &&
            (identical(other.acta, acta) || other.acta == acta) &&
            (identical(other.creadoPor, creadoPor) ||
                other.creadoPor == creadoPor) &&
            (identical(other.creadoEn, creadoEn) ||
                other.creadoEn == creadoEn) &&
            (identical(other.actualizadoEn, actualizadoEn) ||
                other.actualizadoEn == actualizadoEn) &&
            (identical(other.presupuestoEstimado, presupuestoEstimado) ||
                other.presupuestoEstimado == presupuestoEstimado) &&
            (identical(other.direccionMunicipal, direccionMunicipal) ||
                other.direccionMunicipal == direccionMunicipal) &&
            const DeepCollectionEquality().equals(other._adjuntos, _adjuntos));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hashAll([
        runtimeType,
        id,
        tipo,
        estado,
        titulo,
        descripcion,
        fechaInicio,
        fechaFin,
        lat,
        lng,
        direccion,
        sector,
        const DeepCollectionEquality().hash(_participanteIds),
        acta,
        creadoPor,
        creadoEn,
        actualizadoEn,
        presupuestoEstimado,
        direccionMunicipal,
        const DeepCollectionEquality().hash(_adjuntos)
      ]);

  @override
  String toString() {
    return 'ActividadMunicipal(id: $id, tipo: $tipo, estado: $estado, titulo: $titulo, descripcion: $descripcion, fechaInicio: $fechaInicio, fechaFin: $fechaFin, lat: $lat, lng: $lng, direccion: $direccion, sector: $sector, participanteIds: $participanteIds, acta: $acta, creadoPor: $creadoPor, creadoEn: $creadoEn, actualizadoEn: $actualizadoEn, presupuestoEstimado: $presupuestoEstimado, direccionMunicipal: $direccionMunicipal, adjuntos: $adjuntos)';
  }
}

/// @nodoc
abstract mixin class _$ActividadMunicipalCopyWith<$Res>
    implements $ActividadMunicipalCopyWith<$Res> {
  factory _$ActividadMunicipalCopyWith(
          _ActividadMunicipal value, $Res Function(_ActividadMunicipal) _then) =
      __$ActividadMunicipalCopyWithImpl;
  @override
  @useResult
  $Res call(
      {String id,
      TipoActividad tipo,
      EstadoActividad estado,
      String titulo,
      String descripcion,
      DateTime fechaInicio,
      DateTime? fechaFin,
      double? lat,
      double? lng,
      String? direccion,
      String? sector,
      List<String> participanteIds,
      ActaActividad? acta,
      String creadoPor,
      DateTime creadoEn,
      DateTime? actualizadoEn,
      double? presupuestoEstimado,
      String? direccionMunicipal,
      List<String> adjuntos});

  @override
  $ActaActividadCopyWith<$Res>? get acta;
}

/// @nodoc
class __$ActividadMunicipalCopyWithImpl<$Res>
    implements _$ActividadMunicipalCopyWith<$Res> {
  __$ActividadMunicipalCopyWithImpl(this._self, this._then);

  final _ActividadMunicipal _self;
  final $Res Function(_ActividadMunicipal) _then;

  /// Create a copy of ActividadMunicipal
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $Res call({
    Object? id = null,
    Object? tipo = null,
    Object? estado = null,
    Object? titulo = null,
    Object? descripcion = null,
    Object? fechaInicio = null,
    Object? fechaFin = freezed,
    Object? lat = freezed,
    Object? lng = freezed,
    Object? direccion = freezed,
    Object? sector = freezed,
    Object? participanteIds = null,
    Object? acta = freezed,
    Object? creadoPor = null,
    Object? creadoEn = null,
    Object? actualizadoEn = freezed,
    Object? presupuestoEstimado = freezed,
    Object? direccionMunicipal = freezed,
    Object? adjuntos = null,
  }) {
    return _then(_ActividadMunicipal(
      id: null == id
          ? _self.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      tipo: null == tipo
          ? _self.tipo
          : tipo // ignore: cast_nullable_to_non_nullable
              as TipoActividad,
      estado: null == estado
          ? _self.estado
          : estado // ignore: cast_nullable_to_non_nullable
              as EstadoActividad,
      titulo: null == titulo
          ? _self.titulo
          : titulo // ignore: cast_nullable_to_non_nullable
              as String,
      descripcion: null == descripcion
          ? _self.descripcion
          : descripcion // ignore: cast_nullable_to_non_nullable
              as String,
      fechaInicio: null == fechaInicio
          ? _self.fechaInicio
          : fechaInicio // ignore: cast_nullable_to_non_nullable
              as DateTime,
      fechaFin: freezed == fechaFin
          ? _self.fechaFin
          : fechaFin // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      lat: freezed == lat
          ? _self.lat
          : lat // ignore: cast_nullable_to_non_nullable
              as double?,
      lng: freezed == lng
          ? _self.lng
          : lng // ignore: cast_nullable_to_non_nullable
              as double?,
      direccion: freezed == direccion
          ? _self.direccion
          : direccion // ignore: cast_nullable_to_non_nullable
              as String?,
      sector: freezed == sector
          ? _self.sector
          : sector // ignore: cast_nullable_to_non_nullable
              as String?,
      participanteIds: null == participanteIds
          ? _self._participanteIds
          : participanteIds // ignore: cast_nullable_to_non_nullable
              as List<String>,
      acta: freezed == acta
          ? _self.acta
          : acta // ignore: cast_nullable_to_non_nullable
              as ActaActividad?,
      creadoPor: null == creadoPor
          ? _self.creadoPor
          : creadoPor // ignore: cast_nullable_to_non_nullable
              as String,
      creadoEn: null == creadoEn
          ? _self.creadoEn
          : creadoEn // ignore: cast_nullable_to_non_nullable
              as DateTime,
      actualizadoEn: freezed == actualizadoEn
          ? _self.actualizadoEn
          : actualizadoEn // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      presupuestoEstimado: freezed == presupuestoEstimado
          ? _self.presupuestoEstimado
          : presupuestoEstimado // ignore: cast_nullable_to_non_nullable
              as double?,
      direccionMunicipal: freezed == direccionMunicipal
          ? _self.direccionMunicipal
          : direccionMunicipal // ignore: cast_nullable_to_non_nullable
              as String?,
      adjuntos: null == adjuntos
          ? _self._adjuntos
          : adjuntos // ignore: cast_nullable_to_non_nullable
              as List<String>,
    ));
  }

  /// Create a copy of ActividadMunicipal
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $ActaActividadCopyWith<$Res>? get acta {
    if (_self.acta == null) {
      return null;
    }

    return $ActaActividadCopyWith<$Res>(_self.acta!, (value) {
      return _then(_self.copyWith(acta: value));
    });
  }
}

/// @nodoc
mixin _$ActaActividad {
  String? get contenido;
  List<AsistenteActa> get asistentes;
  List<AcuerdoActa> get acuerdos;
  DateTime? get fechaFirma;

  /// Create a copy of ActaActividad
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $ActaActividadCopyWith<ActaActividad> get copyWith =>
      _$ActaActividadCopyWithImpl<ActaActividad>(
          this as ActaActividad, _$identity);

  /// Serializes this ActaActividad to a JSON map.
  Map<String, dynamic> toJson();

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is ActaActividad &&
            (identical(other.contenido, contenido) ||
                other.contenido == contenido) &&
            const DeepCollectionEquality()
                .equals(other.asistentes, asistentes) &&
            const DeepCollectionEquality().equals(other.acuerdos, acuerdos) &&
            (identical(other.fechaFirma, fechaFirma) ||
                other.fechaFirma == fechaFirma));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      contenido,
      const DeepCollectionEquality().hash(asistentes),
      const DeepCollectionEquality().hash(acuerdos),
      fechaFirma);

  @override
  String toString() {
    return 'ActaActividad(contenido: $contenido, asistentes: $asistentes, acuerdos: $acuerdos, fechaFirma: $fechaFirma)';
  }
}

/// @nodoc
abstract mixin class $ActaActividadCopyWith<$Res> {
  factory $ActaActividadCopyWith(
          ActaActividad value, $Res Function(ActaActividad) _then) =
      _$ActaActividadCopyWithImpl;
  @useResult
  $Res call(
      {String? contenido,
      List<AsistenteActa> asistentes,
      List<AcuerdoActa> acuerdos,
      DateTime? fechaFirma});
}

/// @nodoc
class _$ActaActividadCopyWithImpl<$Res>
    implements $ActaActividadCopyWith<$Res> {
  _$ActaActividadCopyWithImpl(this._self, this._then);

  final ActaActividad _self;
  final $Res Function(ActaActividad) _then;

  /// Create a copy of ActaActividad
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? contenido = freezed,
    Object? asistentes = null,
    Object? acuerdos = null,
    Object? fechaFirma = freezed,
  }) {
    return _then(_self.copyWith(
      contenido: freezed == contenido
          ? _self.contenido
          : contenido // ignore: cast_nullable_to_non_nullable
              as String?,
      asistentes: null == asistentes
          ? _self.asistentes
          : asistentes // ignore: cast_nullable_to_non_nullable
              as List<AsistenteActa>,
      acuerdos: null == acuerdos
          ? _self.acuerdos
          : acuerdos // ignore: cast_nullable_to_non_nullable
              as List<AcuerdoActa>,
      fechaFirma: freezed == fechaFirma
          ? _self.fechaFirma
          : fechaFirma // ignore: cast_nullable_to_non_nullable
              as DateTime?,
    ));
  }
}

/// Adds pattern-matching-related methods to [ActaActividad].
extension ActaActividadPatterns on ActaActividad {
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
    TResult Function(_ActaActividad value)? $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _ActaActividad() when $default != null:
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
    TResult Function(_ActaActividad value) $default,
  ) {
    final _that = this;
    switch (_that) {
      case _ActaActividad():
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
    TResult? Function(_ActaActividad value)? $default,
  ) {
    final _that = this;
    switch (_that) {
      case _ActaActividad() when $default != null:
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
    TResult Function(String? contenido, List<AsistenteActa> asistentes,
            List<AcuerdoActa> acuerdos, DateTime? fechaFirma)?
        $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _ActaActividad() when $default != null:
        return $default(_that.contenido, _that.asistentes, _that.acuerdos,
            _that.fechaFirma);
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
    TResult Function(String? contenido, List<AsistenteActa> asistentes,
            List<AcuerdoActa> acuerdos, DateTime? fechaFirma)
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _ActaActividad():
        return $default(_that.contenido, _that.asistentes, _that.acuerdos,
            _that.fechaFirma);
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
    TResult? Function(String? contenido, List<AsistenteActa> asistentes,
            List<AcuerdoActa> acuerdos, DateTime? fechaFirma)?
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _ActaActividad() when $default != null:
        return $default(_that.contenido, _that.asistentes, _that.acuerdos,
            _that.fechaFirma);
      case _:
        return null;
    }
  }
}

/// @nodoc
@JsonSerializable()
class _ActaActividad implements ActaActividad {
  const _ActaActividad(
      {this.contenido,
      final List<AsistenteActa> asistentes = const [],
      final List<AcuerdoActa> acuerdos = const [],
      this.fechaFirma})
      : _asistentes = asistentes,
        _acuerdos = acuerdos;
  factory _ActaActividad.fromJson(Map<String, dynamic> json) =>
      _$ActaActividadFromJson(json);

  @override
  final String? contenido;
  final List<AsistenteActa> _asistentes;
  @override
  @JsonKey()
  List<AsistenteActa> get asistentes {
    if (_asistentes is EqualUnmodifiableListView) return _asistentes;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_asistentes);
  }

  final List<AcuerdoActa> _acuerdos;
  @override
  @JsonKey()
  List<AcuerdoActa> get acuerdos {
    if (_acuerdos is EqualUnmodifiableListView) return _acuerdos;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_acuerdos);
  }

  @override
  final DateTime? fechaFirma;

  /// Create a copy of ActaActividad
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  _$ActaActividadCopyWith<_ActaActividad> get copyWith =>
      __$ActaActividadCopyWithImpl<_ActaActividad>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$ActaActividadToJson(
      this,
    );
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _ActaActividad &&
            (identical(other.contenido, contenido) ||
                other.contenido == contenido) &&
            const DeepCollectionEquality()
                .equals(other._asistentes, _asistentes) &&
            const DeepCollectionEquality().equals(other._acuerdos, _acuerdos) &&
            (identical(other.fechaFirma, fechaFirma) ||
                other.fechaFirma == fechaFirma));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      contenido,
      const DeepCollectionEquality().hash(_asistentes),
      const DeepCollectionEquality().hash(_acuerdos),
      fechaFirma);

  @override
  String toString() {
    return 'ActaActividad(contenido: $contenido, asistentes: $asistentes, acuerdos: $acuerdos, fechaFirma: $fechaFirma)';
  }
}

/// @nodoc
abstract mixin class _$ActaActividadCopyWith<$Res>
    implements $ActaActividadCopyWith<$Res> {
  factory _$ActaActividadCopyWith(
          _ActaActividad value, $Res Function(_ActaActividad) _then) =
      __$ActaActividadCopyWithImpl;
  @override
  @useResult
  $Res call(
      {String? contenido,
      List<AsistenteActa> asistentes,
      List<AcuerdoActa> acuerdos,
      DateTime? fechaFirma});
}

/// @nodoc
class __$ActaActividadCopyWithImpl<$Res>
    implements _$ActaActividadCopyWith<$Res> {
  __$ActaActividadCopyWithImpl(this._self, this._then);

  final _ActaActividad _self;
  final $Res Function(_ActaActividad) _then;

  /// Create a copy of ActaActividad
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $Res call({
    Object? contenido = freezed,
    Object? asistentes = null,
    Object? acuerdos = null,
    Object? fechaFirma = freezed,
  }) {
    return _then(_ActaActividad(
      contenido: freezed == contenido
          ? _self.contenido
          : contenido // ignore: cast_nullable_to_non_nullable
              as String?,
      asistentes: null == asistentes
          ? _self._asistentes
          : asistentes // ignore: cast_nullable_to_non_nullable
              as List<AsistenteActa>,
      acuerdos: null == acuerdos
          ? _self._acuerdos
          : acuerdos // ignore: cast_nullable_to_non_nullable
              as List<AcuerdoActa>,
      fechaFirma: freezed == fechaFirma
          ? _self.fechaFirma
          : fechaFirma // ignore: cast_nullable_to_non_nullable
              as DateTime?,
    ));
  }
}

/// @nodoc
mixin _$AsistenteActa {
  String get nombre;
  String get cargo;
  String? get rut;
  bool get asistio;

  /// Create a copy of AsistenteActa
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $AsistenteActaCopyWith<AsistenteActa> get copyWith =>
      _$AsistenteActaCopyWithImpl<AsistenteActa>(
          this as AsistenteActa, _$identity);

  /// Serializes this AsistenteActa to a JSON map.
  Map<String, dynamic> toJson();

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is AsistenteActa &&
            (identical(other.nombre, nombre) || other.nombre == nombre) &&
            (identical(other.cargo, cargo) || other.cargo == cargo) &&
            (identical(other.rut, rut) || other.rut == rut) &&
            (identical(other.asistio, asistio) || other.asistio == asistio));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, nombre, cargo, rut, asistio);

  @override
  String toString() {
    return 'AsistenteActa(nombre: $nombre, cargo: $cargo, rut: $rut, asistio: $asistio)';
  }
}

/// @nodoc
abstract mixin class $AsistenteActaCopyWith<$Res> {
  factory $AsistenteActaCopyWith(
          AsistenteActa value, $Res Function(AsistenteActa) _then) =
      _$AsistenteActaCopyWithImpl;
  @useResult
  $Res call({String nombre, String cargo, String? rut, bool asistio});
}

/// @nodoc
class _$AsistenteActaCopyWithImpl<$Res>
    implements $AsistenteActaCopyWith<$Res> {
  _$AsistenteActaCopyWithImpl(this._self, this._then);

  final AsistenteActa _self;
  final $Res Function(AsistenteActa) _then;

  /// Create a copy of AsistenteActa
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? nombre = null,
    Object? cargo = null,
    Object? rut = freezed,
    Object? asistio = null,
  }) {
    return _then(_self.copyWith(
      nombre: null == nombre
          ? _self.nombre
          : nombre // ignore: cast_nullable_to_non_nullable
              as String,
      cargo: null == cargo
          ? _self.cargo
          : cargo // ignore: cast_nullable_to_non_nullable
              as String,
      rut: freezed == rut
          ? _self.rut
          : rut // ignore: cast_nullable_to_non_nullable
              as String?,
      asistio: null == asistio
          ? _self.asistio
          : asistio // ignore: cast_nullable_to_non_nullable
              as bool,
    ));
  }
}

/// Adds pattern-matching-related methods to [AsistenteActa].
extension AsistenteActaPatterns on AsistenteActa {
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
    TResult Function(_AsistenteActa value)? $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _AsistenteActa() when $default != null:
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
    TResult Function(_AsistenteActa value) $default,
  ) {
    final _that = this;
    switch (_that) {
      case _AsistenteActa():
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
    TResult? Function(_AsistenteActa value)? $default,
  ) {
    final _that = this;
    switch (_that) {
      case _AsistenteActa() when $default != null:
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
    TResult Function(String nombre, String cargo, String? rut, bool asistio)?
        $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _AsistenteActa() when $default != null:
        return $default(_that.nombre, _that.cargo, _that.rut, _that.asistio);
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
    TResult Function(String nombre, String cargo, String? rut, bool asistio)
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _AsistenteActa():
        return $default(_that.nombre, _that.cargo, _that.rut, _that.asistio);
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
    TResult? Function(String nombre, String cargo, String? rut, bool asistio)?
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _AsistenteActa() when $default != null:
        return $default(_that.nombre, _that.cargo, _that.rut, _that.asistio);
      case _:
        return null;
    }
  }
}

/// @nodoc
@JsonSerializable()
class _AsistenteActa implements AsistenteActa {
  const _AsistenteActa(
      {required this.nombre,
      required this.cargo,
      this.rut,
      this.asistio = true});
  factory _AsistenteActa.fromJson(Map<String, dynamic> json) =>
      _$AsistenteActaFromJson(json);

  @override
  final String nombre;
  @override
  final String cargo;
  @override
  final String? rut;
  @override
  @JsonKey()
  final bool asistio;

  /// Create a copy of AsistenteActa
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  _$AsistenteActaCopyWith<_AsistenteActa> get copyWith =>
      __$AsistenteActaCopyWithImpl<_AsistenteActa>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$AsistenteActaToJson(
      this,
    );
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _AsistenteActa &&
            (identical(other.nombre, nombre) || other.nombre == nombre) &&
            (identical(other.cargo, cargo) || other.cargo == cargo) &&
            (identical(other.rut, rut) || other.rut == rut) &&
            (identical(other.asistio, asistio) || other.asistio == asistio));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, nombre, cargo, rut, asistio);

  @override
  String toString() {
    return 'AsistenteActa(nombre: $nombre, cargo: $cargo, rut: $rut, asistio: $asistio)';
  }
}

/// @nodoc
abstract mixin class _$AsistenteActaCopyWith<$Res>
    implements $AsistenteActaCopyWith<$Res> {
  factory _$AsistenteActaCopyWith(
          _AsistenteActa value, $Res Function(_AsistenteActa) _then) =
      __$AsistenteActaCopyWithImpl;
  @override
  @useResult
  $Res call({String nombre, String cargo, String? rut, bool asistio});
}

/// @nodoc
class __$AsistenteActaCopyWithImpl<$Res>
    implements _$AsistenteActaCopyWith<$Res> {
  __$AsistenteActaCopyWithImpl(this._self, this._then);

  final _AsistenteActa _self;
  final $Res Function(_AsistenteActa) _then;

  /// Create a copy of AsistenteActa
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $Res call({
    Object? nombre = null,
    Object? cargo = null,
    Object? rut = freezed,
    Object? asistio = null,
  }) {
    return _then(_AsistenteActa(
      nombre: null == nombre
          ? _self.nombre
          : nombre // ignore: cast_nullable_to_non_nullable
              as String,
      cargo: null == cargo
          ? _self.cargo
          : cargo // ignore: cast_nullable_to_non_nullable
              as String,
      rut: freezed == rut
          ? _self.rut
          : rut // ignore: cast_nullable_to_non_nullable
              as String?,
      asistio: null == asistio
          ? _self.asistio
          : asistio // ignore: cast_nullable_to_non_nullable
              as bool,
    ));
  }
}

/// @nodoc
mixin _$AcuerdoActa {
  String get id;
  String get descripcion;
  String get responsable;
  DateTime get fechaLimite;
  bool get completado;

  /// Create a copy of AcuerdoActa
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $AcuerdoActaCopyWith<AcuerdoActa> get copyWith =>
      _$AcuerdoActaCopyWithImpl<AcuerdoActa>(this as AcuerdoActa, _$identity);

  /// Serializes this AcuerdoActa to a JSON map.
  Map<String, dynamic> toJson();

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is AcuerdoActa &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.descripcion, descripcion) ||
                other.descripcion == descripcion) &&
            (identical(other.responsable, responsable) ||
                other.responsable == responsable) &&
            (identical(other.fechaLimite, fechaLimite) ||
                other.fechaLimite == fechaLimite) &&
            (identical(other.completado, completado) ||
                other.completado == completado));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType, id, descripcion, responsable, fechaLimite, completado);

  @override
  String toString() {
    return 'AcuerdoActa(id: $id, descripcion: $descripcion, responsable: $responsable, fechaLimite: $fechaLimite, completado: $completado)';
  }
}

/// @nodoc
abstract mixin class $AcuerdoActaCopyWith<$Res> {
  factory $AcuerdoActaCopyWith(
          AcuerdoActa value, $Res Function(AcuerdoActa) _then) =
      _$AcuerdoActaCopyWithImpl;
  @useResult
  $Res call(
      {String id,
      String descripcion,
      String responsable,
      DateTime fechaLimite,
      bool completado});
}

/// @nodoc
class _$AcuerdoActaCopyWithImpl<$Res> implements $AcuerdoActaCopyWith<$Res> {
  _$AcuerdoActaCopyWithImpl(this._self, this._then);

  final AcuerdoActa _self;
  final $Res Function(AcuerdoActa) _then;

  /// Create a copy of AcuerdoActa
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? descripcion = null,
    Object? responsable = null,
    Object? fechaLimite = null,
    Object? completado = null,
  }) {
    return _then(_self.copyWith(
      id: null == id
          ? _self.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      descripcion: null == descripcion
          ? _self.descripcion
          : descripcion // ignore: cast_nullable_to_non_nullable
              as String,
      responsable: null == responsable
          ? _self.responsable
          : responsable // ignore: cast_nullable_to_non_nullable
              as String,
      fechaLimite: null == fechaLimite
          ? _self.fechaLimite
          : fechaLimite // ignore: cast_nullable_to_non_nullable
              as DateTime,
      completado: null == completado
          ? _self.completado
          : completado // ignore: cast_nullable_to_non_nullable
              as bool,
    ));
  }
}

/// Adds pattern-matching-related methods to [AcuerdoActa].
extension AcuerdoActaPatterns on AcuerdoActa {
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
    TResult Function(_AcuerdoActa value)? $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _AcuerdoActa() when $default != null:
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
    TResult Function(_AcuerdoActa value) $default,
  ) {
    final _that = this;
    switch (_that) {
      case _AcuerdoActa():
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
    TResult? Function(_AcuerdoActa value)? $default,
  ) {
    final _that = this;
    switch (_that) {
      case _AcuerdoActa() when $default != null:
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
    TResult Function(String id, String descripcion, String responsable,
            DateTime fechaLimite, bool completado)?
        $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _AcuerdoActa() when $default != null:
        return $default(_that.id, _that.descripcion, _that.responsable,
            _that.fechaLimite, _that.completado);
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
    TResult Function(String id, String descripcion, String responsable,
            DateTime fechaLimite, bool completado)
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _AcuerdoActa():
        return $default(_that.id, _that.descripcion, _that.responsable,
            _that.fechaLimite, _that.completado);
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
    TResult? Function(String id, String descripcion, String responsable,
            DateTime fechaLimite, bool completado)?
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _AcuerdoActa() when $default != null:
        return $default(_that.id, _that.descripcion, _that.responsable,
            _that.fechaLimite, _that.completado);
      case _:
        return null;
    }
  }
}

/// @nodoc
@JsonSerializable()
class _AcuerdoActa implements AcuerdoActa {
  const _AcuerdoActa(
      {required this.id,
      required this.descripcion,
      required this.responsable,
      required this.fechaLimite,
      this.completado = false});
  factory _AcuerdoActa.fromJson(Map<String, dynamic> json) =>
      _$AcuerdoActaFromJson(json);

  @override
  final String id;
  @override
  final String descripcion;
  @override
  final String responsable;
  @override
  final DateTime fechaLimite;
  @override
  @JsonKey()
  final bool completado;

  /// Create a copy of AcuerdoActa
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  _$AcuerdoActaCopyWith<_AcuerdoActa> get copyWith =>
      __$AcuerdoActaCopyWithImpl<_AcuerdoActa>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$AcuerdoActaToJson(
      this,
    );
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _AcuerdoActa &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.descripcion, descripcion) ||
                other.descripcion == descripcion) &&
            (identical(other.responsable, responsable) ||
                other.responsable == responsable) &&
            (identical(other.fechaLimite, fechaLimite) ||
                other.fechaLimite == fechaLimite) &&
            (identical(other.completado, completado) ||
                other.completado == completado));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType, id, descripcion, responsable, fechaLimite, completado);

  @override
  String toString() {
    return 'AcuerdoActa(id: $id, descripcion: $descripcion, responsable: $responsable, fechaLimite: $fechaLimite, completado: $completado)';
  }
}

/// @nodoc
abstract mixin class _$AcuerdoActaCopyWith<$Res>
    implements $AcuerdoActaCopyWith<$Res> {
  factory _$AcuerdoActaCopyWith(
          _AcuerdoActa value, $Res Function(_AcuerdoActa) _then) =
      __$AcuerdoActaCopyWithImpl;
  @override
  @useResult
  $Res call(
      {String id,
      String descripcion,
      String responsable,
      DateTime fechaLimite,
      bool completado});
}

/// @nodoc
class __$AcuerdoActaCopyWithImpl<$Res> implements _$AcuerdoActaCopyWith<$Res> {
  __$AcuerdoActaCopyWithImpl(this._self, this._then);

  final _AcuerdoActa _self;
  final $Res Function(_AcuerdoActa) _then;

  /// Create a copy of AcuerdoActa
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $Res call({
    Object? id = null,
    Object? descripcion = null,
    Object? responsable = null,
    Object? fechaLimite = null,
    Object? completado = null,
  }) {
    return _then(_AcuerdoActa(
      id: null == id
          ? _self.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      descripcion: null == descripcion
          ? _self.descripcion
          : descripcion // ignore: cast_nullable_to_non_nullable
              as String,
      responsable: null == responsable
          ? _self.responsable
          : responsable // ignore: cast_nullable_to_non_nullable
              as String,
      fechaLimite: null == fechaLimite
          ? _self.fechaLimite
          : fechaLimite // ignore: cast_nullable_to_non_nullable
              as DateTime,
      completado: null == completado
          ? _self.completado
          : completado // ignore: cast_nullable_to_non_nullable
              as bool,
    ));
  }
}

// dart format on
