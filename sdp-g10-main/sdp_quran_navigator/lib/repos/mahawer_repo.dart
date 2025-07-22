import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:sdp_quran_navigator/models/mahwar.dart';

class MahawerRepository{
  Future<List<Mahwar>> getMahawer()async{
    var response=await rootBundle.loadString('assets/basair-data/mahawer.json');
    var mahawerList=jsonDecode(response);
    List<Mahwar>mahawers=[];
    for(var mahawerMap in mahawerList){
      mahawers.add(Mahwar.fromJson(mahawerMap));
    }
    return mahawers;
  }
}