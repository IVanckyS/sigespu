import 'package:freezed_annotation/freezed_annotation.dart';

part 'punto_interes.freezed.dart';
part 'punto_interes.g.dart';

@freezed
abstract class PuntoInteres with _$PuntoInteres {
  const factory PuntoInteres({
    required String id,
    required String tipo,
    String? nombre,
    String? descripcion,
    String? direccion,
    required double lat,
    required double lng,
    Map<String, dynamic>? metadata,
    @Default('activo') String estado,
    @Default('manual') String origen,
    @JsonKey(name: 'fuente_origen') String? fuenteOrigen,
    @JsonKey(name: 'created_by') String? createdBy,
    @JsonKey(name: 'created_at') DateTime? createdAt,
    @JsonKey(name: 'updated_at') DateTime? updatedAt,
  }) = _PuntoInteres;

  factory PuntoInteres.fromJson(Map<String, dynamic> json) => _$PuntoInteresFromJson(json);
}
