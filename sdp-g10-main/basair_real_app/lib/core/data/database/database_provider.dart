import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'app_database.dart';

final databaseProvider = FutureProvider<AppDatabase>((ref) async {
  final appDocDir = await getApplicationDocumentsDirectory();
  final dbPath = join(appDocDir.path, 'basair_database.db');

  return await $FloorAppDatabase.databaseBuilder(dbPath).build();
});