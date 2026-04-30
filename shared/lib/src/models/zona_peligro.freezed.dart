// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'zona_peligro.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

ZonaPeligro _$ZonaPeligroFromJson(Map<String, dynamic> json) {
  return _ZonaPeligro.fromJson(json);
}

/// @nodoc
mixin _$ZonaPeligro {
  String get id => throw _privateConstructorUsedError;
  String? get nombre => throw _privateConstructorUsedError;
  List<List<double>> get polygonCoords =>
      throw _privateConstructorUsedError; // [[lat, lng], [lat, lng], ...]
  @JsonKey(name: 'nivel_riesgo')
  int? get nivelRiesgo => throw _privateConstructorUsedError;
  @JsonKey(name: 'tipo_riesgo')
  String? get tipoRiesgo => throw _privateConstructorUsedError;
  String? get descripcion => throw _privateConstructorUsedError;
  @JsonKey(name: 'horario_critico')
  String? get horarioCritico => throw _privateConstructorUsedError;
  @JsonKey(name: 'vigente_desde')
  DateTime? get vigenteDesde => throw _privateConstructorUsedError;
  @JsonKey(name: 'vigente_hasta')
  DateTime? get vigenteHasta => throw _privateConstructorUsedError;
  @JsonKey(name: 'created_by')
  String? get createdBy => throw _privateConstructorUsedError;
  @JsonKey(name: 'created_at')
  DateTime? get createdAt => throw _privateConstructorUsedError;
  @JsonKey(name: 'updated_at')
  DateTime? get updatedAt => throw _privateConstructorUsedError;

  /// Serializes this ZonaPeligro to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of ZonaPeligro
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $ZonaPeligroCopyWith<ZonaPeligro> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ZonaPeligroCopyWith<$Res> {
  factory $ZonaPeligroCopyWith(
          ZonaPeligro value, $Res Function(ZonaPeligro) then) =
      _$ZonaPeligroCopyWithImpl<$Res, ZonaPeligro>;
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
class _$ZonaPeligroCopyWithImpl<$Res, $Val extends ZonaPeligro>
    implements $ZonaPeligroCopyWith<$Res> {
  _$ZonaPeligroCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

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
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      nombre: freezed == nombre
          ? _value.nombre
          : nombre // ignore: cast_nullable_to_non_nullable
              as String?,
      polygonCoords: null == polygonCoords
          ? _value.polygonCoords
          : polygonCoords // ignore: cast_nullable_to_non_nullable
              as List<List<double>>,
      nivelRiesgo: freezed == nivelRiesgo
          ? _value.nivelRiesgo
          : nivelRiesgo // ignore: cast_nullable_to_non_nullable
              as int?,
      tipoRiesgo: freezed == tipoRiesgo
          ? _value.tipoRiesgo
          : tipoRiesgo // ignore: cast_nullable_to_non_nullable
              as String?,
      descripcion: freezed == descripcion
          ? _value.descripcion
          : descripcion // ignore: cast_nullable_to_non_nullable
              as String?,
      horarioCritico: freezed == horarioCritico
          ? _value.horarioCritico
          : horarioCritico // ignore: cast_nullable_to_non_nullable
              as String?,
      vigenteDesde: freezed == vigenteDesde
          ? _value.vigenteDesde
          : vigenteDesde // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      vigenteHasta: freezed == vigenteHasta
          ? _value.vigenteHasta
          : vigenteHasta // ignore: cast_nullable_to_non_nullable
              as DateTime?,
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
abstract class _$$ZonaPeligroImplCopyWith<$Res>
    implements $ZonaPeligroCopyWith<$Res> {
  factory _$$ZonaPeligroImplCopyWith(
          _$ZonaPeligroImpl value, $Res Function(_$ZonaPeligroImpl) then) =
      __$$ZonaPeligroImplCopyWithImpl<$Res>;
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
class __$$ZonaPeligroImplCopyWithImpl<$Res>
    extends _$ZonaPeligroCopyWithImpl<$Res, _$ZonaPeligroImpl>
    implements _$$ZonaPeligroImplCopyWith<$Res> {
  __$$ZonaPeligroImplCopyWithImpl(
      _$ZonaPeligroImpl _value, $Res Function(_$ZonaPeligroImpl) _then)
      : super(_value, _then);

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
    return _then(_$ZonaPeligroImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      nombre: freezed == nombre
          ? _value.nombre
          : nombre // ignore: cast_nullable_to_non_nullable
              as String?,
      polygonCoords: null == polygonCoords
          ? _value._polygonCoords
          : polygonCoords // ignore: cast_nullable_to_non_nullable
              as List<List<double>>,
      nivelRiesgo: freezed == nivelRiesgo
          ? _value.nivelRiesgo
          : nivelRiesgo // ignore: cast_nullable_to_non_nullable
              as int?,
      tipoRiesgo: freezed == tipoRiesgo
          ? _value.tipoRiesgo
          : tipoRiesgo // ignore: cast_nullable_to_non_nullable
              as String?,
      descripcion: freezed == descripcion
          ? _value.descripcion
          : descripcion // ignore: cast_nullable_to_non_nullable
              as String?,
      horarioCritico: freezed == horarioCritico
          ? _value.horarioCritico
          : horarioCritico // ignore: cast_nullable_to_non_nullable
              as String?,
      vigenteDesde: freezed == vigenteDesde
          ? _value.vigenteDesde
          : vigenteDesde // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      vigenteHasta: freezed == vigenteHasta
          ? _value.vigenteHasta
          : vigenteHasta // ignore: cast_nullable_to_non_nullable
              as DateTime?,
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
class _$ZonaPeligroImpl implements _ZonaPeligro {
  const _$ZonaPeligroImpl(
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

  factory _$ZonaPeligroImpl.fromJson(Map<String, dynamic> json) =>
      _$$ZonaPeligroImplFromJson(json);

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

  @override
  String toString() {
    return 'ZonaPeligro(id: $id, nombre: $nombre, polygonCoords: $polygonCoords, nivelRiesgo: $nivelRiesgo, tipoRiesgo: $tipoRiesgo, descripcion: $descripcion, horarioCritico: $horarioCritico, vigenteDesde: $vigenteDesde, vigenteHasta: $vigenteHasta, createdBy: $createdBy, createdAt: $createdAt, updatedAt: $updatedAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ZonaPeligroImpl &&
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

  /// Create a copy of ZonaPeligro
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ZonaPeligroImplCopyWith<_$ZonaPeligroImpl> get copyWith =>
      __$$ZonaPeligroImplCopyWithImpl<_$ZonaPeligroImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$ZonaPeligroImplToJson(
      this,
    );
  }
}

abstract class _ZonaPeligro implements ZonaPeligro {
  const factory _ZonaPeligro(
          {required final String id,
          final String? nombre,
          required final List<List<double>> polygonCoords,
          @JsonKey(name: 'nivel_riesgo') final int? nivelRiesgo,
          @JsonKey(name: 'tipo_riesgo') final String? tipoRiesgo,
          final String? descripcion,
          @JsonKey(name: 'horario_critico') final String? horarioCritico,
          @JsonKey(name: 'vigente_desde') final DateTime? vigenteDesde,
          @JsonKey(name: 'vigente_hasta') final DateTime? vigenteHasta,
          @JsonKey(name: 'created_by') final String? createdBy,
          @JsonKey(name: 'created_at') final DateTime? createdAt,
          @JsonKey(name: 'updated_at') final DateTime? updatedAt}) =
      _$ZonaPeligroImpl;

  factory _ZonaPeligro.fromJson(Map<String, dynamic> json) =
      _$ZonaPeligroImpl.fromJson;

  @override
  String get id;
  @override
  String? get nombre;
  @override
  List<List<double>> get polygonCoords; // [[lat, lng], [lat, lng], ...]
  @override
  @JsonKey(name: 'nivel_riesgo')
  int? get nivelRiesgo;
  @override
  @JsonKey(name: 'tipo_riesgo')
  String? get tipoRiesgo;
  @override
  String? get descripcion;
  @override
  @JsonKey(name: 'horario_critico')
  String? get horarioCritico;
  @override
  @JsonKey(name: 'vigente_desde')
  DateTime? get vigenteDesde;
  @override
  @JsonKey(name: 'vigente_hasta')
  DateTime? get vigenteHasta;
  @override
  @JsonKey(name: 'created_by')
  String? get createdBy;
  @override
  @JsonKey(name: 'created_at')
  DateTime? get createdAt;
  @override
  @JsonKey(name: 'updated_at')
  DateTime? get updatedAt;

  /// Create a copy of ZonaPeligro
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ZonaPeligroImplCopyWith<_$ZonaPeligroImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
