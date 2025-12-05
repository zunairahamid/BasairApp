import 'dart:convert';
import 'package:basair_real_app/core/models/juz.dart';
import 'package:flutter/services.dart';

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
