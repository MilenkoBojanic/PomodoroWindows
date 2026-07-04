import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:pomodoro_windows/app/theme.dart';
import 'package:pomodoro_windows/presentation/display/display_controller.dart';
import 'package:provider/provider.dart';

class DisplayHeader extends StatelessWidget {
  const DisplayHeader({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<DisplayController>();
    final now = controller.now;
    final workHours = controller.todayWorkHours;

    final timeFormat = DateFormat('HH:mm');
    final dateFormat = DateFormat('EEEE, d. MMMM yyyy.', 'bs');

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 20),
      decoration: const BoxDecoration(
        color: AppColors.surface,
        border: Border(
          bottom: BorderSide(color: AppColors.surfaceLight, width: 2),
        ),
      ),
      child: Row(
        children: [
          Image.asset('assets/logo_main.png', height: 56),
          const SizedBox(width: 24),
          Text(
            'POMODORO',
            style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                  letterSpacing: 4,
                  color: AppColors.accentBright,
                ),
          ),
          const Spacer(),
          if (workHours != null)
            Text(
              'Radno vrijeme: ${timeFormat.format(DateTime(0, 0, 0, workHours.startHour, workHours.startMinute))}'
              ' – ${timeFormat.format(DateTime(0, 0, 0, workHours.endHour, workHours.endMinute))}',
              style: Theme.of(context).textTheme.bodyLarge,
            ),
          const SizedBox(width: 40),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                timeFormat.format(now),
                style: Theme.of(context).textTheme.displayLarge?.copyWith(
                      fontFeatures: const [FontFeature.tabularFigures()],
                    ),
              ),
              Text(
                dateFormat.format(now),
                style: Theme.of(context).textTheme.bodyLarge,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
