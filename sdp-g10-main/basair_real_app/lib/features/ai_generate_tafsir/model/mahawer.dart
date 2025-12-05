// models/mahawer.dart
import 'section.dart';

class Mahawer {
  final String id;
  final String type;
  final String sequence;
  final String title;
  final String text;
  final List<int> ayat;
  final List<Section> sections;
  final bool? isMuqadimah;
  final bool? isKhatimah;
  final int startAya;
  final int endAya;

  Mahawer({
    required this.id,
    required this.type,
    required this.sequence,
    required this.title,
    required this.text,
    required this.ayat,
    required this.sections,
    this.isMuqadimah,
    this.isKhatimah,
    required this.startAya,
    required this.endAya,
  });

  factory Mahawer.fromJson(Map<String, dynamic> json) {
    return Mahawer(
      id: json['id']?.toString() ?? '',
      type: json['type']?.toString() ?? 'محور',
      sequence: json['sequence']?.toString() ?? '',
      title: json['title']?.toString() ?? '',
      text: json['text']?.toString() ?? '',
      ayat: List<int>.from(json['ayat'] ?? []),
      sections: (json['sections'] as List<dynamic>?)
          ?.map((section) => Section.fromJson(section))
          .toList() ?? [],
      isMuqadimah: json['isMuqadimah'] ?? false,
      isKhatimah: json['isKhatimah'] ?? false,
      startAya: json['startAya'] ?? 1,
      endAya: json['endAya'] ?? 1,
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
      'sections': sections.map((section) => section.toJson()).toList(),
      'isMuqadimah': isMuqadimah,
      'isKhatimah': isKhatimah,
      'startAya': startAya,
      'endAya': endAya,
    };
  }
}