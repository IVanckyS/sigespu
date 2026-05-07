import 'package:freezed_annotation/freezed_annotation.dart';

part 'sismo_dto.freezed.dart';
part 'sismo_dto.g.dart';

@freezed
class SismoDto with _$SismoDto {
  const factory SismoDto({
    required String id,
    required double magnitude,
    String? magType,
    String? place,
    required DateTime timeUtc,
    double? depthKm,
    required double latitude,
    required double longitude,
    String? alert,
    int? tsunami,
    String? urlUsgs,
  }) = _SismoDto;

  factory SismoDto.fromJson(Map<String, dynamic> json) =>
      _$SismoDtoFromJson(json);
}
