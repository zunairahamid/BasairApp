import 'package:basair_real_app/core/models/juz.dart';
import 'package:basair_real_app/core/repositories/juzs_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';


class JuzNotifier extends AsyncNotifier<List<Juz>> {
  final JuzRepository juzRepository = JuzRepository();

  @override
  Future<List<Juz>> build() async {
    return await loadJuz();
  }

  Future<List<Juz>> loadJuz() async {
    return await juzRepository.getJuz();
  }

  Map<String, int>? getJuzPages(int juzIndex) {
    final list = state.value;
    if (list == null || list.isEmpty) return null;

    final index = list.indexWhere((j) => j.index == juzIndex);
    if (index == -1) return null;

    final startPage = list[index].page;
    final endPage = (index + 1 < list.length) ? list[index + 1].page - 1 : 604;

    return {'startPage': startPage, 'endPage': endPage};
  }

  List<Map<String, int>> getJuzQuarters(int juzIndex) {
    final pages = getJuzPages(juzIndex);
    if (pages == null) return [];

    final start = pages['startPage']!;
    final end = pages['endPage']!;
    final totalPages = end - start + 1;

    final pagesPerQuarter = (totalPages / 8).ceil();
    List<Map<String, int>> quarters = [];

    int currentStart = start;
    for (int i = 0; i < 8 && currentStart <= end; i++) {
      int currentEnd = currentStart + pagesPerQuarter - 1;
      if (currentEnd > end) currentEnd = end;

      quarters.add({'startPage': currentStart, 'endPage': currentEnd});
      currentStart = currentEnd + 1;
    }

    return quarters;
  }

  int? getQuarterStartPage(int juzIndex, int quarterIndex) {
    final quarters = getJuzQuarters(juzIndex);
    if (quarterIndex < 0 || quarterIndex >= quarters.length) return null;
    return quarters[quarterIndex]['startPage'];
  }
}

final juzNotifierProvider =
    AsyncNotifierProvider<JuzNotifier, List<Juz>>(() => JuzNotifier());
