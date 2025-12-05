import 'package:basair_real_app/features/plan_quran_completion/model/entities/quran_plan.dart';
import 'package:floor/floor.dart';

@Entity(
  tableName: 'quran_plan_daily_progress',
  foreignKeys: [
    ForeignKey(
      childColumns: ['planId'],
      parentColumns: ['planId'],
      entity: QuranPlan,
      onDelete: ForeignKeyAction.cascade,
    )
  ],
)
class QuranPlanDailyProgress {
  @PrimaryKey(autoGenerate: true)
  final int? id;
  final int planId; 
  final String date; 
  final int pagesRead;

  QuranPlanDailyProgress({
    this.id,
    required this.planId,
    required this.date,
    required this.pagesRead,
  });

  factory QuranPlanDailyProgress.fromJson(Map<String, dynamic> json) {
    return QuranPlanDailyProgress(
      id: json['id'] as int?,
      planId: json['planId'] as int,
      date: json['date'] as String,
      pagesRead: json['pagesRead'] as int,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'planId': planId,
      'date': date,
      'pagesRead': pagesRead,
    };
  }

  QuranPlanDailyProgress copyWith({
    int? id,
    int? planId,
    String? date,
    int? pagesRead,
  }) {
    return QuranPlanDailyProgress(
      id: id ?? this.id,
      planId: planId ?? this.planId,
      date: date ?? this.date,
      pagesRead: pagesRead ?? this.pagesRead,
    );
  }

  @override
  String toString() {
    return 'QuranPlanDailyProgress{id: $id, planId: $planId, date: $date, pagesRead: $pagesRead}';
  }
}
