// models/section.dart
class Section {
  final String id;
  final String type;
  final String sequence;
  final String title;
  final String text;
  final List<int> ayat;
  final String? conclusion;
  final List<Section>? subSections;
  final List<dynamic>? cases;

  Section({
    required this.id,
    required this.type,
    required this.sequence,
    required this.title,
    required this.text,
    required this.ayat,
    this.conclusion,
    this.subSections,
    this.cases,
  });

  factory Section.fromJson(Map<String, dynamic> json) {
    return Section(
      id: json['id']?.toString() ?? '',
      type: json['type']?.toString() ?? '',
      sequence: json['sequence']?.toString() ?? '',
      title: json['title']?.toString() ?? '',
      text: json['text']?.toString() ?? '',
      ayat: List<int>.from(json['ayat'] ?? []),
      conclusion: json['conclusion']?.toString(),
      subSections: (json['subSections'] as List<dynamic>?)
          ?.map((subSection) => Section.fromJson(subSection))
          .toList(),
      cases: json['cases'] as List<dynamic>?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type,
      'sequence': sequence,
      'title': title,
      'text': text,
      'ayat': ayat,
      'conclusion': conclusion,
      'subSections': subSections?.map((sub) => sub.toJson()).toList(),
      'cases': cases,
    };
  }
}