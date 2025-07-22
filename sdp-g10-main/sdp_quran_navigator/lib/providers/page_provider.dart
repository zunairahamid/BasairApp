import 'package:sdp_quran_navigator/model/page.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../repos/page_repo.dart';

class PageNotifier extends Notifier<List<Pages>> {
  PageRepository pageRepository=PageRepository();
  @override
  List<Pages> build() {
    state=[];
    loadPages();
    return state;
  }

  // Load juz from JSON file
  Future<void> loadPages() async {
   List<Pages>pages=await pageRepository.getPage();
   state=pages;
  }}

final pageNotifierProvider =
    NotifierProvider<PageNotifier, List<Pages>>(() => PageNotifier());
