import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/services.dart' show rootBundle;


void main(){
  runApp(MaterialApp(
    home: DefaultTabController(
        length: 3,
        child: Scaffold(
      appBar: AppBar(
        title: Text('َQuran Viewer',
        style: TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.bold,
          letterSpacing: 2,
        ),),
        centerTitle: true,
        backgroundColor: Colors.indigo[200],
        bottom: TabBar(
          labelColor: Colors.indigo[100],
          indicatorColor: Colors.white,
          tabs: [
            Tab( child: Text('Surah', style: TextStyle(fontSize: 20,),)),
            Tab(child: Text('Juz', style: TextStyle(fontSize: 20,),)),
            Tab(child: Text('Page', style: TextStyle(fontSize: 20,),),),
          ],
        ),
      ),
      body: TabBarView(children: [
        SurahList(),
        Text('juz'),
        Text('page'),
      ])

    ),),
  ));
}

class Surah{
  final int number;
  final String name;
  final String englishName;
  Surah({required this.number, required this.name, required this.englishName});
  factory Surah.fromJson(Map<String, dynamic>json){
    return Surah(
      number: json['number'],
      name: json['name'],
      englishName: json['englishName'],
    );
  }

}
class SurahList extends StatefulWidget {
  const SurahList({super.key});
  @override
  State<SurahList> createState() => _SurahListState();
}
class _SurahListState extends State<SurahList>{
  List surah=[];
  bool isLoading=true;

  @override
  void initState(){
    super.initState();
    fetchSurah();
  }
  Future<void> fetchSurah() async {
    final response = await http.get(Uri.parse('https://api.alquran.cloud/v1/surah'));
    final data = jsonDecode(response.body);
    if (response.statusCode == 200){
      setState(() {
        surah=data['data'];
        isLoading=false;
      });
    } else{
      print("Failed to load surahs");
    }
  }
  @override
  Widget build(BuildContext context) {
    if(isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return ListView.builder(
      itemCount: surah.length,
      itemBuilder: (context, index) {
        final sura = surah[index];
        return ListTile(
          title: Text('${sura['englishName']} (${sura['name']})'),
          subtitle: Text('Ayahs: ${sura['numberOfAyahs']}'),
          leading: CircleAvatar(
            child: Text('${sura['number']}'),
          ),
          onTap: (){
            if (sura['number'] == 4) {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => SurahNisa_Topics(),
                ),
              );
            } else {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Topics Map available only for Surah An-Nisa (النّساء)'),
                ),
              );
            }
          },
        );
      },
    );
  }
}

class SurahNisa_Topics extends StatelessWidget {
  const SurahNisa_Topics({super.key});

  Future<List<Map<String, dynamic>>> loadTopics() async {
    final String jsonString = await rootBundle.loadString(
        'assets/data/surahNisa_topicMap.json');
    final List<dynamic> jsonData = jsonDecode(jsonString);
    return jsonData.cast<Map<String, dynamic>>();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Topics Map",
          style: TextStyle(fontWeight: FontWeight.bold),),
        backgroundColor: Colors.indigo[200],
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: loadTopics(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return const Center(child: Text('Error loading topics'));
          }

          final topics = snapshot.data!;

          return ListView.builder(
            itemCount: topics.length,
            itemBuilder: (context, index) {
              final topic = topics[index];
              final hasSubs = (topic['subtopics'] as List?)?.isNotEmpty ??
                  false;
              return Container(
                margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  border: Border.all(color: Colors.indigo.shade200),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 0),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: ExpansionTile(
                        tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        backgroundColor: Colors.indigo.shade100,
                        collapsedBackgroundColor: Colors.indigo[200],
                        title: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: Colors.indigo.shade400,
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
                            Expanded(
                              child: Text(
                                topic['title_ar'],
                                style: const TextStyle(fontWeight: FontWeight.bold),
                                textDirection: TextDirection.rtl,
                                textAlign: TextAlign.right,
                              ),
                            ),
                          ],
                        ),
                        subtitle: topic['title_en'] != ''
                            ? Text(
                          topic['title_en'],
                          textDirection: TextDirection.ltr,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        )
                            : null,
                        children: hasSubs
                            ? (topic['subtopics'] as List).map<Widget>((sub) {
                          return ListTile(
                            contentPadding: const EdgeInsets.symmetric(horizontal: 20),
                            title: Text(
                              '${sub['id']} - ${sub['en']}',
                              style: const TextStyle(fontWeight: FontWeight.bold),
                            ),
                            subtitle: Text(
                              sub['ar'],
                              textDirection: TextDirection.rtl,
                              style: const TextStyle(fontWeight: FontWeight.bold),
                            ),
                            onTap: () {},
                          );
                        }).toList()
                            : [],
                      ),
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




