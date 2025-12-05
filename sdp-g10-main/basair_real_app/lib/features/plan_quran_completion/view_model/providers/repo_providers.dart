import 'package:basair_real_app/core/data/database/database_provider.dart';
import 'package:basair_real_app/features/plan_quran_completion/model/contracts/quran_plan_daily_progress_repo.dart';
import 'package:basair_real_app/features/plan_quran_completion/model/contracts/quran_plan_repo.dart';
import 'package:basair_real_app/features/plan_quran_completion/model/repositories/quran_plan_daily_progress_repo_local_db.dart';
import 'package:basair_real_app/features/plan_quran_completion/model/repositories/quran_plan_repo_local_db.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final quranPlanRepoProvider = FutureProvider<QuranPlanRepository>((ref) async {
  final database = await ref.watch(databaseProvider.future);
  return QuranPlanRepoLocalDB(database);
});

final quranPlanDailyProgressRepoProvider =
    FutureProvider<QuranPlanDailyProgressRepository>((ref) async {
  final database = await ref.watch(databaseProvider.future);
  return QuranPlanDailyProgressRepoLocalDB(database);
});
