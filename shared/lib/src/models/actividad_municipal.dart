import 'package:freezed_annotation/freezed_annotation.dart';

part 'actividad_municipal.freezed.dart';
part 'actividad_municipal.g.dart';

enum TipoActividad { reunion, operativo, evento, capacitacion }

enum EstadoActividad { planificado, enCurso, completado, archivado }

@freezed
class ActividadMunicipal with _$ActividadMunicipal {
  const factory ActividadMunicipal({
    required String id,
    required TipoActividad tipo,
    required EstadoActividad estado,
    required String titulo,
    required String descripcion,
    required DateTime fechaInicio,
    DateTime? fechaFin,
    double? lat,
    double? lng,
    String? direccion,
    String? sector,
    @Default([]) List<String> participanteIds,
    ActaActividad? acta,
    required String creadoPor,
    required DateTime creadoEn,
    DateTime? actualizadoEn,
    double? presupuestoEstimado,
    String? direccionMunicipal,
    @Default([]) List<String> adjuntos,
  }) = _ActividadMunicipal;

  factory ActividadMunicipal.fromJson(Map<String, dynamic> json) =>
      _$ActividadMunicipalFromJson(json);
}

@freezed
class ActaActividad with _$ActaActividad {
  const factory ActaActividad({
    String? contenido,
    @Default([]) List<AsistenteActa> asistentes,
    @Default([]) List<AcuerdoActa> acuerdos,
    DateTime? fechaFirma,
  }) = _ActaActividad;

  factory ActaActividad.fromJson(Map<String, dynamic> json) =>
      _$ActaActividadFromJson(json);
}

@freezed
class AsistenteActa with _$AsistenteActa {
  const factory AsistenteActa({
    required String nombre,
    required String cargo,
    String? rut,
    @Default(true) bool asistio,
  }) = _AsistenteActa;

  factory AsistenteActa.fromJson(Map<String, dynamic> json) =>
      _$AsistenteActaFromJson(json);
}

@freezed
class AcuerdoActa with _$AcuerdoActa {
  const factory AcuerdoActa({
    required String id,
    required String descripcion,
    required String responsable,
    required DateTime fechaLimite,
    @Default(false) bool completado,
  }) = _AcuerdoActa;

  factory AcuerdoActa.fromJson(Map<String, dynamic> json) =>
      _$AcuerdoActaFromJson(json);
}
