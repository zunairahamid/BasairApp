// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'mahawer.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Mahawer _$MahawerFromJson(Map<String, dynamic> json) => Mahawer(
  id: json['id'] as String,
  type: json['type'] as String,
  sequence: json['sequence'] as String,
  title: json['title'] as String,
  text: json['text'] as String,
  ayat: (json['ayat'] as List<dynamic>?)
      ?.map((e) => (e as num).toInt())
      .toList(),
  isMuqadimah: json['isMuqadimah'] as bool?,
  isKhatimah: json['isKhatimah'] as bool?,
  sections: (json['sections'] as List<dynamic>)
      .map((e) => Section.fromJson(e as Map<String, dynamic>))
      .toList(),
);

Map<String, dynamic> _$MahawerToJson(Mahawer instance) => <String, dynamic>{
  'id': instance.id,
  'type': instance.type,
  'sequence': instance.sequence,
  'title': instance.title,
  'text': instance.text,
  'ayat': instance.ayat,
  'isMuqadimah': instance.isMuqadimah,
  'isKhatimah': instance.isKhatimah,
  'sections': instance.sections,
};
