// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'patente_comercial.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_PatenteComercial _$PatenteComercialFromJson(Map<String, dynamic> json) =>
    _PatenteComercial(
      id: json['id'] as String,
      numeroDecreto: (json['numero_decreto'] as num?)?.toInt(),
      fechaDecreto: json['fecha_decreto'] == null
          ? null
          : DateTime.parse(json['fecha_decreto'] as String),
      fechaPublicacion: json['fecha_publicacion'] == null
          ? null
          : DateTime.parse(json['fecha_publicacion'] as String),
      tipoPatente: json['tipo_patente'] as String?,
      rut: json['rut'] as String?,
      razonSocial: json['razon_social'] as String?,
      giro: json['giro'] as String?,
      direccionRaw: json['direccion_raw'] as String?,
      direccionNormalizada: json['direccion_normalizada'] as String?,
      lat: (json['lat'] as num).toDouble(),
      lng: (json['lng'] as num).toDouble(),
      geocodingConfianza: json['geocoding_confianza'] as String?,
      estadoInferido: json['estado_inferido'] as String? ?? 'vigente_esperado',
      ultimaVerificacionTerreno: json['ultima_verificacion_terreno'] == null
          ? null
          : DateTime.parse(json['ultima_verificacion_terreno'] as String),
      verificadoPor: json['verificado_por'] as String?,
      observaciones: json['observaciones'] as String?,
      urlFuente: json['url_fuente'] as String?,
      scrapedAt: json['scraped_at'] == null
          ? null
          : DateTime.parse(json['scraped_at'] as String),
      rawData: json['raw_data'] as Map<String, dynamic>?,
      createdAt: json['created_at'] == null
          ? null
          : DateTime.parse(json['created_at'] as String),
      updatedAt: json['updated_at'] == null
          ? null
          : DateTime.parse(json['updated_at'] as String),
    );

Map<String, dynamic> _$PatenteComercialToJson(_PatenteComercial instance) =>
    <String, dynamic>{
      'id': instance.id,
      'numero_decreto': instance.numeroDecreto,
      'fecha_decreto': instance.fechaDecreto?.toIso8601String(),
      'fecha_publicacion': instance.fechaPublicacion?.toIso8601String(),
      'tipo_patente': instance.tipoPatente,
      'rut': instance.rut,
      'razon_social': instance.razonSocial,
      'giro': instance.giro,
      'direccion_raw': instance.direccionRaw,
      'direccion_normalizada': instance.direccionNormalizada,
      'lat': instance.lat,
      'lng': instance.lng,
      'geocoding_confianza': instance.geocodingConfianza,
      'estado_inferido': instance.estadoInferido,
      'ultima_verificacion_terreno':
          instance.ultimaVerificacionTerreno?.toIso8601String(),
      'verificado_por': instance.verificadoPor,
      'observaciones': instance.observaciones,
      'url_fuente': instance.urlFuente,
      'scraped_at': instance.scrapedAt?.toIso8601String(),
      'raw_data': instance.rawData,
      'created_at': instance.createdAt?.toIso8601String(),
      'updated_at': instance.updatedAt?.toIso8601String(),
    };
