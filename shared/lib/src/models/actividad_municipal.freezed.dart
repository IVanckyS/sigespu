// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'actividad_municipal.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

ActividadMunicipal _$ActividadMunicipalFromJson(Map<String, dynamic> json) {
  return _ActividadMunicipal.fromJson(json);
}

/// @nodoc
mixin _$ActividadMunicipal {
  String get id => throw _privateConstructorUsedError;
  TipoActividad get tipo => throw _privateConstructorUsedError;
  EstadoActividad get estado => throw _privateConstructorUsedError;
  String get titulo => throw _privateConstructorUsedError;
  String get descripcion => throw _privateConstructorUsedError;
  DateTime get fechaInicio => throw _privateConstructorUsedError;
  DateTime? get fechaFin => throw _privateConstructorUsedError;
  double? get lat => throw _privateConstructorUsedError;
  double? get lng => throw _privateConstructorUsedError;
  String? get direccion => throw _privateConstructorUsedError;
  String? get sector => throw _privateConstructorUsedError;
  List<String> get participanteIds => throw _privateConstructorUsedError;
  ActaActividad? get acta => throw _privateConstructorUsedError;
  String get creadoPor => throw _privateConstructorUsedError;
  DateTime get creadoEn => throw _privateConstructorUsedError;
  DateTime? get actualizadoEn => throw _privateConstructorUsedError;
  double? get presupuestoEstimado => throw _privateConstructorUsedError;
  String? get direccionMunicipal => throw _privateConstructorUsedError;
  List<String> get adjuntos => throw _privateConstructorUsedError;

  /// Serializes this ActividadMunicipal to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of ActividadMunicipal
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $ActividadMunicipalCopyWith<ActividadMunicipal> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ActividadMunicipalCopyWith<$Res> {
  factory $ActividadMunicipalCopyWith(
          ActividadMunicipal value, $Res Function(ActividadMunicipal) then) =
      _$ActividadMunicipalCopyWithImpl<$Res, ActividadMunicipal>;
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
class _$ActividadMunicipalCopyWithImpl<$Res, $Val extends ActividadMunicipal>
    implements $ActividadMunicipalCopyWith<$Res> {
  _$ActividadMunicipalCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

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
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      tipo: null == tipo
          ? _value.tipo
          : tipo // ignore: cast_nullable_to_non_nullable
              as TipoActividad,
      estado: null == estado
          ? _value.estado
          : estado // ignore: cast_nullable_to_non_nullable
              as EstadoActividad,
      titulo: null == titulo
          ? _value.titulo
          : titulo // ignore: cast_nullable_to_non_nullable
              as String,
      descripcion: null == descripcion
          ? _value.descripcion
          : descripcion // ignore: cast_nullable_to_non_nullable
              as String,
      fechaInicio: null == fechaInicio
          ? _value.fechaInicio
          : fechaInicio // ignore: cast_nullable_to_non_nullable
              as DateTime,
      fechaFin: freezed == fechaFin
          ? _value.fechaFin
          : fechaFin // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      lat: freezed == lat
          ? _value.lat
          : lat // ignore: cast_nullable_to_non_nullable
              as double?,
      lng: freezed == lng
          ? _value.lng
          : lng // ignore: cast_nullable_to_non_nullable
              as double?,
      direccion: freezed == direccion
          ? _value.direccion
          : direccion // ignore: cast_nullable_to_non_nullable
              as String?,
      sector: freezed == sector
          ? _value.sector
          : sector // ignore: cast_nullable_to_non_nullable
              as String?,
      participanteIds: null == participanteIds
          ? _value.participanteIds
          : participanteIds // ignore: cast_nullable_to_non_nullable
              as List<String>,
      acta: freezed == acta
          ? _value.acta
          : acta // ignore: cast_nullable_to_non_nullable
              as ActaActividad?,
      creadoPor: null == creadoPor
          ? _value.creadoPor
          : creadoPor // ignore: cast_nullable_to_non_nullable
              as String,
      creadoEn: null == creadoEn
          ? _value.creadoEn
          : creadoEn // ignore: cast_nullable_to_non_nullable
              as DateTime,
      actualizadoEn: freezed == actualizadoEn
          ? _value.actualizadoEn
          : actualizadoEn // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      presupuestoEstimado: freezed == presupuestoEstimado
          ? _value.presupuestoEstimado
          : presupuestoEstimado // ignore: cast_nullable_to_non_nullable
              as double?,
      direccionMunicipal: freezed == direccionMunicipal
          ? _value.direccionMunicipal
          : direccionMunicipal // ignore: cast_nullable_to_non_nullable
              as String?,
      adjuntos: null == adjuntos
          ? _value.adjuntos
          : adjuntos // ignore: cast_nullable_to_non_nullable
              as List<String>,
    ) as $Val);
  }

  /// Create a copy of ActividadMunicipal
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $ActaActividadCopyWith<$Res>? get acta {
    if (_value.acta == null) {
      return null;
    }

    return $ActaActividadCopyWith<$Res>(_value.acta!, (value) {
      return _then(_value.copyWith(acta: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$ActividadMunicipalImplCopyWith<$Res>
    implements $ActividadMunicipalCopyWith<$Res> {
  factory _$$ActividadMunicipalImplCopyWith(_$ActividadMunicipalImpl value,
          $Res Function(_$ActividadMunicipalImpl) then) =
      __$$ActividadMunicipalImplCopyWithImpl<$Res>;
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
class __$$ActividadMunicipalImplCopyWithImpl<$Res>
    extends _$ActividadMunicipalCopyWithImpl<$Res, _$ActividadMunicipalImpl>
    implements _$$ActividadMunicipalImplCopyWith<$Res> {
  __$$ActividadMunicipalImplCopyWithImpl(_$ActividadMunicipalImpl _value,
      $Res Function(_$ActividadMunicipalImpl) _then)
      : super(_value, _then);

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
    return _then(_$ActividadMunicipalImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      tipo: null == tipo
          ? _value.tipo
          : tipo // ignore: cast_nullable_to_non_nullable
              as TipoActividad,
      estado: null == estado
          ? _value.estado
          : estado // ignore: cast_nullable_to_non_nullable
              as EstadoActividad,
      titulo: null == titulo
          ? _value.titulo
          : titulo // ignore: cast_nullable_to_non_nullable
              as String,
      descripcion: null == descripcion
          ? _value.descripcion
          : descripcion // ignore: cast_nullable_to_non_nullable
              as String,
      fechaInicio: null == fechaInicio
          ? _value.fechaInicio
          : fechaInicio // ignore: cast_nullable_to_non_nullable
              as DateTime,
      fechaFin: freezed == fechaFin
          ? _value.fechaFin
          : fechaFin // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      lat: freezed == lat
          ? _value.lat
          : lat // ignore: cast_nullable_to_non_nullable
              as double?,
      lng: freezed == lng
          ? _value.lng
          : lng // ignore: cast_nullable_to_non_nullable
              as double?,
      direccion: freezed == direccion
          ? _value.direccion
          : direccion // ignore: cast_nullable_to_non_nullable
              as String?,
      sector: freezed == sector
          ? _value.sector
          : sector // ignore: cast_nullable_to_non_nullable
              as String?,
      participanteIds: null == participanteIds
          ? _value._participanteIds
          : participanteIds // ignore: cast_nullable_to_non_nullable
              as List<String>,
      acta: freezed == acta
          ? _value.acta
          : acta // ignore: cast_nullable_to_non_nullable
              as ActaActividad?,
      creadoPor: null == creadoPor
          ? _value.creadoPor
          : creadoPor // ignore: cast_nullable_to_non_nullable
              as String,
      creadoEn: null == creadoEn
          ? _value.creadoEn
          : creadoEn // ignore: cast_nullable_to_non_nullable
              as DateTime,
      actualizadoEn: freezed == actualizadoEn
          ? _value.actualizadoEn
          : actualizadoEn // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      presupuestoEstimado: freezed == presupuestoEstimado
          ? _value.presupuestoEstimado
          : presupuestoEstimado // ignore: cast_nullable_to_non_nullable
              as double?,
      direccionMunicipal: freezed == direccionMunicipal
          ? _value.direccionMunicipal
          : direccionMunicipal // ignore: cast_nullable_to_non_nullable
              as String?,
      adjuntos: null == adjuntos
          ? _value._adjuntos
          : adjuntos // ignore: cast_nullable_to_non_nullable
              as List<String>,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$ActividadMunicipalImpl implements _ActividadMunicipal {
  const _$ActividadMunicipalImpl(
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

  factory _$ActividadMunicipalImpl.fromJson(Map<String, dynamic> json) =>
      _$$ActividadMunicipalImplFromJson(json);

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

  @override
  String toString() {
    return 'ActividadMunicipal(id: $id, tipo: $tipo, estado: $estado, titulo: $titulo, descripcion: $descripcion, fechaInicio: $fechaInicio, fechaFin: $fechaFin, lat: $lat, lng: $lng, direccion: $direccion, sector: $sector, participanteIds: $participanteIds, acta: $acta, creadoPor: $creadoPor, creadoEn: $creadoEn, actualizadoEn: $actualizadoEn, presupuestoEstimado: $presupuestoEstimado, direccionMunicipal: $direccionMunicipal, adjuntos: $adjuntos)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ActividadMunicipalImpl &&
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

  /// Create a copy of ActividadMunicipal
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ActividadMunicipalImplCopyWith<_$ActividadMunicipalImpl> get copyWith =>
      __$$ActividadMunicipalImplCopyWithImpl<_$ActividadMunicipalImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$ActividadMunicipalImplToJson(
      this,
    );
  }
}

abstract class _ActividadMunicipal implements ActividadMunicipal {
  const factory _ActividadMunicipal(
      {required final String id,
      required final TipoActividad tipo,
      required final EstadoActividad estado,
      required final String titulo,
      required final String descripcion,
      required final DateTime fechaInicio,
      final DateTime? fechaFin,
      final double? lat,
      final double? lng,
      final String? direccion,
      final String? sector,
      final List<String> participanteIds,
      final ActaActividad? acta,
      required final String creadoPor,
      required final DateTime creadoEn,
      final DateTime? actualizadoEn,
      final double? presupuestoEstimado,
      final String? direccionMunicipal,
      final List<String> adjuntos}) = _$ActividadMunicipalImpl;

  factory _ActividadMunicipal.fromJson(Map<String, dynamic> json) =
      _$ActividadMunicipalImpl.fromJson;

  @override
  String get id;
  @override
  TipoActividad get tipo;
  @override
  EstadoActividad get estado;
  @override
  String get titulo;
  @override
  String get descripcion;
  @override
  DateTime get fechaInicio;
  @override
  DateTime? get fechaFin;
  @override
  double? get lat;
  @override
  double? get lng;
  @override
  String? get direccion;
  @override
  String? get sector;
  @override
  List<String> get participanteIds;
  @override
  ActaActividad? get acta;
  @override
  String get creadoPor;
  @override
  DateTime get creadoEn;
  @override
  DateTime? get actualizadoEn;
  @override
  double? get presupuestoEstimado;
  @override
  String? get direccionMunicipal;
  @override
  List<String> get adjuntos;

  /// Create a copy of ActividadMunicipal
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ActividadMunicipalImplCopyWith<_$ActividadMunicipalImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

ActaActividad _$ActaActividadFromJson(Map<String, dynamic> json) {
  return _ActaActividad.fromJson(json);
}

/// @nodoc
mixin _$ActaActividad {
  String? get contenido => throw _privateConstructorUsedError;
  List<AsistenteActa> get asistentes => throw _privateConstructorUsedError;
  List<AcuerdoActa> get acuerdos => throw _privateConstructorUsedError;
  DateTime? get fechaFirma => throw _privateConstructorUsedError;

  /// Serializes this ActaActividad to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of ActaActividad
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $ActaActividadCopyWith<ActaActividad> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ActaActividadCopyWith<$Res> {
  factory $ActaActividadCopyWith(
          ActaActividad value, $Res Function(ActaActividad) then) =
      _$ActaActividadCopyWithImpl<$Res, ActaActividad>;
  @useResult
  $Res call(
      {String? contenido,
      List<AsistenteActa> asistentes,
      List<AcuerdoActa> acuerdos,
      DateTime? fechaFirma});
}

/// @nodoc
class _$ActaActividadCopyWithImpl<$Res, $Val extends ActaActividad>
    implements $ActaActividadCopyWith<$Res> {
  _$ActaActividadCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

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
    return _then(_value.copyWith(
      contenido: freezed == contenido
          ? _value.contenido
          : contenido // ignore: cast_nullable_to_non_nullable
              as String?,
      asistentes: null == asistentes
          ? _value.asistentes
          : asistentes // ignore: cast_nullable_to_non_nullable
              as List<AsistenteActa>,
      acuerdos: null == acuerdos
          ? _value.acuerdos
          : acuerdos // ignore: cast_nullable_to_non_nullable
              as List<AcuerdoActa>,
      fechaFirma: freezed == fechaFirma
          ? _value.fechaFirma
          : fechaFirma // ignore: cast_nullable_to_non_nullable
              as DateTime?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$ActaActividadImplCopyWith<$Res>
    implements $ActaActividadCopyWith<$Res> {
  factory _$$ActaActividadImplCopyWith(
          _$ActaActividadImpl value, $Res Function(_$ActaActividadImpl) then) =
      __$$ActaActividadImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String? contenido,
      List<AsistenteActa> asistentes,
      List<AcuerdoActa> acuerdos,
      DateTime? fechaFirma});
}

/// @nodoc
class __$$ActaActividadImplCopyWithImpl<$Res>
    extends _$ActaActividadCopyWithImpl<$Res, _$ActaActividadImpl>
    implements _$$ActaActividadImplCopyWith<$Res> {
  __$$ActaActividadImplCopyWithImpl(
      _$ActaActividadImpl _value, $Res Function(_$ActaActividadImpl) _then)
      : super(_value, _then);

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
    return _then(_$ActaActividadImpl(
      contenido: freezed == contenido
          ? _value.contenido
          : contenido // ignore: cast_nullable_to_non_nullable
              as String?,
      asistentes: null == asistentes
          ? _value._asistentes
          : asistentes // ignore: cast_nullable_to_non_nullable
              as List<AsistenteActa>,
      acuerdos: null == acuerdos
          ? _value._acuerdos
          : acuerdos // ignore: cast_nullable_to_non_nullable
              as List<AcuerdoActa>,
      fechaFirma: freezed == fechaFirma
          ? _value.fechaFirma
          : fechaFirma // ignore: cast_nullable_to_non_nullable
              as DateTime?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$ActaActividadImpl implements _ActaActividad {
  const _$ActaActividadImpl(
      {this.contenido,
      final List<AsistenteActa> asistentes = const [],
      final List<AcuerdoActa> acuerdos = const [],
      this.fechaFirma})
      : _asistentes = asistentes,
        _acuerdos = acuerdos;

  factory _$ActaActividadImpl.fromJson(Map<String, dynamic> json) =>
      _$$ActaActividadImplFromJson(json);

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

  @override
  String toString() {
    return 'ActaActividad(contenido: $contenido, asistentes: $asistentes, acuerdos: $acuerdos, fechaFirma: $fechaFirma)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ActaActividadImpl &&
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

  /// Create a copy of ActaActividad
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ActaActividadImplCopyWith<_$ActaActividadImpl> get copyWith =>
      __$$ActaActividadImplCopyWithImpl<_$ActaActividadImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$ActaActividadImplToJson(
      this,
    );
  }
}

abstract class _ActaActividad implements ActaActividad {
  const factory _ActaActividad(
      {final String? contenido,
      final List<AsistenteActa> asistentes,
      final List<AcuerdoActa> acuerdos,
      final DateTime? fechaFirma}) = _$ActaActividadImpl;

  factory _ActaActividad.fromJson(Map<String, dynamic> json) =
      _$ActaActividadImpl.fromJson;

  @override
  String? get contenido;
  @override
  List<AsistenteActa> get asistentes;
  @override
  List<AcuerdoActa> get acuerdos;
  @override
  DateTime? get fechaFirma;

  /// Create a copy of ActaActividad
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ActaActividadImplCopyWith<_$ActaActividadImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

AsistenteActa _$AsistenteActaFromJson(Map<String, dynamic> json) {
  return _AsistenteActa.fromJson(json);
}

/// @nodoc
mixin _$AsistenteActa {
  String get nombre => throw _privateConstructorUsedError;
  String get cargo => throw _privateConstructorUsedError;
  String? get rut => throw _privateConstructorUsedError;
  bool get asistio => throw _privateConstructorUsedError;

  /// Serializes this AsistenteActa to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of AsistenteActa
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $AsistenteActaCopyWith<AsistenteActa> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $AsistenteActaCopyWith<$Res> {
  factory $AsistenteActaCopyWith(
          AsistenteActa value, $Res Function(AsistenteActa) then) =
      _$AsistenteActaCopyWithImpl<$Res, AsistenteActa>;
  @useResult
  $Res call({String nombre, String cargo, String? rut, bool asistio});
}

/// @nodoc
class _$AsistenteActaCopyWithImpl<$Res, $Val extends AsistenteActa>
    implements $AsistenteActaCopyWith<$Res> {
  _$AsistenteActaCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

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
    return _then(_value.copyWith(
      nombre: null == nombre
          ? _value.nombre
          : nombre // ignore: cast_nullable_to_non_nullable
              as String,
      cargo: null == cargo
          ? _value.cargo
          : cargo // ignore: cast_nullable_to_non_nullable
              as String,
      rut: freezed == rut
          ? _value.rut
          : rut // ignore: cast_nullable_to_non_nullable
              as String?,
      asistio: null == asistio
          ? _value.asistio
          : asistio // ignore: cast_nullable_to_non_nullable
              as bool,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$AsistenteActaImplCopyWith<$Res>
    implements $AsistenteActaCopyWith<$Res> {
  factory _$$AsistenteActaImplCopyWith(
          _$AsistenteActaImpl value, $Res Function(_$AsistenteActaImpl) then) =
      __$$AsistenteActaImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String nombre, String cargo, String? rut, bool asistio});
}

/// @nodoc
class __$$AsistenteActaImplCopyWithImpl<$Res>
    extends _$AsistenteActaCopyWithImpl<$Res, _$AsistenteActaImpl>
    implements _$$AsistenteActaImplCopyWith<$Res> {
  __$$AsistenteActaImplCopyWithImpl(
      _$AsistenteActaImpl _value, $Res Function(_$AsistenteActaImpl) _then)
      : super(_value, _then);

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
    return _then(_$AsistenteActaImpl(
      nombre: null == nombre
          ? _value.nombre
          : nombre // ignore: cast_nullable_to_non_nullable
              as String,
      cargo: null == cargo
          ? _value.cargo
          : cargo // ignore: cast_nullable_to_non_nullable
              as String,
      rut: freezed == rut
          ? _value.rut
          : rut // ignore: cast_nullable_to_non_nullable
              as String?,
      asistio: null == asistio
          ? _value.asistio
          : asistio // ignore: cast_nullable_to_non_nullable
              as bool,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$AsistenteActaImpl implements _AsistenteActa {
  const _$AsistenteActaImpl(
      {required this.nombre,
      required this.cargo,
      this.rut,
      this.asistio = true});

  factory _$AsistenteActaImpl.fromJson(Map<String, dynamic> json) =>
      _$$AsistenteActaImplFromJson(json);

  @override
  final String nombre;
  @override
  final String cargo;
  @override
  final String? rut;
  @override
  @JsonKey()
  final bool asistio;

  @override
  String toString() {
    return 'AsistenteActa(nombre: $nombre, cargo: $cargo, rut: $rut, asistio: $asistio)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$AsistenteActaImpl &&
            (identical(other.nombre, nombre) || other.nombre == nombre) &&
            (identical(other.cargo, cargo) || other.cargo == cargo) &&
            (identical(other.rut, rut) || other.rut == rut) &&
            (identical(other.asistio, asistio) || other.asistio == asistio));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, nombre, cargo, rut, asistio);

  /// Create a copy of AsistenteActa
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$AsistenteActaImplCopyWith<_$AsistenteActaImpl> get copyWith =>
      __$$AsistenteActaImplCopyWithImpl<_$AsistenteActaImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$AsistenteActaImplToJson(
      this,
    );
  }
}

abstract class _AsistenteActa implements AsistenteActa {
  const factory _AsistenteActa(
      {required final String nombre,
      required final String cargo,
      final String? rut,
      final bool asistio}) = _$AsistenteActaImpl;

  factory _AsistenteActa.fromJson(Map<String, dynamic> json) =
      _$AsistenteActaImpl.fromJson;

  @override
  String get nombre;
  @override
  String get cargo;
  @override
  String? get rut;
  @override
  bool get asistio;

  /// Create a copy of AsistenteActa
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$AsistenteActaImplCopyWith<_$AsistenteActaImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

AcuerdoActa _$AcuerdoActaFromJson(Map<String, dynamic> json) {
  return _AcuerdoActa.fromJson(json);
}

/// @nodoc
mixin _$AcuerdoActa {
  String get id => throw _privateConstructorUsedError;
  String get descripcion => throw _privateConstructorUsedError;
  String get responsable => throw _privateConstructorUsedError;
  DateTime get fechaLimite => throw _privateConstructorUsedError;
  bool get completado => throw _privateConstructorUsedError;

  /// Serializes this AcuerdoActa to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of AcuerdoActa
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $AcuerdoActaCopyWith<AcuerdoActa> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $AcuerdoActaCopyWith<$Res> {
  factory $AcuerdoActaCopyWith(
          AcuerdoActa value, $Res Function(AcuerdoActa) then) =
      _$AcuerdoActaCopyWithImpl<$Res, AcuerdoActa>;
  @useResult
  $Res call(
      {String id,
      String descripcion,
      String responsable,
      DateTime fechaLimite,
      bool completado});
}

/// @nodoc
class _$AcuerdoActaCopyWithImpl<$Res, $Val extends AcuerdoActa>
    implements $AcuerdoActaCopyWith<$Res> {
  _$AcuerdoActaCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

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
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      descripcion: null == descripcion
          ? _value.descripcion
          : descripcion // ignore: cast_nullable_to_non_nullable
              as String,
      responsable: null == responsable
          ? _value.responsable
          : responsable // ignore: cast_nullable_to_non_nullable
              as String,
      fechaLimite: null == fechaLimite
          ? _value.fechaLimite
          : fechaLimite // ignore: cast_nullable_to_non_nullable
              as DateTime,
      completado: null == completado
          ? _value.completado
          : completado // ignore: cast_nullable_to_non_nullable
              as bool,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$AcuerdoActaImplCopyWith<$Res>
    implements $AcuerdoActaCopyWith<$Res> {
  factory _$$AcuerdoActaImplCopyWith(
          _$AcuerdoActaImpl value, $Res Function(_$AcuerdoActaImpl) then) =
      __$$AcuerdoActaImplCopyWithImpl<$Res>;
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
class __$$AcuerdoActaImplCopyWithImpl<$Res>
    extends _$AcuerdoActaCopyWithImpl<$Res, _$AcuerdoActaImpl>
    implements _$$AcuerdoActaImplCopyWith<$Res> {
  __$$AcuerdoActaImplCopyWithImpl(
      _$AcuerdoActaImpl _value, $Res Function(_$AcuerdoActaImpl) _then)
      : super(_value, _then);

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
    return _then(_$AcuerdoActaImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      descripcion: null == descripcion
          ? _value.descripcion
          : descripcion // ignore: cast_nullable_to_non_nullable
              as String,
      responsable: null == responsable
          ? _value.responsable
          : responsable // ignore: cast_nullable_to_non_nullable
              as String,
      fechaLimite: null == fechaLimite
          ? _value.fechaLimite
          : fechaLimite // ignore: cast_nullable_to_non_nullable
              as DateTime,
      completado: null == completado
          ? _value.completado
          : completado // ignore: cast_nullable_to_non_nullable
              as bool,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$AcuerdoActaImpl implements _AcuerdoActa {
  const _$AcuerdoActaImpl(
      {required this.id,
      required this.descripcion,
      required this.responsable,
      required this.fechaLimite,
      this.completado = false});

  factory _$AcuerdoActaImpl.fromJson(Map<String, dynamic> json) =>
      _$$AcuerdoActaImplFromJson(json);

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

  @override
  String toString() {
    return 'AcuerdoActa(id: $id, descripcion: $descripcion, responsable: $responsable, fechaLimite: $fechaLimite, completado: $completado)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$AcuerdoActaImpl &&
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

  /// Create a copy of AcuerdoActa
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$AcuerdoActaImplCopyWith<_$AcuerdoActaImpl> get copyWith =>
      __$$AcuerdoActaImplCopyWithImpl<_$AcuerdoActaImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$AcuerdoActaImplToJson(
      this,
    );
  }
}

abstract class _AcuerdoActa implements AcuerdoActa {
  const factory _AcuerdoActa(
      {required final String id,
      required final String descripcion,
      required final String responsable,
      required final DateTime fechaLimite,
      final bool completado}) = _$AcuerdoActaImpl;

  factory _AcuerdoActa.fromJson(Map<String, dynamic> json) =
      _$AcuerdoActaImpl.fromJson;

  @override
  String get id;
  @override
  String get descripcion;
  @override
  String get responsable;
  @override
  DateTime get fechaLimite;
  @override
  bool get completado;

  /// Create a copy of AcuerdoActa
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$AcuerdoActaImplCopyWith<_$AcuerdoActaImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
