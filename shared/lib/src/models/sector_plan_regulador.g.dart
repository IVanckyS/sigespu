// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'sector_plan_regulador.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$SectorPlanReguladorImpl _$$SectorPlanReguladorImplFromJson(
        Map<String, dynamic> json) =>
    _$SectorPlanReguladorImpl(
      id: json['id'] as String,
      codigo: json['codigo'] as String?,
      nombre: json['nombre'] as String?,
      sectorPadre: json['sector_padre'] as String?,
      polygonCoords: (json['polygonCoords'] as List<dynamic>)
          .map((e) =>
              (e as List<dynamic>).map((e) => (e as num).toDouble()).toList())
          .toList(),
      usosPermitidos: json['usos_permitidos'] as Map<String, dynamic>?,
      usosProhibidos: json['usos_prohibidos'] as Map<String, dynamic>?,
      fuente: json['fuente'] as String?,
      vigente: json['vigente'] as bool? ?? true,
      createdAt: json['created_at'] == null
          ? null
          : DateTime.parse(json['created_at'] as String),
    );

Map<String, dynamic> _$$SectorPlanReguladorImplToJson(
        _$SectorPlanReguladorImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'codigo': instance.codigo,
      'nombre': instance.nombre,
      'sector_padre': instance.sectorPadre,
      'polygonCoords': instance.polygonCoords,
      'usos_permitidos': instance.usosPermitidos,
      'usos_prohibidos': instance.usosProhibidos,
      'fuente': instance.fuente,
      'vigente': instance.vigente,
      'created_at': instance.createdAt?.toIso8601String(),
    };
