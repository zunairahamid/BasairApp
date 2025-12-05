import 'package:basair_real_app/features/plan_quran_completion/model/contracts/quran_plan_repo.dart';
import 'package:basair_real_app/features/plan_quran_completion/model/entities/quran_plan.dart';
import 'package:basair_real_app/features/plan_quran_completion/view_model/providers/repo_providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class QuranPlanNotifier extends AsyncNotifier<List<QuranPlan>> {
  late final QuranPlanRepository planRepo;

  @override
  Future<List<QuranPlan>> build() async {
    planRepo = await ref.read(quranPlanRepoProvider.future);

    planRepo.getPlans().listen((plans) {
      state = AsyncData(plans);
    });

    return [];
  }

  Future<void> addPlan(QuranPlan plan) async {
    try {
      await planRepo.addPlan(plan);
    } catch (e) {
      rethrow;
    }
  }

  Future<void> updatePlan(QuranPlan plan) async {
    try {
      await planRepo.updatePlan(plan);
    } catch (e) {
      rethrow;
    }
  }

  Future<void> deletePlan(QuranPlan plan) async {
    try {
      await planRepo.deletePlan(plan);
    } catch (e) {
      rethrow;
    }
  }

  Future<QuranPlan?> getPlanById(int id) async {
    return await planRepo.getPlanById(id);
  }
}

final quranPlanNotifierProvider =
    AsyncNotifierProvider<QuranPlanNotifier, List<QuranPlan>>(
  () => QuranPlanNotifier(),
);
