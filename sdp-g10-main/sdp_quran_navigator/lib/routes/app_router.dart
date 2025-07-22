import 'package:sdp_quran_navigator/display/home_screen.dart';
import 'package:sdp_quran_navigator/display/quran_navigator_screen.dart';

import '../display/signin_screen.dart';
import '../display/quran_viewer_screen.dart';
import '../display/shell_screen.dart';
import '../display/signup_screen.dart';
import '../display/topicsmapsurahalnisa.dart';
import '../models/user.dart';
import 'package:go_router/go_router.dart';

class AppRouter {
  // Route definitions
  static final navigation = (name: 'home', path: '/');
  static final quranViewer = (name: 'quranViewer', path: '/quranViewer');
  static final topicScreen = (name: 'topicScreen', path: '/topics');
  static final juzScreen = (name: 'juzScreen', path: '/juz');
  static final loginScreen = (name: 'loginScreen', path: '/login');
  static final signupScreen = (name: 'signupScreen', path: '/signup');
  
  static final router = GoRouter(
    initialLocation: navigation.path, // Typically start with login
    routes: [
      // Auth routes outside of shell
      GoRoute(
        name: loginScreen.name,
        path: loginScreen.path,
        builder: (context, state) => const SigninScreen(),
      ),
      GoRoute(
        name: signupScreen.name,
        path: signupScreen.path,
        builder: (context, state) => const SignupScreen(),
      ),
      
      // Shell route for main app navigation
      ShellRoute(
        builder: (context, state, child) {
          final user = state.extra as User?;
          return ShellScreen(
            user: user,
            child: child,
          );
        },
        routes: [
          // Home route
          GoRoute(
            name: navigation.name,
            path: navigation.path,
            builder: (context, state) => const QuranNavigator(), // Replace with your home widget

             // Replace with your home widget

          ),
          
          // Topic screen
          GoRoute(
            name: topicScreen.name,
            path: topicScreen.path,
            builder: (context, state) => SurahNisa_Topics(),
          ),
          
          // Quran viewer
          GoRoute(
            name: quranViewer.name,
            path: quranViewer.path,
            builder: (context, state) {
              final pageNumber = state.extra as int? ?? 1;
              return QuranViewerScreen(pageNumber: pageNumber);
            },
          ),
          
          // Juz screen (add your juz screen widget)
          GoRoute(
            name: juzScreen.name,
            path: juzScreen.path,
            builder: (context, state) => const QuranNavigator(), // Replace with your juz widget
          ),
        ],
      ),
    ],
  );
}