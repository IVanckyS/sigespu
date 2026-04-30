// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'zona_peligro.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$ZonaPeligroImpl _$$ZonaPeligroImplFromJson(Map<String, dynamic> json) =>
    _$ZonaPeligroImpl(
      id: json['id'] as String,
      nombre: json['nombre'] as String?,
      polygonCoords: (json['polygonCoords'] as List<dynamic>)
          .map((e) =>
              (e as List<dynamic>).map((e) => (e as num).toDouble()).toList())
          .toList(),
      nivelRiesgo: (json['nivel_riesgo'] as num?)?.toInt(),
      tipoRiesgo: json['tipo_riesgo'] as String?,
      descripcion: json['descripcion'] as String?,
      horarioCritico: json['horario_critico'] as String?,
      vigenteDesde: json['vigente_desde'] == null
          ? null
          : DateTime.parse(json['vigente_desde'] as String),
      vigenteHasta: json['vigente_hasta'] == null
          ? null
          : DateTime.parse(json['vigente_hasta'] as String),
      createdBy: json['created_by'] as String?,
      createdAt: json['created_at'] == null
          ? null
          : DateTime.parse(json['created_at'] as String),
      updatedAt: json['updated_at'] == null
          ? null
          : DateTime.parse(json['updated_at'] as String),
    );

Map<String, dynamic> _$$ZonaPeligroImplToJson(_$ZonaPeligroImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'nombre': instance.nombre,
      'polygonCoords': instance.polygonCoords,
      'nivel_riesgo': instance.nivelRiesgo,
      'tipo_riesgo': instance.tipoRiesgo,
      'descripcion': instance.descripcion,
      'horario_critico': instance.horarioCritico,
      'vigente_desde': instance.vigenteDesde?.toIso8601String(),
      'vigente_hasta': instance.vigenteHasta?.toIso8601String(),
      'created_by': instance.createdBy,
      'created_at': instance.createdAt?.toIso8601String(),
      'updated_at': instance.updatedAt?.toIso8601String(),
    };
