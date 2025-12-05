import 'package:basair_real_app/core/widgets/basair_app_bar.dart';
import 'package:basair_real_app/features/plan_quran_completion/view_model/providers/quran_plan_daily_progress_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class QuranPlannerDailyProgressScreen extends ConsumerWidget {
  final int planId;

  const QuranPlannerDailyProgressScreen({super.key, required this.planId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dailyProgressAsync =
        ref.watch(quranPlanDailyProgressNotifierProvider);

    return Scaffold(
      backgroundColor: Colors.indigo.shade50,
      appBar: BasairAppBar(
        title: "Quran Daily Progress",
        showBackButton: true,
      ),
      body: dailyProgressAsync.when(
        data: (progressList) {
          final planProgress =
              progressList.where((p) => p.planId == planId).toList();

          if (planProgress.isEmpty) {
            return const Center(
              child: Text(
                "No daily progress yet.",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: planProgress.length,
            itemBuilder: (context, index) {
              final progress = planProgress[index];

              return Card(
                color: Colors.indigo[200],
                margin: const EdgeInsets.symmetric(vertical: 6),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(25),
                ),
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Date : ${progress.date}",
                        style: const TextStyle(
                          fontSize: 25,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'CrimsonText',
                        ),
                      ),
                      const SizedBox(height: 10),
                      Container(
                        padding:
                            EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.indigo[100],
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.menu_book_rounded, size: 20),
                            const SizedBox(width: 6),
                            Text(
                              "Read ${progress.pagesRead} Pages",
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) =>
            Center(child: Text("Error loading progress: $error")),
      ),
    );
  }
}
