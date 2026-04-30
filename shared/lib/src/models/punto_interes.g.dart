// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'punto_interes.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$PuntoInteresImpl _$$PuntoInteresImplFromJson(Map<String, dynamic> json) =>
    _$PuntoInteresImpl(
      id: json['id'] as String,
      tipo: json['tipo'] as String,
      nombre: json['nombre'] as String?,
      descripcion: json['descripcion'] as String?,
      direccion: json['direccion'] as String?,
      lat: (json['lat'] as num).toDouble(),
      lng: (json['lng'] as num).toDouble(),
      metadata: json['metadata'] as Map<String, dynamic>?,
      estado: json['estado'] as String? ?? 'activo',
      origen: json['origen'] as String? ?? 'manual',
      fuenteOrigen: json['fuente_origen'] as String?,
      createdBy: json['created_by'] as String?,
      createdAt: json['created_at'] == null
          ? null
          : DateTime.parse(json['created_at'] as String),
      updatedAt: json['updated_at'] == null
          ? null
          : DateTime.parse(json['updated_at'] as String),
    );

Map<String, dynamic> _$$PuntoInteresImplToJson(_$PuntoInteresImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'tipo': instance.tipo,
      'nombre': instance.nombre,
      'descripcion': instance.descripcion,
      'direccion': instance.direccion,
      'lat': instance.lat,
      'lng': instance.lng,
      'metadata': instance.metadata,
      'estado': instance.estado,
      'origen': instance.origen,
      'fuente_origen': instance.fuenteOrigen,
      'created_by': instance.createdBy,
      'created_at': instance.createdAt?.toIso8601String(),
      'updated_at': instance.updatedAt?.toIso8601String(),
    };
