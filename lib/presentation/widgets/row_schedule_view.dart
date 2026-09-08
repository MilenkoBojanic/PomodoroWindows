import 'package:flutter/material.dart';
import 'package:pomodoro_windows/presentation/display/display_controller.dart';
import 'package:pomodoro_windows/presentation/widgets/runway_panel.dart';

class RowScheduleView extends StatelessWidget {
  final List<RunwaySchedule> schedules;

  const RowScheduleView({super.key, required this.schedules});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          for (var i = 0; i < schedules.length; i++) ...[
            if (i > 0) const SizedBox(width: 12),
            Expanded(child: RunwayPanel(schedule: schedules[i])),
          ],
        ],
      ),
    );
  }
}
