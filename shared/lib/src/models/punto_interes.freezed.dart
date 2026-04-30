// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'punto_interes.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

PuntoInteres _$PuntoInteresFromJson(Map<String, dynamic> json) {
  return _PuntoInteres.fromJson(json);
}

/// @nodoc
mixin _$PuntoInteres {
  String get id => throw _privateConstructorUsedError;
  String get tipo => throw _privateConstructorUsedError;
  String? get nombre => throw _privateConstructorUsedError;
  String? get descripcion => throw _privateConstructorUsedError;
  String? get direccion => throw _privateConstructorUsedError;
  double get lat => throw _privateConstructorUsedError;
  double get lng => throw _privateConstructorUsedError;
  Map<String, dynamic>? get metadata => throw _privateConstructorUsedError;
  String get estado => throw _privateConstructorUsedError;
  String get origen => throw _privateConstructorUsedError;
  @JsonKey(name: 'fuente_origen')
  String? get fuenteOrigen => throw _privateConstructorUsedError;
  @JsonKey(name: 'created_by')
  String? get createdBy => throw _privateConstructorUsedError;
  @JsonKey(name: 'created_at')
  DateTime? get createdAt => throw _privateConstructorUsedError;
  @JsonKey(name: 'updated_at')
  DateTime? get updatedAt => throw _privateConstructorUsedError;

  /// Serializes this PuntoInteres to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of PuntoInteres
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $PuntoInteresCopyWith<PuntoInteres> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $PuntoInteresCopyWith<$Res> {
  factory $PuntoInteresCopyWith(
          PuntoInteres value, $Res Function(PuntoInteres) then) =
      _$PuntoInteresCopyWithImpl<$Res, PuntoInteres>;
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
class _$PuntoInteresCopyWithImpl<$Res, $Val extends PuntoInteres>
    implements $PuntoInteresCopyWith<$Res> {
  _$PuntoInteresCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

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
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      tipo: null == tipo
          ? _value.tipo
          : tipo // ignore: cast_nullable_to_non_nullable
              as String,
      nombre: freezed == nombre
          ? _value.nombre
          : nombre // ignore: cast_nullable_to_non_nullable
              as String?,
      descripcion: freezed == descripcion
          ? _value.descripcion
          : descripcion // ignore: cast_nullable_to_non_nullable
              as String?,
      direccion: freezed == direccion
          ? _value.direccion
          : direccion // ignore: cast_nullable_to_non_nullable
              as String?,
      lat: null == lat
          ? _value.lat
          : lat // ignore: cast_nullable_to_non_nullable
              as double,
      lng: null == lng
          ? _value.lng
          : lng // ignore: cast_nullable_to_non_nullable
              as double,
      metadata: freezed == metadata
          ? _value.metadata
          : metadata // ignore: cast_nullable_to_non_nullable
              as Map<String, dynamic>?,
      estado: null == estado
          ? _value.estado
          : estado // ignore: cast_nullable_to_non_nullable
              as String,
      origen: null == origen
          ? _value.origen
          : origen // ignore: cast_nullable_to_non_nullable
              as String,
      fuenteOrigen: freezed == fuenteOrigen
          ? _value.fuenteOrigen
          : fuenteOrigen // ignore: cast_nullable_to_non_nullable
              as String?,
      createdBy: freezed == createdBy
          ? _value.createdBy
          : createdBy // ignore: cast_nullable_to_non_nullable
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
abstract class _$$PuntoInteresImplCopyWith<$Res>
    implements $PuntoInteresCopyWith<$Res> {
  factory _$$PuntoInteresImplCopyWith(
          _$PuntoInteresImpl value, $Res Function(_$PuntoInteresImpl) then) =
      __$$PuntoInteresImplCopyWithImpl<$Res>;
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
class __$$PuntoInteresImplCopyWithImpl<$Res>
    extends _$PuntoInteresCopyWithImpl<$Res, _$PuntoInteresImpl>
    implements _$$PuntoInteresImplCopyWith<$Res> {
  __$$PuntoInteresImplCopyWithImpl(
      _$PuntoInteresImpl _value, $Res Function(_$PuntoInteresImpl) _then)
      : super(_value, _then);

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
    return _then(_$PuntoInteresImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      tipo: null == tipo
          ? _value.tipo
          : tipo // ignore: cast_nullable_to_non_nullable
              as String,
      nombre: freezed == nombre
          ? _value.nombre
          : nombre // ignore: cast_nullable_to_non_nullable
              as String?,
      descripcion: freezed == descripcion
          ? _value.descripcion
          : descripcion // ignore: cast_nullable_to_non_nullable
              as String?,
      direccion: freezed == direccion
          ? _value.direccion
          : direccion // ignore: cast_nullable_to_non_nullable
              as String?,
      lat: null == lat
          ? _value.lat
          : lat // ignore: cast_nullable_to_non_nullable
              as double,
      lng: null == lng
          ? _value.lng
          : lng // ignore: cast_nullable_to_non_nullable
              as double,
      metadata: freezed == metadata
          ? _value._metadata
          : metadata // ignore: cast_nullable_to_non_nullable
              as Map<String, dynamic>?,
      estado: null == estado
          ? _value.estado
          : estado // ignore: cast_nullable_to_non_nullable
              as String,
      origen: null == origen
          ? _value.origen
          : origen // ignore: cast_nullable_to_non_nullable
              as String,
      fuenteOrigen: freezed == fuenteOrigen
          ? _value.fuenteOrigen
          : fuenteOrigen // ignore: cast_nullable_to_non_nullable
              as String?,
      createdBy: freezed == createdBy
          ? _value.createdBy
          : createdBy // ignore: cast_nullable_to_non_nullable
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
class _$PuntoInteresImpl implements _PuntoInteres {
  const _$PuntoInteresImpl(
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

  factory _$PuntoInteresImpl.fromJson(Map<String, dynamic> json) =>
      _$$PuntoInteresImplFromJson(json);

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

  @override
  String toString() {
    return 'PuntoInteres(id: $id, tipo: $tipo, nombre: $nombre, descripcion: $descripcion, direccion: $direccion, lat: $lat, lng: $lng, metadata: $metadata, estado: $estado, origen: $origen, fuenteOrigen: $fuenteOrigen, createdBy: $createdBy, createdAt: $createdAt, updatedAt: $updatedAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$PuntoInteresImpl &&
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

  /// Create a copy of PuntoInteres
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$PuntoInteresImplCopyWith<_$PuntoInteresImpl> get copyWith =>
      __$$PuntoInteresImplCopyWithImpl<_$PuntoInteresImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$PuntoInteresImplToJson(
      this,
    );
  }
}

abstract class _PuntoInteres implements PuntoInteres {
  const factory _PuntoInteres(
          {required final String id,
          required final String tipo,
          final String? nombre,
          final String? descripcion,
          final String? direccion,
          required final double lat,
          required final double lng,
          final Map<String, dynamic>? metadata,
          final String estado,
          final String origen,
          @JsonKey(name: 'fuente_origen') final String? fuenteOrigen,
          @JsonKey(name: 'created_by') final String? createdBy,
          @JsonKey(name: 'created_at') final DateTime? createdAt,
          @JsonKey(name: 'updated_at') final DateTime? updatedAt}) =
      _$PuntoInteresImpl;

  factory _PuntoInteres.fromJson(Map<String, dynamic> json) =
      _$PuntoInteresImpl.fromJson;

  @override
  String get id;
  @override
  String get tipo;
  @override
  String? get nombre;
  @override
  String? get descripcion;
  @override
  String? get direccion;
  @override
  double get lat;
  @override
  double get lng;
  @override
  Map<String, dynamic>? get metadata;
  @override
  String get estado;
  @override
  String get origen;
  @override
  @JsonKey(name: 'fuente_origen')
  String? get fuenteOrigen;
  @override
  @JsonKey(name: 'created_by')
  String? get createdBy;
  @override
  @JsonKey(name: 'created_at')
  DateTime? get createdAt;
  @override
  @JsonKey(name: 'updated_at')
  DateTime? get updatedAt;

  /// Create a copy of PuntoInteres
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$PuntoInteresImplCopyWith<_$PuntoInteresImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
