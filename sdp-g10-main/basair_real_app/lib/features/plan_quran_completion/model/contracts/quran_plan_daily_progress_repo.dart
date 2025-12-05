import 'package:basair_real_app/features/plan_quran_completion/model/entities/quran_plan_daily_progress.dart';

abstract class QuranPlanDailyProgressRepository {
  Stream<List<QuranPlanDailyProgress>> getAllDailyProgress();
  Future<QuranPlanDailyProgress?> getDailyProgressById(int id);
  Future<List<QuranPlanDailyProgress>> getDailyProgressByPlanId(int planId);
  Future<void> addDailyProgress(QuranPlanDailyProgress progress);
  Future<void> updateDailyProgress(QuranPlanDailyProgress progress);
  Future<void> deleteDailyProgress(QuranPlanDailyProgress progress);
}
