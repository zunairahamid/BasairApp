// models/section.dart
class Sections {
  final double id;
  final String text;
  final int startAya;
  final int endAya;
  Sections({
    required this.id,
    required this.text,
    required this.startAya,
    required this.endAya,
  });

  // Factory method to create a product from JSON
  factory Sections.fromJson(Map<String, dynamic> json) {
    return Sections(
      id: json['id'],
      text: json['text'],
      startAya: json['startAya'],
      endAya: json['endAya'],
    );
  }

  @override
  String toString() {
    return "Section id: $id, text: $text, startAya: $startAya, endAya: $endAya";
  }
}
