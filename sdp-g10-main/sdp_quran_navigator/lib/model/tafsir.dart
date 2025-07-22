class Tafsir {
  final String index;
  final String surah;
  final List<Ayah> ayat;

  Tafsir({required this.index, required this.surah, required this.ayat});

  factory Tafsir.fromJson(Map<String, dynamic> json) {
    var ayatJson = json['ayat'] as List;
    List<Ayah> ayatList = ayatJson.map((ayah) => Ayah.fromJson(ayah)).toList();

    return Tafsir(
      index: json['index'],
      surah: json['surah'],
      ayat: ayatList,
    );
  }

  @override
  String toString() {
    return "Tafsir index: $index, surah: $surah, aya: $ayat";
  }
}

class Ayah {
  final String index;
  final String text;

  Ayah({required this.index, required this.text});

  factory Ayah.fromJson(Map<String, dynamic> json) {
    return Ayah(
      index: json['index'],
      text: json['text'],
    );
  }

  @override
  String toString() {
    return "Aya index: $index, text: $text";
  }
}
