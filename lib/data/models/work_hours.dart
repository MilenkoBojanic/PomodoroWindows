class WorkHours {
  final int startHour;
  final int startMinute;
  final int endHour;
  final int endMinute;

  const WorkHours({
    required this.startHour,
    required this.startMinute,
    required this.endHour,
    required this.endMinute,
  });

  factory WorkHours.fromJson(Map<String, dynamic> json) {
    return WorkHours(
      startHour: json['start_hour'] as int,
      startMinute: json['start_minute'] as int,
      endHour: json['end_hour'] as int,
      endMinute: json['end_minute'] as int,
    );
  }
}
