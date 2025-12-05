// viewmodels/qna_viewmodel.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../service/qna_service.dart';
import '../model/quiz.dart';

class QnAViewModel extends StateNotifier<QnAState> {
  final QnAService qnaService;
  final String surahTitle;
  
  QnAViewModel({required this.qnaService, required this.surahTitle})
      : super(QnAState.initial(surahTitle));

  // Getters
  List<QuizQuestion> get questions => state.questions;
  QuizResult? get quizResult => state.quizResult;
  bool get isLoading => state.isLoading;
  String? get error => state.error;
  bool get quizGenerated => state.quizGenerated;
  bool get showResults => state.showResults;
  
  int get answeredCount => state.questions.where((q) => _isQuestionAnswered(q)).length;
  int get totalQuestions => state.questions.length;
  double get progress => totalQuestions > 0 ? answeredCount / totalQuestions : 0.0;
  bool get allQuestionsAnswered => answeredCount == totalQuestions && totalQuestions > 0;

  bool _isQuestionAnswered(QuizQuestion question) {
    if (question.userAnswer != null && question.userAnswer!.isNotEmpty) {
      return true;
    }
    
    final questionIndex = state.questions.indexOf(question);
    if (questionIndex != -1) {
      if (question.questionType == 'multiple_select') {
        final selections = state.currentSelections[questionIndex] ?? [];
        return selections.isNotEmpty;
      }
      
      if (hasMultipleBlanks(questionIndex)) {
        final assignments = state.blankAssignments[questionIndex] ?? {};
        final requiredCount = getRequiredSelectionsCount(questionIndex);
        return assignments.length == requiredCount;
      }
    }
    
    return false;
  }

  List<String> getSelectedOptions(int questionIndex) {
    return state.currentSelections[questionIndex] ?? [];
  }

  Map<int, String> getBlankAssignments(int questionIndex) {
    return state.blankAssignments[questionIndex] ?? {};
  }
  
  bool hasMultipleBlanks(int questionIndex) {
    if (questionIndex < 0 || questionIndex >= state.questions.length) return false;
    final question = state.questions[questionIndex];
    return question.questionType == 'fill_blank' && question.correctAnswer.contains('-');
  }

  bool isMultipleSelection(int questionIndex) {
    if (questionIndex < 0 || questionIndex >= state.questions.length) return false;
    final question = state.questions[questionIndex];
    return question.questionType == 'multiple_select';
  }

  int getRequiredSelectionsCount(int questionIndex) {
    if (questionIndex < 0 || questionIndex >= state.questions.length) return 1;
    final question = state.questions[questionIndex];
    
    if (question.questionType == 'multiple_select') {
      return question.correctAnswer.split(',').length;
    } else if (hasMultipleBlanks(questionIndex)) {
      return question.correctAnswer.split('-').length;
    }
    return 1;
  }

  int getActualBlankCountFromText(String questionText) {
    final blankMatches = RegExp(r'_{3}').allMatches(questionText);
    return blankMatches.length;
  }

  int getBlankCount(int questionIndex) {
    if (questionIndex < 0 || questionIndex >= state.questions.length) return 0;
    final question = state.questions[questionIndex];
    
    if (question.questionType == 'fill_blank') {
      final blankCount = getActualBlankCountFromText(question.question);
      
      if (question.correctAnswer.contains('-')) {
        final expectedCount = question.correctAnswer.split('-').length;
        if (blankCount != expectedCount) {
          return expectedCount;
        }
      }
      
      return blankCount;
    }
    return 0;
  }

  Future<void> generateQuiz(String surahName) async {
    try {
      state = state.copyWith(isLoading: true, error: null);
      
      // Reset state
      state = state.copyWith(
        questions: [],
        quizResult: null,
        currentSelections: {},
        blankAssignments: {},
        showResults: false,
      );
      
      final questions = await qnaService.generateQuiz(surahName);
      
      if (questions.isEmpty) {
        state = state.copyWith(
          error: 'Failed to generate questions. Please check your internet connection and API key.',
          quizGenerated: false,
          isLoading: false,
        );
      } else {
        // Initialize selection state
        final currentSelections = <int, List<String>>{};
        final blankAssignments = <int, Map<int, String>>{};
        
        for (int i = 0; i < questions.length; i++) {
          currentSelections[i] = [];
          blankAssignments[i] = {};
        }
        
        state = state.copyWith(
          questions: questions,
          quizGenerated: true,
          currentSelections: currentSelections,
          blankAssignments: blankAssignments,
          isLoading: false,
        );
      }
    } catch (e) {
      state = state.copyWith(
        error: 'Error generating quiz: $e',
        quizGenerated: false,
        isLoading: false,
      );
    }
  }

  void toggleWordSelection(int questionIndex, String word) {
    if (questionIndex < 0 || questionIndex >= state.questions.length) return;
    
    final question = state.questions[questionIndex];
    
    if (question.questionType == 'multiple_select') {
      _handleMultipleSelectSelection(questionIndex, word);
    } else if (hasMultipleBlanks(questionIndex)) {
      _handleMultipleBlankWordSelection(questionIndex, word);
    } else {
      _handleSingleSelection(questionIndex, word);
    }
  }

  void _handleSingleSelection(int questionIndex, String word) {
    final questions = List<QuizQuestion>.from(state.questions);
    final question = questions[questionIndex];
    
    final updatedOptions = question.selectableOptions.map((option) {
      return option.copyWith(isSelected: option.value == word);
    }).toList();
    
    questions[questionIndex] = question.copyWith(
      userAnswer: word,
      selectableOptions: updatedOptions,
    );
    
    final currentSelections = Map<int, List<String>>.from(state.currentSelections);
    currentSelections[questionIndex] = [word];
    
    state = state.copyWith(
      questions: questions,
      currentSelections: currentSelections,
    );
  }

  void _handleMultipleSelectSelection(int questionIndex, String word) {
    final currentSelections = Map<int, List<String>>.from(state.currentSelections);
    List<String> selections = currentSelections[questionIndex] ?? [];
    
    List<String> newSelections = List.from(selections);

    if (newSelections.contains(word)) {
      newSelections.remove(word);
    } else {
      newSelections.add(word);
    }
    
    currentSelections[questionIndex] = newSelections;
    
    final questions = List<QuizQuestion>.from(state.questions);
    final question = questions[questionIndex];
    final updatedOptions = question.selectableOptions.map((option) {
      return option.copyWith(isSelected: newSelections.contains(option.value));
    }).toList();
    
    final userAnswer = newSelections.isNotEmpty ? newSelections.join(',') : null;
    
    questions[questionIndex] = question.copyWith(
      userAnswer: userAnswer,
      selectableOptions: updatedOptions,
    );
    
    state = state.copyWith(
      questions: questions,
      currentSelections: currentSelections,
    );
  }

  void _handleMultipleBlankWordSelection(int questionIndex, String word) {
    final currentSelections = Map<int, List<String>>.from(state.currentSelections);
    final blankAssignments = Map<int, Map<int, String>>.from(state.blankAssignments);
    
    List<String> selections = currentSelections[questionIndex] ?? [];
    Map<int, String> assignments = blankAssignments[questionIndex] ?? {};
    
    List<String> newSelections = List.from(selections);
    Map<int, String> newAssignments = Map.from(assignments);

    if (newSelections.contains(word)) {
      newSelections.remove(word);
      newAssignments.removeWhere((_, value) => value == word);
    } else {
      newSelections.add(word);
      final blankCount = getBlankCount(questionIndex);
      
      for (int i = 0; i < blankCount; i++) {
        if (!newAssignments.containsKey(i)) {
          newAssignments[i] = word;
          break;
        }
      }
      
      if (!newAssignments.containsValue(word) && blankCount > 0) {
        newAssignments[blankCount - 1] = word;
      }
    }
    
    currentSelections[questionIndex] = newSelections;
    blankAssignments[questionIndex] = newAssignments;
    
    _updateMultipleBlankDisplay(questionIndex, currentSelections, blankAssignments);
  }

  void assignWordToBlank(int questionIndex, String word, int blankIndex) {
    final blankAssignments = Map<int, Map<int, String>>.from(state.blankAssignments);
    Map<int, String> assignments = blankAssignments[questionIndex] ?? {};

    assignments.removeWhere((key, value) => value == word);
    
    Map<int, String> newAssignments = Map.from(assignments);
    newAssignments[blankIndex] = word;
    
    blankAssignments[questionIndex] = newAssignments;
    
    final currentSelections = Map<int, List<String>>.from(state.currentSelections);
    List<String> selections = currentSelections[questionIndex] ?? [];
    if (!selections.contains(word)) {
      selections.add(word);
      currentSelections[questionIndex] = selections;
    }
    
    _updateMultipleBlankDisplay(questionIndex, currentSelections, blankAssignments);
  }

  void removeWordFromBlank(int questionIndex, int blankIndex) {
    final blankAssignments = Map<int, Map<int, String>>.from(state.blankAssignments);
    final currentSelections = Map<int, List<String>>.from(state.currentSelections);
    
    Map<int, String> assignments = blankAssignments[questionIndex] ?? {};
    final word = assignments[blankIndex];
    
    if (word != null) {
      Map<int, String> newAssignments = Map.from(assignments);
      newAssignments.remove(blankIndex);
      
      blankAssignments[questionIndex] = newAssignments;
      
      final isWordUsedElsewhere = newAssignments.containsValue(word);
      if (!isWordUsedElsewhere) {
        List<String> selections = currentSelections[questionIndex] ?? [];
        selections.remove(word);
        currentSelections[questionIndex] = selections;
      }
      
      _updateMultipleBlankDisplay(questionIndex, currentSelections, blankAssignments);
    }
  }

  void _updateMultipleBlankDisplay(int questionIndex, Map<int, List<String>> currentSelections, Map<int, Map<int, String>> blankAssignments) {
    final questions = List<QuizQuestion>.from(state.questions);
    final question = questions[questionIndex];
    final assignments = blankAssignments[questionIndex] ?? {};
    final blanksCount = getBlankCount(questionIndex);
    
    List<String> orderedAnswer = [];
    for (int i = 0; i < blanksCount; i++) {
      orderedAnswer.add(assignments[i] ?? '');
    }
    
    final userAnswer = orderedAnswer.where((a) => a.isNotEmpty).isNotEmpty ? orderedAnswer.join('-') : null;
    
    questions[questionIndex] = question.copyWith(userAnswer: userAnswer);
    
    state = state.copyWith(
      questions: questions,
      currentSelections: currentSelections,
      blankAssignments: blankAssignments,
    );
  }

  void clearWordSelection(int questionIndex, String word) {
    if (questionIndex < 0 || questionIndex >= state.questions.length) return;
    
    final questions = List<QuizQuestion>.from(state.questions);
    final currentSelections = Map<int, List<String>>.from(state.currentSelections);
    final blankAssignments = Map<int, Map<int, String>>.from(state.blankAssignments);
    
    final question = questions[questionIndex];
    
    if (question.questionType == 'multiple_select') {
      List<String> selections = currentSelections[questionIndex] ?? [];
      selections.remove(word);
      currentSelections[questionIndex] = selections;
      
      final updatedOptions = question.selectableOptions.map((option) {
        return option.copyWith(isSelected: option.value == word ? false : option.isSelected);
      }).toList();
      
      final userAnswer = selections.isNotEmpty ? selections.join(',') : null;
      
      questions[questionIndex] = question.copyWith(
        userAnswer: userAnswer,
        selectableOptions: updatedOptions,
      );
    } else if (hasMultipleBlanks(questionIndex)) {
      Map<int, String> assignments = blankAssignments[questionIndex] ?? {};
      assignments.removeWhere((_, value) => value == word);
      blankAssignments[questionIndex] = assignments;
      
      List<String> selections = currentSelections[questionIndex] ?? [];
      selections.remove(word);
      currentSelections[questionIndex] = selections;
      
      _updateMultipleBlankDisplay(questionIndex, currentSelections, blankAssignments);
    } else {
      if (question.userAnswer == word) {
        final updatedOptions = question.selectableOptions.map((option) {
          return option.copyWith(isSelected: false);
        }).toList();
        
        questions[questionIndex] = question.copyWith(
          userAnswer: null,
          selectableOptions: updatedOptions,
        );
        currentSelections[questionIndex] = [];
      }
    }
    
    state = state.copyWith(
      questions: questions,
      currentSelections: currentSelections,
      blankAssignments: blankAssignments,
    );
  }

  Future<void> submitQuiz() async {
    try {
      state = state.copyWith(isLoading: true, error: null, showResults: false);
      
      List<QuizQuestion> updatedQuestions = List.from(state.questions);
      
      for (int i = 0; i < updatedQuestions.length; i++) {
        final question = updatedQuestions[i];
        String userAnswer = '';
        
        if (question.questionType == 'multiple_select') {
          final selections = state.currentSelections[i] ?? [];
          userAnswer = selections.join(',');
        } else if (hasMultipleBlanks(i)) {
          final assignments = state.blankAssignments[i] ?? {};
          final blanksCount = getBlankCount(i);
          List<String> orderedAnswer = [];
          for (int j = 0; j < blanksCount; j++) {
            orderedAnswer.add(assignments[j] ?? '');
          }
          userAnswer = orderedAnswer.join('-');
        } else {
          userAnswer = question.userAnswer ?? '';
        }
        
        if (userAnswer.isNotEmpty) {
          try {
            final updatedQuestion = await qnaService.submitAnswer(question, userAnswer);
            updatedQuestions[i] = updatedQuestion;
          } catch (e) {
            updatedQuestions[i] = question.copyWith(
              userAnswer: userAnswer,
              isCorrect: false,
              feedback: 'Evaluation failed: $e',
            );
          }
        } else {
          updatedQuestions[i] = question.copyWith(
            userAnswer: null,
            isCorrect: false,
            feedback: 'No answer provided.',
          );
        }
      }
      
      final quizResult = await qnaService.calculateResults(updatedQuestions, surahTitle);
      
      state = state.copyWith(
        questions: updatedQuestions,
        quizResult: quizResult,
        showResults: true,
        isLoading: false,
      );
      
    } catch (e) {
      state = state.copyWith(
        error: 'Submit error: $e',
        isLoading: false,
      );
    }
  }

  void clearSelections(int questionIndex) {
    if (questionIndex < 0 || questionIndex >= state.questions.length) return;
    
    final questions = List<QuizQuestion>.from(state.questions);
    final currentSelections = Map<int, List<String>>.from(state.currentSelections);
    final blankAssignments = Map<int, Map<int, String>>.from(state.blankAssignments);
    
    final question = questions[questionIndex];
    
    if (question.questionType == 'multiple_select') {
      currentSelections[questionIndex] = [];
      
      final updatedOptions = question.selectableOptions.map((option) {
        return option.copyWith(isSelected: false);
      }).toList();
      
      questions[questionIndex] = question.copyWith(
        userAnswer: null,
        selectableOptions: updatedOptions,
      );
    } else if (hasMultipleBlanks(questionIndex)) {
      currentSelections[questionIndex] = [];
      blankAssignments[questionIndex] = {};
      
      questions[questionIndex] = question.copyWith(
        userAnswer: null,
      );
    } else {
      final updatedOptions = question.selectableOptions.map((option) {
        return option.copyWith(isSelected: false);
      }).toList();
      
      questions[questionIndex] = question.copyWith(
        userAnswer: null,
        selectableOptions: updatedOptions,
      );
      currentSelections[questionIndex] = [];
    }
    
    state = state.copyWith(
      questions: questions,
      currentSelections: currentSelections,
      blankAssignments: blankAssignments,
    );
  }

  void resetQuiz() {
    state = QnAState.initial(surahTitle);
  }
}

class QnAState {
  final List<QuizQuestion> questions;
  final QuizResult? quizResult;
  final bool isLoading;
  final String? error;
  final bool quizGenerated;
  final bool showResults;
  final Map<int, List<String>> currentSelections;
  final Map<int, Map<int, String>> blankAssignments;
  final String surahTitle;

  QnAState({
    required this.questions,
    this.quizResult,
    required this.isLoading,
    this.error,
    required this.quizGenerated,
    required this.showResults,
    required this.currentSelections,
    required this.blankAssignments,
    required this.surahTitle,
  });

  factory QnAState.initial(String surahTitle) {
    return QnAState(
      questions: [],
      quizResult: null,
      isLoading: false,
      error: null,
      quizGenerated: false,
      showResults: false,
      currentSelections: {},
      blankAssignments: {},
      surahTitle: surahTitle,
    );
  }

  QnAState copyWith({
    List<QuizQuestion>? questions,
    QuizResult? quizResult,
    bool? isLoading,
    String? error,
    bool? quizGenerated,
    bool? showResults,
    Map<int, List<String>>? currentSelections,
    Map<int, Map<int, String>>? blankAssignments,
    String? surahTitle,
  }) {
    return QnAState(
      questions: questions ?? this.questions,
      quizResult: quizResult ?? this.quizResult,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
      quizGenerated: quizGenerated ?? this.quizGenerated,
      showResults: showResults ?? this.showResults,
      currentSelections: currentSelections ?? this.currentSelections,
      blankAssignments: blankAssignments ?? this.blankAssignments,
      surahTitle: surahTitle ?? this.surahTitle,
    );
  }
}

// Riverpod Providers
final qnAViewModelProvider = StateNotifierProvider.autoDispose<QnAViewModel, QnAState>((ref) {
  final qnaService = ref.watch(qnaServiceProvider);
  throw UnimplementedError('Use qnAViewModelFamilyProvider instead');
});

final qnAViewModelFamilyProvider = StateNotifierProvider.autoDispose.family<QnAViewModel, QnAState, String>((ref, surahTitle) {
  final qnaService = ref.watch(qnaServiceProvider);
  return QnAViewModel(qnaService: qnaService, surahTitle: surahTitle);
});