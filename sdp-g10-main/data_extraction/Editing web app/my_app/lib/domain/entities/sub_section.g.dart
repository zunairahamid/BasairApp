// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'sub_section.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SubSection _$SubSectionFromJson(Map json) => SubSection(
  id: json['id'] as String,
  type: json['type'] as String,
  sequence: json['sequence'] as String,
  text: json['text'] as String,
  ayat: (json['ayat'] as List<dynamic>?)
      ?.map((e) => (e as num).toInt())
      .toList(),
  conclusion: json['conclusion'] as String?,
  topics: (json['topics'] as List<dynamic>?)
      ?.map((e) => Topic.fromJson(Map<String, dynamic>.from(e as Map)))
      .toList(),
);

Map<String, dynamic> _$SubSectionToJson(SubSection instance) =>
    <String, dynamic>{
      'id': instance.id,
      'type': instance.type,
      'sequence': instance.sequence,
      'text': instance.text,
      'ayat': instance.ayat,
      'conclusion': instance.conclusion,
      'topics': instance.topics?.map((e) => e.toJson()).toList(),
    };
