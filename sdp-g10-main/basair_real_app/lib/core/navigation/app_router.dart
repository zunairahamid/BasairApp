import 'package:basair_real_app/features/plan_quran_completion/view/screens/quran_planner_adding_screen.dart';
import 'package:basair_real_app/features/plan_quran_completion/view/screens/quran_planner_daily_progress_screen.dart';
import 'package:basair_real_app/features/plan_quran_completion/view/screens/quran_planner_home_screen.dart';
import 'package:basair_real_app/features/plan_quran_completion/view/screens/quran_planner_viewer_screen.dart';
import 'package:basair_real_app/features/quran_navigator/view/screens/quran_navigator_screen.dart';
import 'package:basair_real_app/features/sign_in/view/screens/option_screen.dart';
import 'package:go_router/go_router.dart';

class AppRouter {
  static final router = GoRouter(
    initialLocation: "/quranNavigator",
    routes: [
      GoRoute(
          path: "/quranNavigator",
          name: "quranNavigatorScreen",
          builder: (context, state) => QuranNavigator()),
      GoRoute(
        path: "/contribute",
        name: "contributeScreen",
        builder: (context, state) => const OptionScreen(),
      ),
      GoRoute(
          path: "/quranPlanner",
          name: "quranPlannerHomeScreen",
          builder: (context, state) => QuranPlannerHomeScreen()),
      GoRoute(
          path: "/quranPlannerAdding",
          name: "quranPlannerAddingScreen",
          builder: (context, state) => QuranPlannerAddingScreen()),
      GoRoute(
        path: '/quranPlannerViewer/:planId',
        builder: (context, state) {
          final planId = int.parse(state.pathParameters['planId']!);
          return QuranPlannerViewerScreen(planId: planId);
        },
      ),
      GoRoute(
        path:
            '/quranPlannerDailyProgress/:planId', 
        name: 'quranPlannerDailyProgressScreen',
        builder: (context, state) {
          final planId = state.pathParameters['planId']!;
          return QuranPlannerDailyProgressScreen(planId: int.parse(planId));
        },
      ),
    ],
  );
}
