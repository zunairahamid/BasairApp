import 'dart:convert';
import 'package:sdp_test/model/section.dart';
import 'package:flutter/services.dart';

class SectionRepository{
  Future<List<Sections>> getSection()async{
    var response=await rootBundle.loadString('assets/basair-data/sections.json');
    var sectionList=jsonDecode(response);
    List<Sections>sections=[];
    for(var sectionMap in sectionList){
      sections.add(Sections.fromJson(sectionMap));
    }
    return sections;
  }
}