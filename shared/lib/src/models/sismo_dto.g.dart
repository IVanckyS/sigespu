// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'sismo_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_SismoDto _$SismoDtoFromJson(Map<String, dynamic> json) => _SismoDto(
      id: json['id'] as String,
      magnitude: (json['magnitude'] as num).toDouble(),
      magType: json['magType'] as String?,
      place: json['place'] as String?,
      timeUtc: DateTime.parse(json['timeUtc'] as String),
      depthKm: (json['depthKm'] as num?)?.toDouble(),
      latitude: (json['latitude'] as num).toDouble(),
      longitude: (json['longitude'] as num).toDouble(),
      alert: json['alert'] as String?,
      tsunami: (json['tsunami'] as num?)?.toInt(),
      urlUsgs: json['urlUsgs'] as String?,
    );

Map<String, dynamic> _$SismoDtoToJson(_SismoDto instance) => <String, dynamic>{
      'id': instance.id,
      'magnitude': instance.magnitude,
      'magType': instance.magType,
      'place': instance.place,
      'timeUtc': instance.timeUtc.toIso8601String(),
      'depthKm': instance.depthKm,
      'latitude': instance.latitude,
      'longitude': instance.longitude,
      'alert': instance.alert,
      'tsunami': instance.tsunami,
      'urlUsgs': instance.urlUsgs,
    };
