// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'patente_comercial.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$PatenteComercial {
  String get id;
  @JsonKey(name: 'numero_decreto')
  int? get numeroDecreto;
  @JsonKey(name: 'fecha_decreto')
  DateTime? get fechaDecreto;
  @JsonKey(name: 'fecha_publicacion')
  DateTime? get fechaPublicacion;
  @JsonKey(name: 'tipo_patente')
  String? get tipoPatente;
  String? get rut;
  @JsonKey(name: 'razon_social')
  String? get razonSocial;
  String? get giro;
  @JsonKey(name: 'direccion_raw')
  String? get direccionRaw;
  @JsonKey(name: 'direccion_normalizada')
  String? get direccionNormalizada;
  double get lat;
  double get lng;
  @JsonKey(name: 'geocoding_confianza')
  String? get geocodingConfianza;
  @JsonKey(name: 'estado_inferido')
  String get estadoInferido;
  @JsonKey(name: 'ultima_verificacion_terreno')
  DateTime? get ultimaVerificacionTerreno;
  @JsonKey(name: 'verificado_por')
  String? get verificadoPor;
  String? get observaciones;
  @JsonKey(name: 'url_fuente')
  String? get urlFuente;
  @JsonKey(name: 'scraped_at')
  DateTime? get scrapedAt;
  @JsonKey(name: 'raw_data')
  Map<String, dynamic>? get rawData;
  @JsonKey(name: 'created_at')
  DateTime? get createdAt;
  @JsonKey(name: 'updated_at')
  DateTime? get updatedAt;

  /// Create a copy of PatenteComercial
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $PatenteComercialCopyWith<PatenteComercial> get copyWith =>
      _$PatenteComercialCopyWithImpl<PatenteComercial>(
          this as PatenteComercial, _$identity);

  /// Serializes this PatenteComercial to a JSON map.
  Map<String, dynamic> toJson();

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is PatenteComercial &&
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
            const DeepCollectionEquality().equals(other.rawData, rawData) &&
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
        const DeepCollectionEquality().hash(rawData),
        createdAt,
        updatedAt
      ]);

  @override
  String toString() {
    return 'PatenteComercial(id: $id, numeroDecreto: $numeroDecreto, fechaDecreto: $fechaDecreto, fechaPublicacion: $fechaPublicacion, tipoPatente: $tipoPatente, rut: $rut, razonSocial: $razonSocial, giro: $giro, direccionRaw: $direccionRaw, direccionNormalizada: $direccionNormalizada, lat: $lat, lng: $lng, geocodingConfianza: $geocodingConfianza, estadoInferido: $estadoInferido, ultimaVerificacionTerreno: $ultimaVerificacionTerreno, verificadoPor: $verificadoPor, observaciones: $observaciones, urlFuente: $urlFuente, scrapedAt: $scrapedAt, rawData: $rawData, createdAt: $createdAt, updatedAt: $updatedAt)';
  }
}

/// @nodoc
abstract mixin class $PatenteComercialCopyWith<$Res> {
  factory $PatenteComercialCopyWith(
          PatenteComercial value, $Res Function(PatenteComercial) _then) =
      _$PatenteComercialCopyWithImpl;
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
class _$PatenteComercialCopyWithImpl<$Res>
    implements $PatenteComercialCopyWith<$Res> {
  _$PatenteComercialCopyWithImpl(this._self, this._then);

  final PatenteComercial _self;
  final $Res Function(PatenteComercial) _then;

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
    return _then(_self.copyWith(
      id: null == id
          ? _self.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      numeroDecreto: freezed == numeroDecreto
          ? _self.numeroDecreto
          : numeroDecreto // ignore: cast_nullable_to_non_nullable
              as int?,
      fechaDecreto: freezed == fechaDecreto
          ? _self.fechaDecreto
          : fechaDecreto // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      fechaPublicacion: freezed == fechaPublicacion
          ? _self.fechaPublicacion
          : fechaPublicacion // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      tipoPatente: freezed == tipoPatente
          ? _self.tipoPatente
          : tipoPatente // ignore: cast_nullable_to_non_nullable
              as String?,
      rut: freezed == rut
          ? _self.rut
          : rut // ignore: cast_nullable_to_non_nullable
              as String?,
      razonSocial: freezed == razonSocial
          ? _self.razonSocial
          : razonSocial // ignore: cast_nullable_to_non_nullable
              as String?,
      giro: freezed == giro
          ? _self.giro
          : giro // ignore: cast_nullable_to_non_nullable
              as String?,
      direccionRaw: freezed == direccionRaw
          ? _self.direccionRaw
          : direccionRaw // ignore: cast_nullable_to_non_nullable
              as String?,
      direccionNormalizada: freezed == direccionNormalizada
          ? _self.direccionNormalizada
          : direccionNormalizada // ignore: cast_nullable_to_non_nullable
              as String?,
      lat: null == lat
          ? _self.lat
          : lat // ignore: cast_nullable_to_non_nullable
              as double,
      lng: null == lng
          ? _self.lng
          : lng // ignore: cast_nullable_to_non_nullable
              as double,
      geocodingConfianza: freezed == geocodingConfianza
          ? _self.geocodingConfianza
          : geocodingConfianza // ignore: cast_nullable_to_non_nullable
              as String?,
      estadoInferido: null == estadoInferido
          ? _self.estadoInferido
          : estadoInferido // ignore: cast_nullable_to_non_nullable
              as String,
      ultimaVerificacionTerreno: freezed == ultimaVerificacionTerreno
          ? _self.ultimaVerificacionTerreno
          : ultimaVerificacionTerreno // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      verificadoPor: freezed == verificadoPor
          ? _self.verificadoPor
          : verificadoPor // ignore: cast_nullable_to_non_nullable
              as String?,
      observaciones: freezed == observaciones
          ? _self.observaciones
          : observaciones // ignore: cast_nullable_to_non_nullable
              as String?,
      urlFuente: freezed == urlFuente
          ? _self.urlFuente
          : urlFuente // ignore: cast_nullable_to_non_nullable
              as String?,
      scrapedAt: freezed == scrapedAt
          ? _self.scrapedAt
          : scrapedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      rawData: freezed == rawData
          ? _self.rawData
          : rawData // ignore: cast_nullable_to_non_nullable
              as Map<String, dynamic>?,
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

/// Adds pattern-matching-related methods to [PatenteComercial].
extension PatenteComercialPatterns on PatenteComercial {
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
    TResult Function(_PatenteComercial value)? $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _PatenteComercial() when $default != null:
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
    TResult Function(_PatenteComercial value) $default,
  ) {
    final _that = this;
    switch (_that) {
      case _PatenteComercial():
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
    TResult? Function(_PatenteComercial value)? $default,
  ) {
    final _that = this;
    switch (_that) {
      case _PatenteComercial() when $default != null:
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
            @JsonKey(name: 'numero_decreto') int? numeroDecreto,
            @JsonKey(name: 'fecha_decreto') DateTime? fechaDecreto,
            @JsonKey(name: 'fecha_publicacion') DateTime? fechaPublicacion,
            @JsonKey(name: 'tipo_patente') String? tipoPatente,
            String? rut,
            @JsonKey(name: 'razon_social') String? razonSocial,
            String? giro,
            @JsonKey(name: 'direccion_raw') String? direccionRaw,
            @JsonKey(name: 'direccion_normalizada')
            String? direccionNormalizada,
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
            @JsonKey(name: 'updated_at') DateTime? updatedAt)?
        $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _PatenteComercial() when $default != null:
        return $default(
            _that.id,
            _that.numeroDecreto,
            _that.fechaDecreto,
            _that.fechaPublicacion,
            _that.tipoPatente,
            _that.rut,
            _that.razonSocial,
            _that.giro,
            _that.direccionRaw,
            _that.direccionNormalizada,
            _that.lat,
            _that.lng,
            _that.geocodingConfianza,
            _that.estadoInferido,
            _that.ultimaVerificacionTerreno,
            _that.verificadoPor,
            _that.observaciones,
            _that.urlFuente,
            _that.scrapedAt,
            _that.rawData,
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
            @JsonKey(name: 'numero_decreto') int? numeroDecreto,
            @JsonKey(name: 'fecha_decreto') DateTime? fechaDecreto,
            @JsonKey(name: 'fecha_publicacion') DateTime? fechaPublicacion,
            @JsonKey(name: 'tipo_patente') String? tipoPatente,
            String? rut,
            @JsonKey(name: 'razon_social') String? razonSocial,
            String? giro,
            @JsonKey(name: 'direccion_raw') String? direccionRaw,
            @JsonKey(name: 'direccion_normalizada')
            String? direccionNormalizada,
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
            @JsonKey(name: 'updated_at') DateTime? updatedAt)
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _PatenteComercial():
        return $default(
            _that.id,
            _that.numeroDecreto,
            _that.fechaDecreto,
            _that.fechaPublicacion,
            _that.tipoPatente,
            _that.rut,
            _that.razonSocial,
            _that.giro,
            _that.direccionRaw,
            _that.direccionNormalizada,
            _that.lat,
            _that.lng,
            _that.geocodingConfianza,
            _that.estadoInferido,
            _that.ultimaVerificacionTerreno,
            _that.verificadoPor,
            _that.observaciones,
            _that.urlFuente,
            _that.scrapedAt,
            _that.rawData,
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
            @JsonKey(name: 'numero_decreto') int? numeroDecreto,
            @JsonKey(name: 'fecha_decreto') DateTime? fechaDecreto,
            @JsonKey(name: 'fecha_publicacion') DateTime? fechaPublicacion,
            @JsonKey(name: 'tipo_patente') String? tipoPatente,
            String? rut,
            @JsonKey(name: 'razon_social') String? razonSocial,
            String? giro,
            @JsonKey(name: 'direccion_raw') String? direccionRaw,
            @JsonKey(name: 'direccion_normalizada')
            String? direccionNormalizada,
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
            @JsonKey(name: 'updated_at') DateTime? updatedAt)?
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _PatenteComercial() when $default != null:
        return $default(
            _that.id,
            _that.numeroDecreto,
            _that.fechaDecreto,
            _that.fechaPublicacion,
            _that.tipoPatente,
            _that.rut,
            _that.razonSocial,
            _that.giro,
            _that.direccionRaw,
            _that.direccionNormalizada,
            _that.lat,
            _that.lng,
            _that.geocodingConfianza,
            _that.estadoInferido,
            _that.ultimaVerificacionTerreno,
            _that.verificadoPor,
            _that.observaciones,
            _that.urlFuente,
            _that.scrapedAt,
            _that.rawData,
            _that.createdAt,
            _that.updatedAt);
      case _:
        return null;
    }
  }
}

/// @nodoc
@JsonSerializable()
class _PatenteComercial implements PatenteComercial {
  const _PatenteComercial(
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
  factory _PatenteComercial.fromJson(Map<String, dynamic> json) =>
      _$PatenteComercialFromJson(json);

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

  /// Create a copy of PatenteComercial
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  _$PatenteComercialCopyWith<_PatenteComercial> get copyWith =>
      __$PatenteComercialCopyWithImpl<_PatenteComercial>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$PatenteComercialToJson(
      this,
    );
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _PatenteComercial &&
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

  @override
  String toString() {
    return 'PatenteComercial(id: $id, numeroDecreto: $numeroDecreto, fechaDecreto: $fechaDecreto, fechaPublicacion: $fechaPublicacion, tipoPatente: $tipoPatente, rut: $rut, razonSocial: $razonSocial, giro: $giro, direccionRaw: $direccionRaw, direccionNormalizada: $direccionNormalizada, lat: $lat, lng: $lng, geocodingConfianza: $geocodingConfianza, estadoInferido: $estadoInferido, ultimaVerificacionTerreno: $ultimaVerificacionTerreno, verificadoPor: $verificadoPor, observaciones: $observaciones, urlFuente: $urlFuente, scrapedAt: $scrapedAt, rawData: $rawData, createdAt: $createdAt, updatedAt: $updatedAt)';
  }
}

/// @nodoc
abstract mixin class _$PatenteComercialCopyWith<$Res>
    implements $PatenteComercialCopyWith<$Res> {
  factory _$PatenteComercialCopyWith(
          _PatenteComercial value, $Res Function(_PatenteComercial) _then) =
      __$PatenteComercialCopyWithImpl;
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
class __$PatenteComercialCopyWithImpl<$Res>
    implements _$PatenteComercialCopyWith<$Res> {
  __$PatenteComercialCopyWithImpl(this._self, this._then);

  final _PatenteComercial _self;
  final $Res Function(_PatenteComercial) _then;

  /// Create a copy of PatenteComercial
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
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
    return _then(_PatenteComercial(
      id: null == id
          ? _self.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      numeroDecreto: freezed == numeroDecreto
          ? _self.numeroDecreto
          : numeroDecreto // ignore: cast_nullable_to_non_nullable
              as int?,
      fechaDecreto: freezed == fechaDecreto
          ? _self.fechaDecreto
          : fechaDecreto // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      fechaPublicacion: freezed == fechaPublicacion
          ? _self.fechaPublicacion
          : fechaPublicacion // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      tipoPatente: freezed == tipoPatente
          ? _self.tipoPatente
          : tipoPatente // ignore: cast_nullable_to_non_nullable
              as String?,
      rut: freezed == rut
          ? _self.rut
          : rut // ignore: cast_nullable_to_non_nullable
              as String?,
      razonSocial: freezed == razonSocial
          ? _self.razonSocial
          : razonSocial // ignore: cast_nullable_to_non_nullable
              as String?,
      giro: freezed == giro
          ? _self.giro
          : giro // ignore: cast_nullable_to_non_nullable
              as String?,
      direccionRaw: freezed == direccionRaw
          ? _self.direccionRaw
          : direccionRaw // ignore: cast_nullable_to_non_nullable
              as String?,
      direccionNormalizada: freezed == direccionNormalizada
          ? _self.direccionNormalizada
          : direccionNormalizada // ignore: cast_nullable_to_non_nullable
              as String?,
      lat: null == lat
          ? _self.lat
          : lat // ignore: cast_nullable_to_non_nullable
              as double,
      lng: null == lng
          ? _self.lng
          : lng // ignore: cast_nullable_to_non_nullable
              as double,
      geocodingConfianza: freezed == geocodingConfianza
          ? _self.geocodingConfianza
          : geocodingConfianza // ignore: cast_nullable_to_non_nullable
              as String?,
      estadoInferido: null == estadoInferido
          ? _self.estadoInferido
          : estadoInferido // ignore: cast_nullable_to_non_nullable
              as String,
      ultimaVerificacionTerreno: freezed == ultimaVerificacionTerreno
          ? _self.ultimaVerificacionTerreno
          : ultimaVerificacionTerreno // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      verificadoPor: freezed == verificadoPor
          ? _self.verificadoPor
          : verificadoPor // ignore: cast_nullable_to_non_nullable
              as String?,
      observaciones: freezed == observaciones
          ? _self.observaciones
          : observaciones // ignore: cast_nullable_to_non_nullable
              as String?,
      urlFuente: freezed == urlFuente
          ? _self.urlFuente
          : urlFuente // ignore: cast_nullable_to_non_nullable
              as String?,
      scrapedAt: freezed == scrapedAt
          ? _self.scrapedAt
          : scrapedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      rawData: freezed == rawData
          ? _self._rawData
          : rawData // ignore: cast_nullable_to_non_nullable
              as Map<String, dynamic>?,
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
