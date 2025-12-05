import 'package:basair_real_app/features/plan_quran_completion/model/entities/quran_plan.dart';
import 'package:floor/floor.dart';

@dao
abstract class QuranPlanDao {
  @Query("SELECT * FROM quran_plans")
  Stream<List<QuranPlan>> getPlans();

  @Query("SELECT * FROM quran_plans")
  Future<List<QuranPlan>> getAllPlans();

  @Query("SELECT * FROM quran_plans WHERE planId = :id")
  Future<QuranPlan?> getPlanById(int id);

  @insert
  Future<void> addPlan(QuranPlan plan);

  @update
  Future<void> updatePlan(QuranPlan plan);

  @delete
  Future<void> deletePlan(QuranPlan plan);

  @Insert(onConflict: OnConflictStrategy.replace)
  Future<void> upsertPlan(QuranPlan plan);

  @insert
  Future<void> insertPlans(List<QuranPlan> plans);

  @Query("DELETE FROM quran_plans")
  Future<void> deleteAllPlans();
}
