import 'package:basair_real_app/features/plan_quran_completion/model/entities/quran_plan.dart';

abstract class QuranPlanRepository {
  Stream<List<QuranPlan>> getPlans();
  Future<QuranPlan?> getPlanById(int planId);
  Future<void> addPlan(QuranPlan plan);
  Future<void> updatePlan(QuranPlan plan);
  Future<void> deletePlan(QuranPlan plan);
}
