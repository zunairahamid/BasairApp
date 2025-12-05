import 'package:json_annotation/json_annotation.dart';
import 'sub_section.dart';

part 'section.g.dart';

@JsonSerializable()
class Section {
  final String id;
  final String type;
  final String sequence;
  final String? title;
  final String text;
  final List<int>? ayat;
  final String? conclusion;
  final List<SubSection>? subSections;

  Section({
    required this.id,
    required this.type,
    required this.sequence,
    this.title,
    required this.text,
    this.ayat,
    this.conclusion,
    this.subSections,
  });

  factory Section.fromJson(Map<String, dynamic> json) =>
      _$SectionFromJson(json);
  Map<String, dynamic> toJson() => _$SectionToJson(this);
}
