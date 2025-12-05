import 'package:json_annotation/json_annotation.dart';
import 'surah.dart';
import 'mahawer.dart';

part 'tafsir.g.dart';

@JsonSerializable()
class Tafsir {
  final String tafsirId;
  final String title;
  final String author;
  final String publisher;
  final int year;
  final String location;
  final String isbn;
  final String surahId;
  final String state;
  final Surah surah;
  final List<Mahawer> mahawer;

  Tafsir({
    required this.tafsirId,
    required this.title,
    required this.author,
    required this.publisher,
    required this.year,
    required this.location,
    required this.isbn,
    required this.surahId,
    required this.state,
    required this.surah,
    required this.mahawer,
  });

  factory Tafsir.fromJson(Map<String, dynamic> json) => _$TafsirFromJson(json);
  Map<String, dynamic> toJson() => _$TafsirToJson(this);
}