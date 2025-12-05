// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'tafsir.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Tafsir _$TafsirFromJson(Map<String, dynamic> json) => Tafsir(
  tafsirId: json['tafsirId'] as String,
  title: json['title'] as String,
  author: json['author'] as String,
  publisher: json['publisher'] as String,
  year: (json['year'] as num).toInt(),
  location: json['location'] as String,
  isbn: json['isbn'] as String,
  surahId: json['surahId'] as String,
  state: json['state'] as String,
  surah: Surah.fromJson(json['surah'] as Map<String, dynamic>),
  mahawer: (json['mahawer'] as List<dynamic>)
      .map((e) => Mahawer.fromJson(e as Map<String, dynamic>))
      .toList(),
);

Map<String, dynamic> _$TafsirToJson(Tafsir instance) => <String, dynamic>{
  'tafsirId': instance.tafsirId,
  'title': instance.title,
  'author': instance.author,
  'publisher': instance.publisher,
  'year': instance.year,
  'location': instance.location,
  'isbn': instance.isbn,
  'surahId': instance.surahId,
  'state': instance.state,
  'surah': instance.surah,
  'mahawer': instance.mahawer,
};
