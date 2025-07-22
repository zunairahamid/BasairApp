import '../repos/juzs_repo.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../model/juz.dart';

class JuzNotifier extends AsyncNotifier<List<Juz>> {
  final JuzRepository juzRepository = JuzRepository();

  @override
  Future<List<Juz>> build() async {
    return await loadJuz();
  }

  // Load Juz from JSON file
  Future<List<Juz>> loadJuz() async {
    return await juzRepository.getJuz();
  }
  
}

final juzNotifierProvider =
    AsyncNotifierProvider<JuzNotifier, List<Juz>>(() => JuzNotifier());