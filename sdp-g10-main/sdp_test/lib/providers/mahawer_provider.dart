import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../model/mahawer.dart';

import '../repos/mahawer_repo.dart';

class MahawerNotifier extends Notifier<List<Mahawer>> {
  MahawerRepository mahawerRepository=MahawerRepository();
  @override
  List<Mahawer> build() {
    state=[];
    loadMahawer();
    return state;
  }

  // Load juz from JSON file
  Future<void> loadMahawer() async {
   List<Mahawer>mahawers=await mahawerRepository.getMahawer();
   state=mahawers;
   print(state);
  }
}

final mahawerNotifierProvider =
    NotifierProvider<MahawerNotifier, List<Mahawer>>(() => MahawerNotifier());
