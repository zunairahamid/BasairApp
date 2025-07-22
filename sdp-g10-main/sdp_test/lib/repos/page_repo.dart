import 'dart:convert';
import 'package:flutter/services.dart';
import '../model/page.dart';

class PageRepository{
  Future<List<Pages>> getPage()async{
    var response=await rootBundle.loadString('assets/basair-data/pages.json');
    var pageList=jsonDecode(response);
    List<Pages>pages=[];
    for(var pageMap in pageList){
      pages.add(Pages.fromJson(pageMap));
    }
    return pages;
  }
}