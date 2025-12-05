import 'package:basair_real_app/features/plan_quran_completion/model/contracts/quran_plan_daily_progress_repo.dart';
import 'package:basair_real_app/features/plan_quran_completion/model/entities/quran_plan_daily_progress.dart';
import 'package:basair_real_app/features/plan_quran_completion/view_model/providers/repo_providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class QuranPlanDailyProgressNotifier
    extends AsyncNotifier<List<QuranPlanDailyProgress>> {
  late final QuranPlanDailyProgressRepository progressRepo;

  @override
  Future<List<QuranPlanDailyProgress>> build() async {
    progressRepo = await ref.read(quranPlanDailyProgressRepoProvider.future);
    progressRepo.getAllDailyProgress().listen((progressList) {
      state = AsyncData(progressList);
    });

    return [];
  }

  // ===========================
  // CRUD METHODS
  // ===========================

  Future<List<QuranPlanDailyProgress>> getDailyProgressByPlanId(
      int planId) async {
    return await progressRepo.getDailyProgressByPlanId(planId);
  }

  Future<void> addDailyProgress(QuranPlanDailyProgress progress) async {
    await progressRepo.addDailyProgress(progress);
  }

  Future<void> updateDailyProgress(QuranPlanDailyProgress progress) async {
    await progressRepo.updateDailyProgress(progress);
  }

  Future<void> deleteDailyProgress(QuranPlanDailyProgress progress) async {
    await progressRepo.deleteDailyProgress(progress);
  }

  Future<QuranPlanDailyProgress?> getDailyProgressById(int id) async {
    return await progressRepo.getDailyProgressById(id);
  }
}

final quranPlanDailyProgressNotifierProvider = AsyncNotifierProvider<
    QuranPlanDailyProgressNotifier, List<QuranPlanDailyProgress>>(
  () => QuranPlanDailyProgressNotifier(),
);
