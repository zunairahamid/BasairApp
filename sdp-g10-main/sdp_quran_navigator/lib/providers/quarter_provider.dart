// providers/quarterprovider.dart
import 'package:sdp_quran_navigator/model/quarters.dart';
import 'package:sdp_quran_navigator/repos/quarter_repo.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class QuarterNotifier extends Notifier<List<Quarters>> {
  final QuarterRepository quarterRepository = QuarterRepository();

  @override
  List<Quarters> build() {
    _loadQuarter(); // Call async function properly
    return [];
  }

  // Load quarters from JSON file
  Future<void> _loadQuarter() async {
    try {
      List<Quarters> quarters = await quarterRepository.getQuarter();
      state = [...quarters]; // Ensures state updates properly
    } catch (e) {
      print('Error loading Quarters: $e');
    }
  }
}

final quarterNotifierProvider =
    NotifierProvider<QuarterNotifier, List<Quarters>>(() => QuarterNotifier());
