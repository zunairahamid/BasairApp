// viewmodels/tafsir_viewmodel.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../model/mahawer.dart';
import '../model/section.dart';
import '../service/tafsir_service.dart';
import '../service/ai_service.dart';

class TafsirState {
  final List<Mahawer> mahawer;
  final bool isLoading;
  final String? error;
  final Map<String, String> aiExplanations;
  final Set<String> loadingSections;
  final Map<String, dynamic> surahInfo;
  final Map<String, dynamic> publicationInfo;
  final String? author;
  final int currentSurahId;

  const TafsirState({
    this.mahawer = const [],
    this.isLoading = false,
    this.error,
    this.aiExplanations = const {},
    this.loadingSections = const {},
    this.surahInfo = const {},
    this.publicationInfo = const {},
    this.author,
    this.currentSurahId = 4,
  });

  TafsirState copyWith({
    List<Mahawer>? mahawer,
    bool? isLoading,
    String? error,
    Map<String, String>? aiExplanations,
    Set<String>? loadingSections,
    Map<String, dynamic>? surahInfo,
    Map<String, dynamic>? publicationInfo,
    String? author,
    int? currentSurahId,
  }) {
    return TafsirState(
      mahawer: mahawer ?? this.mahawer,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
      aiExplanations: aiExplanations ?? this.aiExplanations,
      loadingSections: loadingSections ?? this.loadingSections,
      surahInfo: surahInfo ?? this.surahInfo,
      publicationInfo: publicationInfo ?? this.publicationInfo,
      author: author ?? this.author,
      currentSurahId: currentSurahId ?? this.currentSurahId,
    );
  }
}

class TafsirNotifier extends StateNotifier<TafsirState> {
  final TafsirService _tafsirService;
  final AIService _aiService;

  TafsirNotifier({
    required TafsirService tafsirService,
    required AIService aiService,
  })  : _tafsirService = tafsirService,
        _aiService = aiService,
        super(const TafsirState());

  Future<void> init(int surahId) async {
    print('🚀 Initializing tafsir for surah: $surahId');
    
    // For Surah 4 - NEVER show loading or error states, always show data
    if (surahId == 4) {
      // Set initial state with empty data (will be replaced immediately)
      state = state.copyWith(
        currentSurahId: surahId,
        isLoading: false, // No loading state for Surah 4
        error: null, // No errors for Surah 4
        surahInfo: {
          'surahID': surahId,
          'surahName': 'سورة النساء',
          'author': 'التفسير الموضوعي',
        },
      );
      
      // Load data in background and update when ready
      _loadSurah4Data(surahId);
      return;
    }
    
    // For other surahs - show unavailable message
    state = state.copyWith(
      currentSurahId: surahId,
      isLoading: false,
      error: 'التفسير متوفر فقط لسورة النساء (٤)',
      mahawer: [],
      surahInfo: {
        'surahID': surahId,
        'surahName': 'سورة $surahId',
        'author': 'التفسير غير متوفر',
      },
    );
  }

  Future<void> _loadSurah4Data(int surahId) async {
    try {
      print('📖 Loading Surah 4 tafsir data...');
      
      await _tafsirService.ensureDataLoaded();
      
      final mahawer = await _tafsirService.loadMahawer(surahId);
      final surahInfo = await _tafsirService.getSurahInfo(surahId);
      final publicationInfo = Map<String, dynamic>.from(
          _tafsirService.getPublicationInfo() ?? <String, dynamic>{});
      final author = _tafsirService.getAuthor();
      
      print('✅ Loaded ${mahawer.length} mahawer sections for Surah 4');
      
      // Update state with the loaded data - NO ERROR STATES for Surah 4
      state = state.copyWith(
        mahawer: mahawer,
        isLoading: false,
        error: null, // Always null for Surah 4
        surahInfo: surahInfo,
        publicationInfo: publicationInfo,
        author: author,
      );
      
    } catch (e) {
      print('❌ Error loading Surah 4 data: $e');
      
      // For Surah 4 - NEVER show errors, just log and continue with empty data
      state = state.copyWith(
        mahawer: [], // Empty but no error
        isLoading: false,
        error: null, // No errors for Surah 4
        surahInfo: {
          'surahID': surahId,
          'surahName': 'سورة النساء',
          'author': 'التفسير الموضوعي',
        },
      );
    }
  }

  Future<void> explainSection(String sectionId, String text, {String? context}) async {
    if (state.loadingSections.contains(sectionId) || 
        state.aiExplanations.containsKey(sectionId)) {
      return;
    }

    state = state.copyWith(
      loadingSections: {...state.loadingSections, sectionId},
    );

    try {
      final explanation = context != null 
          ? await _aiService.explainWithContext(text: text, topic: context)
          : await _aiService.explainText(text);
      
      final newExplanations = Map<String, String>.from(state.aiExplanations);
      newExplanations[sectionId] = explanation;
      
      state = state.copyWith(
        aiExplanations: newExplanations,
        loadingSections: {...state.loadingSections}..remove(sectionId),
      );
      
    } catch (e) {
      final newExplanations = Map<String, String>.from(state.aiExplanations);
      newExplanations[sectionId] = 'تعذر توليد التفسير';
      
      state = state.copyWith(
        aiExplanations: newExplanations,
        loadingSections: {...state.loadingSections}..remove(sectionId),
      );
    }
  }

  void clearExplanation(String sectionId) {
    final newExplanations = Map<String, String>.from(state.aiExplanations);
    newExplanations.remove(sectionId);
    state = state.copyWith(aiExplanations: newExplanations);
  }

  void clearAllExplanations() {
    state = state.copyWith(
      aiExplanations: const {},
      loadingSections: const {},
    );
  }

  Future<void> refresh(int surahId) async {
    clearAllExplanations();
    await init(surahId);
  }

  Future<void> retry(int surahId) async {
    await init(surahId);
  }
}

// Providers
final tafsirServiceProvider = Provider<TafsirService>((ref) {
  return TafsirService();
});

final aiServiceProvider = Provider<AIService>((ref) {
  return AIService(aiClient: AIClient());
});

final tafsirNotifierProvider = StateNotifierProvider<TafsirNotifier, TafsirState>(
  (ref) {
    return TafsirNotifier(
      tafsirService: ref.read(tafsirServiceProvider),
      aiService: ref.read(aiServiceProvider),
    );
  },
);

final sectionExplanationProvider = Provider.family<String?, String>((ref, sectionId) {
  final state = ref.watch(tafsirNotifierProvider);
  return state.aiExplanations[sectionId];
});

final sectionLoadingProvider = Provider.family<bool, String>((ref, sectionId) {
  final state = ref.watch(tafsirNotifierProvider);
  return state.loadingSections.contains(sectionId);
});