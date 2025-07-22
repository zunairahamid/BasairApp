import 'dart:convert';
import 'package:sdp_test/model/quarters.dart';
import 'package:flutter/services.dart';

class QuarterRepository {
  Future<List<Quarters>> getQuarter() async {
    var response = await rootBundle.loadString('assets/data/quarters.json');
    var quarterList = jsonDecode(response);
    List<Quarters> quarters = [];
    for (var quarterMap in quarterList) {
      quarters.add(Quarters.fromJson(quarterMap));
    }
    return quarters;
  }
}
