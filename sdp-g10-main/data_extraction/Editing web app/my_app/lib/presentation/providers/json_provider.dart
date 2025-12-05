import 'package:flutter/material.dart';
import '../../domain/entities/tafsir.dart';

class JsonProvider with ChangeNotifier {
  Tafsir? _tafsir;
  bool _isLoading = false;

  Tafsir? get tafsir => _tafsir;
  bool get isLoading => _isLoading;

  void setTafsir(Tafsir tafsir) {
    _tafsir = tafsir;
    _isLoading = false;
    notifyListeners();
  }
   void startLoading() { 
    _isLoading = true;
    notifyListeners();
  }
  
  void stopLoading() {  
    _isLoading = false;
    notifyListeners();
  }

  void updateTafsir(Tafsir updatedTafsir) {
    _tafsir = updatedTafsir;
    notifyListeners();
  }
}