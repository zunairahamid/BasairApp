import '../entities/tafsir.dart';
import '../repositories/supabase_repository.dart';

class UploadToSupabaseUseCase {
  final SupabaseRepository supabaseRepository;

  UploadToSupabaseUseCase(this.supabaseRepository);

  Future<void> call(Tafsir tafsir) => supabaseRepository.uploadTafsir(tafsir);
}