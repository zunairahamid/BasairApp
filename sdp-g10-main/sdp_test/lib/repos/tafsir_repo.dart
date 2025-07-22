import 'dart:convert';
import 'package:flutter/services.dart';

import '../model/tafsir.dart';

class TafsirRepository{
  Future<List<Tafsir>> getTafsir()async{
    var response=await rootBundle.loadString('assets/basair-data/tasfir.json');
    var tafsirList=jsonDecode(response);
    List<Tafsir>tafsirs=[];
    for(var tafsirMap in tafsirList){
      tafsirs.add(Tafsir.fromJson(tafsirMap));
    }
    return tafsirs;
  }
}