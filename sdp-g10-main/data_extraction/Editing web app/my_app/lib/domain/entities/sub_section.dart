import 'package:json_annotation/json_annotation.dart';
import 'topic.dart';

part 'sub_section.g.dart';

@JsonSerializable(anyMap: true, explicitToJson: true)
@JsonSerializable(ignoreUnannotated: false, explicitToJson: true)
class SubSection {
  final String id;
  final String type;
  final String sequence;
  final String text;
  final List<int>? ayat;
  final String? conclusion;
  final List<Topic>? topics;

  SubSection({
    required this.id,
    required this.type,
    required this.sequence,
    required this.text,
    this.ayat,
    this.conclusion,
    this.topics,
  });

  factory SubSection.fromJson(Map<String, dynamic> json) => _$SubSectionFromJson(json);
  Map<String, dynamic> toJson() => _$SubSectionToJson(this);
}