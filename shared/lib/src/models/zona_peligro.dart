import 'package:freezed_annotation/freezed_annotation.dart';

part 'zona_peligro.freezed.dart';
part 'zona_peligro.g.dart';

@freezed
class ZonaPeligro with _$ZonaPeligro {
  const factory ZonaPeligro({
    required String id,
    String? nombre,
    required List<List<double>> polygonCoords, // [[lat, lng], [lat, lng], ...]
    @JsonKey(name: 'nivel_riesgo') int? nivelRiesgo,
    @JsonKey(name: 'tipo_riesgo') String? tipoRiesgo,
    String? descripcion,
    @JsonKey(name: 'horario_critico') String? horarioCritico,
    @JsonKey(name: 'vigente_desde') DateTime? vigenteDesde,
    @JsonKey(name: 'vigente_hasta') DateTime? vigenteHasta,
    @JsonKey(name: 'created_by') String? createdBy,
    @JsonKey(name: 'created_at') DateTime? createdAt,
    @JsonKey(name: 'updated_at') DateTime? updatedAt,
  }) = _ZonaPeligro;

  factory ZonaPeligro.fromJson(Map<String, dynamic> json) => _$ZonaPeligroFromJson(json);
}
