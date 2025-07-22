import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sdp_test/providers/surah_provider.dart';
import '../models/surah.dart';

class SurahDisplay extends ConsumerWidget {
  const SurahDisplay({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final surahs = ref.watch(surahProvider);

    return ListView.builder(
      itemCount: surahs.length,
      itemBuilder: (context, index) {
        Surah surah = surahs.elementAt(index);
        return Row(
          children: [
            Expanded(
              child: Card(
                color: const Color.fromARGB(213, 3, 22, 11),
                margin: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(70),
                ),
                child: ListTile(
                  title: Row(
                    children: [
                      Container(
                        padding: EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: const Color.fromARGB(255, 169, 197, 170),
                          shape: BoxShape.circle,
                        ),
                        child: Text(
                          '${surah.id}',
                          style: TextStyle(
                            color: const Color.fromARGB(213, 3, 22, 11),
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      SizedBox(width: 10),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            surah.name,
                            style: TextStyle(
                              color: const Color.fromARGB(255, 169, 197, 170),
                              fontFamily: 'CrimsonText',
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 4),
                          Text(
                            '${surah.ayaCount} Ayahs',
                            style: TextStyle(
                              color: const Color.fromARGB(255, 169, 197, 170),
                              fontFamily: 'CrimsonText',
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  trailing: Text(
                    surah.name,
                    style: TextStyle(
                      color: const Color.fromARGB(210, 232, 241, 233),
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => PlaceholderScreenForSurah(),
                      ),
                    );
                  },
                ),
              ),
            ),
            InkWell(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => PlaceholderScreen()),
                );
              },
              borderRadius: BorderRadius.circular(50),
              child: Container(
                padding: EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color.fromARGB(255, 169, 197, 170),
                  shape: BoxShape.circle,
                ),
                child: Image.network(
                  'https://static.thenounproject.com/png/5054253-200.png',
                  width: 30,
                  height: 30,
                ),
              ),
            ),
            SizedBox(width: 10),
          ],
        );
      },
    );
  }
}

class PlaceholderScreen extends StatelessWidget {
  const PlaceholderScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Topics Map Screen')),
      body: Center(child: Text('This is the Topics Map Screen for Surah.')),
    );
  }
}

class PlaceholderScreenForSurah extends StatelessWidget {
  const PlaceholderScreenForSurah({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Quran Viewer Screen')),
      body: Center(
        child: Text('Displays the First Page of the Surah on Quran Viewer.'),
      ),
    );
  }
}
