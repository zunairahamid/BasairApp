import 'package:flutter/material.dart';
import 'package:basair_real_app/features/plan_quran_completion/model/entities/quran_plan.dart';

class PlanCard extends StatelessWidget {
  final QuranPlan plan;
  final VoidCallback onDelete;
  final VoidCallback onViewProgress;
  final VoidCallback onTap;
  final int daysRemaining;
  final bool isPlanOverdue;

  const PlanCard({
    super.key,
    required this.plan,
    required this.onDelete,
    required this.onViewProgress,
    required this.onTap,
    required this.daysRemaining,
    required this.isPlanOverdue,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.indigo[200],
      margin: EdgeInsets.symmetric(vertical: 5),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(30),
      ),
      child: ListTile(
        contentPadding: EdgeInsets.all(12),
        onTap: onTap,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              plan.planName,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                fontFamily: 'CrimsonText',
              ),
            ),
            SizedBox(height: 8),
            Row(
              children: [
                labels(plan.planType),
                SizedBox(width: 8),
                labels(
                  isPlanOverdue
                      ? "Please Finish Plan"
                      : "$daysRemaining days left",
                  isPlanOverdue ? Colors.red[100]! : Colors.indigo[100]!,
                ),
              ],
            ),
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: Icon(Icons.bar_chart, size: 25, color: Colors.black),
              onPressed: onViewProgress,
            ),
            IconButton(
              icon: Icon(Icons.delete, size: 25, color: Colors.black),
              onPressed: onDelete,
            ),
          ],
        ),
      ),
    );
  }

  Widget labels(String text, [Color? color]) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color ?? Colors.indigo[100],
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
