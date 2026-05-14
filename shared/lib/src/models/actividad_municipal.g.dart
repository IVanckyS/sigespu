// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'actividad_municipal.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$ActividadMunicipalImpl _$$ActividadMunicipalImplFromJson(
        Map<String, dynamic> json) =>
    _$ActividadMunicipalImpl(
      id: json['id'] as String,
      tipo: $enumDecode(_$TipoActividadEnumMap, json['tipo']),
      estado: $enumDecode(_$EstadoActividadEnumMap, json['estado']),
      titulo: json['titulo'] as String,
      descripcion: json['descripcion'] as String,
      fechaInicio: DateTime.parse(json['fechaInicio'] as String),
      fechaFin: json['fechaFin'] == null
          ? null
          : DateTime.parse(json['fechaFin'] as String),
      lat: (json['lat'] as num?)?.toDouble(),
      lng: (json['lng'] as num?)?.toDouble(),
      direccion: json['direccion'] as String?,
      sector: json['sector'] as String?,
      participanteIds: (json['participanteIds'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
      acta: json['acta'] == null
          ? null
          : ActaActividad.fromJson(json['acta'] as Map<String, dynamic>),
      creadoPor: json['creadoPor'] as String,
      creadoEn: DateTime.parse(json['creadoEn'] as String),
      actualizadoEn: json['actualizadoEn'] == null
          ? null
          : DateTime.parse(json['actualizadoEn'] as String),
      presupuestoEstimado: (json['presupuestoEstimado'] as num?)?.toDouble(),
      direccionMunicipal: json['direccionMunicipal'] as String?,
      adjuntos: (json['adjuntos'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
    );

Map<String, dynamic> _$$ActividadMunicipalImplToJson(
        _$ActividadMunicipalImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'tipo': _$TipoActividadEnumMap[instance.tipo]!,
      'estado': _$EstadoActividadEnumMap[instance.estado]!,
      'titulo': instance.titulo,
      'descripcion': instance.descripcion,
      'fechaInicio': instance.fechaInicio.toIso8601String(),
      'fechaFin': instance.fechaFin?.toIso8601String(),
      'lat': instance.lat,
      'lng': instance.lng,
      'direccion': instance.direccion,
      'sector': instance.sector,
      'participanteIds': instance.participanteIds,
      'acta': instance.acta,
      'creadoPor': instance.creadoPor,
      'creadoEn': instance.creadoEn.toIso8601String(),
      'actualizadoEn': instance.actualizadoEn?.toIso8601String(),
      'presupuestoEstimado': instance.presupuestoEstimado,
      'direccionMunicipal': instance.direccionMunicipal,
      'adjuntos': instance.adjuntos,
    };

const _$TipoActividadEnumMap = {
  TipoActividad.reunion: 'reunion',
  TipoActividad.operativo: 'operativo',
  TipoActividad.evento: 'evento',
  TipoActividad.capacitacion: 'capacitacion',
};

const _$EstadoActividadEnumMap = {
  EstadoActividad.planificado: 'planificado',
  EstadoActividad.enCurso: 'enCurso',
  EstadoActividad.completado: 'completado',
  EstadoActividad.archivado: 'archivado',
};

_$ActaActividadImpl _$$ActaActividadImplFromJson(Map<String, dynamic> json) =>
    _$ActaActividadImpl(
      contenido: json['contenido'] as String?,
      asistentes: (json['asistentes'] as List<dynamic>?)
              ?.map((e) => AsistenteActa.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      acuerdos: (json['acuerdos'] as List<dynamic>?)
              ?.map((e) => AcuerdoActa.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      fechaFirma: json['fechaFirma'] == null
          ? null
          : DateTime.parse(json['fechaFirma'] as String),
    );

Map<String, dynamic> _$$ActaActividadImplToJson(_$ActaActividadImpl instance) =>
    <String, dynamic>{
      'contenido': instance.contenido,
      'asistentes': instance.asistentes,
      'acuerdos': instance.acuerdos,
      'fechaFirma': instance.fechaFirma?.toIso8601String(),
    };

_$AsistenteActaImpl _$$AsistenteActaImplFromJson(Map<String, dynamic> json) =>
    _$AsistenteActaImpl(
      nombre: json['nombre'] as String,
      cargo: json['cargo'] as String,
      rut: json['rut'] as String?,
      asistio: json['asistio'] as bool? ?? true,
    );

Map<String, dynamic> _$$AsistenteActaImplToJson(_$AsistenteActaImpl instance) =>
    <String, dynamic>{
      'nombre': instance.nombre,
      'cargo': instance.cargo,
      'rut': instance.rut,
      'asistio': instance.asistio,
    };

_$AcuerdoActaImpl _$$AcuerdoActaImplFromJson(Map<String, dynamic> json) =>
    _$AcuerdoActaImpl(
      id: json['id'] as String,
      descripcion: json['descripcion'] as String,
      responsable: json['responsable'] as String,
      fechaLimite: DateTime.parse(json['fechaLimite'] as String),
      completado: json['completado'] as bool? ?? false,
    );

Map<String, dynamic> _$$AcuerdoActaImplToJson(_$AcuerdoActaImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'descripcion': instance.descripcion,
      'responsable': instance.responsable,
      'fechaLimite': instance.fechaLimite.toIso8601String(),
      'completado': instance.completado,
    };
