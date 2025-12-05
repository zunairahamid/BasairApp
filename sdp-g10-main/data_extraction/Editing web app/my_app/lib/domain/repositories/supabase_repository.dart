import '../entities/tafsir.dart';

abstract class SupabaseRepository {
  Future<void> uploadTafsir(Tafsir tafsir);
}