import 'dart:convert';
import 'package:sdp_quran_navigator/models/mahwar.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class SurahWithMahawerProvider extends Notifier<List<SurahWithMahawer>> {
  final Map<double, Color> sectionsWithColorsPortrait = {};
  final Map<double, Color> sectionsWithColorsLandscape = {};
  
  final List<Color> colorsPortrait = [
    const Color.fromARGB(255, 10, 71, 224),
    const Color.fromARGB(255, 9, 140, 107),
    const Color.fromARGB(255, 104, 3, 8),
    const Color.fromARGB(255, 131, 13, 113)
  ];
  
  final List<Color> colorsLandscape = [
    const Color.fromARGB(255, 193, 207, 243),
    const Color.fromARGB(255, 182, 236, 223),
    const Color.fromARGB(255, 236, 187, 190),
    const Color.fromARGB(255, 233, 190, 226)
  ];

  @override
  List<SurahWithMahawer> build() {
    return [];
  }

  Future<void> loadData() async {
    if (state.isNotEmpty) return;
    
    try {
      final data = await rootBundle.loadString('assets/data/mahawer.json');
      final mahawerData = jsonDecode(data) as List<dynamic>;
      state = mahawerData.map((mahwer) => SurahWithMahawer.fromJson(mahwer)).toList();
      print(state);
      _assignColorsToSections();
    } catch (e) {
      print('Error loading mahawer data: $e');
      state = [];
    }
  }

  Map<String, dynamic> findSections(int verseIndex, int surahIndex) {
    final surah = state.firstWhere(
      (s) => s.surahID == surahIndex,
      orElse: () => SurahWithMahawer(surahID: -1, moqadema: Moqadema(sections: [], title: '', range: ''), mahawer: []),
    );

    if (surah.surahID == -1) return {};

    for (final section in surah.moqadema.sections) {
      if (verseIndex >= section.startAya && verseIndex <= section.endAya) {
        return {
          'id': section.id,
          'text': section.text,
          'range': '[${section.startAya}-${section.endAya}]'
        };
      }
    }

    for (final mahwar in surah.mahawer) {
      for (final section in mahwar.sections) {
        if (verseIndex >= section.startAya && verseIndex <= section.endAya) {
          return {
            'id': section.id,
            'text': section.text,
            'range': '[${section.startAya}-${section.endAya}]'
          };
        }
      }
    }

    return {};
  }

  void _assignColorsToSections() {
    int colorIndex = 0;
    
    for (final surah in state) {
      for (final section in surah.moqadema.sections) {
        sectionsWithColorsPortrait[section.id] = colorsPortrait[colorIndex % colorsPortrait.length];
        sectionsWithColorsLandscape[section.id] = colorsLandscape[colorIndex % colorsLandscape.length];
        colorIndex++;
      }

      for (final mahwar in surah.mahawer) {
        for (final section in mahwar.sections) {
          sectionsWithColorsPortrait[section.id] = colorsPortrait[colorIndex % colorsPortrait.length];
          sectionsWithColorsLandscape[section.id] = colorsLandscape[colorIndex % colorsLandscape.length];
          colorIndex++;
        }
      }
    }
  }

  Color? getSectionColorPortrait(double sectionId) {
    return sectionsWithColorsPortrait[sectionId];
  }

  Color? getSectionColorLandscape(double sectionId) {
    return sectionsWithColorsLandscape[sectionId];
  }
}

final mahawerNotifierProvider = NotifierProvider<SurahWithMahawerProvider, List<SurahWithMahawer>>(
  () => SurahWithMahawerProvider(),
);