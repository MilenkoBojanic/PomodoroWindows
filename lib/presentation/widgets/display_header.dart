import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:pomodoro_windows/app/theme.dart';
import 'package:pomodoro_windows/presentation/display/display_controller.dart';
import 'package:pomodoro_windows/presentation/widgets/display_date_picker_dialog.dart';
import 'package:provider/provider.dart';

class DisplayHeader extends StatelessWidget {
  const DisplayHeader({super.key});

  void _openDatePicker(BuildContext context, DisplayController controller) {
    DisplayDatePickerDialog.show(
      context,
      selectedDate: controller.selectedDate,
      onDateSelected: controller.selectDate,
    );
  }

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<DisplayController>();
    final now = controller.now;
    final selectedDate = controller.selectedDate;
    final workHours = controller.todayWorkHours;

    final timeFormat = DateFormat('HH:mm');
    final dateFormat = DateFormat('EEEE, d. MMMM yyyy.', 'bs');

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
      decoration: const BoxDecoration(
        color: AppColors.surface,
        border: Border(
          bottom: BorderSide(color: AppColors.surfaceLight, width: 2),
        ),
      ),
      child: Row(
        children: [
          Image.asset('assets/logo_main.png', height: 36),
          const SizedBox(width: 16),
          Text(
            'POMODORO',
            style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                  letterSpacing: 4,
                  color: AppColors.accentBright,
                ),
          ),
          const SizedBox(width: 20),
          const _ViewModeSelector(),
          const Spacer(),
          if (workHours != null)
            Text(
              'Radno vrijeme: ${timeFormat.format(DateTime(0, 0, 0, workHours.startHour, workHours.startMinute))}'
              ' – ${timeFormat.format(DateTime(0, 0, 0, workHours.endHour, workHours.endMinute))}',
              style: Theme.of(context).textTheme.bodyLarge,
            ),
          const SizedBox(width: 24),
          if (!controller.isViewingToday) ...[
            _BackToTodayButton(onTap: controller.goToToday),
            const SizedBox(width: 12),
          ],
          Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () => _openDatePicker(context, controller),
              borderRadius: BorderRadius.circular(8),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      timeFormat.format(now),
                      style: Theme.of(context).textTheme.displayLarge?.copyWith(
                            fontFeatures: const [FontFeature.tabularFigures()],
                          ),
                    ),
                    Text(
                      dateFormat.format(selectedDate),
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            color: controller.isViewingToday
                                ? AppColors.textSecondary
                                : AppColors.accentBright,
                          ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _BackToTodayButton extends StatelessWidget {
  final VoidCallback onTap;

  const _BackToTodayButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.background,
      borderRadius: BorderRadius.circular(8),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: AppColors.surfaceLight),
          ),
          child: Text(
            'Nazad',
            style: Theme.of(context).textTheme.labelLarge?.copyWith(
                  color: AppColors.accentBright,
                  letterSpacing: 0.4,
                ),
          ),
        ),
      ),
    );
  }
}

class _ViewModeSelector extends StatelessWidget {
  const _ViewModeSelector();

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<DisplayController>();
    final selected = controller.viewMode;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.surfaceLight),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _ViewModeButton(
            label: 'Rezervacije po redu',
            selected: selected == DisplayViewMode.row,
            onTap: () => controller.setViewMode(DisplayViewMode.row),
          ),
          _ViewModeButton(
            label: 'Rezervacije po satnici',
            selected: selected == DisplayViewMode.timeline,
            onTap: () => controller.setViewMode(DisplayViewMode.timeline),
          ),
        ],
      ),
    );
  }
}

class _ViewModeButton extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _ViewModeButton({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: selected ? AppColors.surfaceLight : Colors.transparent,
      borderRadius: BorderRadius.circular(7),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(7),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          child: Text(
            label,
            style: Theme.of(context).textTheme.labelLarge?.copyWith(
                  color: selected ? AppColors.accentBright : AppColors.textSecondary,
                  letterSpacing: 0.2,
                ),
          ),
        ),
      ),
    );
  }
}
