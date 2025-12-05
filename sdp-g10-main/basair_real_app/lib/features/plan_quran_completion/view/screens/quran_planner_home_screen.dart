import 'package:basair_real_app/core/widgets/basair_app_bar.dart';
import 'package:basair_real_app/features/plan_quran_completion/view/screens/quran_planner_dashboard_screen.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class QuranPlannerHomeScreen extends StatelessWidget {
  const QuranPlannerHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: Colors.indigo.shade50,
        appBar: BasairAppBar(
          title: "Quran Planner",
          actions: [
            IconButton(
              hoverColor: Colors.indigo.shade200,
              iconSize: 40,
              icon: Icon(Icons.add_circle_outline, color: Colors.black),
              tooltip: "Create Plan",
              onPressed: () {
                GoRouter.of(context).push('/quranPlannerAdding');
              },
            )
          ],
          showBackButton: true,
        ),
        body: QuranPlannerDashboard(),
      ),
    );
  }
}
