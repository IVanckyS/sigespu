import 'package:freezed_annotation/freezed_annotation.dart';

part 'capa_personalizada_dto.freezed.dart';
part 'capa_personalizada_dto.g.dart';

@freezed
abstract class CapaPersonalizadaDto with _$CapaPersonalizadaDto {
  const factory CapaPersonalizadaDto({
    required String id,
    required String nombre,
    String? descripcion,
    required String color,
    required double opacidad,
    required bool visible,
    required String formato,
    required String categoria,
    required DateTime createdAt,
  }) = _CapaPersonalizadaDto;

  factory CapaPersonalizadaDto.fromJson(Map<String, dynamic> json) =>
      _$CapaPersonalizadaDtoFromJson(json);
}
