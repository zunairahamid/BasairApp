// services/qna_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:riverpod/riverpod.dart';
import '../../ai_generate_tafsir/service/tafsir_service.dart';
import '../../ai_generate_tafsir/viewmodel/tafsir_viewmodel.dart';
import '../model/quiz.dart';

class QnAService {
  final String baseUrl;
  final TafsirService tafsirService;

  QnAService({String baseUrl = 'https://api.openai.com/v1', required this.tafsirService}) 
    : baseUrl = baseUrl.trim();

  Future<List<QuizQuestion>> generateQuiz(String surahName) async {
    try {
      // Validate that this is Surah Al-Nisa
      if (!_isSurahAlNisa(surahName)) {
        throw Exception('Quiz generation is currently only available for Surah Al-Nisa (An-Nisa). Please select Surah Al-Nisa to generate a quiz.');
      }

      // Load environment variables
      await dotenv.load();
      final apiKey = dotenv.env['OPENAI_API_KEY'];
      
      if (apiKey == null || apiKey.isEmpty) {
        throw Exception('OpenAI API key not found. Please check your OPENAI_API_KEY in .env file');
      }

      // Get surah data from TafsirService to provide context to AI
      final surahId = _extractSurahId(surahName);
      final surahData = await getSurahData(surahId);
      
      if (surahData.isEmpty) {
        throw Exception('No tafsir data available for Surah $surahName');
      }

      print('🚀 Generating PURE AI quiz for Surah: $surahName');
      
      // Prepare the prompt content
      final promptContent = _buildPromptContent(surahData);
      
      final response = await http.post(
        Uri.parse('$baseUrl/chat/completions'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $apiKey',
        },
        body: jsonEncode({
          'model': 'gpt-3.5-turbo',
          'messages': [
            {
              'role': 'system',
              'content': '''You are an expert Islamic scholar specializing in Surah Al-Nisa (The Women). 
              Generate comprehensive quiz questions with detailed educational feedback based EXCLUSIVELY on Surah Al-Nisa content.
              
              IMPORTANT: You MUST return a valid JSON object with quiz questions. Do not include any other text or explanations.'''
            },
            {
              'role': 'user', 
              'content': promptContent
            }
          ],
          'max_tokens': 4000,
          'temperature': 0.7,
          'response_format': {'type': 'json_object'},
        }),
      );

      print('🤖 AI Response Status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final questions = parseAIResponse(response.body);
        
        if (questions.isEmpty) {
          throw Exception('AI generated no valid questions. Please try again.');
        }
        
        print('✅ Successfully generated ${questions.length} PURE AI questions for $surahName');
        return questions;
      } else if (response.statusCode == 401) {
        throw Exception('Invalid API key. Please check your OPENAI_API_KEY in .env file.');
      } else if (response.statusCode == 429) {
        throw Exception('API rate limit exceeded. Please try again later.');
      } else {
        throw Exception('API Error: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      print('❌ PURE AI Quiz generation error: $e');
      throw Exception('Failed to generate PURE AI quiz: $e');
    }
  }

  // New method to get surah data from TafsirService
  Future<Map<String, dynamic>> getSurahData(int surahId) async {
    try {
      await tafsirService.ensureDataLoaded();
      final mahawerList = await tafsirService.loadMahawer(surahId);
      final surahInfo = await tafsirService.getSurahInfo(surahId);
      
      // Convert mahawer data to a format suitable for AI prompt
      final mahawerData = mahawerList.map((mahawer) {
        return {
          'title': mahawer.title,
          'text': mahawer.text,
          'startAya': mahawer.startAya,
          'endAya': mahawer.endAya,
          'type': mahawer.type,
          'sections': mahawer.sections?.map((section) {
            return {
              'title': section.title,
              'text': section.text,
              'type': section.type,
              'conclusion': section.conclusion,
            };
          }).toList(),
        };
      }).toList();

      return {
        'surahInfo': surahInfo,
        'mahawer': mahawerData,
        'author': tafsirService.getAuthor(),
        'publicationInfo': tafsirService.getPublicationInfo(),
      };
    } catch (e) {
      print('❌ Error getting surah data from TafsirService: $e');
      return {};
    }
  }

  bool _isSurahAlNisa(String surahName) {
    final cleanName = surahName.replaceAll('Surah', '').trim().toLowerCase();
    
    final alNisaNames = {
      'an-nisa', 'an nisa', 'النساء', 'an-nisa\'', 
      'an-nisaa', 'nisa', 'nisaa', 'women',
      'al-nisa', 'al nisa', 'an nisaa', 'al-nisaa',
      'an-nisa\'', 'an nisa\'', 'surah nisa', 'surah an-nisa',
      'surah al-nisa', 'surah an nisa', 'surah al nisa',
      'nisa\'', 'nisa\''
    };
    
    return alNisaNames.contains(cleanName);
  }

  String _buildPromptContent(Map<String, dynamic> surahData) {
    // Build comprehensive context from surah data
    String context = 'Surah Al-Nisa Context:\n\n';
    
    if (surahData['mahawer'] != null && surahData['mahawer'] is List) {
      final mahawerList = surahData['mahawer'] as List;
      for (final mahawer in mahawerList) {
        context += '• ${mahawer['title']}: ${mahawer['text']}\n';
        if (mahawer['sections'] != null) {
          for (final section in mahawer['sections'] as List) {
            context += '  - ${section['title']}: ${section['text']}\n';
          }
        }
      }
    }

    return '''Create 4-7 comprehensive quiz questions about Surah Al-Nisa (Chapter 4) with DETAILED EDUCATIONAL FEEDBACK. 
    Include a VARIETY of question types: multiple choice (mcq), multiple select, and fill-in-the-blank questions.

$context

IMPORTANT: Return ONLY valid JSON in this exact format:
{
  "questions": [
    {
      "id": "1",
      "question": "Multiple choice question about Surah Al-Nisa?",
      "question_type": "mcq",
      "correct_answer": "a",
      "feedback": "COMPREHENSIVE DETAILED EXPLANATION covering:
• Why the correct answer is right with specific verse references
• Historical context and circumstances of revelation
• Islamic principles and values demonstrated
• Practical applications in Muslim life
• Why other options are incorrect
• Broader Quranic connections and lessons",
      "selectable_options": [
        {"value": "a", "display_text": "Correct option based on Surah Al-Nisa"},
        {"value": "b", "display_text": "Plausible but incorrect option"},
        {"value": "c", "display_text": "Incorrect option"},
        {"value": "d", "display_text": "Clearly wrong option"}
      ]
    },
    {
      "id": "2",
      "question": "Multiple select question about Surah Al-Nisa?",
      "question_type": "multiple_select",
      "correct_answer": "a,b,c",
      "feedback": "COMPREHENSIVE DETAILED EXPLANATION...",
      "selectable_options": [
        {"value": "a", "display_text": "Correct option 1"},
        {"value": "b", "display_text": "Correct option 2"},
        {"value": "c", "display_text": "Correct option 3"},
        {"value": "d", "display_text": "Incorrect option"}
      ]
    },
    {
      "id": "3",
      "question": "Fill in the blank: Surah Al-Nisa emphasizes ______ for orphans and ______ for women.",
      "question_type": "fill_blank",
      "correct_answer": "protection-rights",
      "feedback": "COMPREHENSIVE DETAILED EXPLANATION...",
      "selectable_options": [
        {"value": "protection", "display_text": "protection"},
        {"value": "rights", "display_text": "rights"},
        {"value": "justice", "display_text": "justice"},
        {"value": "inheritance", "display_text": "inheritance"},
        {"value": "obligations", "display_text": "obligations"}
      ]
    }
  ]
}

CRITICAL REQUIREMENTS FOR COMPREHENSIVE FEEDBACK:
1. VERSE REFERENCES: Always mention specific verses from Surah Al-Nisa (e.g., "Verse 4:11 states...")
2. HISTORICAL CONTEXT: Explain the circumstances of revelation when relevant
3. ISLAMIC PRINCIPLES: Connect to broader Islamic values and ethics
4. PRACTICAL APPLICATION: Explain how this teaching applies to modern Muslim life
5. ERROR ANALYSIS: Explain why each incorrect option is wrong
6. EDUCATIONAL VALUE: Make this a learning opportunity with deep insights
7. QURANIC CONNECTIONS: Relate to other relevant Quranic teachings

SURAH AL-NISA KEY THEMES TO COVER:
• Rights and protection of orphans (verses 2-10)
• Women's rights in marriage, divorce, and inheritance (verses 3-4, 11-12, 19-22, 34)
• Inheritance laws and financial justice (verses 7-12, 176)
• Family relations and marital harmony (verses 1, 34-35, 128)
• Legal rulings and social justice (verses 13-14, 58-59, 105-115)
• Prohibited marriage relationships (verses 22-24)
• Justice, testimony, and community affairs (verses 58, 105, 135)

SPECIFIC INSTRUCTIONS:
1. Generate 4-7 questions (not always 5)
2. Include at least 1 multiple_select question
3. Include at least 1 fill_blank question
4. Use ___ for blanks in fill_blank questions
5. For multiple_select, separate correct answers with commas (e.g., "a,b,c")
6. For fill_blank with multiple blanks, separate correct answers with hyphens (e.g., "protection-rights")

Return ONLY the JSON, no other text.''';
  }

  int _extractSurahId(String surahName) {
    return 4; // Always return 4 for Al-Nisa
  }

  List<QuizQuestion> parseAIResponse(String responseBody) {
    try {
      print('🔍 Parsing AI response...');
      
      final Map<String, dynamic> data = jsonDecode(responseBody);
      final List<dynamic>? choices = data['choices'] as List?;
      
      if (choices == null || choices.isEmpty) {
        throw Exception('No AI response received from API');
      }

      final Map<String, dynamic> firstChoice = choices.first as Map<String, dynamic>;
      final Map<String, dynamic> message = firstChoice['message'] as Map<String, dynamic>;
      
      String content = message['content'] as String;
      
      print('📄 Raw AI content length: ${content.length} characters');
      
      // Clean content
      content = content.trim();
      if (content.startsWith('```json')) {
        content = content.substring(7).trim();
      }
      if (content.endsWith('```')) {
        content = content.substring(0, content.length - 3).trim();
      }
      
      print('🔍 Parsing JSON content...');
      final Map<String, dynamic> quizData = jsonDecode(content);
      print('📊 JSON keys found: ${quizData.keys.join(', ')}');
      
      // Find questions array
      List<dynamic>? questionsJson;
      if (quizData['questions'] != null && quizData['questions'] is List) {
        questionsJson = quizData['questions'] as List;
      } else {
        // Try to find any array that might contain questions
        for (final key in quizData.keys) {
          if (quizData[key] is List) {
            final potentialList = quizData[key] as List;
            if (potentialList.isNotEmpty) {
              final firstItem = potentialList.first;
              if (firstItem is Map) {
                final firstItemMap = Map<String, dynamic>.from(firstItem);
                if (firstItemMap.containsKey('question') || firstItemMap.containsKey('text')) {
                  questionsJson = potentialList;
                  print('✅ Found questions in key: $key');
                  break;
                }
              }
            }
          }
        }
      }

      if (questionsJson == null || questionsJson.isEmpty) {
        print('❌ No questions found in response');
        print('📊 Available data: $quizData');
        throw Exception('No questions found in AI response');
      }

      print('📊 Found ${questionsJson.length} potential questions');
      
      // Validate we have between 4-7 questions
      if (questionsJson.length < 4 || questionsJson.length > 7) {
        print('⚠️ Warning: Got ${questionsJson.length} questions, expected 4-7');
      }

      final List<QuizQuestion> questions = [];
      int questionCount = 0;
      
      // Track question types for variety
      Map<String, int> typeCount = {'mcq': 0, 'multiple_select': 0, 'fill_blank': 0};
      
      for (final dynamic q in questionsJson) {
        questionCount++;
        if (q is Map) {
          try {
            final question = _parseQuestion(q, questionCount);
            if (question != null) {
              questions.add(question);
              typeCount[question.questionType] = (typeCount[question.questionType] ?? 0) + 1;
            }
          } catch (e) {
            print('❌ Error parsing question $questionCount: $e');
          }
        }
      }

      if (questions.isEmpty) {
        throw Exception('Could not parse any valid questions from AI response');
      }

      // Log question type distribution
      print('📊 Question type distribution:');
      typeCount.forEach((type, count) {
        if (count > 0) print('  • $type: $count questions');
      });
      
      print('✅ Successfully parsed ${questions.length} questions with variety');
      return questions;
    } catch (e) {
      print('❌ AI response parsing error: $e');
      throw Exception('Failed to parse AI response: $e');
    }
  }

  QuizQuestion? _parseQuestion(dynamic questionData, int questionCount) {
    try {
      print('🔍 Parsing question $questionCount...');
      
      // Convert to Map<String, dynamic> safely
      final Map<String, dynamic> questionMap;
      if (questionData is Map<String, dynamic>) {
        questionMap = questionData;
      } else if (questionData is Map) {
        questionMap = Map<String, dynamic>.from(questionData);
      } else {
        print('⚠️ Skipping question $questionCount: Invalid data type');
        return null;
      }
      
      // Get question text
      String questionText = getFieldValue(questionMap, ['question', 'text', 'query']);
      if (questionText.isEmpty) {
        print('⚠️ Skipping question $questionCount: No question text found');
        return null;
      }

      // Get correct answer
      String correctAnswer = getFieldValue(questionMap, ['correct_answer', 'answer', 'correct']);
      if (correctAnswer.isEmpty) {
        print('⚠️ Skipping question $questionCount: No correct answer found');
        return null;
      }

      // Get question type
      String questionType = getFieldValue(questionMap, ['question_type', 'type', 'questionType'], 'mcq').toLowerCase();
      
      // Validate and normalize question type
      if (questionType == 'multiple_choice') questionType = 'mcq';
      if (questionType == 'fill_in_blank' || questionType == 'fill_in_the_blank') questionType = 'fill_blank';
      
      // If type is not recognized, infer from structure
      if (!['mcq', 'multiple_select', 'fill_blank'].contains(questionType)) {
        if (questionText.contains('___') || correctAnswer.contains('-')) {
          questionType = 'fill_blank';
        } else if (correctAnswer.contains(',')) {
          questionType = 'multiple_select';
        } else {
          questionType = 'mcq';
        }
        print('⚠️ Inferred question type as: $questionType');
      }

      // Get feedback
      final feedback = getFieldValue(questionMap, ['feedback', 'explanation', 'hint', 'detail']);

      // Parse options
      final options = _parseOptions(questionMap, questionCount);
      if (options.length < 2) {
        print('⚠️ Skipping question $questionCount: Not enough options (${options.length})');
        return null;
      }

      final question = QuizQuestion(
        id: getFieldValue(questionMap, ['id', 'question_id'], questionCount.toString()),
        question: questionText,
        questionType: questionType,
        correctAnswer: correctAnswer,
        selectableOptions: options,
        feedback: feedback.isNotEmpty ? feedback : _generateComprehensiveFeedback(questionText, correctAnswer, options),
        sourceSection: 'Surah Al-Nisa',
      );

      print('✅ Added question type $questionType: ${question.id}');
      return question;
    } catch (e) {
      print('❌ Error parsing question $questionCount: $e');
      return null;
    }
  }

  List<SelectableOption> _parseOptions(Map<String, dynamic> questionData, int questionCount) {
    final List<SelectableOption> options = [];
    
    // Try different option structures
    if (questionData['selectable_options'] is List) {
      final optionsList = questionData['selectable_options'] as List;
      for (final dynamic opt in optionsList) {
        if (opt is Map) {
          final Map<String, dynamic> optMap = _convertToStringDynamicMap(opt);
          final value = getFieldValue(optMap, ['value', 'id', 'key']);
          final displayText = getFieldValue(optMap, ['display_text', 'displayText', 'text', 'option']);
          if (value.isNotEmpty && displayText.isNotEmpty) {
            options.add(SelectableOption(
              value: value,
              displayText: displayText,
              isSelected: false,
            ));
          }
        }
      }
    }
    
    // Try 'options' as Map
    if (options.isEmpty && questionData['options'] is Map) {
      final optionsMap = questionData['options'] as Map;
      optionsMap.forEach((key, value) {
        if (key != null && value != null) {
          options.add(SelectableOption(
            value: key.toString(),
            displayText: value.toString(),
            isSelected: false,
          ));
        }
      });
    }
    
    // Try 'options' as List
    if (options.isEmpty && questionData['options'] is List) {
      final optionsList = questionData['options'] as List;
      for (int i = 0; i < optionsList.length; i++) {
        final dynamic opt = optionsList[i];
        if (opt != null) {
          final value = String.fromCharCode(97 + i); // a, b, c, d
          String displayText;
          if (opt is Map) {
            final optMap = _convertToStringDynamicMap(opt);
            displayText = getFieldValue(optMap, ['text', 'option']);
          } else {
            displayText = opt.toString();
          }
          if (displayText.isNotEmpty) {
            options.add(SelectableOption(
              value: value,
              displayText: displayText,
              isSelected: false,
            ));
          }
        }
      }
    }
    
    // Try 'choices' as List
    if (options.isEmpty && questionData['choices'] is List) {
      final choicesList = questionData['choices'] as List;
      for (int i = 0; i < choicesList.length; i++) {
        final dynamic choice = choicesList[i];
        if (choice != null) {
          final value = String.fromCharCode(97 + i);
          String displayText;
          if (choice is Map) {
            final choiceMap = _convertToStringDynamicMap(choice);
            displayText = getFieldValue(choiceMap, ['text', 'choice']);
          } else {
            displayText = choice.toString();
          }
          if (displayText.isNotEmpty) {
            options.add(SelectableOption(
              value: value,
              displayText: displayText,
              isSelected: false,
            ));
          }
        }
      }
    }

    print('📝 Question $questionCount: Found ${options.length} options');
    return options;
  }

  Map<String, dynamic> _convertToStringDynamicMap(dynamic map) {
    if (map is Map<String, dynamic>) {
      return map;
    } else if (map is Map) {
      return Map<String, dynamic>.from(map);
    } else {
      return <String, dynamic>{};
    }
  }

  String getFieldValue(Map<String, dynamic> map, List<String> possibleKeys, [String defaultValue = '']) {
    for (final key in possibleKeys) {
      if (map.containsKey(key) && map[key] != null) {
        final value = map[key].toString();
        if (value.isNotEmpty) {
          return value;
        }
      }
    }
    return defaultValue;
  }

  String _generateComprehensiveFeedback(String question, String correctAnswer, List<SelectableOption> options) {
    String correctText = '';
    for (final option in options) {
      if (option.value == correctAnswer) {
        correctText = option.displayText;
        break;
      }
    }
    
    return '''COMPREHENSIVE EXPLANATION - SURAH AL-NISA:

📖 **Correct Answer Analysis:**
The correct answer is "$correctText". This reflects the comprehensive teachings of Surah Al-Nisa (Chapter 4), which revolutionized social justice in 7th century Arabia.

🎯 **Quranic Basis:**
Surah Al-Nisa extensively addresses social legislation, with specific verses establishing:
• Protection of orphans' rights (4:2-10)
• Women's financial rights in marriage and inheritance (4:4, 4:11-12)
• Family justice and marital harmony (4:19, 4:34-35)
• Legal testimony and social responsibility (4:58, 4:135)

🌍 **Historical Context:**
Revealed in Medina, these verses addressed specific social challenges faced by the early Muslim community, establishing unprecedented rights for women and vulnerable members of society.

💡 **Islamic Principles:**
This teaching demonstrates core Islamic values of:
• Adl (Justice) and Ihsan (Excellence)
• Protection of vulnerable populations
• Economic justice and fair wealth distribution
• Family as the foundation of society

🔄 **Modern Application:**
These principles continue to guide Islamic family law, inheritance systems, and social welfare practices in Muslim communities worldwide.

🔍 **Educational Insight:**
Surah Al-Nisa's comprehensive social legislation represents one of the Quran's most significant contributions to human rights, establishing protections that were revolutionary for their time and remain relevant today.''';
  }

  Future<QuizQuestion> submitAnswer(QuizQuestion question, String userAnswer) async {
    try {
      final isCorrect = _checkAnswerCorrectness(question, userAnswer);
      
      String feedback;
      if (question.feedback != null && question.feedback!.isNotEmpty) {
        if (isCorrect) {
          feedback = '🎉 EXCELLENT! YOU GOT IT RIGHT!\n\n${question.feedback}';
        } else {
          feedback = '💡 LEARNING OPPORTUNITY\n\nThe correct answer is ${question.correctAnswer}.\n\n${question.feedback}';
        }
      } else {
        feedback = isCorrect 
            ? '🎉 Correct! Excellent understanding of Surah Al-Nisa\'s teachings.' 
            : '💡 The correct answer is ${question.correctAnswer}. Review Surah Al-Nisa for deeper understanding.';
      }
      
      return question.copyWith(
        userAnswer: userAnswer,
        isCorrect: isCorrect,
        feedback: feedback,
      );
    } catch (e) {
      return question.copyWith(
        userAnswer: userAnswer,
        isCorrect: false,
        feedback: 'Error evaluating answer. Please try again.',
      );
    }
  }

  bool _checkAnswerCorrectness(QuizQuestion question, String userAnswer) {
    if (userAnswer.isEmpty) return false;
    return userAnswer.trim().toLowerCase() == question.correctAnswer.trim().toLowerCase();
  }

  Future<QuizResult> calculateResults(List<QuizQuestion> questions, String surahTitle) async {
    try {
      final evaluatedQuestions = <QuizQuestion>[];
      
      for (final question in questions) {
        if (question.userAnswer != null && question.isCorrect == null) {
          final evaluated = await submitAnswer(question, question.userAnswer!);
          evaluatedQuestions.add(evaluated);
        } else {
          evaluatedQuestions.add(question);
        }
      }
      
      final correctAnswers = evaluatedQuestions.where((q) => q.isCorrect == true).length;
      final totalQuestions = evaluatedQuestions.length;
      final score = totalQuestions > 0 ? (correctAnswers / totalQuestions * 100).round() : 0;
      final incorrectQuestions = evaluatedQuestions.where((q) => q.isCorrect == false).toList();
      
      final performanceLevel = _calculatePerformanceLevel(score);
      final detailedFeedback = _generateResultsFeedback(
        score, correctAnswers, totalQuestions, incorrectQuestions
      );

      return QuizResult(
        score: score,
        correctAnswers: correctAnswers,
        totalQuestions: totalQuestions,
        performanceLevel: performanceLevel,
        detailedFeedback: detailedFeedback,
        incorrectQuestions: incorrectQuestions,
      );
    } catch (e) {
      throw Exception('Failed to calculate results: $e');
    }
  }

  String _calculatePerformanceLevel(int score) {
    if (score >= 90) return 'Quran Scholar 🏆';
    if (score >= 75) return 'Advanced Student 🌟';
    if (score >= 60) return 'Good Understanding 📚';
    if (score >= 50) return 'Developing Knowledge 📖';
    return 'Keep Studying 🔍';
  }

  String _generateResultsFeedback(
    int score,
    int correctAnswers,
    int totalQuestions,
    List<QuizQuestion> incorrectQuestions,
  ) {
    final incorrectSection = incorrectQuestions.isNotEmpty 
        ? '''
### 📚 Areas for Deepened Understanding:
${incorrectQuestions.map((q) => 
'**${q.question}**\n• Your answer: "${q.userAnswer ?? 'No answer'}"\n• Correct answer: "${q.correctAnswer}"\n• Learning insight: ${q.feedback?.replaceAll('🎉 EXCELLENT! YOU GOT IT RIGHT!\\n\\n', '').replaceAll('💡 LEARNING OPPORTUNITY\\n\\nThe correct answer is ${q.correctAnswer}.\\n\\n', '') ?? 'Review the comprehensive explanation above'}').join('\n\n')}'''
        : '### 🎉 MASTERFUL UNDERSTANDING!\nYou have demonstrated exceptional comprehension of Surah Al-Nisa\'s comprehensive teachings.';

    return '''
# 📖 SURAH AL-NISA QUIZ RESULTS
## Comprehensive Knowledge Assessment

## 🎯 Performance Summary
**Score:** $score% | **Correct Answers:** $correctAnswers/$totalQuestions
**Knowledge Level:** ${_calculatePerformanceLevel(score)}

$incorrectSection

## 🌟 About This Comprehensive Quiz:
• All questions and detailed explanations focus exclusively on Surah Al-Nisa (Chapter 4)
• Feedback includes verse references, historical context, Islamic principles, and modern applications
• Designed to provide deep educational value beyond simple question-answer format

## 💫 Continuing Your Quranic Journey:
${incorrectQuestions.isEmpty 
  ? '• You have mastered key concepts from Surah Al-Nisa\n• Consider studying tafsir (Quranic exegesis) for deeper insights\n• Practice applying these teachings in daily life and community contexts'
  : '• Review the comprehensive explanations for questions you missed\n• Read the actual verses of Surah Al-Nisa with translation\n• Reflect on how these teachings apply to contemporary social issues'}

*"The best among you are those who learn the Quran and teach it." - Prophet Muhammad (PBUH)*
''';
  }
}

// Riverpod Provider for QnAService
final qnaServiceProvider = Provider<QnAService>((ref) {
  final tafsirService = ref.read(tafsirServiceProvider);
  return QnAService(tafsirService: tafsirService);
});