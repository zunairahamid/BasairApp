import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class SurahNisa_Topics extends StatelessWidget {
  const SurahNisa_Topics({super.key});

  Future<Map<String, dynamic>> loadTopics() async {
    try {
      final String jsonString = await rootBundle.loadString(
          'assets/data/surahNisa_topicMap.json');
      final Map<String, dynamic> jsonData = jsonDecode(jsonString);
      return jsonData;
    } catch (e) {
      throw Exception('Failed to load topics: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Surah An-Nisa Topics Map",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.indigo[200],
      ),
      body: FutureBuilder<Map<String, dynamic>>(
        future: loadTopics(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(
                color: Colors.indigo,
              ),
            );
          } else if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, color: Colors.red, size: 48),
                  const SizedBox(height: 16),
                  Text(
                    'Error loading topics',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    snapshot.error.toString(),
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ],
              ),
            );
          }

          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(
              child: Text('No topics available'),
            );
          }

          final topicsData = snapshot.data!;
          final topicsList = topicsData['topics'] as List<dynamic>? ?? [];

          return ListView.separated(
            padding: const EdgeInsets.all(12),
            itemCount: topicsList.length,
            separatorBuilder: (context, index) => const SizedBox(height: 8),
            itemBuilder: (context, index) {
              final topic = topicsList[index] as Map<String, dynamic>;
              final subtopics = topic['subtopics'] as List<dynamic>? ?? [];
              final hasSubs = subtopics.isNotEmpty;
              
              return Card(
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
                child: ExpansionTile(
                  initiallyExpanded: index == 0,
                  tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  backgroundColor: Colors.indigo.shade50,
                  collapsedBackgroundColor: Colors.indigo[100],
                  iconColor: Colors.indigo,
                  textColor: Colors.black,
                  collapsedTextColor: Colors.black,
                  childrenPadding: const EdgeInsets.only(bottom: 8),
                  title: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.indigo[400],
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          'Topic ${topic['id']}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (topic['title_ar'] != null && topic['title_ar'].isNotEmpty)
                              Text(
                                topic['title_ar'],
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                                textDirection: TextDirection.rtl,
                              ),
                            if (topic['title_en'] != null && topic['title_en'].isNotEmpty)
                              Text(
                                topic['title_en'],
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                ),
                              ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  children: hasSubs
                      ? subtopics.map<Widget>((sub) {
                          final subMap = sub as Map<String, dynamic>;
                          return Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            child: Card(
                              margin: const EdgeInsets.only(bottom: 8),
                              color: Colors.grey[50],
                              child: ListTile(
                                contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 16, vertical: 8),
                                title: Text(
                                  '${subMap['id']}. ${subMap['en']}',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                subtitle: subMap['ar'] != null && subMap['ar'].isNotEmpty
                                    ? Text(
                                        subMap['ar'],
                                        textDirection: TextDirection.rtl,
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                        ),
                                      )
                                    : null,
                                onTap: () {
                                  // Add navigation or action here
                                },
                              ),
                            ),
                          );
                        }).toList()
                      : [
                          const Padding(
                            padding: EdgeInsets.all(16),
                            child: Text('No subtopics available'),
                          )
                        ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}