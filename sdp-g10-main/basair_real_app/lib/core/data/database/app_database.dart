import 'dart:async';
import 'package:basair_real_app/core/data/database/daos/quran_plan_daily_progress_dao.dart';
import 'package:basair_real_app/core/data/database/daos/quran_plan_dao.dart';
import 'package:basair_real_app/features/plan_quran_completion/model/entities/quran_plan.dart';
import 'package:basair_real_app/features/plan_quran_completion/model/entities/quran_plan_daily_progress.dart';
import 'package:sqflite/sqflite.dart' as sqflite;
import 'package:floor/floor.dart';
part 'app_database.g.dart';

@Database(version: 1, entities: [QuranPlan, QuranPlanDailyProgress])
abstract class AppDatabase extends FloorDatabase {
  QuranPlanDao get quranPlanDao;
  QuranPlanDailyProgressDao get quranPlanDailyProgressDao;
}
