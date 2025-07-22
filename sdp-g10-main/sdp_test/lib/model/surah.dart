
// import 'package:basair_app/models/verse.dart';

class Surah {
  final int id;
  final String name;
  final String englishName;
  final String type;
  final int ayaCount;
  //  final List<Verse> verses;

  Surah({
    required this.id,
    required this.name,
    required this.englishName,
    required this.type,
    required this.ayaCount,
    //  required this.verses
  });

  factory Surah.fromJson(Map<String, dynamic> json) {
    //  var verseJson = json['verse'] as List;
    //  List<Verse> verseList = verseJson.map((verse) => Verse.fromJson(verse)).toList();
    return Surah(
      id: json['id'],
      name: json['name'],
      englishName: json['englishName'],
      type: json['type'],
      ayaCount: json['ayaCount'],
      //  verses: verseList
    );
  }

  @override
  String toString() {
    return "Surah Id: $id, Name: $name, EnglishName: $englishName, ayaCount: $ayaCount, type: $type";
  }
}
