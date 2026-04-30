// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'reporte_seguridad.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$ReporteSeguridadImpl _$$ReporteSeguridadImplFromJson(
        Map<String, dynamic> json) =>
    _$ReporteSeguridadImpl(
      id: json['id'] as String,
      tipo: json['tipo'] as String,
      lat: (json['lat'] as num).toDouble(),
      lng: (json['lng'] as num).toDouble(),
      direccion: json['direccion'] as String?,
      descripcion: json['descripcion'] as String?,
      severidad: (json['severidad'] as num?)?.toInt(),
      fechaEvento: json['fecha_evento'] == null
          ? null
          : DateTime.parse(json['fecha_evento'] as String),
      fotos:
          (json['fotos'] as List<dynamic>?)?.map((e) => e as String).toList() ??
              const [],
      estado: json['estado'] as String? ?? 'reportado',
      derivadoA: json['derivado_a'] as String?,
      reportadoPor: json['reportado_por'] as String?,
      verificadoPor: json['verificado_por'] as String?,
      createdAt: json['created_at'] == null
          ? null
          : DateTime.parse(json['created_at'] as String),
      updatedAt: json['updated_at'] == null
          ? null
          : DateTime.parse(json['updated_at'] as String),
    );

Map<String, dynamic> _$$ReporteSeguridadImplToJson(
        _$ReporteSeguridadImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'tipo': instance.tipo,
      'lat': instance.lat,
      'lng': instance.lng,
      'direccion': instance.direccion,
      'descripcion': instance.descripcion,
      'severidad': instance.severidad,
      'fecha_evento': instance.fechaEvento?.toIso8601String(),
      'fotos': instance.fotos,
      'estado': instance.estado,
      'derivado_a': instance.derivadoA,
      'reportado_por': instance.reportadoPor,
      'verificado_por': instance.verificadoPor,
      'created_at': instance.createdAt?.toIso8601String(),
      'updated_at': instance.updatedAt?.toIso8601String(),
    };
