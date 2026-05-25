import 'package:freezed_annotation/freezed_annotation.dart';

part 'sector_plan_regulador.freezed.dart';
part 'sector_plan_regulador.g.dart';

@freezed
abstract class SectorPlanRegulador with _$SectorPlanRegulador {
  const factory SectorPlanRegulador({
    required String id,
    String? codigo,
    String? nombre,
    @JsonKey(name: 'sector_padre') String? sectorPadre,
    required List<List<double>> polygonCoords,
    @JsonKey(name: 'usos_permitidos') Map<String, dynamic>? usosPermitidos,
    @JsonKey(name: 'usos_prohibidos') Map<String, dynamic>? usosProhibidos,
    String? fuente,
    @Default(true) bool vigente,
    @JsonKey(name: 'created_at') DateTime? createdAt,
  }) = _SectorPlanRegulador;

  factory SectorPlanRegulador.fromJson(Map<String, dynamic> json) => _$SectorPlanReguladorFromJson(json);
}
