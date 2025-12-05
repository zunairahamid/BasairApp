class SurahVerses {
  int id;
  String name;
  String transliteration;
  String type;
  int total_verses;
  List<Verse> verses;

  SurahVerses({
    required this.id,
    required this.name,
    required this.transliteration,
    required this.type,
    required this.total_verses,
    required this.verses,
  });

  factory SurahVerses.fromJson(Map<String, dynamic> json) {
    return SurahVerses(
      id: json['id'] as int? ?? 0,
      name: json['name'] as String? ?? '',
      transliteration: json['transliteration'] as String? ?? '',
      type: json['type'] as String? ?? '',
      total_verses: json['total_verses'] as int? ?? 0,
      verses: (json['verses'] as List?)
              ?.map((verse) => Verse.fromJson(verse as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }
}

class Verse {
  int id;
  String text;

  Verse({required this.id, required this.text});

  factory Verse.fromJson(Map<String, dynamic> json) {
    return Verse(
      id: json['id'] as int? ?? 0,
      text: json['text'] as String? ?? '',
    );
  }
}
