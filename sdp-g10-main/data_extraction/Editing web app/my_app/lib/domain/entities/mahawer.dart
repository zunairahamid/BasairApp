import 'package:json_annotation/json_annotation.dart';
import 'section.dart';

part 'mahawer.g.dart';

@JsonSerializable()
class Mahawer {
  final String id;
  final String type;
  final String sequence;
  final String title;
  final String text;
  final List<int>? ayat;
  final bool? isMuqadimah;
  final bool? isKhatimah;
  final List<Section> sections;

  Mahawer({
    required this.id,
    required this.type,
    required this.sequence,
    required this.title,
    required this.text,
    this.ayat,
    this.isMuqadimah,
    this.isKhatimah,
    required this.sections,
  });

  factory Mahawer.fromJson(Map<String, dynamic> json) => _$MahawerFromJson(json);
  Map<String, dynamic> toJson() => _$MahawerToJson(this);
}