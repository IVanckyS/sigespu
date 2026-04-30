// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'reporte_seguridad.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

ReporteSeguridad _$ReporteSeguridadFromJson(Map<String, dynamic> json) {
  return _ReporteSeguridad.fromJson(json);
}

/// @nodoc
mixin _$ReporteSeguridad {
  String get id => throw _privateConstructorUsedError;
  String get tipo => throw _privateConstructorUsedError;
  double get lat => throw _privateConstructorUsedError;
  double get lng => throw _privateConstructorUsedError;
  String? get direccion => throw _privateConstructorUsedError;
  String? get descripcion => throw _privateConstructorUsedError;
  int? get severidad => throw _privateConstructorUsedError;
  @JsonKey(name: 'fecha_evento')
  DateTime? get fechaEvento => throw _privateConstructorUsedError;
  List<String> get fotos => throw _privateConstructorUsedError;
  String get estado => throw _privateConstructorUsedError;
  @JsonKey(name: 'derivado_a')
  String? get derivadoA => throw _privateConstructorUsedError;
  @JsonKey(name: 'reportado_por')
  String? get reportadoPor => throw _privateConstructorUsedError;
  @JsonKey(name: 'verificado_por')
  String? get verificadoPor => throw _privateConstructorUsedError;
  @JsonKey(name: 'created_at')
  DateTime? get createdAt => throw _privateConstructorUsedError;
  @JsonKey(name: 'updated_at')
  DateTime? get updatedAt => throw _privateConstructorUsedError;

  /// Serializes this ReporteSeguridad to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of ReporteSeguridad
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $ReporteSeguridadCopyWith<ReporteSeguridad> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ReporteSeguridadCopyWith<$Res> {
  factory $ReporteSeguridadCopyWith(
          ReporteSeguridad value, $Res Function(ReporteSeguridad) then) =
      _$ReporteSeguridadCopyWithImpl<$Res, ReporteSeguridad>;
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
class _$ReporteSeguridadCopyWithImpl<$Res, $Val extends ReporteSeguridad>
    implements $ReporteSeguridadCopyWith<$Res> {
  _$ReporteSeguridadCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

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
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      tipo: null == tipo
          ? _value.tipo
          : tipo // ignore: cast_nullable_to_non_nullable
              as String,
      lat: null == lat
          ? _value.lat
          : lat // ignore: cast_nullable_to_non_nullable
              as double,
      lng: null == lng
          ? _value.lng
          : lng // ignore: cast_nullable_to_non_nullable
              as double,
      direccion: freezed == direccion
          ? _value.direccion
          : direccion // ignore: cast_nullable_to_non_nullable
              as String?,
      descripcion: freezed == descripcion
          ? _value.descripcion
          : descripcion // ignore: cast_nullable_to_non_nullable
              as String?,
      severidad: freezed == severidad
          ? _value.severidad
          : severidad // ignore: cast_nullable_to_non_nullable
              as int?,
      fechaEvento: freezed == fechaEvento
          ? _value.fechaEvento
          : fechaEvento // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      fotos: null == fotos
          ? _value.fotos
          : fotos // ignore: cast_nullable_to_non_nullable
              as List<String>,
      estado: null == estado
          ? _value.estado
          : estado // ignore: cast_nullable_to_non_nullable
              as String,
      derivadoA: freezed == derivadoA
          ? _value.derivadoA
          : derivadoA // ignore: cast_nullable_to_non_nullable
              as String?,
      reportadoPor: freezed == reportadoPor
          ? _value.reportadoPor
          : reportadoPor // ignore: cast_nullable_to_non_nullable
              as String?,
      verificadoPor: freezed == verificadoPor
          ? _value.verificadoPor
          : verificadoPor // ignore: cast_nullable_to_non_nullable
              as String?,
      createdAt: freezed == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      updatedAt: freezed == updatedAt
          ? _value.updatedAt
          : updatedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$ReporteSeguridadImplCopyWith<$Res>
    implements $ReporteSeguridadCopyWith<$Res> {
  factory _$$ReporteSeguridadImplCopyWith(_$ReporteSeguridadImpl value,
          $Res Function(_$ReporteSeguridadImpl) then) =
      __$$ReporteSeguridadImplCopyWithImpl<$Res>;
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
class __$$ReporteSeguridadImplCopyWithImpl<$Res>
    extends _$ReporteSeguridadCopyWithImpl<$Res, _$ReporteSeguridadImpl>
    implements _$$ReporteSeguridadImplCopyWith<$Res> {
  __$$ReporteSeguridadImplCopyWithImpl(_$ReporteSeguridadImpl _value,
      $Res Function(_$ReporteSeguridadImpl) _then)
      : super(_value, _then);

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
    return _then(_$ReporteSeguridadImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      tipo: null == tipo
          ? _value.tipo
          : tipo // ignore: cast_nullable_to_non_nullable
              as String,
      lat: null == lat
          ? _value.lat
          : lat // ignore: cast_nullable_to_non_nullable
              as double,
      lng: null == lng
          ? _value.lng
          : lng // ignore: cast_nullable_to_non_nullable
              as double,
      direccion: freezed == direccion
          ? _value.direccion
          : direccion // ignore: cast_nullable_to_non_nullable
              as String?,
      descripcion: freezed == descripcion
          ? _value.descripcion
          : descripcion // ignore: cast_nullable_to_non_nullable
              as String?,
      severidad: freezed == severidad
          ? _value.severidad
          : severidad // ignore: cast_nullable_to_non_nullable
              as int?,
      fechaEvento: freezed == fechaEvento
          ? _value.fechaEvento
          : fechaEvento // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      fotos: null == fotos
          ? _value._fotos
          : fotos // ignore: cast_nullable_to_non_nullable
              as List<String>,
      estado: null == estado
          ? _value.estado
          : estado // ignore: cast_nullable_to_non_nullable
              as String,
      derivadoA: freezed == derivadoA
          ? _value.derivadoA
          : derivadoA // ignore: cast_nullable_to_non_nullable
              as String?,
      reportadoPor: freezed == reportadoPor
          ? _value.reportadoPor
          : reportadoPor // ignore: cast_nullable_to_non_nullable
              as String?,
      verificadoPor: freezed == verificadoPor
          ? _value.verificadoPor
          : verificadoPor // ignore: cast_nullable_to_non_nullable
              as String?,
      createdAt: freezed == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      updatedAt: freezed == updatedAt
          ? _value.updatedAt
          : updatedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$ReporteSeguridadImpl implements _ReporteSeguridad {
  const _$ReporteSeguridadImpl(
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

  factory _$ReporteSeguridadImpl.fromJson(Map<String, dynamic> json) =>
      _$$ReporteSeguridadImplFromJson(json);

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

  @override
  String toString() {
    return 'ReporteSeguridad(id: $id, tipo: $tipo, lat: $lat, lng: $lng, direccion: $direccion, descripcion: $descripcion, severidad: $severidad, fechaEvento: $fechaEvento, fotos: $fotos, estado: $estado, derivadoA: $derivadoA, reportadoPor: $reportadoPor, verificadoPor: $verificadoPor, createdAt: $createdAt, updatedAt: $updatedAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ReporteSeguridadImpl &&
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

  /// Create a copy of ReporteSeguridad
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ReporteSeguridadImplCopyWith<_$ReporteSeguridadImpl> get copyWith =>
      __$$ReporteSeguridadImplCopyWithImpl<_$ReporteSeguridadImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$ReporteSeguridadImplToJson(
      this,
    );
  }
}

abstract class _ReporteSeguridad implements ReporteSeguridad {
  const factory _ReporteSeguridad(
          {required final String id,
          required final String tipo,
          required final double lat,
          required final double lng,
          final String? direccion,
          final String? descripcion,
          final int? severidad,
          @JsonKey(name: 'fecha_evento') final DateTime? fechaEvento,
          final List<String> fotos,
          final String estado,
          @JsonKey(name: 'derivado_a') final String? derivadoA,
          @JsonKey(name: 'reportado_por') final String? reportadoPor,
          @JsonKey(name: 'verificado_por') final String? verificadoPor,
          @JsonKey(name: 'created_at') final DateTime? createdAt,
          @JsonKey(name: 'updated_at') final DateTime? updatedAt}) =
      _$ReporteSeguridadImpl;

  factory _ReporteSeguridad.fromJson(Map<String, dynamic> json) =
      _$ReporteSeguridadImpl.fromJson;

  @override
  String get id;
  @override
  String get tipo;
  @override
  double get lat;
  @override
  double get lng;
  @override
  String? get direccion;
  @override
  String? get descripcion;
  @override
  int? get severidad;
  @override
  @JsonKey(name: 'fecha_evento')
  DateTime? get fechaEvento;
  @override
  List<String> get fotos;
  @override
  String get estado;
  @override
  @JsonKey(name: 'derivado_a')
  String? get derivadoA;
  @override
  @JsonKey(name: 'reportado_por')
  String? get reportadoPor;
  @override
  @JsonKey(name: 'verificado_por')
  String? get verificadoPor;
  @override
  @JsonKey(name: 'created_at')
  DateTime? get createdAt;
  @override
  @JsonKey(name: 'updated_at')
  DateTime? get updatedAt;

  /// Create a copy of ReporteSeguridad
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ReporteSeguridadImplCopyWith<_$ReporteSeguridadImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
