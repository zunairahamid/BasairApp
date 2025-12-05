import 'package:supabase_flutter/supabase_flutter.dart';
import '../../domain/entities/tafsir.dart';
import '../../domain/repositories/supabase_repository.dart';

class SupabaseRepositoryImpl implements SupabaseRepository {
  final SupabaseClient client;

  SupabaseRepositoryImpl(this.client);

  @override
  Future<void> uploadTafsir(Tafsir tafsir) async {
    await client.from('surahs').upsert({'surah_id': tafsir.surah.surahId, 'surah_name': tafsir.surah.surahName});
    await client.from('tafsirs').upsert({
      'tafsir_id': tafsir.tafsirId,
      'title': tafsir.title,
      'author': tafsir.author,
      'publisher': tafsir.publisher,
      'year': tafsir.year,
      'location': tafsir.location,
      'isbn': tafsir.isbn,
      'surah_id': tafsir.surahId,
      'state': tafsir.state,
    });
    for (var mahawer in tafsir.mahawer) {
      await client.from('mahawer').upsert({
        'mahawer_id': mahawer.id,
        'type': mahawer.type,
        'sequence': mahawer.sequence,
        'title': mahawer.title,
        'text': mahawer.text,
        'ayat': mahawer.ayat,
        'is_muqadimah': mahawer.isMuqadimah,
        'is_khatimah': mahawer.isKhatimah,
        'tafsir_id': tafsir.tafsirId,
      });
      for (var section in mahawer.sections) {
        await client.from('sections').upsert({
          'section_id': section.id,
          'type': section.type,
          'sequence': section.sequence,
          'title': section.title,
          'text': section.text,
          'ayat': section.ayat,
          'conclusion': section.conclusion,
          'mahawer_id': mahawer.id,
        });
        if (section.subSections != null) {
          for (var subSection in section.subSections!) {
            await client.from('sub_sections').upsert({
              'sub_section_id': subSection.id,
              'type': subSection.type,
              'sequence': subSection.sequence,
              'text': subSection.text,
              'ayat': subSection.ayat,
              'conclusion': subSection.conclusion,
              'section_id': section.id,
            });
            if (subSection.topics != null) {
              for (var topic in subSection.topics!) {
                await client.from('topics').upsert({
                  'topic_id': topic.id,
                  'type': topic.type,
                  'sequence': topic.sequence,
                  'text': topic.text,
                  'ayat': topic.ayat,
                  'sub_section_id': subSection.id,
                });
              }
            }
          }
        }
      }
    }
  }
}