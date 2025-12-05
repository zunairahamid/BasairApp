import 'dart:convert';
import 'package:basair_real_app/core/models/tafsir.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class TafsirProvider extends Notifier<List<Tafsir>> {
  @override
  List<Tafsir> build() {
    return [];
  }

  Future<void> loadData() async {
    if (state.isNotEmpty) return;

    try {
      final data = await rootBundle.loadString('assets/data/tafsir.json');
      final tafsirData = jsonDecode(data) as List<dynamic>;
      state = tafsirData.map((tafsir) => Tafsir.fromJson(tafsir)).toList();
      print(state);
    } catch (e) {
      print('Error loading tafsir data: $e');
      state = [];
    }
  }

  Future<String> getTafsir(int surahNumber, int verseNumber) async {
    if (state.isEmpty) await loadData();

    try {
      final foundTafsir = state.firstWhere(
        (tafsir) => tafsir.index == surahNumber,
      );

      final index = verseNumber - 1;
      if (index < 0 || index >= foundTafsir.ayat.length) {
        return "التفسير غير متوفر";
      }

      return foundTafsir.ayat[index].text;
    } catch (e) {
      return "التفسير غير متوفر";
    }
  }
}

final tafsirNotifierProvider = NotifierProvider<TafsirProvider, List<Tafsir>>(
  () => TafsirProvider(),
);
