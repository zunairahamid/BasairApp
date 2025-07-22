import 'package:flutter/material.dart';
import 'package:sdp_quran_navigator/display/juz_display.dart';
import 'package:sdp_quran_navigator/display/page_display.dart';
import 'package:sdp_quran_navigator/display/signup_screen.dart';
import 'package:sdp_quran_navigator/display/surah_display.dart';

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
          backgroundColor: Colors.indigo[300],
          title: PageDisplay(),
          bottom: TabBar(
            indicatorColor: Colors.black,
            labelColor: Colors.black,
            unselectedLabelColor: Colors.black54,
            tabs: [
              Tab(text: 'Surah'),
              Tab(text: 'Juz'),
            ],
            labelStyle: TextStyle(
              fontFamily: 'CrimsonText',
              fontSize: 16,
              fontWeight: FontWeight.normal,
            ),
          ),
        ),
        body: TabBarView(
          children: [
            SurahDisplay(),
            JuzDisplay(),
          ],
        ),
        floatingActionButton: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            FloatingActionButton(
              heroTag: 'addContent',
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => SignupScreen()),
                );
              },
              backgroundColor: Colors.indigo[100],
              child: const Text('Add', style: TextStyle(color: Colors.black)),
            ),
            SizedBox(height: 16),
            FloatingActionButton(
              heroTag: 'reviewContent',
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => SignupScreen()),
                );
              },
              backgroundColor: Colors.indigo[100],
              child: const Text('Review', style: TextStyle(color: Colors.black)),
            ),
          ],
        ),
      ),
    );
  }
}