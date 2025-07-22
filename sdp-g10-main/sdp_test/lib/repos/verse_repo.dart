import 'dart:convert';
import 'package:sdp_test/model/verse.dart';
import 'package:flutter/services.dart';

class VerseRepository{
  Future<List<Verse>> getVerse()async{
    var response=await rootBundle.loadString('assets/basair-data/verses.json');
    var verseList=jsonDecode(response);
    List<Verse>verses=[];
    for(var verseMap in verseList){
      verses.add(Verse.fromJson(verseMap));
    }
    return verses;
  }
}