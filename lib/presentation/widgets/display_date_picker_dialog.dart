import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:pomodoro_windows/app/theme.dart';

class DisplayDatePickerDialog extends StatefulWidget {
  final DateTime selectedDate;
  final ValueChanged<DateTime> onDateSelected;

  const DisplayDatePickerDialog({
    super.key,
    required this.selectedDate,
    required this.onDateSelected,
  });

  static Future<void> show(
    BuildContext context, {
    required DateTime selectedDate,
    required ValueChanged<DateTime> onDateSelected,
  }) {
    return showDialog<void>(
      context: context,
      barrierColor: Colors.black54,
      builder: (context) => DisplayDatePickerDialog(
        selectedDate: selectedDate,
        onDateSelected: onDateSelected,
      ),
    );
  }

  @override
  State<DisplayDatePickerDialog> createState() =>
      _DisplayDatePickerDialogState();
}

class _DisplayDatePickerDialogState extends State<DisplayDatePickerDialog> {
  late DateTime _focusedDay;

  DateTime get _today => DateTime.now();
  DateTime get _firstSelectableDay =>
      DateTime(_today.year, _today.month, _today.day);
  DateTime get _lastSelectableDay =>
      DateTime(_today.year + 1, _today.month, _today.day);

  @override
  void initState() {
    super.initState();
    _focusedDay = widget.selectedDate;
  }

  bool _isSelectable(DateTime day) {
    final normalized = DateTime(day.year, day.month, day.day);
    return !normalized.isBefore(_firstSelectableDay);
  }

  @override
  Widget build(BuildContext context) {
    final monthFormat = DateFormat('MMMM yyyy.', 'bs');

    return Dialog(
      backgroundColor: AppColors.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: AppColors.surfaceLight),
      ),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 420, maxHeight: 480),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      'Odaberite datum',
                      style: Theme.of(context).textTheme.headlineMedium,
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.close, color: AppColors.textSecondary),
                    tooltip: 'Zatvori',
                  ),
                ],
              ),
              Text(
                monthFormat.format(_focusedDay),
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: AppColors.accentBright,
                    ),
              ),
              const SizedBox(height: 8),
              Flexible(
                child: Theme(
                  data: Theme.of(context).copyWith(
                    colorScheme: const ColorScheme.dark(
                      primary: AppColors.accent,
                      onPrimary: AppColors.textPrimary,
                      onSurface: AppColors.textPrimary,
                      surface: AppColors.surface,
                    ),
                  ),
                  child: CalendarDatePicker(
                    initialDate: widget.selectedDate,
                    currentDate: _today,
                    firstDate: _firstSelectableDay,
                    lastDate: _lastSelectableDay,
                    onDateChanged: (date) {
                      if (!_isSelectable(date)) return;
                      widget.onDateSelected(date);
                      Navigator.of(context).pop();
                    },
                    onDisplayedMonthChanged: (month) {
                      setState(() => _focusedDay = month);
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
