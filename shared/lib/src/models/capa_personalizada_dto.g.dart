// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'capa_personalizada_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_CapaPersonalizadaDto _$CapaPersonalizadaDtoFromJson(
        Map<String, dynamic> json) =>
    _CapaPersonalizadaDto(
      id: json['id'] as String,
      nombre: json['nombre'] as String,
      descripcion: json['descripcion'] as String?,
      color: json['color'] as String,
      opacidad: (json['opacidad'] as num).toDouble(),
      visible: json['visible'] as bool,
      formato: json['formato'] as String,
      categoria: json['categoria'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );

Map<String, dynamic> _$CapaPersonalizadaDtoToJson(
        _CapaPersonalizadaDto instance) =>
    <String, dynamic>{
      'id': instance.id,
      'nombre': instance.nombre,
      'descripcion': instance.descripcion,
      'color': instance.color,
      'opacidad': instance.opacidad,
      'visible': instance.visible,
      'formato': instance.formato,
      'categoria': instance.categoria,
      'createdAt': instance.createdAt.toIso8601String(),
    };
