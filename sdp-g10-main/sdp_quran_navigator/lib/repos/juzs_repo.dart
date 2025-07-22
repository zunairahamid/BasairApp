import 'dart:convert';

import 'package:flutter/services.dart';

import '../model/juz.dart';

class JuzRepository {
  Future<List<Juz>> getJuz() async {
    var response = await rootBundle.loadString('assets/data/juzs.json');
    var juzList = jsonDecode(response);
    List<Juz> juzs = [];
    for (var juzMap in juzList) {
      juzs.add(Juz.fromJson(juzMap));
    }
    return juzs;
  }
}
