import 'package:basair_real_app/core/data/database/app_database.dart';
import 'package:basair_real_app/features/plan_quran_completion/model/contracts/quran_plan_repo.dart';
import 'package:basair_real_app/features/plan_quran_completion/model/entities/quran_plan.dart';

class QuranPlanRepoLocalDB implements QuranPlanRepository {
  final AppDatabase database;

  QuranPlanRepoLocalDB(this.database);

  @override
  Stream<List<QuranPlan>> getPlans() {
    return database.quranPlanDao.getPlans();
  }

  @override
  Future<QuranPlan?> getPlanById(int id) {
    return database.quranPlanDao.getPlanById(id);
  }

  @override
  Future<void> addPlan(QuranPlan plan) {
    return database.quranPlanDao.addPlan(plan);
  }

  @override
  Future<void> updatePlan(QuranPlan plan) {
    return database.quranPlanDao.updatePlan(plan);
  }

  @override
  Future<void> deletePlan(QuranPlan plan) {
    return database.quranPlanDao.deletePlan(plan);
  }
}
