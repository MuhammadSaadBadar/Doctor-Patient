// lib/patient/features/water_intake/models/weekly_water_intake.dart

class WeeklyWaterIntake {
  final Map<String, int> dailyIntake; // day -> ml

  WeeklyWaterIntake({required this.dailyIntake});

  factory WeeklyWaterIntake.fromJson(Map<String, dynamic> json) {
    return WeeklyWaterIntake(dailyIntake: Map<String, int>.from(json));
  }

  List<String> get days => ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
  int get maxValue => dailyIntake.values.isEmpty
      ? 1
      : dailyIntake.values.reduce((a, b) => a > b ? a : b);
  double getPercentage(String day) {
    final value = dailyIntake[day] ?? 0;
    return maxValue > 0 ? value / maxValue : 0;
  }
}
