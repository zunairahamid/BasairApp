// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'topic.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Topic _$TopicFromJson(Map<String, dynamic> json) => Topic(
  id: json['id'] as String,
  type: json['type'] as String,
  sequence: json['sequence'] as String,
  text: json['text'] as String,
  ayat: (json['ayat'] as List<dynamic>?)
      ?.map((e) => (e as num).toInt())
      .toList(),
);

Map<String, dynamic> _$TopicToJson(Topic instance) => <String, dynamic>{
  'id': instance.id,
  'type': instance.type,
  'sequence': instance.sequence,
  'text': instance.text,
  'ayat': instance.ayat,
};
