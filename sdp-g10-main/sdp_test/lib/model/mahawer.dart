// models/mahawer.dart
import 'package:sdp_test/model/section.dart';

class Mahawer {
  final int surahID;
  final Moqadema moqadema;
  // final String title;
  // final String range;
  final List<Mehwar> mahawer;

  Mahawer(
      {required this.surahID,
      required this.moqadema,
      required this.mahawer});

  // Factory method to create a product from JSON
  factory Mahawer.fromJson(Map<String, dynamic> json) {
    var mahawerJson = json['mahawer'] as List;
    List<Mehwar> mahawerList =
        mahawerJson.map((mehwar) => Mehwar.fromJson(mehwar)).toList();

    return Mahawer(
      surahID: json['surahID'],
      moqadema: Moqadema.fromJson(json['moqadema']),
      // title: json['title'],
      // range: json['range'],
      mahawer: mahawerList,
    );
  }
}

class Moqadema {
  final String title;
  final String range;
  final List<Sections> sections;

  Moqadema({
    required this.title,
    required this.range,
    required this.sections,
  });

  factory Moqadema.fromJson(Map<String, dynamic> json) {
    var sectionsJson = json['sections'] as List;
    List<Sections> sectionsList =
        sectionsJson.map((section) => Sections.fromJson(section)).toList();

    return Moqadema(
      title: json['title'],
      range: json['range'],
      sections: sectionsList,
    );
  }
}

class Mehwar {
  final int id;
  final String counter;
  final String title;
  final String text;
  final String range;
  final List<Sections> sections;

  Mehwar(
      {required this.id,
      required this.counter,
      required this.title,
      required this.text,
      required this.range,
      required this.sections});
  
  factory Mehwar.fromJson(Map<String, dynamic> json) {
    return Mehwar(
      id: json['id'],
      title: json['title'],
      text: json['text'],
      range: json['range'],
      counter: json['counter'],
      sections: (json['sections'] as List).map((item) => Sections.fromJson(item)).toList(),
    );
  }
}
