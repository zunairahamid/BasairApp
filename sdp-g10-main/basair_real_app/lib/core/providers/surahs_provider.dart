import 'dart:convert';
import 'package:basair_real_app/core/models/surah.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class SurahNotifier extends Notifier<List<Surah>> {
  @override
  List<Surah> build() {
    initializeState();
    return [];
  }

  Future<void> initializeState() async {
    try {
      final data = await rootBundle.loadString('assets/data/surahs.json');
      final surahsMap = jsonDecode(data) as List<dynamic>;

      final surahs = surahsMap.map((map) => Surah.fromJson(map)).toList();
      state = surahs;
    } catch (error) {
      print('Error loading surahs: $error');
    }
  }

  List<Surah> filterSurahs({String name = ''}) {
    return state.where((surah) {
      return surah.name.toLowerCase().contains(name.toLowerCase());
    }).toList();
  }

  Map<String, int>? getSurahPages(int surahId) {
    if (state.isEmpty) return null;

    final surahIndex = state.indexWhere((s) => s.id == surahId);
    if (surahIndex == -1) return null;

    final startPage = state[surahIndex].page;
    final endPage =
        (surahIndex + 1 < state.length) ? state[surahIndex + 1].page - 1 : 604;

    return {
      'startPage': startPage,
      'endPage': endPage,
    };
  }
}

final surahProvider = NotifierProvider<SurahNotifier, List<Surah>>(
  () => SurahNotifier(),
);
