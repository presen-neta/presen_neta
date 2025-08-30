// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'review_result.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_ReviewResult _$ReviewResultFromJson(Map<String, dynamic> json) =>
    _ReviewResult(
      point: (json['point'] as num).toInt(),
      good: (json['good'] as List<dynamic>).map((e) => e as String).toList(),
      improve:
          (json['improve'] as List<dynamic>).map((e) => e as String).toList(),
    );

Map<String, dynamic> _$ReviewResultToJson(_ReviewResult instance) =>
    <String, dynamic>{
      'point': instance.point,
      'good': instance.good,
      'improve': instance.improve,
    };
