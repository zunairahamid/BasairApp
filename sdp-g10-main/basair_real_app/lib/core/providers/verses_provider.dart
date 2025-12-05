import 'dart:convert';
import 'package:basair_real_app/core/models/page.dart';
import 'package:basair_real_app/core/models/verse.dart';
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

  /// AR / Makkah/Madinah type for the *page’s* surah
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
        total_verses: 0,
      ),
    );

    return surah.type == 'medinan' ? 'مدنية' : 'مكية';
  }

  /// Surah name for the surah that starts on this page
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
            total_verses: 0,
          ),
        )
        .name;
  }

  /// Surah name by its ID
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
            total_verses: 0,
          ),
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

  /// Load pages.json + verses.json once
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

  /// Load verses for a specific mushaf page, grouped by surah
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

    final Map<int, List<Verse>> surahsOnPage = {};
    final bool isLastPage = nextPageData == null;
    bool lastSurahReached = false;

    while (!lastSurahReached) {
      final surahData = getSurahData(currentSurahNumber);
      if (surahData == null) break;

      final List<Verse> allAyas = surahData.verses;
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
      return state.pages.firstWhere((page) => page.index == pageNumber);
    } catch (_) {
      return null;
    }
  }

  SurahVerses? getSurahData(int surahNumber) {
    try {
      return state.surahs.firstWhere((surah) => surah.id == surahNumber);
    } catch (_) {
      return null;
    }
  }

  /// All verses for a surah (for Topic Map)
  List<Verse> getAllSurahVerses(int surahId) {
    try {
      final surah = state.surahs.firstWhere((s) => s.id == surahId);
      return surah.verses;
    } catch (_) {
      return [];
    }
  }

  /// Ensures verses for this surah are loaded (in case of lazy loading later)
  Future<void> loadVersesForSurah(int surahId) async {
    // Already loaded
    if (state.surahs.any((s) => s.id == surahId && s.verses.isNotEmpty)) {
      return;
    }

    // Load base data if needed
    if (state.surahs.isEmpty || state.pages.isEmpty) {
      await loadData();
    }

    try {
      final surah = state.surahs.firstWhere((s) => s.id == surahId);
      if (surah.verses.isEmpty) {
        final versesData =
            await rootBundle.loadString('assets/data/verses.json');
        final allSurahs = (jsonDecode(versesData) as List<dynamic>)
            .map((s) => SurahVerses.fromJson(s))
            .toList();

        final updatedSurah =
            allSurahs.firstWhere((s) => s.id == surahId, orElse: () => surah);

        final updatedSurahs = List<SurahVerses>.from(state.surahs);
        final index = updatedSurahs.indexWhere((s) => s.id == surahId);
        if (index != -1) {
          updatedSurahs[index] = updatedSurah;
        }

        state = state.copyWith(surahs: updatedSurahs);
      }
    } catch (e) {
      print('Error loading verses for surah $surahId: $e');
    }
  }

  /// Convenience wrapper so callers don't need to touch `state` directly
  String? getSurahNameById(int surahId) {
    try {
      return state.surahs.firstWhere((surah) => surah.id == surahId).name;
    } catch (_) {
      return null;
    }
  }

  /// Returns the mushaf page index where this surah starts (aya = 1)
  int? getSurahStartingPage(int surahId) {
    try {
      for (final page in state.pages) {
        if (page.sura == surahId && page.aya == 1) {
          return page.index;
        }
      }
      return null;
    } catch (e) {
      print('Error finding starting page for Surah $surahId: $e');
      return null;
    }
  }
}

final versesNotifierProvider = NotifierProvider<VersesProvider, VersesState>(
  () => VersesProvider(),
);
