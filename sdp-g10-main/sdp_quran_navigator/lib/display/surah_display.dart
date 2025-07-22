import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sdp_quran_navigator/display/quran_viewer_screen.dart';
import '../providers/surah_provider.dart';
import '../models/surah.dart';
import '../display/topicsmapsurahalnisa.dart';

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
                color: Colors.indigo[200],
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
                          color: Colors.indigo[300],
                          shape: BoxShape.circle,
                        ),
                        child: Text(
                          '${surah.id}',
                          style: TextStyle(
                            color: Colors.black,
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
                            surah.englishName,
                            style: TextStyle(
                              color: Colors.black,
                              fontFamily: 'CrimsonText',
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 4),
                          Text(
                            '${surah.ayaCount} Ayahs',
                            style: TextStyle(
                              color: Colors.grey[800],
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
                      color: Colors.black,
                      fontFamily: 'Hafs',
                      fontWeight: FontWeight.bold,
                      fontSize: 32,
                    ),
                  ),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            QuranViewerScreen(pageNumber: surah.page),
                      ),
                    );
                  },
                ),
              ),
            ),
            InkWell(
              onTap: () {
                if (surah.id == 4) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => SurahNisa_Topics(),
                    ),
                  );
                } else {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          QuranViewerScreen(pageNumber: surah.page),
                    ),
                  );
                }
              },
              borderRadius: BorderRadius.circular(50),
              child: Container(
                padding: EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.indigo[100],
                  shape: BoxShape.circle,
                ),
                child: Image.asset(
                  'assets/images/5054253-200.png',
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