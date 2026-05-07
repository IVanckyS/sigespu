// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'capa_personalizada_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$CapaPersonalizadaDtoImpl _$$CapaPersonalizadaDtoImplFromJson(
        Map<String, dynamic> json) =>
    _$CapaPersonalizadaDtoImpl(
      id: (json['id'] as num).toInt(),
      nombre: json['nombre'] as String,
      descripcion: json['descripcion'] as String?,
      color: json['color'] as String,
      opacidad: (json['opacidad'] as num).toDouble(),
      visible: json['visible'] as bool,
      formato: json['formato'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );

Map<String, dynamic> _$$CapaPersonalizadaDtoImplToJson(
        _$CapaPersonalizadaDtoImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'nombre': instance.nombre,
      'descripcion': instance.descripcion,
      'color': instance.color,
      'opacidad': instance.opacidad,
      'visible': instance.visible,
      'formato': instance.formato,
      'createdAt': instance.createdAt.toIso8601String(),
    };
