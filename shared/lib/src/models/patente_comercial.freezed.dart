// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'patente_comercial.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

PatenteComercial _$PatenteComercialFromJson(Map<String, dynamic> json) {
  return _PatenteComercial.fromJson(json);
}

/// @nodoc
mixin _$PatenteComercial {
  String get id => throw _privateConstructorUsedError;
  @JsonKey(name: 'numero_decreto')
  int? get numeroDecreto => throw _privateConstructorUsedError;
  @JsonKey(name: 'fecha_decreto')
  DateTime? get fechaDecreto => throw _privateConstructorUsedError;
  @JsonKey(name: 'fecha_publicacion')
  DateTime? get fechaPublicacion => throw _privateConstructorUsedError;
  @JsonKey(name: 'tipo_patente')
  String? get tipoPatente => throw _privateConstructorUsedError;
  String? get rut => throw _privateConstructorUsedError;
  @JsonKey(name: 'razon_social')
  String? get razonSocial => throw _privateConstructorUsedError;
  String? get giro => throw _privateConstructorUsedError;
  @JsonKey(name: 'direccion_raw')
  String? get direccionRaw => throw _privateConstructorUsedError;
  @JsonKey(name: 'direccion_normalizada')
  String? get direccionNormalizada => throw _privateConstructorUsedError;
  double get lat => throw _privateConstructorUsedError;
  double get lng => throw _privateConstructorUsedError;
  @JsonKey(name: 'geocoding_confianza')
  String? get geocodingConfianza => throw _privateConstructorUsedError;
  @JsonKey(name: 'estado_inferido')
  String get estadoInferido => throw _privateConstructorUsedError;
  @JsonKey(name: 'ultima_verificacion_terreno')
  DateTime? get ultimaVerificacionTerreno => throw _privateConstructorUsedError;
  @JsonKey(name: 'verificado_por')
  String? get verificadoPor => throw _privateConstructorUsedError;
  String? get observaciones => throw _privateConstructorUsedError;
  @JsonKey(name: 'url_fuente')
  String? get urlFuente => throw _privateConstructorUsedError;
  @JsonKey(name: 'scraped_at')
  DateTime? get scrapedAt => throw _privateConstructorUsedError;
  @JsonKey(name: 'raw_data')
  Map<String, dynamic>? get rawData => throw _privateConstructorUsedError;
  @JsonKey(name: 'created_at')
  DateTime? get createdAt => throw _privateConstructorUsedError;
  @JsonKey(name: 'updated_at')
  DateTime? get updatedAt => throw _privateConstructorUsedError;

  /// Serializes this PatenteComercial to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of PatenteComercial
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $PatenteComercialCopyWith<PatenteComercial> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $PatenteComercialCopyWith<$Res> {
  factory $PatenteComercialCopyWith(
          PatenteComercial value, $Res Function(PatenteComercial) then) =
      _$PatenteComercialCopyWithImpl<$Res, PatenteComercial>;
  @useResult
  $Res call(
      {String id,
      @JsonKey(name: 'numero_decreto') int? numeroDecreto,
      @JsonKey(name: 'fecha_decreto') DateTime? fechaDecreto,
      @JsonKey(name: 'fecha_publicacion') DateTime? fechaPublicacion,
      @JsonKey(name: 'tipo_patente') String? tipoPatente,
      String? rut,
      @JsonKey(name: 'razon_social') String? razonSocial,
      String? giro,
      @JsonKey(name: 'direccion_raw') String? direccionRaw,
      @JsonKey(name: 'direccion_normalizada') String? direccionNormalizada,
      double lat,
      double lng,
      @JsonKey(name: 'geocoding_confianza') String? geocodingConfianza,
      @JsonKey(name: 'estado_inferido') String estadoInferido,
      @JsonKey(name: 'ultima_verificacion_terreno')
      DateTime? ultimaVerificacionTerreno,
      @JsonKey(name: 'verificado_por') String? verificadoPor,
      String? observaciones,
      @JsonKey(name: 'url_fuente') String? urlFuente,
      @JsonKey(name: 'scraped_at') DateTime? scrapedAt,
      @JsonKey(name: 'raw_data') Map<String, dynamic>? rawData,
      @JsonKey(name: 'created_at') DateTime? createdAt,
      @JsonKey(name: 'updated_at') DateTime? updatedAt});
}

/// @nodoc
class _$PatenteComercialCopyWithImpl<$Res, $Val extends PatenteComercial>
    implements $PatenteComercialCopyWith<$Res> {
  _$PatenteComercialCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of PatenteComercial
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? numeroDecreto = freezed,
    Object? fechaDecreto = freezed,
    Object? fechaPublicacion = freezed,
    Object? tipoPatente = freezed,
    Object? rut = freezed,
    Object? razonSocial = freezed,
    Object? giro = freezed,
    Object? direccionRaw = freezed,
    Object? direccionNormalizada = freezed,
    Object? lat = null,
    Object? lng = null,
    Object? geocodingConfianza = freezed,
    Object? estadoInferido = null,
    Object? ultimaVerificacionTerreno = freezed,
    Object? verificadoPor = freezed,
    Object? observaciones = freezed,
    Object? urlFuente = freezed,
    Object? scrapedAt = freezed,
    Object? rawData = freezed,
    Object? createdAt = freezed,
    Object? updatedAt = freezed,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      numeroDecreto: freezed == numeroDecreto
          ? _value.numeroDecreto
          : numeroDecreto // ignore: cast_nullable_to_non_nullable
              as int?,
      fechaDecreto: freezed == fechaDecreto
          ? _value.fechaDecreto
          : fechaDecreto // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      fechaPublicacion: freezed == fechaPublicacion
          ? _value.fechaPublicacion
          : fechaPublicacion // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      tipoPatente: freezed == tipoPatente
          ? _value.tipoPatente
          : tipoPatente // ignore: cast_nullable_to_non_nullable
              as String?,
      rut: freezed == rut
          ? _value.rut
          : rut // ignore: cast_nullable_to_non_nullable
              as String?,
      razonSocial: freezed == razonSocial
          ? _value.razonSocial
          : razonSocial // ignore: cast_nullable_to_non_nullable
              as String?,
      giro: freezed == giro
          ? _value.giro
          : giro // ignore: cast_nullable_to_non_nullable
              as String?,
      direccionRaw: freezed == direccionRaw
          ? _value.direccionRaw
          : direccionRaw // ignore: cast_nullable_to_non_nullable
              as String?,
      direccionNormalizada: freezed == direccionNormalizada
          ? _value.direccionNormalizada
          : direccionNormalizada // ignore: cast_nullable_to_non_nullable
              as String?,
      lat: null == lat
          ? _value.lat
          : lat // ignore: cast_nullable_to_non_nullable
              as double,
      lng: null == lng
          ? _value.lng
          : lng // ignore: cast_nullable_to_non_nullable
              as double,
      geocodingConfianza: freezed == geocodingConfianza
          ? _value.geocodingConfianza
          : geocodingConfianza // ignore: cast_nullable_to_non_nullable
              as String?,
      estadoInferido: null == estadoInferido
          ? _value.estadoInferido
          : estadoInferido // ignore: cast_nullable_to_non_nullable
              as String,
      ultimaVerificacionTerreno: freezed == ultimaVerificacionTerreno
          ? _value.ultimaVerificacionTerreno
          : ultimaVerificacionTerreno // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      verificadoPor: freezed == verificadoPor
          ? _value.verificadoPor
          : verificadoPor // ignore: cast_nullable_to_non_nullable
              as String?,
      observaciones: freezed == observaciones
          ? _value.observaciones
          : observaciones // ignore: cast_nullable_to_non_nullable
              as String?,
      urlFuente: freezed == urlFuente
          ? _value.urlFuente
          : urlFuente // ignore: cast_nullable_to_non_nullable
              as String?,
      scrapedAt: freezed == scrapedAt
          ? _value.scrapedAt
          : scrapedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      rawData: freezed == rawData
          ? _value.rawData
          : rawData // ignore: cast_nullable_to_non_nullable
              as Map<String, dynamic>?,
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
abstract class _$$PatenteComercialImplCopyWith<$Res>
    implements $PatenteComercialCopyWith<$Res> {
  factory _$$PatenteComercialImplCopyWith(_$PatenteComercialImpl value,
          $Res Function(_$PatenteComercialImpl) then) =
      __$$PatenteComercialImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      @JsonKey(name: 'numero_decreto') int? numeroDecreto,
      @JsonKey(name: 'fecha_decreto') DateTime? fechaDecreto,
      @JsonKey(name: 'fecha_publicacion') DateTime? fechaPublicacion,
      @JsonKey(name: 'tipo_patente') String? tipoPatente,
      String? rut,
      @JsonKey(name: 'razon_social') String? razonSocial,
      String? giro,
      @JsonKey(name: 'direccion_raw') String? direccionRaw,
      @JsonKey(name: 'direccion_normalizada') String? direccionNormalizada,
      double lat,
      double lng,
      @JsonKey(name: 'geocoding_confianza') String? geocodingConfianza,
      @JsonKey(name: 'estado_inferido') String estadoInferido,
      @JsonKey(name: 'ultima_verificacion_terreno')
      DateTime? ultimaVerificacionTerreno,
      @JsonKey(name: 'verificado_por') String? verificadoPor,
      String? observaciones,
      @JsonKey(name: 'url_fuente') String? urlFuente,
      @JsonKey(name: 'scraped_at') DateTime? scrapedAt,
      @JsonKey(name: 'raw_data') Map<String, dynamic>? rawData,
      @JsonKey(name: 'created_at') DateTime? createdAt,
      @JsonKey(name: 'updated_at') DateTime? updatedAt});
}

/// @nodoc
class __$$PatenteComercialImplCopyWithImpl<$Res>
    extends _$PatenteComercialCopyWithImpl<$Res, _$PatenteComercialImpl>
    implements _$$PatenteComercialImplCopyWith<$Res> {
  __$$PatenteComercialImplCopyWithImpl(_$PatenteComercialImpl _value,
      $Res Function(_$PatenteComercialImpl) _then)
      : super(_value, _then);

  /// Create a copy of PatenteComercial
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? numeroDecreto = freezed,
    Object? fechaDecreto = freezed,
    Object? fechaPublicacion = freezed,
    Object? tipoPatente = freezed,
    Object? rut = freezed,
    Object? razonSocial = freezed,
    Object? giro = freezed,
    Object? direccionRaw = freezed,
    Object? direccionNormalizada = freezed,
    Object? lat = null,
    Object? lng = null,
    Object? geocodingConfianza = freezed,
    Object? estadoInferido = null,
    Object? ultimaVerificacionTerreno = freezed,
    Object? verificadoPor = freezed,
    Object? observaciones = freezed,
    Object? urlFuente = freezed,
    Object? scrapedAt = freezed,
    Object? rawData = freezed,
    Object? createdAt = freezed,
    Object? updatedAt = freezed,
  }) {
    return _then(_$PatenteComercialImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      numeroDecreto: freezed == numeroDecreto
          ? _value.numeroDecreto
          : numeroDecreto // ignore: cast_nullable_to_non_nullable
              as int?,
      fechaDecreto: freezed == fechaDecreto
          ? _value.fechaDecreto
          : fechaDecreto // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      fechaPublicacion: freezed == fechaPublicacion
          ? _value.fechaPublicacion
          : fechaPublicacion // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      tipoPatente: freezed == tipoPatente
          ? _value.tipoPatente
          : tipoPatente // ignore: cast_nullable_to_non_nullable
              as String?,
      rut: freezed == rut
          ? _value.rut
          : rut // ignore: cast_nullable_to_non_nullable
              as String?,
      razonSocial: freezed == razonSocial
          ? _value.razonSocial
          : razonSocial // ignore: cast_nullable_to_non_nullable
              as String?,
      giro: freezed == giro
          ? _value.giro
          : giro // ignore: cast_nullable_to_non_nullable
              as String?,
      direccionRaw: freezed == direccionRaw
          ? _value.direccionRaw
          : direccionRaw // ignore: cast_nullable_to_non_nullable
              as String?,
      direccionNormalizada: freezed == direccionNormalizada
          ? _value.direccionNormalizada
          : direccionNormalizada // ignore: cast_nullable_to_non_nullable
              as String?,
      lat: null == lat
          ? _value.lat
          : lat // ignore: cast_nullable_to_non_nullable
              as double,
      lng: null == lng
          ? _value.lng
          : lng // ignore: cast_nullable_to_non_nullable
              as double,
      geocodingConfianza: freezed == geocodingConfianza
          ? _value.geocodingConfianza
          : geocodingConfianza // ignore: cast_nullable_to_non_nullable
              as String?,
      estadoInferido: null == estadoInferido
          ? _value.estadoInferido
          : estadoInferido // ignore: cast_nullable_to_non_nullable
              as String,
      ultimaVerificacionTerreno: freezed == ultimaVerificacionTerreno
          ? _value.ultimaVerificacionTerreno
          : ultimaVerificacionTerreno // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      verificadoPor: freezed == verificadoPor
          ? _value.verificadoPor
          : verificadoPor // ignore: cast_nullable_to_non_nullable
              as String?,
      observaciones: freezed == observaciones
          ? _value.observaciones
          : observaciones // ignore: cast_nullable_to_non_nullable
              as String?,
      urlFuente: freezed == urlFuente
          ? _value.urlFuente
          : urlFuente // ignore: cast_nullable_to_non_nullable
              as String?,
      scrapedAt: freezed == scrapedAt
          ? _value.scrapedAt
          : scrapedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      rawData: freezed == rawData
          ? _value._rawData
          : rawData // ignore: cast_nullable_to_non_nullable
              as Map<String, dynamic>?,
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
class _$PatenteComercialImpl implements _PatenteComercial {
  const _$PatenteComercialImpl(
      {required this.id,
      @JsonKey(name: 'numero_decreto') this.numeroDecreto,
      @JsonKey(name: 'fecha_decreto') this.fechaDecreto,
      @JsonKey(name: 'fecha_publicacion') this.fechaPublicacion,
      @JsonKey(name: 'tipo_patente') this.tipoPatente,
      this.rut,
      @JsonKey(name: 'razon_social') this.razonSocial,
      this.giro,
      @JsonKey(name: 'direccion_raw') this.direccionRaw,
      @JsonKey(name: 'direccion_normalizada') this.direccionNormalizada,
      required this.lat,
      required this.lng,
      @JsonKey(name: 'geocoding_confianza') this.geocodingConfianza,
      @JsonKey(name: 'estado_inferido')
      this.estadoInferido = 'vigente_esperado',
      @JsonKey(name: 'ultima_verificacion_terreno')
      this.ultimaVerificacionTerreno,
      @JsonKey(name: 'verificado_por') this.verificadoPor,
      this.observaciones,
      @JsonKey(name: 'url_fuente') this.urlFuente,
      @JsonKey(name: 'scraped_at') this.scrapedAt,
      @JsonKey(name: 'raw_data') final Map<String, dynamic>? rawData,
      @JsonKey(name: 'created_at') this.createdAt,
      @JsonKey(name: 'updated_at') this.updatedAt})
      : _rawData = rawData;

  factory _$PatenteComercialImpl.fromJson(Map<String, dynamic> json) =>
      _$$PatenteComercialImplFromJson(json);

  @override
  final String id;
  @override
  @JsonKey(name: 'numero_decreto')
  final int? numeroDecreto;
  @override
  @JsonKey(name: 'fecha_decreto')
  final DateTime? fechaDecreto;
  @override
  @JsonKey(name: 'fecha_publicacion')
  final DateTime? fechaPublicacion;
  @override
  @JsonKey(name: 'tipo_patente')
  final String? tipoPatente;
  @override
  final String? rut;
  @override
  @JsonKey(name: 'razon_social')
  final String? razonSocial;
  @override
  final String? giro;
  @override
  @JsonKey(name: 'direccion_raw')
  final String? direccionRaw;
  @override
  @JsonKey(name: 'direccion_normalizada')
  final String? direccionNormalizada;
  @override
  final double lat;
  @override
  final double lng;
  @override
  @JsonKey(name: 'geocoding_confianza')
  final String? geocodingConfianza;
  @override
  @JsonKey(name: 'estado_inferido')
  final String estadoInferido;
  @override
  @JsonKey(name: 'ultima_verificacion_terreno')
  final DateTime? ultimaVerificacionTerreno;
  @override
  @JsonKey(name: 'verificado_por')
  final String? verificadoPor;
  @override
  final String? observaciones;
  @override
  @JsonKey(name: 'url_fuente')
  final String? urlFuente;
  @override
  @JsonKey(name: 'scraped_at')
  final DateTime? scrapedAt;
  final Map<String, dynamic>? _rawData;
  @override
  @JsonKey(name: 'raw_data')
  Map<String, dynamic>? get rawData {
    final value = _rawData;
    if (value == null) return null;
    if (_rawData is EqualUnmodifiableMapView) return _rawData;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(value);
  }

  @override
  @JsonKey(name: 'created_at')
  final DateTime? createdAt;
  @override
  @JsonKey(name: 'updated_at')
  final DateTime? updatedAt;

  @override
  String toString() {
    return 'PatenteComercial(id: $id, numeroDecreto: $numeroDecreto, fechaDecreto: $fechaDecreto, fechaPublicacion: $fechaPublicacion, tipoPatente: $tipoPatente, rut: $rut, razonSocial: $razonSocial, giro: $giro, direccionRaw: $direccionRaw, direccionNormalizada: $direccionNormalizada, lat: $lat, lng: $lng, geocodingConfianza: $geocodingConfianza, estadoInferido: $estadoInferido, ultimaVerificacionTerreno: $ultimaVerificacionTerreno, verificadoPor: $verificadoPor, observaciones: $observaciones, urlFuente: $urlFuente, scrapedAt: $scrapedAt, rawData: $rawData, createdAt: $createdAt, updatedAt: $updatedAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$PatenteComercialImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.numeroDecreto, numeroDecreto) ||
                other.numeroDecreto == numeroDecreto) &&
            (identical(other.fechaDecreto, fechaDecreto) ||
                other.fechaDecreto == fechaDecreto) &&
            (identical(other.fechaPublicacion, fechaPublicacion) ||
                other.fechaPublicacion == fechaPublicacion) &&
            (identical(other.tipoPatente, tipoPatente) ||
                other.tipoPatente == tipoPatente) &&
            (identical(other.rut, rut) || other.rut == rut) &&
            (identical(other.razonSocial, razonSocial) ||
                other.razonSocial == razonSocial) &&
            (identical(other.giro, giro) || other.giro == giro) &&
            (identical(other.direccionRaw, direccionRaw) ||
                other.direccionRaw == direccionRaw) &&
            (identical(other.direccionNormalizada, direccionNormalizada) ||
                other.direccionNormalizada == direccionNormalizada) &&
            (identical(other.lat, lat) || other.lat == lat) &&
            (identical(other.lng, lng) || other.lng == lng) &&
            (identical(other.geocodingConfianza, geocodingConfianza) ||
                other.geocodingConfianza == geocodingConfianza) &&
            (identical(other.estadoInferido, estadoInferido) ||
                other.estadoInferido == estadoInferido) &&
            (identical(other.ultimaVerificacionTerreno,
                    ultimaVerificacionTerreno) ||
                other.ultimaVerificacionTerreno == ultimaVerificacionTerreno) &&
            (identical(other.verificadoPor, verificadoPor) ||
                other.verificadoPor == verificadoPor) &&
            (identical(other.observaciones, observaciones) ||
                other.observaciones == observaciones) &&
            (identical(other.urlFuente, urlFuente) ||
                other.urlFuente == urlFuente) &&
            (identical(other.scrapedAt, scrapedAt) ||
                other.scrapedAt == scrapedAt) &&
            const DeepCollectionEquality().equals(other._rawData, _rawData) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.updatedAt, updatedAt) ||
                other.updatedAt == updatedAt));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hashAll([
        runtimeType,
        id,
        numeroDecreto,
        fechaDecreto,
        fechaPublicacion,
        tipoPatente,
        rut,
        razonSocial,
        giro,
        direccionRaw,
        direccionNormalizada,
        lat,
        lng,
        geocodingConfianza,
        estadoInferido,
        ultimaVerificacionTerreno,
        verificadoPor,
        observaciones,
        urlFuente,
        scrapedAt,
        const DeepCollectionEquality().hash(_rawData),
        createdAt,
        updatedAt
      ]);

  /// Create a copy of PatenteComercial
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$PatenteComercialImplCopyWith<_$PatenteComercialImpl> get copyWith =>
      __$$PatenteComercialImplCopyWithImpl<_$PatenteComercialImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$PatenteComercialImplToJson(
      this,
    );
  }
}

abstract class _PatenteComercial implements PatenteComercial {
  const factory _PatenteComercial(
      {required final String id,
      @JsonKey(name: 'numero_decreto') final int? numeroDecreto,
      @JsonKey(name: 'fecha_decreto') final DateTime? fechaDecreto,
      @JsonKey(name: 'fecha_publicacion') final DateTime? fechaPublicacion,
      @JsonKey(name: 'tipo_patente') final String? tipoPatente,
      final String? rut,
      @JsonKey(name: 'razon_social') final String? razonSocial,
      final String? giro,
      @JsonKey(name: 'direccion_raw') final String? direccionRaw,
      @JsonKey(name: 'direccion_normalizada')
      final String? direccionNormalizada,
      required final double lat,
      required final double lng,
      @JsonKey(name: 'geocoding_confianza') final String? geocodingConfianza,
      @JsonKey(name: 'estado_inferido') final String estadoInferido,
      @JsonKey(name: 'ultima_verificacion_terreno')
      final DateTime? ultimaVerificacionTerreno,
      @JsonKey(name: 'verificado_por') final String? verificadoPor,
      final String? observaciones,
      @JsonKey(name: 'url_fuente') final String? urlFuente,
      @JsonKey(name: 'scraped_at') final DateTime? scrapedAt,
      @JsonKey(name: 'raw_data') final Map<String, dynamic>? rawData,
      @JsonKey(name: 'created_at') final DateTime? createdAt,
      @JsonKey(name: 'updated_at')
      final DateTime? updatedAt}) = _$PatenteComercialImpl;

  factory _PatenteComercial.fromJson(Map<String, dynamic> json) =
      _$PatenteComercialImpl.fromJson;

  @override
  String get id;
  @override
  @JsonKey(name: 'numero_decreto')
  int? get numeroDecreto;
  @override
  @JsonKey(name: 'fecha_decreto')
  DateTime? get fechaDecreto;
  @override
  @JsonKey(name: 'fecha_publicacion')
  DateTime? get fechaPublicacion;
  @override
  @JsonKey(name: 'tipo_patente')
  String? get tipoPatente;
  @override
  String? get rut;
  @override
  @JsonKey(name: 'razon_social')
  String? get razonSocial;
  @override
  String? get giro;
  @override
  @JsonKey(name: 'direccion_raw')
  String? get direccionRaw;
  @override
  @JsonKey(name: 'direccion_normalizada')
  String? get direccionNormalizada;
  @override
  double get lat;
  @override
  double get lng;
  @override
  @JsonKey(name: 'geocoding_confianza')
  String? get geocodingConfianza;
  @override
  @JsonKey(name: 'estado_inferido')
  String get estadoInferido;
  @override
  @JsonKey(name: 'ultima_verificacion_terreno')
  DateTime? get ultimaVerificacionTerreno;
  @override
  @JsonKey(name: 'verificado_por')
  String? get verificadoPor;
  @override
  String? get observaciones;
  @override
  @JsonKey(name: 'url_fuente')
  String? get urlFuente;
  @override
  @JsonKey(name: 'scraped_at')
  DateTime? get scrapedAt;
  @override
  @JsonKey(name: 'raw_data')
  Map<String, dynamic>? get rawData;
  @override
  @JsonKey(name: 'created_at')
  DateTime? get createdAt;
  @override
  @JsonKey(name: 'updated_at')
  DateTime? get updatedAt;

  /// Create a copy of PatenteComercial
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$PatenteComercialImplCopyWith<_$PatenteComercialImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
