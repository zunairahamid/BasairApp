import 'package:floor/floor.dart';

@Entity(tableName: 'quran_plans')
class QuranPlan{
  @PrimaryKey(autoGenerate: true)
  final int planId;

  final String planName;
  final String planType;
  final int? surahId;
  final int? juzId;
  final String startDate;
  final int targetDays;
  final bool isPlanComplete;

  QuranPlan({
    required this.planId,
    required this.planName,
    required this.planType,
    this.surahId,
    this.juzId,
    required this.startDate,
    required this.targetDays,
    required this.isPlanComplete,
  });

  factory QuranPlan.fromJson(Map<String, dynamic> json) {
    return QuranPlan(
      planId: json['planId'] as int,
      planName: json['planName'] as String,
      planType: json['planType'] as String,
      surahId: json['surahId'] as int?,
      juzId: json['juzId'] as int?,
      startDate: json['startDate'] as String,
      targetDays: json['targetDays'] as int,
      isPlanComplete: json['isPlanComplete'] as bool,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'planId': planId,
      'planName': planName,
      'planType': planType,
      'surahId': surahId,
      'juzId': juzId,
      'startDate': startDate,
      'targetDays': targetDays,
      'isPlanComplete': isPlanComplete,
    };
  }

  QuranPlan copyWith({
    int? planId,
    String? planName,
    String? planType,
    int? surahId,
    int? juzId,
    String? startDate,
    int? targetDays,
    bool? isPlanComplete,
  }) {
    return QuranPlan(
      planId: planId ?? this.planId,
      planName: planName ?? this.planName,
      planType: planType ?? this.planType,
      surahId: surahId ?? this.surahId,
      juzId: juzId ?? this.juzId,
      startDate: startDate ?? this.startDate,
      targetDays: targetDays ?? this.targetDays,
      isPlanComplete: isPlanComplete ?? this.isPlanComplete,
    );
  }

  @override
  String toString() {
    return 'QuranPlanEntity{planId: $planId, planName: $planName, planType: $planType, surahId: $surahId, juzId: $juzId, startDate: $startDate, targetDays: $targetDays, isPlanComplete: $isPlanComplete}';
  }
}
