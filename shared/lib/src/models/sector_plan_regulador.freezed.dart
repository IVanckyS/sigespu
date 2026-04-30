// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'sector_plan_regulador.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

SectorPlanRegulador _$SectorPlanReguladorFromJson(Map<String, dynamic> json) {
  return _SectorPlanRegulador.fromJson(json);
}

/// @nodoc
mixin _$SectorPlanRegulador {
  String get id => throw _privateConstructorUsedError;
  String? get codigo => throw _privateConstructorUsedError;
  String? get nombre => throw _privateConstructorUsedError;
  @JsonKey(name: 'sector_padre')
  String? get sectorPadre => throw _privateConstructorUsedError;
  List<List<double>> get polygonCoords => throw _privateConstructorUsedError;
  @JsonKey(name: 'usos_permitidos')
  Map<String, dynamic>? get usosPermitidos =>
      throw _privateConstructorUsedError;
  @JsonKey(name: 'usos_prohibidos')
  Map<String, dynamic>? get usosProhibidos =>
      throw _privateConstructorUsedError;
  String? get fuente => throw _privateConstructorUsedError;
  bool get vigente => throw _privateConstructorUsedError;
  @JsonKey(name: 'created_at')
  DateTime? get createdAt => throw _privateConstructorUsedError;

  /// Serializes this SectorPlanRegulador to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of SectorPlanRegulador
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $SectorPlanReguladorCopyWith<SectorPlanRegulador> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $SectorPlanReguladorCopyWith<$Res> {
  factory $SectorPlanReguladorCopyWith(
          SectorPlanRegulador value, $Res Function(SectorPlanRegulador) then) =
      _$SectorPlanReguladorCopyWithImpl<$Res, SectorPlanRegulador>;
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
class _$SectorPlanReguladorCopyWithImpl<$Res, $Val extends SectorPlanRegulador>
    implements $SectorPlanReguladorCopyWith<$Res> {
  _$SectorPlanReguladorCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

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
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      codigo: freezed == codigo
          ? _value.codigo
          : codigo // ignore: cast_nullable_to_non_nullable
              as String?,
      nombre: freezed == nombre
          ? _value.nombre
          : nombre // ignore: cast_nullable_to_non_nullable
              as String?,
      sectorPadre: freezed == sectorPadre
          ? _value.sectorPadre
          : sectorPadre // ignore: cast_nullable_to_non_nullable
              as String?,
      polygonCoords: null == polygonCoords
          ? _value.polygonCoords
          : polygonCoords // ignore: cast_nullable_to_non_nullable
              as List<List<double>>,
      usosPermitidos: freezed == usosPermitidos
          ? _value.usosPermitidos
          : usosPermitidos // ignore: cast_nullable_to_non_nullable
              as Map<String, dynamic>?,
      usosProhibidos: freezed == usosProhibidos
          ? _value.usosProhibidos
          : usosProhibidos // ignore: cast_nullable_to_non_nullable
              as Map<String, dynamic>?,
      fuente: freezed == fuente
          ? _value.fuente
          : fuente // ignore: cast_nullable_to_non_nullable
              as String?,
      vigente: null == vigente
          ? _value.vigente
          : vigente // ignore: cast_nullable_to_non_nullable
              as bool,
      createdAt: freezed == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$SectorPlanReguladorImplCopyWith<$Res>
    implements $SectorPlanReguladorCopyWith<$Res> {
  factory _$$SectorPlanReguladorImplCopyWith(_$SectorPlanReguladorImpl value,
          $Res Function(_$SectorPlanReguladorImpl) then) =
      __$$SectorPlanReguladorImplCopyWithImpl<$Res>;
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
class __$$SectorPlanReguladorImplCopyWithImpl<$Res>
    extends _$SectorPlanReguladorCopyWithImpl<$Res, _$SectorPlanReguladorImpl>
    implements _$$SectorPlanReguladorImplCopyWith<$Res> {
  __$$SectorPlanReguladorImplCopyWithImpl(_$SectorPlanReguladorImpl _value,
      $Res Function(_$SectorPlanReguladorImpl) _then)
      : super(_value, _then);

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
    return _then(_$SectorPlanReguladorImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      codigo: freezed == codigo
          ? _value.codigo
          : codigo // ignore: cast_nullable_to_non_nullable
              as String?,
      nombre: freezed == nombre
          ? _value.nombre
          : nombre // ignore: cast_nullable_to_non_nullable
              as String?,
      sectorPadre: freezed == sectorPadre
          ? _value.sectorPadre
          : sectorPadre // ignore: cast_nullable_to_non_nullable
              as String?,
      polygonCoords: null == polygonCoords
          ? _value._polygonCoords
          : polygonCoords // ignore: cast_nullable_to_non_nullable
              as List<List<double>>,
      usosPermitidos: freezed == usosPermitidos
          ? _value._usosPermitidos
          : usosPermitidos // ignore: cast_nullable_to_non_nullable
              as Map<String, dynamic>?,
      usosProhibidos: freezed == usosProhibidos
          ? _value._usosProhibidos
          : usosProhibidos // ignore: cast_nullable_to_non_nullable
              as Map<String, dynamic>?,
      fuente: freezed == fuente
          ? _value.fuente
          : fuente // ignore: cast_nullable_to_non_nullable
              as String?,
      vigente: null == vigente
          ? _value.vigente
          : vigente // ignore: cast_nullable_to_non_nullable
              as bool,
      createdAt: freezed == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$SectorPlanReguladorImpl implements _SectorPlanRegulador {
  const _$SectorPlanReguladorImpl(
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

  factory _$SectorPlanReguladorImpl.fromJson(Map<String, dynamic> json) =>
      _$$SectorPlanReguladorImplFromJson(json);

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

  @override
  String toString() {
    return 'SectorPlanRegulador(id: $id, codigo: $codigo, nombre: $nombre, sectorPadre: $sectorPadre, polygonCoords: $polygonCoords, usosPermitidos: $usosPermitidos, usosProhibidos: $usosProhibidos, fuente: $fuente, vigente: $vigente, createdAt: $createdAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$SectorPlanReguladorImpl &&
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

  /// Create a copy of SectorPlanRegulador
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$SectorPlanReguladorImplCopyWith<_$SectorPlanReguladorImpl> get copyWith =>
      __$$SectorPlanReguladorImplCopyWithImpl<_$SectorPlanReguladorImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$SectorPlanReguladorImplToJson(
      this,
    );
  }
}

abstract class _SectorPlanRegulador implements SectorPlanRegulador {
  const factory _SectorPlanRegulador(
          {required final String id,
          final String? codigo,
          final String? nombre,
          @JsonKey(name: 'sector_padre') final String? sectorPadre,
          required final List<List<double>> polygonCoords,
          @JsonKey(name: 'usos_permitidos')
          final Map<String, dynamic>? usosPermitidos,
          @JsonKey(name: 'usos_prohibidos')
          final Map<String, dynamic>? usosProhibidos,
          final String? fuente,
          final bool vigente,
          @JsonKey(name: 'created_at') final DateTime? createdAt}) =
      _$SectorPlanReguladorImpl;

  factory _SectorPlanRegulador.fromJson(Map<String, dynamic> json) =
      _$SectorPlanReguladorImpl.fromJson;

  @override
  String get id;
  @override
  String? get codigo;
  @override
  String? get nombre;
  @override
  @JsonKey(name: 'sector_padre')
  String? get sectorPadre;
  @override
  List<List<double>> get polygonCoords;
  @override
  @JsonKey(name: 'usos_permitidos')
  Map<String, dynamic>? get usosPermitidos;
  @override
  @JsonKey(name: 'usos_prohibidos')
  Map<String, dynamic>? get usosProhibidos;
  @override
  String? get fuente;
  @override
  bool get vigente;
  @override
  @JsonKey(name: 'created_at')
  DateTime? get createdAt;

  /// Create a copy of SectorPlanRegulador
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$SectorPlanReguladorImplCopyWith<_$SectorPlanReguladorImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
