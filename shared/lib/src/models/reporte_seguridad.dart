import 'package:freezed_annotation/freezed_annotation.dart';

part 'reporte_seguridad.freezed.dart';
part 'reporte_seguridad.g.dart';

@freezed
abstract class ReporteSeguridad with _$ReporteSeguridad {
  const factory ReporteSeguridad({
    required String id,
    required String tipo,
    required double lat,
    required double lng,
    String? direccion,
    String? descripcion,
    int? severidad,
    @JsonKey(name: 'fecha_evento') DateTime? fechaEvento,
    @Default([]) List<String> fotos,
    @Default('reportado') String estado,
    @JsonKey(name: 'derivado_a') String? derivadoA,
    @JsonKey(name: 'reportado_por') String? reportadoPor,
    @JsonKey(name: 'verificado_por') String? verificadoPor,
    @JsonKey(name: 'created_at') DateTime? createdAt,
    @JsonKey(name: 'updated_at') DateTime? updatedAt,
  }) = _ReporteSeguridad;

  factory ReporteSeguridad.fromJson(Map<String, dynamic> json) => _$ReporteSeguridadFromJson(json);
}
