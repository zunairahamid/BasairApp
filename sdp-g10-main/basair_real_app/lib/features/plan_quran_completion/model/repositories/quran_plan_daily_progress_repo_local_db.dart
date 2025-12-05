import 'package:basair_real_app/core/data/database/app_database.dart';
import 'package:basair_real_app/features/plan_quran_completion/model/contracts/quran_plan_daily_progress_repo.dart';
import 'package:basair_real_app/features/plan_quran_completion/model/entities/quran_plan_daily_progress.dart';

class QuranPlanDailyProgressRepoLocalDB
    implements QuranPlanDailyProgressRepository {
  final AppDatabase database;

  QuranPlanDailyProgressRepoLocalDB(this.database);

  @override
  Stream<List<QuranPlanDailyProgress>> getAllDailyProgress() {
    return database.quranPlanDailyProgressDao.getAllDailyProgress();
  }

  @override
  Future<QuranPlanDailyProgress?> getDailyProgressById(int id) {
    return database.quranPlanDailyProgressDao.getDailyProgressById(id);
  }

  @override
  Future<List<QuranPlanDailyProgress>> getDailyProgressByPlanId(int planId) {
    return database.quranPlanDailyProgressDao.getDailyProgressByPlanId(planId);
  }

  @override
  Future<void> addDailyProgress(QuranPlanDailyProgress progress) {
    return database.quranPlanDailyProgressDao.addDailyProgress(progress);
  }

  @override
  Future<void> updateDailyProgress(QuranPlanDailyProgress progress) {
    return database.quranPlanDailyProgressDao.updateDailyProgress(progress);
  }

  @override
  Future<void> deleteDailyProgress(QuranPlanDailyProgress progress) {
    return database.quranPlanDailyProgressDao.deleteDailyProgress(progress);
  }
}
