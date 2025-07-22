import 'dart:convert';
import 'package:flutter/services.dart';
import '../model/mahawer.dart';

class MahawerRepository{
  Future<List<Mahawer>> getMahawer()async{
    var response=await rootBundle.loadString('assets/basair-data/mahawer.json');
    var mahawerList=jsonDecode(response);
    List<Mahawer>mahawers=[];
    for(var mahawerMap in mahawerList){
      mahawers.add(Mahawer.fromJson(mahawerMap));
    }
    return mahawers;
  }
}