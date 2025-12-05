import 'package:json_annotation/json_annotation.dart';

part 'topic.g.dart';

@JsonSerializable()
class Topic {
  final String id;
  final String type;
  final String sequence;
  final String text;
  final List<int>? ayat;

  Topic({
    required this.id,
    required this.type,
    required this.sequence,
    required this.text,
    this.ayat,
  });

  factory Topic.fromJson(Map<String, dynamic> json) => _$TopicFromJson(json);
  Map<String, dynamic> toJson() => _$TopicToJson(this);
}