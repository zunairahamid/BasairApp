import 'dart:convert';
import 'package:flutter/services.dart';

import '../model/surah.dart';

class SurahRepository {
  Future<List<Surah>> getSurah() async {
    var response = await rootBundle.loadString('assets/data/surahs.json');
    var surahList = jsonDecode(response);
    List<Surah> surahs = [];
    for (var surahMap in surahList) {
      surahs.add(Surah.fromJson(surahMap));
    }
    return surahs;
  }
}
