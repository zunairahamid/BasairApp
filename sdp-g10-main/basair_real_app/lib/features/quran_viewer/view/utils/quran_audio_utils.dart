// quran_audio_utils.dart

import 'dart:io';
import 'package:audioplayers/audioplayers.dart';
import 'package:dio/dio.dart';
import 'package:path_provider/path_provider.dart';

Future<File> getLocalFile(int surahId, int ayahNumber) async {
  final dir = await getApplicationDocumentsDirectory();
  String surahStr = surahId.toString().padLeft(3, '0');

  // Al-Fatiha (surah 1) starts from 001001, others from 000
  String ayahStr;
  if (surahId == 1) {
    ayahStr = (1000 + ayahNumber).toString().substring(1); // 001001 → 001007
  } else {
    ayahStr = ayahNumber.toString().padLeft(3, '0'); // e.g., 002000 → 002286
  }

  final fileName = 's${surahStr}a$ayahStr.mp3';
  return File('${dir.path}/$fileName');
}

String onlineAudioUrl(int surah, int ayah) {
  final ss = surah.toString().padLeft(3, '0');
  final aa = ayah.toString().padLeft(3, '0');
  return 'https://everyayah.com/data/Alafasy_128kbps/$ss$aa.mp3';
}

Future<void> downloadAyah(int surah, int ayah) async {
  final file = await getLocalFile(surah, ayah);
  if (!file.existsSync()) {
    final dio = Dio();
    await dio.download(onlineAudioUrl(surah, ayah), file.path);
  }
}

Future<void> playAyah(AudioPlayer player, int surah, int ayah) async {
  final file = await getLocalFile(surah, ayah);
  if (file.existsSync()) {
    await player.play(DeviceFileSource(file.path));
  } else {
    await player.play(UrlSource(onlineAudioUrl(surah, ayah)));
  }
}
