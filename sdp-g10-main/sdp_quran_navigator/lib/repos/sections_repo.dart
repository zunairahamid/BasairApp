import 'dart:convert';
import '../model/section.dart';
import 'package:flutter/services.dart';

class SectionRepository{
  Future<List<Sections>> getSection()async{
    var response=await rootBundle.loadString('assets/data/sections.json');
    var sectionList=jsonDecode(response);
    List<Sections>sections=[];
    for(var sectionMap in sectionList){
      sections.add(Sections.fromJson(sectionMap));
    }
    return sections;
  }
}