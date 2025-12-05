// screens/qna_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../viewmodel/qna_viewmodel.dart';
import '../model/quiz.dart';

class QnAScreen extends ConsumerStatefulWidget {
  final String surahTitle;
  final int surahId;
  const QnAScreen({super.key, required this.surahTitle, required this.surahId});

  @override
  ConsumerState<QnAScreen> createState() => _QnAScreenState();
}

class _QnAScreenState extends ConsumerState<QnAScreen> {
  @override
  void initState() {
    super.initState();
    // Delay initialization to avoid widget tree issues
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeQuiz();
    });
  }

  void _initializeQuiz() {
    try {
      final vm = ref.read(qnAViewModelFamilyProvider(widget.surahTitle).notifier);
      vm.resetQuiz();
      vm.generateQuiz(widget.surahTitle);
    } catch (e) {
      print('Error initializing quiz: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(qnAViewModelFamilyProvider(widget.surahTitle));
    final vm = ref.read(qnAViewModelFamilyProvider(widget.surahTitle).notifier);

    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.surahTitle} - Quiz'),
        backgroundColor: Colors.orange[700],
        foregroundColor: Colors.white,
      ),
      body: _buildBody(state, vm),
    );
  }

  Widget _buildBody(QnAState state, QnAViewModel vm) {
    if (state.isLoading && !state.quizGenerated) return _buildLoading();
    if (state.error != null) return _buildError(state, vm);
    if (!state.quizGenerated) return _buildStart(vm);
    
    return Column(
      children: [
        _buildProgress(state, vm),
        Expanded(
          child: ListView(
            padding: const EdgeInsets.all(16.0),
            children: [
              const SizedBox(height: 8),
              ...state.questions.asMap().entries.map((entry) {
                final index = entry.key;
                final question = entry.value;
                return Padding(
                  padding: const EdgeInsets.only(bottom: 16.0),
                  child: _buildQuestion(state, vm, question, index),
                );
              }).toList(),
              
              if (!state.showResults) _buildSubmitButton(state, vm),
              if (state.showResults) _buildResults(state, vm),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildLoading() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(),
          SizedBox(height: 16),
          Text(
            'Generating Quiz Questions...',
            style: TextStyle(fontSize: 16, color: Colors.grey),
          ),
        ],
      ),
    );
  }

  Widget _buildError(QnAState state, QnAViewModel vm) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: Colors.red[400],
            ),
            const SizedBox(height: 16),
            Text(
              'Quiz Questions for this Surah coming soon!',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.red[700],
              ),
            ),
            const SizedBox(height: 12),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Text(
                 'Quz questions for this surah coming soon',
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 14, color: Colors.grey),
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () {
                vm.resetQuiz();
                vm.generateQuiz(widget.surahTitle);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange[700],
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
              ),
              child: const Text('Try Again'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStart(QnAViewModel vm) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.quiz_outlined,
              size: 80,
              color: Colors.orange[700],
            ),
            const SizedBox(height: 20),
            const Text(
              'Quran Quiz',
              style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              'Surah ${widget.surahTitle}',
              style: const TextStyle(fontSize: 18, color: Colors.grey),
            ),
            const SizedBox(height: 24),
            const Text(
              'Test your knowledge with AI-generated questions about this surah',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: () {
                vm.resetQuiz();
                vm.generateQuiz(widget.surahTitle);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange[700],
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 16),
                textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              child: const Text('Start Quiz'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProgress(QnAState state, QnAViewModel vm) {
    final answeredCount = state.questions.where((q) {
      if (q.userAnswer != null && q.userAnswer!.isNotEmpty) return true;
      final questionIndex = state.questions.indexOf(q);
      if (questionIndex != -1) {
        if (q.questionType == 'multiple_select') {
          final selections = state.currentSelections[questionIndex] ?? [];
          return selections.isNotEmpty;
        }
        if (vm.hasMultipleBlanks(questionIndex)) {
          final assignments = state.blankAssignments[questionIndex] ?? {};
          final requiredCount = vm.getRequiredSelectionsCount(questionIndex);
          return assignments.length == requiredCount;
        }
      }
      return false;
    }).length;

    final totalQuestions = state.questions.length;
    final progress = totalQuestions > 0 ? answeredCount / totalQuestions : 0.0;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Progress: $answeredCount/$totalQuestions',
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
              ),
              Text(
                '${(progress * 100).round()}%',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.orange[700],
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          LinearProgressIndicator(
            value: progress,
            backgroundColor: Colors.grey[300],
            valueColor: AlwaysStoppedAnimation<Color>(Colors.orange[700]!),
          ),
        ],
      ),
    );
  }

  Widget _buildQuestion(QnAState state, QnAViewModel vm, QuizQuestion question, int index) {
    final isAnswered = question.userAnswer != null && question.userAnswer!.isNotEmpty;

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Question ${index + 1}',
                  style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                ),
                if (isAnswered && question.isCorrect != null)
                  Icon(
                    question.isCorrect! ? Icons.check_circle : Icons.cancel,
                    color: question.isCorrect! ? Colors.green : Colors.red,
                    size: 20,
                  ),
              ],
            ),
            const SizedBox(height: 8),
            _buildQuestionInput(state, vm, question, index),
            
            if (isAnswered && question.feedback != null && state.showResults) 
              _buildFeedback(question),
            
            if (isAnswered && !state.showResults) 
              _buildClearButton(vm, index),
          ],
        ),
      ),
    );
  }

  Widget _buildQuestionInput(QnAState state, QnAViewModel vm, QuizQuestion question, int index) {
    if (question.questionType == 'multiple_select') {
      return _buildMultipleSelectOptions(state, vm, question, index);
    } else if (question.questionType == 'fill_blank') {
      return _buildFillInBlanks(state, vm, question, index);
    } else {
      return _buildMCQOptions(state, vm, question, index);
    }
  }

  Widget _buildMCQOptions(QnAState state, QnAViewModel vm, QuizQuestion question, int index) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          question.question,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 16),
        Column(
          children: question.selectableOptions.map((option) {
            final isSelected = option.isSelected;
            
            Color borderColor = isSelected ? Colors.blue : Colors.grey[300]!;
            Color boxColor = isSelected ? Colors.blue[50]! : Colors.grey[50]!;
            Color textColor = Colors.black87;

            if (state.showResults && question.isCorrect != null) {
              final isCorrectAnswer = question.correctAnswer.toLowerCase().contains(option.value.toLowerCase());
              final isUsersWrongSelection = isSelected && !isCorrectAnswer;
              
              if (isCorrectAnswer) {
                borderColor = Colors.green;
                boxColor = Colors.green[50]!;
              } else if (isUsersWrongSelection) {
                borderColor = Colors.red;
                boxColor = Colors.red[50]!;
              }
            }
            
            return GestureDetector(
              onTap: state.showResults ? null : () => vm.toggleWordSelection(index, option.value),
              child: Container(
                width: double.infinity,
                margin: const EdgeInsets.only(bottom: 8),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: boxColor,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: borderColor, width: 1.5),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 20,
                      height: 20,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: borderColor, width: 2),
                        color: isSelected ? borderColor : Colors.transparent,
                      ),
                      child: isSelected 
                          ? const Icon(Icons.check, size: 12, color: Colors.white)
                          : null,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        option.displayText,
                        style: TextStyle(
                          color: textColor,
                          fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildMultipleSelectOptions(QnAState state, QnAViewModel vm, QuizQuestion question, int index) {
    final selections = vm.getSelectedOptions(index);
    final requiredCount = vm.getRequiredSelectionsCount(index);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          question.question,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 16),
        Text(
          'Select $requiredCount option${requiredCount > 1 ? 's' : ''}',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: selections.length >= requiredCount ? Colors.purple[700] : Colors.grey[600],
          ),
        ),
        const SizedBox(height: 8),
        
        Column(
          children: question.selectableOptions.map((option) {
            final isSelected = selections.contains(option.value);
            
            Color borderColor = isSelected ? Colors.purple : Colors.grey[300]!;
            Color boxColor = isSelected ? Colors.purple[50]! : Colors.grey[50]!;

            if (state.showResults && question.isCorrect != null) {
              final isCorrectAnswer = question.correctAnswer.toLowerCase().contains(option.value.toLowerCase());
              if (isCorrectAnswer) {
                borderColor = Colors.green;
                boxColor = Colors.green[50]!;
              } else if (isSelected) {
                borderColor = Colors.red;
                boxColor = Colors.red[50]!;
              }
            }
            
            return GestureDetector(
              onTap: state.showResults ? null : () => vm.toggleWordSelection(index, option.value),
              child: Container(
                width: double.infinity,
                margin: const EdgeInsets.only(bottom: 8),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: boxColor,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: borderColor, width: 1.5),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 20,
                      height: 20,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(4),
                        border: Border.all(color: borderColor, width: 2),
                        color: isSelected ? borderColor : Colors.transparent,
                      ),
                      child: isSelected 
                          ? const Icon(Icons.check, size: 12, color: Colors.white)
                          : null,
                    ),
                    const SizedBox(width: 12),
                    Expanded(child: Text(option.displayText)),
                  ],
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildFillInBlanks(QnAState state, QnAViewModel vm, QuizQuestion question, int index) {
    final isMultipleBlanks = vm.hasMultipleBlanks(index);
    final blankCount = vm.getBlankCount(index);
    
    if (isMultipleBlanks || blankCount > 1) {
      return _buildMultipleFillInBlanks(state, vm, question, index, blankCount);
    } else {
      return _buildSingleFillInBlank(state, vm, question, index);
    }
  }

  Widget _buildSingleFillInBlank(QnAState state, QnAViewModel vm, QuizQuestion question, int index) {
    final userAnswer = question.userAnswer ?? '';
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildQuestionWithVisualBlanks(question.question, userAnswer, 1),
        
        const SizedBox(height: 16),
        
        if (!state.showResults) ...[
          const Text(
            'Select the correct word:',
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: Colors.grey),
          ),
          const SizedBox(height: 8),
          _buildAllOptionsGrid(state, vm, question, index, userAnswer),
        ],
      ],
    );
  }

  Widget _buildMultipleFillInBlanks(QnAState state, QnAViewModel vm, QuizQuestion question, int index, int blankCount) {
    final blankAssignments = vm.getBlankAssignments(index);
    final selectedWords = vm.getSelectedOptions(index);
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildQuestionWithVisualBlanks(question.question, '', blankCount, blankAssignments),
        
        const SizedBox(height: 16),
        
        if (!state.showResults) ...[
          _buildSelectedWordsDisplay(vm, index, selectedWords, blankAssignments, blankCount),
          
          const SizedBox(height: 16),
          
          _buildAllOptionsGrid(state, vm, question, index, '', blankAssignments: blankAssignments),
          
          if (blankCount > 1) ...[
            const SizedBox(height: 12),
            Text(
              'Selected words will automatically fill the blanks in order',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        ],
      ],
    );
  }

  Widget _buildSelectedWordsDisplay(QnAViewModel vm, int questionIndex, List<String> selectedWords, Map<int, String> blankAssignments, int blankCount) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Fill the blanks:',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Colors.grey[700],
          ),
        ),
        const SizedBox(height: 12),
        
        Wrap(
          spacing: 12.0,
          runSpacing: 12.0,
          children: List.generate(blankCount, (blankIndex) {
            final assignedWord = blankAssignments[blankIndex];
            final isFilled = assignedWord != null && assignedWord.isNotEmpty;
            
            return Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isFilled ? Colors.orange[50] : Colors.grey[50],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: isFilled ? Colors.orange[700]! : Colors.grey[400]!,
                  width: 2,
                ),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Blank ${blankIndex + 1}',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: isFilled ? Colors.orange[800] : Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    isFilled ? assignedWord : '_______',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: isFilled ? Colors.orange[800] : Colors.grey[600],
                    ),
                  ),
                  if (isFilled) ...[
                    const SizedBox(height: 6),
                    GestureDetector(
                      onTap: () => vm.clearWordSelection(questionIndex, assignedWord),
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: Colors.red[50],
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Icon(
                          Icons.clear,
                          size: 14,
                          color: Colors.red[700],
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            );
          }),
        ),
        
        if (selectedWords.isNotEmpty) ...[
          const SizedBox(height: 16),
          Text(
            'Available words:',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: Colors.grey[700],
            ),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8.0,
            runSpacing: 8.0,
            children: selectedWords.map((word) {
              final isAssigned = blankAssignments.containsValue(word);
              
              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: isAssigned ? Colors.green[50] : Colors.blue[50],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: isAssigned ? Colors.green[700]! : Colors.blue[700]!,
                    width: 1.5,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      word,
                      style: TextStyle(
                        fontWeight: FontWeight.w500,
                        color: isAssigned ? Colors.green[800] : Colors.blue[800],
                      ),
                    ),
                    if (!isAssigned) ...[
                      const SizedBox(width: 6),
                      GestureDetector(
                        onTap: () {
                          final blankAssignments = vm.getBlankAssignments(questionIndex);
                          for (int i = 0; i < blankCount; i++) {
                            if (!blankAssignments.containsKey(i)) {
                              vm.assignWordToBlank(questionIndex, word, i);
                              break;
                            }
                          }
                        },
                        child: Icon(
                          Icons.add,
                          size: 16,
                          color: Colors.blue[700],
                        ),
                      ),
                    ],
                    const SizedBox(width: 4),
                    GestureDetector(
                      onTap: () => vm.clearWordSelection(questionIndex, word),
                      child: Icon(
                        Icons.clear,
                        size: 16,
                        color: Colors.grey[500],
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ],
      ],
    );
  }

  Widget _buildAllOptionsGrid(QnAState state, QnAViewModel vm, QuizQuestion question, int index, String userAnswer, {Map<int, String>? blankAssignments}) {
    final isMultipleBlanks = blankAssignments != null;
    final selectedWords = vm.getSelectedOptions(index);
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Select from these words:',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Colors.grey[700],
          ),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8.0,
          runSpacing: 8.0,
          children: question.selectableOptions.map((option) {
            final isSelected = isMultipleBlanks 
                ? selectedWords.contains(option.value)
                : userAnswer == option.value;
            
            final isAssigned = isMultipleBlanks && blankAssignments != null && blankAssignments.containsValue(option.value);
            
            return Container(
              decoration: BoxDecoration(
                color: isSelected ? (isAssigned ? Colors.green[100] : Colors.blue[100]) : Colors.grey[100],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: isSelected ? (isAssigned ? Colors.green[700]! : Colors.blue[700]!) : Colors.grey[300]!,
                  width: 1.5,
                ),
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  borderRadius: BorderRadius.circular(8),
                  onTap: state.showResults ? null : () {
                    if (isSelected) {
                      vm.clearWordSelection(index, option.value);
                    } else {
                      vm.toggleWordSelection(index, option.value);
                    }
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    child: Text(
                      option.displayText,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: isSelected ? Colors.black87 : Colors.black87,
                      ),
                    ),
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildQuestionWithVisualBlanks(String questionText, String userAnswer, int blankCount, [Map<int, String>? blankAssignments]) {
    final parts = questionText.split('___');
    final List<InlineSpan> spans = [];
    
    for (int i = 0; i < parts.length; i++) {
      if (parts[i].isNotEmpty) {
        spans.add(TextSpan(
          text: parts[i],
          style: const TextStyle(fontSize: 16, color: Colors.black87),
        ));
      }
      
      if (i < parts.length - 1) {
        String displayText;
        Color borderColor;
        Color backgroundColor;
        
        if (blankAssignments != null && blankAssignments[i] != null) {
          displayText = blankAssignments[i]!;
          borderColor = Colors.orange[700]!;
          backgroundColor = Colors.orange[50]!;
        } else if (userAnswer.isNotEmpty && blankCount == 1) {
          displayText = userAnswer;
          borderColor = Colors.blue[700]!;
          backgroundColor = Colors.blue[50]!;
        } else {
          displayText = '_______';
          borderColor = Colors.grey[400]!;
          backgroundColor = Colors.transparent;
        }
        
        spans.add(WidgetSpan(
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 4),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              border: Border.all(color: borderColor, width: 2),
              borderRadius: BorderRadius.circular(6),
              color: backgroundColor,
            ),
            child: Text(
              displayText,
              style: TextStyle(
                color: displayText != '_______' ? Colors.black : Colors.grey[600],
                fontWeight: FontWeight.w600,
                fontSize: 14,
              ),
            ),
          ),
        ));
      }
    }
    
    return RichText(
      text: TextSpan(
        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600, height: 1.4),
        children: spans,
      ),
    );
  }

  Widget _buildClearButton(QnAViewModel vm, int index) {
    return Align(
      alignment: Alignment.centerRight,
      child: TextButton.icon(
        icon: const Icon(Icons.clear, size: 16),
        label: const Text('Clear Answer'),
        onPressed: () => vm.clearSelections(index),
        style: TextButton.styleFrom(
          foregroundColor: Colors.red,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        ),
      ),
    );
  }

  Widget _buildFeedback(QuizQuestion question) {
    final isCorrect = question.isCorrect == true;
    final color = isCorrect ? Colors.green[50] : Colors.red[50];
    final borderColor = isCorrect ? Colors.green : Colors.red;
    final icon = isCorrect ? Icons.check_circle : Icons.error;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      margin: const EdgeInsets.only(top: 12),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: borderColor!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(icon, color: borderColor, size: 18),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  question.feedback ?? (isCorrect ? 'Correct!' : 'Incorrect.'),
                  style: TextStyle(color: borderColor, fontSize: 14),
                ),
              ),
            ],
          ),
          
          if (!isCorrect && question.questionType == 'fill_blank' && question.correctAnswer.contains('-'))
            _buildBlankByBlankFeedback(question),
        ],
      ),
    );
  }

  Widget _buildBlankByBlankFeedback(QuizQuestion question) {
    try {
      final userAnswers = (question.userAnswer ?? '').split('-');
      final correctAnswers = question.correctAnswer.split('-');
      
      return Padding(
        padding: const EdgeInsets.only(top: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Blank by blank feedback:',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            ...List.generate(correctAnswers.length, (index) {
              final userAnswer = index < userAnswers.length ? userAnswers[index] : 'empty';
              final correctAnswer = correctAnswers[index];
              final isCorrect = userAnswer == correctAnswer;
              
              return Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: Row(
                  children: [
                    Icon(
                      isCorrect ? Icons.check : Icons.close,
                      size: 16,
                      color: isCorrect ? Colors.green : Colors.red,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Blank ${index + 1}: ${isCorrect ? 'Correct - "$userAnswer"' : 'You said "$userAnswer", correct is "$correctAnswer"'}',
                        style: TextStyle(
                          fontSize: 13,
                          color: isCorrect ? Colors.green : Colors.red,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }),
          ],
        ),
      );
    } catch (e) {
      return const SizedBox();
    }
  }

  Widget _buildSubmitButton(QnAState state, QnAViewModel vm) {
    final allAnswered = vm.allQuestionsAnswered;
    
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 20.0),
      child: Center(
        child: ElevatedButton(
          onPressed: allAnswered && !state.isLoading
              ? () => vm.submitQuiz()
              : null,
          style: ElevatedButton.styleFrom(
            backgroundColor: allAnswered ? Colors.green[600] : Colors.grey[400],
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 16),
            textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            elevation: allAnswered ? 2 : 0,
          ),
          child: state.isLoading
              ? const SizedBox(
                  height: 20, 
                  width: 20, 
                  child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    strokeWidth: 2,
                  ),
                )
              : Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.send, size: 18),
                    const SizedBox(width: 8),
                    Text(
                      allAnswered 
                          ? 'Submit Answers' 
                          : 'Complete All Questions (${vm.answeredCount}/${vm.totalQuestions})',
                    ),
                  ],
                ),
        ),
      ),
    );
  }

  Widget _buildResults(QnAState state, QnAViewModel vm) {
    final result = state.quizResult!;
    
    return Container(
      margin: const EdgeInsets.only(top: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Column(
              children: [
                Icon(
                  Icons.celebration,
                  size: 48,
                  color: Colors.green[600],
                ),
                const SizedBox(height: 12),
                Text(
                  'Quiz Completed!',
                  style: TextStyle(
                    fontSize: 22, 
                    fontWeight: FontWeight.bold, 
                    color: Colors.green[800]
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Surah ${widget.surahTitle}',
                  style: const TextStyle(fontSize: 16, color: Colors.grey),
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 20),
          
          _buildResultCard('Score', '${result.score}%', 
              result.score >= 70 ? Colors.green : Colors.orange),
          _buildResultCard('Correct Answers', '${result.correctAnswers}/${result.totalQuestions}', 
              Colors.blue),
          _buildResultCard('Performance', result.performanceLevel, 
              Colors.purple),
          
          const SizedBox(height: 20),
          
          const Text(
            'Results:',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.grey[300]!),
            ),
            child: SingleChildScrollView(
              child: Text(
                result.detailedFeedback,
                style: const TextStyle(fontSize: 14, height: 1.4),
              ),
            ),
          ),
          
          const SizedBox(height: 24),
          
          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: () {
                    vm.resetQuiz();
                    vm.generateQuiz(widget.surahTitle);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange[700],
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  child: const Text('New Quiz'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: OutlinedButton(
                  onPressed: () => Navigator.pop(context),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  child: const Text('Back'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildResultCard(String title, String value, Color color) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: const TextStyle(fontSize: 14, color: Colors.grey),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 14, 
              fontWeight: FontWeight.bold, 
              color: color
            ),
          ),
        ],
      ),
    );
  }
}