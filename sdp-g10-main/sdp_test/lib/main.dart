import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sdp_test/display/juz_display.dart';
import 'package:sdp_test/display/page_display.dart';
import 'package:sdp_test/display/surah_display.dart';

void main() {
  runApp(ProviderScope(child: MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: QuranNavigator(),
    );
  }
}

class QuranNavigator extends StatefulWidget {
  const QuranNavigator({super.key});

  @override
  _QuranNavigatorState createState() => _QuranNavigatorState();
}

class _QuranNavigatorState extends State<QuranNavigator> {
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: const Color.fromARGB(213, 3, 22, 11),
          title: PageDisplay(),
          bottom: TabBar(
            indicatorColor: const Color.fromARGB(255, 169, 197, 170),
            tabs: [_buildTab('Surah'), _buildTab('Juz')],
          ),
        ),
        body: TabBarView(children: [SurahDisplay(), JuzDisplay()]),
      ),
    );
  }

  Widget _buildTab(String text) {
    return Tab(
      child: Container(
        decoration: BoxDecoration(
          color: const Color.fromARGB(136, 119, 183, 140),
          borderRadius: BorderRadius.circular(70),
        ),
        padding: EdgeInsets.symmetric(vertical: 5, horizontal: 10),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(width: 2),
            Text(
              text,
              style: TextStyle(
                color: const Color.fromARGB(255, 197, 213, 198),
                fontFamily: 'CrimsonText',
                fontSize: 16,
                fontWeight: FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
