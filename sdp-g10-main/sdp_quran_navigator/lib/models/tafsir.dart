class Tafsir {
  List<Ayat> ayat;
  int index;
  String surah;

  Tafsir ({
    required this.index,
    required this.surah,
    required this.ayat
  });

  factory Tafsir.fromJson(Map<String, dynamic> json) {
    return Tafsir(
      index: int.parse(json['index']),
      surah: json['surah'],
      ayat: (json['ayat'] as List)
          .map((aya) => Ayat.fromJson(aya))
          .toList(),
    );
  }

}

class Ayat {
  int index;
  String text;

  Ayat ({
    required this.index,
    required this.text
  });

  factory Ayat.fromJson(Map<String, dynamic> json) {
    return Ayat(
      index: int.parse(json['index']),
      text: json['text'],
    );
  }

}