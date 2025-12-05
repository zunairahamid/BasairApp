// models/quiz.dart
class QuizQuestion {
  final String id;
  final String question;
  final String questionType;
  final String correctAnswer;
  List<SelectableOption> selectableOptions; // Changed from final to mutable
  final String? userAnswer;
  final bool? isCorrect;
  final String? feedback;
  final String? sourceSection;

  QuizQuestion({
    required this.id,
    required this.question,
    required this.questionType,
    required this.correctAnswer,
    required this.selectableOptions,
    this.userAnswer,
    this.isCorrect,
    this.feedback,
    this.sourceSection,
  });

  QuizQuestion copyWith({
    String? userAnswer,
    bool? isCorrect,
    String? feedback,
    List<SelectableOption>? selectableOptions,
    String? sourceSection,
  }) {
    return QuizQuestion(
      id: id,
      question: question,
      questionType: questionType,
      correctAnswer: correctAnswer,
      selectableOptions: selectableOptions ?? this.selectableOptions,
      userAnswer: userAnswer ?? this.userAnswer,
      isCorrect: isCorrect ?? this.isCorrect,
      feedback: feedback ?? this.feedback,
      sourceSection: sourceSection ?? this.sourceSection,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'question': question,
      'question_type': questionType,
      'correct_answer': correctAnswer,
      'selectable_options': selectableOptions.map((opt) => opt.toJson()).toList(),
      'user_answer': userAnswer,
      'is_correct': isCorrect,
      'feedback': feedback,
      'source_section': sourceSection,
    };
  }

  factory QuizQuestion.fromJson(Map<String, dynamic> json) {
    return QuizQuestion(
      id: json['id'] ?? '',
      question: json['question'] ?? '',
      questionType: json['question_type'] ?? 'mcq',
      correctAnswer: json['correct_answer'] ?? '',
      selectableOptions: (json['selectable_options'] as List?)
          ?.map((opt) => SelectableOption.fromJson(opt))
          .toList() ?? [],
      userAnswer: json['user_answer'],
      isCorrect: json['is_correct'],
      feedback: json['feedback'],
      sourceSection: json['source_section'],
    );
  }
}

class SelectableOption {
  final String value;
  final String displayText;
  final bool isSelected;

  SelectableOption({
    required this.value,
    required this.displayText,
    this.isSelected = false,
  });

  SelectableOption copyWith({
    String? value,
    String? displayText,
    bool? isSelected,
  }) {
    return SelectableOption(
      value: value ?? this.value,
      displayText: displayText ?? this.displayText,
      isSelected: isSelected ?? this.isSelected,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'value': value,
      'display_text': displayText,
      'is_selected': isSelected,
    };
  }

  factory SelectableOption.fromJson(Map<String, dynamic> json) {
    return SelectableOption(
      value: json['value'] ?? '',
      displayText: json['display_text'] ?? '',
      isSelected: json['is_selected'] ?? false,
    );
  }
}

class QuizResult {
  final int score;
  final int correctAnswers;
  final int totalQuestions;
  final String performanceLevel;
  final String detailedFeedback;
  final List<QuizQuestion> incorrectQuestions;
  final bool isAIGenerated;

  QuizResult({
    required this.score,
    required this.correctAnswers,
    required this.totalQuestions,
    required this.performanceLevel,
    required this.detailedFeedback,
    this.incorrectQuestions = const [],
    this.isAIGenerated = true,
  });

  Map<String, dynamic> toJson() {
    return {
      'score': score,
      'correct_answers': correctAnswers,
      'total_questions': totalQuestions,
      'performance_level': performanceLevel,
      'detailed_feedback': detailedFeedback,
      'incorrect_questions': incorrectQuestions.map((q) => q.toJson()).toList(),
      'is_ai_generated': isAIGenerated,
    };
  }

  factory QuizResult.fromJson(Map<String, dynamic> json) {
    return QuizResult(
      score: json['score'] ?? 0,
      correctAnswers: json['correct_answers'] ?? 0,
      totalQuestions: json['total_questions'] ?? 0,
      performanceLevel: json['performance_level'] ?? '',
      detailedFeedback: json['detailed_feedback'] ?? '',
      incorrectQuestions: (json['incorrect_questions'] as List?)
          ?.map((q) => QuizQuestion.fromJson(q))
          .toList() ?? [],
      isAIGenerated: json['is_ai_generated'] ?? true,
    );
  }
}