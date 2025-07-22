import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sdp_quran_navigator/models/mahwar.dart';

import 'package:sdp_quran_navigator/repos/mahawer_repo.dart';

class MahawerNotifier extends Notifier<List<Mahwar>> {
  MahawerRepository mahawerRepository=MahawerRepository();
  @override
  List<Mahwar> build() {
    state=[];
    loadMahawer();
    return state;
  }

  // Load juz from JSON file
  Future<void> loadMahawer() async {
   List<Mahwar>mahawers=await mahawerRepository.getMahawer();
   state=mahawers;
   print(state);
  }
}

final mahawerNotifierProvider =
    NotifierProvider<MahawerNotifier, List<Mahwar>>(() => MahawerNotifier());
