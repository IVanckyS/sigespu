import 'package:freezed_annotation/freezed_annotation.dart';

part 'patente_comercial.freezed.dart';
part 'patente_comercial.g.dart';

@freezed
abstract class PatenteComercial with _$PatenteComercial {
  const factory PatenteComercial({
    required String id,
    @JsonKey(name: 'numero_decreto') int? numeroDecreto,
    @JsonKey(name: 'fecha_decreto') DateTime? fechaDecreto,
    @JsonKey(name: 'fecha_publicacion') DateTime? fechaPublicacion,
    @JsonKey(name: 'tipo_patente') String? tipoPatente,
    String? rut,
    @JsonKey(name: 'razon_social') String? razonSocial,
    String? giro,
    @JsonKey(name: 'direccion_raw') String? direccionRaw,
    @JsonKey(name: 'direccion_normalizada') String? direccionNormalizada,
    required double lat,
    required double lng,
    @JsonKey(name: 'geocoding_confianza') String? geocodingConfianza,
    @JsonKey(name: 'estado_inferido') @Default('vigente_esperado') String estadoInferido,
    @JsonKey(name: 'ultima_verificacion_terreno') DateTime? ultimaVerificacionTerreno,
    @JsonKey(name: 'verificado_por') String? verificadoPor,
    String? observaciones,
    @JsonKey(name: 'url_fuente') String? urlFuente,
    @JsonKey(name: 'scraped_at') DateTime? scrapedAt,
    @JsonKey(name: 'raw_data') Map<String, dynamic>? rawData,
    @JsonKey(name: 'created_at') DateTime? createdAt,
    @JsonKey(name: 'updated_at') DateTime? updatedAt,
  }) = _PatenteComercial;

  factory PatenteComercial.fromJson(Map<String, dynamic> json) => _$PatenteComercialFromJson(json);
}
