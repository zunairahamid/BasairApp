// providers/verseprovider.dart
import 'package:sdp_quran_navigator/model/verse.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../repos/verse_repo.dart';

class VerseNotifier extends Notifier<List<Verse>> {
 VerseRepository verseRepository=VerseRepository();
  @override
  List<Verse> build() {
    state=[];
    loadVerse();
    return state;
  }

  // Load juz from JSON file
  Future<void> loadVerse() async {
   List<Verse>verses=await verseRepository.getVerse();
   state=verses;
  }
}

final verseNotifierProvider =
    NotifierProvider<VerseNotifier, List<Verse>>(() => VerseNotifier());
