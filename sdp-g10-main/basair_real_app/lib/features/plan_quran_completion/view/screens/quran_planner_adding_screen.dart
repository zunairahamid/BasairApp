import 'package:basair_real_app/core/widgets/basair_app_bar.dart';
import 'package:basair_real_app/features/plan_quran_completion/view/widgets/input_field.dart';
import 'package:basair_real_app/features/plan_quran_completion/view/widgets/plan_dropdown.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:basair_real_app/features/plan_quran_completion/view_model/providers/quran_plan_provider.dart';
import 'package:basair_real_app/features/plan_quran_completion/model/entities/quran_plan.dart';
import 'package:go_router/go_router.dart';

class QuranPlannerAddingScreen extends ConsumerStatefulWidget {
  const QuranPlannerAddingScreen({super.key});

  @override
  ConsumerState<QuranPlannerAddingScreen> createState() =>
      _QuranPlannerAddingScreenState();
}

class _QuranPlannerAddingScreenState
    extends ConsumerState<QuranPlannerAddingScreen> {
  final TextEditingController planNameController = TextEditingController();
  final TextEditingController targetDaysController = TextEditingController();

  String? planType;
  int? selectedSurah;
  int? selectedJuz;

  final List<int> surahNumbers = List.generate(114, (index) => index + 1);
  final List<int> juzNumbers = List.generate(30, (index) => index + 1);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.indigo.shade50,
      appBar: BasairAppBar(
        title: "Add Quran Plan",
        showBackButton: true,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 8, vertical: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SizedBox(height: 10),
              InputField(
                controller: planNameController,
                label: "Plan Name",
                icon: Icons.schedule,
              ),
              SizedBox(height: 10),
              // Plan Type Dropdown
              PlanDropdown<String>(
                value: planType,
                onChanged: (value) {
                  setState(() {
                    planType = value;
                    selectedSurah = null;
                    selectedJuz = null;
                  });
                },
                hintText: "Select Plan Type",
                icon: Icons.category,
              ),
              SizedBox(height: 10),
              // Surah Dropdown
              if (planType == "Surah")
                PlanDropdown<int>(
                  value: selectedSurah,
                  onChanged: (value) => setState(() => selectedSurah = value),
                  items: surahNumbers,
                  hintText: "Select Surah",
                  icon: Icons.menu_book_rounded,
                ),
              // Juz Dropdown
              if (planType == "Juz")
                PlanDropdown<int>(
                  value: selectedJuz,
                  onChanged: (value) => setState(() => selectedJuz = value),
                  items: juzNumbers,
                  hintText: "Select Juz",
                  icon: Icons.menu_book_rounded,
                ),
              SizedBox(height: 10),
              InputField(
                controller: targetDaysController,
                label: "Target Days",
                icon: Icons.calendar_today,
                isNumber: true,
              ),
              SizedBox(height: 20),
              Container(
                margin: EdgeInsets.symmetric(horizontal: 15),
                width: double.infinity,
                height: 45,
                child: TextButton(
                  onPressed: addPlan,
                  style: TextButton.styleFrom(
                    backgroundColor: Colors.indigo.shade200,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  child: Text(
                    'Add Plan',
                    style: TextStyle(
                      fontFamily: 'CrimsonText',
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                      fontSize: 20,
                      letterSpacing: 1,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void addPlan() async {
    if (planNameController.text.isEmpty ||
        planType == null ||
        targetDaysController.text.isEmpty ||
        (planType == "Surah" && selectedSurah == null) ||
        (planType == "Juz" && selectedJuz == null)) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text(
            "All fields must be filled",
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          backgroundColor: Colors.red.shade200,
        ),
      );
      return;
    }

    final addedPlan = QuranPlan(
      planId: DateTime.now().millisecondsSinceEpoch,
      planName: planNameController.text,
      planType: planType!,
      surahId: selectedSurah,
      juzId: selectedJuz,
      targetDays: int.parse(targetDaysController.text),
      startDate: DateTime.now().toIso8601String(),
      isPlanComplete: false,
    );

    await ref.read(quranPlanNotifierProvider.notifier).addPlan(addedPlan);

    if (!mounted) return;
    context.pop();
  }
}
