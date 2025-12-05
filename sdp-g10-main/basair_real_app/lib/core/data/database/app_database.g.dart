// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// **************************************************************************
// FloorGenerator
// **************************************************************************

abstract class $AppDatabaseBuilderContract {
  /// Adds migrations to the builder.
  $AppDatabaseBuilderContract addMigrations(List<Migration> migrations);

  /// Adds a database [Callback] to the builder.
  $AppDatabaseBuilderContract addCallback(Callback callback);

  /// Creates the database and initializes it.
  Future<AppDatabase> build();
}

// ignore: avoid_classes_with_only_static_members
class $FloorAppDatabase {
  /// Creates a database builder for a persistent database.
  /// Once a database is built, you should keep a reference to it and re-use it.
  static $AppDatabaseBuilderContract databaseBuilder(String name) =>
      _$AppDatabaseBuilder(name);

  /// Creates a database builder for an in memory database.
  /// Information stored in an in memory database disappears when the process is killed.
  /// Once a database is built, you should keep a reference to it and re-use it.
  static $AppDatabaseBuilderContract inMemoryDatabaseBuilder() =>
      _$AppDatabaseBuilder(null);
}

class _$AppDatabaseBuilder implements $AppDatabaseBuilderContract {
  _$AppDatabaseBuilder(this.name);

  final String? name;

  final List<Migration> _migrations = [];

  Callback? _callback;

  @override
  $AppDatabaseBuilderContract addMigrations(List<Migration> migrations) {
    _migrations.addAll(migrations);
    return this;
  }

  @override
  $AppDatabaseBuilderContract addCallback(Callback callback) {
    _callback = callback;
    return this;
  }

  @override
  Future<AppDatabase> build() async {
    final path = name != null
        ? await sqfliteDatabaseFactory.getDatabasePath(name!)
        : ':memory:';
    final database = _$AppDatabase();
    database.database = await database.open(
      path,
      _migrations,
      _callback,
    );
    return database;
  }
}

class _$AppDatabase extends AppDatabase {
  _$AppDatabase([StreamController<String>? listener]) {
    changeListener = listener ?? StreamController<String>.broadcast();
  }

  QuranPlanDao? _quranPlanDaoInstance;

  QuranPlanDailyProgressDao? _quranPlanDailyProgressDaoInstance;

  Future<sqflite.Database> open(
    String path,
    List<Migration> migrations, [
    Callback? callback,
  ]) async {
    final databaseOptions = sqflite.OpenDatabaseOptions(
      version: 1,
      onConfigure: (database) async {
        await database.execute('PRAGMA foreign_keys = ON');
        await callback?.onConfigure?.call(database);
      },
      onOpen: (database) async {
        await callback?.onOpen?.call(database);
      },
      onUpgrade: (database, startVersion, endVersion) async {
        await MigrationAdapter.runMigrations(
            database, startVersion, endVersion, migrations);

        await callback?.onUpgrade?.call(database, startVersion, endVersion);
      },
      onCreate: (database, version) async {
        await database.execute(
            'CREATE TABLE IF NOT EXISTS `quran_plans` (`planId` INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL, `planName` TEXT NOT NULL, `planType` TEXT NOT NULL, `surahId` INTEGER, `juzId` INTEGER, `startDate` TEXT NOT NULL, `targetDays` INTEGER NOT NULL, `isPlanComplete` INTEGER NOT NULL)');
        await database.execute(
            'CREATE TABLE IF NOT EXISTS `quran_plan_daily_progress` (`id` INTEGER PRIMARY KEY AUTOINCREMENT, `planId` INTEGER NOT NULL, `date` TEXT NOT NULL, `pagesRead` INTEGER NOT NULL, FOREIGN KEY (`planId`) REFERENCES `quran_plans` (`planId`) ON UPDATE NO ACTION ON DELETE CASCADE)');

        await callback?.onCreate?.call(database, version);
      },
    );
    return sqfliteDatabaseFactory.openDatabase(path, options: databaseOptions);
  }

  @override
  QuranPlanDao get quranPlanDao {
    return _quranPlanDaoInstance ??= _$QuranPlanDao(database, changeListener);
  }

  @override
  QuranPlanDailyProgressDao get quranPlanDailyProgressDao {
    return _quranPlanDailyProgressDaoInstance ??=
        _$QuranPlanDailyProgressDao(database, changeListener);
  }
}

class _$QuranPlanDao extends QuranPlanDao {
  _$QuranPlanDao(
    this.database,
    this.changeListener,
  )   : _queryAdapter = QueryAdapter(database, changeListener),
        _quranPlanInsertionAdapter = InsertionAdapter(
            database,
            'quran_plans',
            (QuranPlan item) => <String, Object?>{
                  'planId': item.planId,
                  'planName': item.planName,
                  'planType': item.planType,
                  'surahId': item.surahId,
                  'juzId': item.juzId,
                  'startDate': item.startDate,
                  'targetDays': item.targetDays,
                  'isPlanComplete': item.isPlanComplete ? 1 : 0
                },
            changeListener),
        _quranPlanUpdateAdapter = UpdateAdapter(
            database,
            'quran_plans',
            ['planId'],
            (QuranPlan item) => <String, Object?>{
                  'planId': item.planId,
                  'planName': item.planName,
                  'planType': item.planType,
                  'surahId': item.surahId,
                  'juzId': item.juzId,
                  'startDate': item.startDate,
                  'targetDays': item.targetDays,
                  'isPlanComplete': item.isPlanComplete ? 1 : 0
                },
            changeListener),
        _quranPlanDeletionAdapter = DeletionAdapter(
            database,
            'quran_plans',
            ['planId'],
            (QuranPlan item) => <String, Object?>{
                  'planId': item.planId,
                  'planName': item.planName,
                  'planType': item.planType,
                  'surahId': item.surahId,
                  'juzId': item.juzId,
                  'startDate': item.startDate,
                  'targetDays': item.targetDays,
                  'isPlanComplete': item.isPlanComplete ? 1 : 0
                },
            changeListener);

  final sqflite.DatabaseExecutor database;

  final StreamController<String> changeListener;

  final QueryAdapter _queryAdapter;

  final InsertionAdapter<QuranPlan> _quranPlanInsertionAdapter;

  final UpdateAdapter<QuranPlan> _quranPlanUpdateAdapter;

  final DeletionAdapter<QuranPlan> _quranPlanDeletionAdapter;

  @override
  Stream<List<QuranPlan>> getPlans() {
    return _queryAdapter.queryListStream('SELECT * FROM quran_plans',
        mapper: (Map<String, Object?> row) => QuranPlan(
            planId: row['planId'] as int,
            planName: row['planName'] as String,
            planType: row['planType'] as String,
            surahId: row['surahId'] as int?,
            juzId: row['juzId'] as int?,
            startDate: row['startDate'] as String,
            targetDays: row['targetDays'] as int,
            isPlanComplete: (row['isPlanComplete'] as int) != 0),
        queryableName: 'quran_plans',
        isView: false);
  }

  @override
  Future<List<QuranPlan>> getAllPlans() async {
    return _queryAdapter.queryList('SELECT * FROM quran_plans',
        mapper: (Map<String, Object?> row) => QuranPlan(
            planId: row['planId'] as int,
            planName: row['planName'] as String,
            planType: row['planType'] as String,
            surahId: row['surahId'] as int?,
            juzId: row['juzId'] as int?,
            startDate: row['startDate'] as String,
            targetDays: row['targetDays'] as int,
            isPlanComplete: (row['isPlanComplete'] as int) != 0));
  }

  @override
  Future<QuranPlan?> getPlanById(int id) async {
    return _queryAdapter.query('SELECT * FROM quran_plans WHERE planId = ?1',
        mapper: (Map<String, Object?> row) => QuranPlan(
            planId: row['planId'] as int,
            planName: row['planName'] as String,
            planType: row['planType'] as String,
            surahId: row['surahId'] as int?,
            juzId: row['juzId'] as int?,
            startDate: row['startDate'] as String,
            targetDays: row['targetDays'] as int,
            isPlanComplete: (row['isPlanComplete'] as int) != 0),
        arguments: [id]);
  }

  @override
  Future<void> deleteAllPlans() async {
    await _queryAdapter.queryNoReturn('DELETE FROM quran_plans');
  }

  @override
  Future<void> addPlan(QuranPlan plan) async {
    await _quranPlanInsertionAdapter.insert(plan, OnConflictStrategy.abort);
  }

  @override
  Future<void> upsertPlan(QuranPlan plan) async {
    await _quranPlanInsertionAdapter.insert(plan, OnConflictStrategy.replace);
  }

  @override
  Future<void> insertPlans(List<QuranPlan> plans) async {
    await _quranPlanInsertionAdapter.insertList(
        plans, OnConflictStrategy.abort);
  }

  @override
  Future<void> updatePlan(QuranPlan plan) async {
    await _quranPlanUpdateAdapter.update(plan, OnConflictStrategy.abort);
  }

  @override
  Future<void> deletePlan(QuranPlan plan) async {
    await _quranPlanDeletionAdapter.delete(plan);
  }
}

class _$QuranPlanDailyProgressDao extends QuranPlanDailyProgressDao {
  _$QuranPlanDailyProgressDao(
    this.database,
    this.changeListener,
  )   : _queryAdapter = QueryAdapter(database, changeListener),
        _quranPlanDailyProgressInsertionAdapter = InsertionAdapter(
            database,
            'quran_plan_daily_progress',
            (QuranPlanDailyProgress item) => <String, Object?>{
                  'id': item.id,
                  'planId': item.planId,
                  'date': item.date,
                  'pagesRead': item.pagesRead
                },
            changeListener),
        _quranPlanDailyProgressUpdateAdapter = UpdateAdapter(
            database,
            'quran_plan_daily_progress',
            ['id'],
            (QuranPlanDailyProgress item) => <String, Object?>{
                  'id': item.id,
                  'planId': item.planId,
                  'date': item.date,
                  'pagesRead': item.pagesRead
                },
            changeListener),
        _quranPlanDailyProgressDeletionAdapter = DeletionAdapter(
            database,
            'quran_plan_daily_progress',
            ['id'],
            (QuranPlanDailyProgress item) => <String, Object?>{
                  'id': item.id,
                  'planId': item.planId,
                  'date': item.date,
                  'pagesRead': item.pagesRead
                },
            changeListener);

  final sqflite.DatabaseExecutor database;

  final StreamController<String> changeListener;

  final QueryAdapter _queryAdapter;

  final InsertionAdapter<QuranPlanDailyProgress>
      _quranPlanDailyProgressInsertionAdapter;

  final UpdateAdapter<QuranPlanDailyProgress>
      _quranPlanDailyProgressUpdateAdapter;

  final DeletionAdapter<QuranPlanDailyProgress>
      _quranPlanDailyProgressDeletionAdapter;

  @override
  Stream<List<QuranPlanDailyProgress>> getAllDailyProgress() {
    return _queryAdapter.queryListStream(
        'SELECT * FROM quran_plan_daily_progress',
        mapper: (Map<String, Object?> row) => QuranPlanDailyProgress(
            id: row['id'] as int?,
            planId: row['planId'] as int,
            date: row['date'] as String,
            pagesRead: row['pagesRead'] as int),
        queryableName: 'quran_plan_daily_progress',
        isView: false);
  }

  @override
  Future<List<QuranPlanDailyProgress>> getDailyProgressList() async {
    return _queryAdapter.queryList('SELECT * FROM quran_plan_daily_progress',
        mapper: (Map<String, Object?> row) => QuranPlanDailyProgress(
            id: row['id'] as int?,
            planId: row['planId'] as int,
            date: row['date'] as String,
            pagesRead: row['pagesRead'] as int));
  }

  @override
  Future<QuranPlanDailyProgress?> getDailyProgressById(int id) async {
    return _queryAdapter.query(
        'SELECT * FROM quran_plan_daily_progress WHERE id=?1',
        mapper: (Map<String, Object?> row) => QuranPlanDailyProgress(
            id: row['id'] as int?,
            planId: row['planId'] as int,
            date: row['date'] as String,
            pagesRead: row['pagesRead'] as int),
        arguments: [id]);
  }

  @override
  Future<List<QuranPlanDailyProgress>> getDailyProgressByPlanId(
      int planId) async {
    return _queryAdapter.queryList(
        'SELECT * FROM quran_plan_daily_progress WHERE planId=?1',
        mapper: (Map<String, Object?> row) => QuranPlanDailyProgress(
            id: row['id'] as int?,
            planId: row['planId'] as int,
            date: row['date'] as String,
            pagesRead: row['pagesRead'] as int),
        arguments: [planId]);
  }

  @override
  Future<void> deleteAllDailyProgress() async {
    await _queryAdapter.queryNoReturn('DELETE FROM quran_plan_daily_progress');
  }

  @override
  Future<void> addDailyProgress(QuranPlanDailyProgress progress) async {
    await _quranPlanDailyProgressInsertionAdapter.insert(
        progress, OnConflictStrategy.abort);
  }

  @override
  Future<void> upsertDailyProgress(QuranPlanDailyProgress progress) async {
    await _quranPlanDailyProgressInsertionAdapter.insert(
        progress, OnConflictStrategy.replace);
  }

  @override
  Future<void> insertDailyProgressList(
      List<QuranPlanDailyProgress> progresses) async {
    await _quranPlanDailyProgressInsertionAdapter.insertList(
        progresses, OnConflictStrategy.abort);
  }

  @override
  Future<void> updateDailyProgress(QuranPlanDailyProgress progress) async {
    await _quranPlanDailyProgressUpdateAdapter.update(
        progress, OnConflictStrategy.abort);
  }

  @override
  Future<void> deleteDailyProgress(QuranPlanDailyProgress progress) async {
    await _quranPlanDailyProgressDeletionAdapter.delete(progress);
  }
}
