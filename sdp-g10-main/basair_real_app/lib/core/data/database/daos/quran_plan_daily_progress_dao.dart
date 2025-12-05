import 'package:basair_real_app/features/plan_quran_completion/model/entities/quran_plan_daily_progress.dart';
import 'package:floor/floor.dart';

@dao
abstract class QuranPlanDailyProgressDao {
  @Query("SELECT * FROM quran_plan_daily_progress")
  Stream<List<QuranPlanDailyProgress>> getAllDailyProgress();

  @Query("SELECT * FROM quran_plan_daily_progress")
  Future<List<QuranPlanDailyProgress>> getDailyProgressList();

  @Query("SELECT * FROM quran_plan_daily_progress WHERE id=:id")
  Future<QuranPlanDailyProgress?> getDailyProgressById(int id);

  @Query("SELECT * FROM quran_plan_daily_progress WHERE planId=:planId")
  Future<List<QuranPlanDailyProgress>> getDailyProgressByPlanId(int planId);

  @insert
  Future<void> addDailyProgress(QuranPlanDailyProgress progress);

  @update
  Future<void> updateDailyProgress(QuranPlanDailyProgress progress);

  @delete
  Future<void> deleteDailyProgress(QuranPlanDailyProgress progress);

  @Insert(onConflict: OnConflictStrategy.replace)
  Future<void> upsertDailyProgress(QuranPlanDailyProgress progress);

  @insert
  Future<void> insertDailyProgressList(List<QuranPlanDailyProgress> progresses);

  @Query("DELETE FROM quran_plan_daily_progress")
  Future<void> deleteAllDailyProgress();
}
