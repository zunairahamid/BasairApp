import 'dart:convert';
import 'package:sdp_quran_navigator/models/page.dart';
import 'package:sdp_quran_navigator/models/verses.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class VersesState {
  final List<Page> pages;
  final List<SurahVerses> surahs;
  final Map<int, List<Verse>> currentPageVerses;

  VersesState({
    required this.pages,
    required this.surahs,
    required this.currentPageVerses,
  });

  VersesState copyWith({
    List<Page>? pages,
    List<SurahVerses>? surahs,
    Map<int, List<Verse>>? currentPageVerses,
  }) {
    return VersesState(
      pages: pages ?? this.pages,
      surahs: surahs ?? this.surahs,
      currentPageVerses: currentPageVerses ?? this.currentPageVerses,
    );
  }

  String? getSurahTypeByPage(int pageNumber) {
    final page = pages.firstWhere(
      (p) => p.index == pageNumber,
      orElse: () => Page(index: -1, sura: -1, aya: -1),
    );

    if (page.index == -1) return null;

    final surah = surahs.firstWhere(
      (s) => s.id == page.sura,
      orElse: () => SurahVerses(
          id: -1,
          name: '',
          type: '',
          verses: [],
          transliteration: '',
          total_verses: 0),
    );

    return surah.type == 'medinan' ? 'مدنية' : 'مكية';
  }

  String? getSurahNameByPage(int pageNumber) {
    final page = pages.firstWhere(
      (p) => p.index == pageNumber,
      orElse: () => Page(index: -1, sura: -1, aya: -1),
    );

    if (page.index == -1) return null;

    return surahs
        .firstWhere(
          (s) => s.id == page.sura,
          orElse: () => SurahVerses(
              id: -1,
              name: '',
              type: '',
              verses: [],
              transliteration: '',
              total_verses: 0),
        )
        .name;
  }

  String? getSurahNameById(int surahId) {
    return surahs
        .firstWhere(
          (s) => s.id == surahId,
          orElse: () => SurahVerses(
              id: -1,
              name: '',
              type: '',
              verses: [],
              transliteration: '',
              total_verses: 0),
        )
        .name;
  }
}

class VersesProvider extends Notifier<VersesState> {
  static const int LastSurahNumber = 114;

  @override
  VersesState build() {
    return VersesState(
      pages: [],
      surahs: [],
      currentPageVerses: {},
    );
  }

  Future<void> loadData() async {
    if (state.pages.isNotEmpty && state.surahs.isNotEmpty) return;

    try {
      final pagesData = await rootBundle.loadString('assets/data/pages.json');
      final versesData = await rootBundle.loadString('assets/data/verses.json');

      final pages = (jsonDecode(pagesData) as List<dynamic>)
          .map((page) => Page.fromJson(page))
          .toList();

      final surahs = (jsonDecode(versesData) as List<dynamic>)
          .map((surah) => SurahVerses.fromJson(surah))
          .toList();

      state = state.copyWith(pages: pages, surahs: surahs);
    } catch (e) {
      print('Error loading verses data: $e');
    }
  }

  Future<void> loadVersesByPage(int pageNumber) async {
    if (state.pages.isEmpty || state.surahs.isEmpty) {
      await loadData();
    }

    final pageData = state.pages.firstWhere(
      (page) => page.index == pageNumber,
      orElse: () => Page(index: -1, sura: -1, aya: -1),
    );

    if (pageData.index == -1) return;

    int currentSurahNumber = pageData.sura;
    int currentAya = pageData.aya;

    final nextPageData = getPageData(pageNumber + 1);
    int nextPageSurahNumber = nextPageData?.sura ?? LastSurahNumber;
    int nextPageAya = nextPageData?.aya ?? 1;

    Map<int, List<Verse>> surahsOnPage = {};
    bool isLastPage = nextPageData == null;
    bool lastSurahReached = false;

    while (!lastSurahReached) {
      final surahData = getSurahData(currentSurahNumber);
      if (surahData == null) break;

      List<Verse> allAyas = surahData.verses;
      int startIndex = currentAya - 1;
      int endIndex = allAyas.length;

      if (!isLastPage && currentSurahNumber == nextPageSurahNumber) {
        endIndex = nextPageAya - 1;
        lastSurahReached = true;
      }

      final versesOnPage = allAyas.sublist(startIndex, endIndex);
      surahsOnPage[currentSurahNumber] = versesOnPage;

      if (!lastSurahReached) {
        if (isLastPage && currentSurahNumber >= LastSurahNumber) {
          lastSurahReached = true;
        } else {
          currentSurahNumber += 1;
          currentAya = 1;
        }
      }
    }

    state = state.copyWith(currentPageVerses: surahsOnPage);
  }

  Page? getPageData(int pageNumber) {
    try {
      return state.pages.firstWhere(
        (page) => page.index == pageNumber,
      );
    } catch (e) {
      return null;
    }
  }

  SurahVerses? getSurahData(int surahNumber) {
    try {
      return state.surahs.firstWhere(
        (surah) => surah.id == surahNumber,
      );
    } catch (e) {
      return null;
    }
  }

  String? getSurahNameById(int surahId) {
    try {
      return state.surahs
          .firstWhere(
            (surah) => surah.id == surahId,
          )
          .name;
    } catch (e) {
      return null;
    }
  }
}

final versesNotifierProvider = NotifierProvider<VersesProvider, VersesState>(
  () => VersesProvider(),
);
