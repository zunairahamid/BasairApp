import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:basair_real_app/features/quran_navigator/view/screens/juz_display.dart';
import 'package:basair_real_app/features/quran_navigator/view/screens/page_display.dart';
import 'package:basair_real_app/features/quran_navigator/view/screens/surah_display.dart';

class QuranNavigator extends StatefulWidget {
  const QuranNavigator({super.key});

  @override
  QuranNavigatorState createState() => QuranNavigatorState();
}

class QuranNavigatorState extends State<QuranNavigator> {
  int _selectedIndex = 0;

  void _onItemTapped(int index) {
    setState(() => _selectedIndex = index);

    // 0 -> Contribute (Option / Topic Map / Reviewer/Author choice)
    // 1 -> Quran Planner screen
    switch (index) {
      case 0:
        GoRouter.of(context).push('/contribute'); // your OptionScreen / Topic Map entry
        break;
      case 1:
        GoRouter.of(context).push('/quranPlanner');
        break;
    }

    // Reset back to base tab after navigation (optional but matches your old behavior)
    if (mounted) {
      setState(() => _selectedIndex = 0);
    }
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: Colors.indigo[50],
        appBar: AppBar(
          backgroundColor: Colors.indigo[200],
          title: const PageDisplay(),
          bottom: const TabBar(
            indicatorColor: Colors.black,
            labelColor: Colors.black,
            unselectedLabelColor: Colors.black54,
            tabs: [
              Tab(text: 'Surah'),
              Tab(text: 'Juz'),
            ],
            labelStyle: TextStyle(
              letterSpacing: 1.5,
              color: Colors.black,
              fontFamily: 'CrimsonText',
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        body: const TabBarView(
          children: [
            SurahDisplay(),
            JuzDisplay(),
          ],
        ),
        bottomNavigationBar: BottomNavigationBar(
          type: BottomNavigationBarType.fixed,
          currentIndex: _selectedIndex,
          onTap: _onItemTapped,
          backgroundColor: Colors.indigo[200],
          selectedItemColor: Colors.black,
          unselectedItemColor: Colors.black54,
          showUnselectedLabels: true,
          selectedLabelStyle: const TextStyle(
            fontFamily: 'Lato',
            fontWeight: FontWeight.bold,
            letterSpacing: 1.5,
          ),
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.add_circle_outline),
              label: 'Contribute',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.schedule_outlined),
              label: 'Planner',
            ),
          ],
        ),
      ),
    );
  }
}
