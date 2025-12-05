// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'section.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Section _$SectionFromJson(Map<String, dynamic> json) => Section(
  id: json['id'] as String,
  type: json['type'] as String,
  sequence: json['sequence'] as String,
  title: json['title'] as String?,
  text: json['text'] as String,
  ayat: (json['ayat'] as List<dynamic>?)
      ?.map((e) => (e as num).toInt())
      .toList(),
  conclusion: json['conclusion'] as String?,
  subSections: (json['subSections'] as List<dynamic>?)
      ?.map((e) => SubSection.fromJson(e as Map<String, dynamic>))
      .toList(),
);

Map<String, dynamic> _$SectionToJson(Section instance) => <String, dynamic>{
  'id': instance.id,
  'type': instance.type,
  'sequence': instance.sequence,
  'title': instance.title,
  'text': instance.text,
  'ayat': instance.ayat,
  'conclusion': instance.conclusion,
  'subSections': instance.subSections,
};
