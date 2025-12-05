import 'dart:convert';
import 'package:flutter/services.dart';
import '../../../features/plan_quran_completion/model/entities/quran_plan.dart';
import '../../../features/plan_quran_completion/model/entities/quran_plan_daily_progress.dart';
import 'app_database.dart';

class QuranDatabaseSeeder {
  /// Seeds the database if empty
  static Future<void> seedDatabase(AppDatabase database) async {
    try {
      final planCount = await database.quranPlanDao.getAllPlans();

      if (planCount.isNotEmpty) {
        return; // Already seeded
      }

      await _seedQuranPlans(database);
      await _seedDailyProgress(database);
    } catch (e) {
      rethrow;
    }
  }

  static Future<void> _seedQuranPlans(AppDatabase database) async {
    final jsonString =
        await rootBundle.loadString('assets/data/quran_plans.json');
    final List<dynamic> jsonData = json.decode(jsonString);
    final plans = jsonData.map((json) => QuranPlan.fromJson(json)).toList();
    await database.quranPlanDao.insertPlans(plans);
  }

  static Future<void> _seedDailyProgress(AppDatabase database) async {
    final jsonString =
        await rootBundle.loadString('assets/data/quran_plan_progress.json');
    final List<dynamic> jsonData = json.decode(jsonString);
    final progressList =
        jsonData.map((json) => QuranPlanDailyProgress.fromJson(json)).toList();
    await database.quranPlanDailyProgressDao
        .insertDailyProgressList(progressList);
  }

  /// Clears both tables
  static Future<void> clearDatabase(AppDatabase database) async {
    await database.quranPlanDailyProgressDao.deleteAllDailyProgress();
    await database.quranPlanDao.deleteAllPlans();
  }
}
