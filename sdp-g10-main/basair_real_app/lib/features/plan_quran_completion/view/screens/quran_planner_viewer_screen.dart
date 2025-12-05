import 'package:basair_real_app/core/providers/juzs_provider.dart';
import 'package:basair_real_app/core/providers/surahs_provider.dart';
import 'package:basair_real_app/core/providers/verses_provider.dart';
import 'package:basair_real_app/core/widgets/basair_app_bar.dart';
import 'package:basair_real_app/features/plan_quran_completion/model/entities/quran_plan_daily_progress.dart';
import 'package:basair_real_app/features/plan_quran_completion/view_model/providers/quran_plan_daily_progress_provider.dart';
import 'package:basair_real_app/features/plan_quran_completion/view_model/providers/quran_plan_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class QuranPlannerViewerScreen extends ConsumerStatefulWidget {
  final int planId;

  const QuranPlannerViewerScreen({
    super.key,
    required this.planId,
  });

  @override
  ConsumerState<QuranPlannerViewerScreen> createState() =>
      _QuranPlannerViewerScreenState();
}

class _QuranPlannerViewerScreenState
    extends ConsumerState<QuranPlannerViewerScreen> {
  int? startPage;
  int? endPage;
  int currentPage = 1;
  bool loading = true;
  bool pageLoading = false;
  String? sectionName;
  String? errorMessage;
  int totalPagesRead = 0;
  String? planType;
  int? surahId;
  int? juzId;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      initializePlan();
    });
  }

  Future<void> initializePlan() async {
    setState(() => loading = true);

    try {
      final plansDataAsync = ref.read(quranPlanNotifierProvider);

      await plansDataAsync.when(
        data: (plans) async {
          final plan = plans.firstWhere(
            (p) => p.planId == widget.planId,
          );
          planType = plan.planType;
          surahId = plan.surahId;
          juzId = plan.juzId;
        },
        loading: () async {
          await Future.delayed(const Duration(seconds: 1));
          throw Exception('Plans are still loading');
        },
        error: (err, stack) =>
            throw Exception('There was an error loading the plans: $err'),
      );

      if (planType?.toLowerCase() == 'surah' && surahId != null) {
        await loadSurahPages(surahId!);
      } else if (planType?.toLowerCase() == 'juz' && juzId != null) {
        await loadJuzPages(juzId!);
      } else {
        throw Exception('The plan type is invalid or plan ID is missing');
      }

      if (startPage == null || endPage == null) {
        throw Exception('Could not get the page range');
      }

      try {
        await ref.read(quranPlanDailyProgressNotifierProvider.future);
        final progressNotifier =
            ref.read(quranPlanDailyProgressNotifierProvider.notifier);
        final dailyProgressList =
            await progressNotifier.getDailyProgressByPlanId(widget.planId);

        totalPagesRead = dailyProgressList.fold<int>(
          0,
          (sum, entry) => sum + entry.pagesRead,
        );
      } catch (e) {
        totalPagesRead = 0;
      }

      final totalPlanPages = endPage! - startPage! + 1;
      totalPagesRead = totalPagesRead.clamp(0, totalPlanPages);

      if (totalPagesRead >= totalPlanPages) {
        currentPage = endPage!;
      } else {
        currentPage = (startPage! + totalPagesRead).clamp(startPage!, endPage!);
      }

      await loadPageVerses(currentPage);
    } catch (e) {
      setState(() {
        errorMessage = 'Error: $e';
      });
    }

    if (mounted) setState(() => loading = false);
  }

  Future<void> loadSurahPages(int surahId) async {
    final surahs = ref.read(surahProvider);
    if (surahs.isEmpty) {
      await ref.read(surahProvider.notifier).initializeState();
      await Future.delayed(const Duration(milliseconds: 500));
    }

    final updatedSurahs = ref.read(surahProvider);
    final pages = ref.read(surahProvider.notifier).getSurahPages(surahId);

    if (pages != null) {
      startPage = pages['startPage'];
      endPage = pages['endPage'];
      final surah = updatedSurahs.firstWhere(
        (s) => s.id == surahId,
      );
      sectionName = surah.name;
    } else {
      throw Exception('Surah with ID: $surahId was not found');
    }
  }

  Future<void> loadJuzPages(int juzId) async {
    final juzNotifier = ref.read(juzNotifierProvider.notifier);
    final pages = juzNotifier.getJuzPages(juzId);

    if (pages != null) {
      startPage = pages['startPage'];
      endPage = pages['endPage'];
    } else {
      throw Exception('Juz with ID: $juzId was not found');
    }
  }

  Future<void> loadPageVerses(int pageNumber) async {
    if (startPage == null || endPage == null) return;
    if (pageNumber < startPage! || pageNumber > endPage!) return;

    await ref
        .read(versesNotifierProvider.notifier)
        .loadVersesByPage(pageNumber);
  }

  Future<void> loadPage(int pageNumber) async {
    if (pageNumber < startPage! || pageNumber > endPage!) return;
    setState(() => pageLoading = true);
    await loadPageVerses(pageNumber);
    if (!mounted) return;
    setState(() {
      currentPage = pageNumber;
      pageLoading = false;
    });
  }

  Future<void> saveDailyProgress() async {
    if (!mounted) return;
    if (startPage == null || endPage == null) return;

    final progressNotifier =
        ref.read(quranPlanDailyProgressNotifierProvider.notifier);

    final dailyProgressList =
        await progressNotifier.getDailyProgressByPlanId(widget.planId);

    final totalPagesReadSoFar = dailyProgressList.fold<int>(
      0,
      (sum, entry) => sum + entry.pagesRead,
    );

    final pageIndexInPlan = currentPage - startPage! + 1;

    // Only save progress if current page not yet counted
    if (pageIndexInPlan > totalPagesReadSoFar) {
      final today = DateTime.now();
      final todayDateString =
          '${today.year}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}';

      final todayProgress = QuranPlanDailyProgress(
        planId: widget.planId,
        date: todayDateString,
        pagesRead: 1,
      );

      await progressNotifier.addDailyProgress(todayProgress);
      totalPagesRead += 1;
    }
  }

  void goToNextPage() async {
    if (endPage == null) return;
    await saveDailyProgress();
    if (currentPage < endPage!) {
      await loadPage(currentPage + 1);
    }
  }

  void goToPreviousPage() async {
    if (startPage != null && currentPage > startPage!) {
      await loadPage(currentPage - 1);
    }
  }

  bool isNewSurahStart(int surahId) {
    final surahStartPage =
        ref.read(versesNotifierProvider.notifier).getSurahStartingPage(surahId);
    return surahStartPage == currentPage;
  }

  @override
  Widget build(BuildContext context) {
    final versesState = ref.watch(versesNotifierProvider);
    final pageVerses = versesState.currentPageVerses;
    final totalPlanPages =
        (endPage != null && startPage != null) ? endPage! - startPage! + 1 : 0;

    final currentPageInPlan = totalPlanPages > 0
        ? (currentPage - (startPage ?? 1) + 1).clamp(1, totalPlanPages)
        : 1;

    if (loading) {
      return Scaffold(
        backgroundColor: Colors.indigo[50],
        appBar: BasairAppBar(title: 'Loading Verses', showBackButton: true),
        body: const Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    return Scaffold(
      backgroundColor: Colors.indigo[50],
      appBar: BasairAppBar(title: 'Quran Viewer', showBackButton: true),
      body: pageLoading
          ? const Center(child: CircularProgressIndicator())
          : pageVerses.isEmpty
              ? const Center(child: Text('No Verses Found'))
              : ListView(
                  padding: EdgeInsets.all(16),
                  children: pageVerses.entries.expand<Widget>((entry) {
                    final surahIndex = entry.key;
                    final verses = entry.value;

                    return [
                      if (verses.isNotEmpty && isNewSurahStart(surahIndex))
                        Container(
                          margin: EdgeInsets.symmetric(vertical: 12),
                          padding: EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(20),
                            color: Colors.indigo[200],
                            border: Border.all(color: Colors.black, width: 2),
                          ),
                          child: Center(
                            child: Text(
                              versesState.getSurahNameById(surahIndex) ?? '',
                              style: const TextStyle(
                                fontFamily: 'Hafs',
                                fontSize: 28,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ...verses.map(
                        (verse) => Padding(
                          padding: EdgeInsets.symmetric(vertical: 6),
                          child: Text(
                            '${verse.text} \u06DD',
                            textAlign: TextAlign.center,
                            textDirection: TextDirection.rtl,
                            style: TextStyle(
                              fontFamily: 'Hafs',
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                              height: 2,
                              color: Colors.black,
                            ),
                          ),
                        ),
                      ),
                    ];
                  }).toList(),
                ),
      bottomNavigationBar: SafeArea(
        child: Container(
          color: Colors.indigo.shade50,
          padding: EdgeInsets.symmetric(vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              IconButton(
                icon: Icon(
                  Icons.arrow_back_ios,
                  size: 32,
                ),
                onPressed: currentPage > startPage! ? goToPreviousPage : null,
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                decoration: BoxDecoration(
                  color: Colors.indigo.shade200,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.black, width: 2),
                ),
                child: Text(
                  '$currentPageInPlan / $totalPlanPages',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Lato',
                  ),
                ),
              ),
              currentPage < endPage!
                  ? IconButton(
                      icon: Icon(Icons.arrow_forward_ios, size: 32),
                      onPressed: goToNextPage,
                    )
                  : IconButton(
                      icon: Icon(Icons.check_circle,
                          size: 36, color: Colors.indigo.shade200),
                      onPressed: () async {
                        await saveDailyProgress();
                        context.go('/quranPlanner');
                      },
                    ),
            ],
          ),
        ),
      ),
    );
  }
}
