class Verse {
  final int id;
  final String name;
  final String transliteration;
  final String type;
  final int totalVerses;
  final List<Verses> verses;

  Verse({
    required this.id,
    required this.name,
    required this.transliteration,
    required this.type,
    required this.totalVerses,
    required this.verses,
  });

  factory Verse.fromJson(Map<String, dynamic> json) {
    var versesJson = json['verses'] as List;
    List<Verses> versesList =
        versesJson.map((verse) => Verses.fromJson(verse)).toList();

    return Verse(
      id: json['id'],
      // text: json['text'],
      verses: versesList,
      name: json['name'],
      transliteration: json['transliteration'],
      type: json['type'],
      totalVerses: json['total_verses'],
    );
  }

  @override
  String toString() {
    return "Surah Id: $id, Name: $name, ayaCount: $totalVerses, type: $type, verses: $verses";
  }
}

class Verses {
  final int id;
  final String text;

  Verses({required this.id, required this.text});

  factory Verses.fromJson(Map<String, dynamic> map) {
    return Verses(
      id: map['id'],
      text: map['text'],
    );
  }
}
