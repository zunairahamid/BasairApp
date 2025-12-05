import 'dart:async';
import 'package:basair_real_app/core/providers/juzs_provider.dart';
import 'package:basair_real_app/core/providers/surahs_provider.dart';
import 'package:basair_real_app/core/widgets/basair_dialog.dart';
import 'package:basair_real_app/features/plan_quran_completion/view_model/providers/quran_plan_provider.dart';
import 'package:basair_real_app/features/plan_quran_completion/view_model/providers/quran_plan_daily_progress_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../widgets/plan_card.dart';
import 'package:go_router/go_router.dart';

// We need to update the target days everyday (after midnight)
class QuranPlannerDashboard extends StatefulWidget {
  const QuranPlannerDashboard({super.key});

  @override
  State<QuranPlannerDashboard> createState() => _QuranPlannerDashboardState();
}

class _QuranPlannerDashboardState extends State<QuranPlannerDashboard> {
  late DateTime dateToday;
  Timer? timerForMidnight;

  @override
  void initState() {
    super.initState();
    dateToday = DateTime.now();
    scheduleMidnightUpdateForTargetDays();
  }

  void scheduleMidnightUpdateForTargetDays() {
    final now = DateTime.now();
    final nextMidnight =
        DateTime(now.year, now.month, now.day).add(const Duration(days: 1));
    final durationUntilMidnight = nextMidnight.difference(now);

    timerForMidnight = Timer(durationUntilMidnight, () {
      if (mounted) {
        setState(() {
          dateToday = DateTime.now();
        });
        scheduleMidnightUpdateForTargetDays();
      }
    });
  }

  @override
  void dispose() {
    timerForMidnight?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return QuranPlannerDashboardScreen(today: dateToday);
  }
}

class QuranPlannerDashboardScreen extends ConsumerWidget {
  final DateTime today;

  const QuranPlannerDashboardScreen({super.key, required this.today});

  DateTime getDate(String date) => DateTime.tryParse(date) ?? today;

  int daysPassedSincePlanCreation(String startDate) {
    final start = getDate(startDate);
    return today.difference(start).inDays;
  }

  int daysRemainingUntilPlanFinishes(String startDate, int targetDays) {
    final remainingDays = targetDays - daysPassedSincePlanCreation(startDate);
    return remainingDays < 0 ? 0 : remainingDays;
  }

  bool isPlanOverdue(String startDate, int targetDays) =>
      daysPassedSincePlanCreation(startDate) >= targetDays;

  Future<Map<String, int>> getPageRange(
      WidgetRef ref, String planType, int? surahId, int? juzId) async {
    int? startPage;
    int? endPage;

    if (planType.toLowerCase() == 'surah' && surahId != null) {
      final surahs = ref.read(surahProvider);
      if (surahs.isEmpty) {
        await ref.read(surahProvider.notifier).initializeState();
        await Future.delayed(const Duration(milliseconds: 200));
      }
      final pages = ref.read(surahProvider.notifier).getSurahPages(surahId);
      if (pages != null) {
        startPage = pages['startPage'];
        endPage = pages['endPage'];
      }
    } else if (planType.toLowerCase() == 'juz' && juzId != null) {
      final juzNotifier = ref.read(juzNotifierProvider.notifier);
      await juzNotifier.loadJuz();
      final pages = juzNotifier.getJuzPages(juzId);
      if (pages != null) {
        startPage = pages['startPage'];
        endPage = pages['endPage'];
      }
    }

    return {'startPage': startPage ?? 0, 'endPage': endPage ?? 0};
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final plansDataAsync = ref.watch(quranPlanNotifierProvider);

    return Scaffold(
      backgroundColor: Colors.indigo.shade50,
      body: plansDataAsync.when(
        data: (plans) {
          if (plans.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.book_outlined,
                      size: 100, color: Colors.indigo.shade200),
                  const SizedBox(height: 20),
                  const Text(
                    'No Plans Created',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'CrimsonText',
                    ),
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    'Create your first plan to get started',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'CrimsonText',
                    ),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: plans.length,
            itemBuilder: (context, index) {
              final plan = plans[index];
              final daysRemaining = daysRemainingUntilPlanFinishes(
                  plan.startDate, plan.targetDays);
              final isOverdue = isPlanOverdue(plan.startDate, plan.targetDays);
              return Padding(
                padding: EdgeInsets.symmetric(vertical: 6),
                child: PlanCard(
                  plan: plan,
                  daysRemaining: daysRemaining,
                  isPlanOverdue: isOverdue,
                  onViewProgress: () {
                    context.push('/quranPlannerDailyProgress/${plan.planId}');
                  },
                  onDelete: () {
                    BasairDialog.show(
                      context: context,
                      title: 'Delete Plan',
                      message:
                          'Are you sure you want to delete "${plan.planName}"?',
                      icon: Icons.delete_forever,
                      iconColor: Colors.black,
                      actions: [
                        {'Cancel': () => context.pop()},
                        {
                          'Delete': () async {
                            await ref
                                .read(quranPlanNotifierProvider.notifier)
                                .deletePlan(plan);
                            if (context.mounted) context.pop();
                          }
                        }
                      ],
                    );
                  },
                  onTap: () async {
                    if (plan.planId <= 0) return;

                    final dateToday = today;
                    final dateStart = getDate(plan.startDate);
                    final daysPassed = dateToday.difference(dateStart).inDays;

                    // 1️⃣ Check if plan is complete
                    if (plan.isPlanComplete) {
                      BasairDialog.show(
                        context: context,
                        title: 'Plan Completed',
                        message:
                            'You have already completed the plan "${plan.planName}".',
                        icon: Icons.emoji_events_rounded,
                        iconColor: Colors.amber.shade200,
                        actions: [
                          {'Close': () => context.pop()},
                        ],
                      );
                      return;
                    }

                    // Check if we need to add more target days (extension)
                    final isOverdue = daysPassed >= plan.targetDays;
                    final isTargetDayOne = plan.targetDays == 1;
                    final allowExtension = isOverdue || isTargetDayOne;

                    showDialog(
                      context: context,
                      barrierDismissible: false,
                      builder: (_) =>
                          const Center(child: CircularProgressIndicator()),
                    );

                    try {
                      // Refresh to get the latest plan information
                      final latestPlanList =
                          await ref.read(quranPlanNotifierProvider.future);
                      var latestPlan = latestPlanList.firstWhere(
                        (p) => p.planId == plan.planId,
                      );

                      final pages = await getPageRange(
                        ref,
                        latestPlan.planType,
                        latestPlan.surahId,
                        latestPlan.juzId,
                      );
                      final startPage = pages['startPage']!;
                      final endPage = pages['endPage']!;
                      final totalPages = endPage - startPage + 1;

                      await ref
                          .read(quranPlanDailyProgressNotifierProvider.future);
                      final progressNotifier = ref.read(
                          quranPlanDailyProgressNotifierProvider.notifier);
                      final dailyProgressList = await progressNotifier
                          .getDailyProgressByPlanId(plan.planId);

                      final pagesRead = dailyProgressList
                          .fold<int>(0, (sum, e) => sum + e.pagesRead)
                          .clamp(0, totalPages);
                      final pagesLeft = totalPages - pagesRead;

                      if (!context.mounted) return;
                      context.pop();

                      final targetDaysExtensionController =
                          TextEditingController();

                      if (allowExtension && pagesLeft > 0) {
                        // Show dialog for the user to add more target days
                        showDialog(
                          context: context,
                          barrierDismissible: false,
                          builder: (ctx) => AlertDialog(
                            title: Text(latestPlan.planName),
                            content: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                    "You can extend the target days to complete your plan."),
                                const SizedBox(height: 12),
                                TextField(
                                  controller: targetDaysExtensionController,
                                  keyboardType: TextInputType.number,
                                  decoration: InputDecoration(
                                    labelText: "Extra Days",
                                    border: OutlineInputBorder(),
                                  ),
                                ),
                              ],
                            ),
                            actions: [
                              TextButton(
                                onPressed: () => context.pop(),
                                child: Text("Close"),
                              ),
                              TextButton(
                                onPressed: () async {
                                  final extraDays = int.tryParse(
                                      targetDaysExtensionController.text);
                                  if (extraDays != null && extraDays > 0) {
                                    final updatedPlan = latestPlan.copyWith(
                                      targetDays:
                                          latestPlan.targetDays + extraDays,
                                    );
                                    await ref
                                        .read(
                                            quranPlanNotifierProvider.notifier)
                                        .updatePlan(updatedPlan);
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(
                                            "Plan extended by $extraDays days successfully!"),
                                      ),
                                    );
                                  }
                                  context.pop();
                                  context.push(
                                      '/quranPlannerViewer/${latestPlan.planId}');
                                },
                                child: const Text("Continue"),
                              ),
                            ],
                          ),
                        );
                      } else {
                        // Show progress to user (total pages, pages read and pages left)
                        if (pagesLeft == 0 && !latestPlan.isPlanComplete) {
                          final updatedPlan =
                              latestPlan.copyWith(isPlanComplete: true);
                          await ref
                              .read(quranPlanNotifierProvider.notifier)
                              .updatePlan(updatedPlan);
                          latestPlan = updatedPlan;
                        }
                        BasairDialog.show(
                          context: context,
                          title: latestPlan.planName,
                          icon: Icons.menu_book_outlined,
                          message: "Total Pages: $totalPages\n"
                              "Pages Read: $pagesRead\n"
                              "Pages Left: $pagesLeft\n\n"
                              "${pagesLeft > 0 ? "Keep Going" : "Plan Completed"}",
                          actions: [
                            {'Close': () => context.pop()},
                            if (!latestPlan.isPlanComplete)
                              {
                                'Continue': () {
                                  context.pop();
                                  context.push(
                                      '/quranPlannerViewer/${latestPlan.planId}');
                                }
                              }
                          ],
                        );
                      }
                    } catch (e) {
                      if (context.mounted) context.pop();
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Error Loading Plan: $e')),
                      );
                    }
                  },
                ),
              );
            },
          );
        },
        loading: () => CircularProgressIndicator(),
        error: (error, stack) => Text('Error loading plans: $error'),
      ),
    );
  }
}
