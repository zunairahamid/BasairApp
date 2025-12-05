import 'package:json_annotation/json_annotation.dart';

part 'surah.g.dart';

@JsonSerializable()
class Surah {
  final String surahId;
  final String surahName;

  Surah({required this.surahId, required this.surahName});

  factory Surah.fromJson(Map<String, dynamic> json) => _$SurahFromJson(json);
  Map<String, dynamic> toJson() => _$SurahToJson(this);
}