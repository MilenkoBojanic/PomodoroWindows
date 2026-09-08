import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';
import 'package:pomodoro_windows/app/theme.dart';
import 'package:pomodoro_windows/presentation/display/display_controller.dart';
import 'package:pomodoro_windows/presentation/widgets/display_header.dart';
import 'package:pomodoro_windows/presentation/widgets/row_schedule_view.dart';
import 'package:pomodoro_windows/presentation/widgets/timeline/timeline_schedule_view.dart';
import 'package:provider/provider.dart';

class DisplayScreen extends StatefulWidget {
  const DisplayScreen({super.key});

  @override
  State<DisplayScreen> createState() => _DisplayScreenState();
}

class _DisplayScreenState extends State<DisplayScreen> {
  @override
  void initState() {
    super.initState();

    initializeDateFormatting('bs');

    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<DisplayController>().init();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Consumer<DisplayController>(
        builder: (context, controller, _) {
          return Column(
            children: [
              const DisplayHeader(),
              Expanded(
                child: _buildBody(context, controller),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildBody(BuildContext context, DisplayController controller) {
    if (controller.loading) {
      return const Center(
        child: CircularProgressIndicator(color: AppColors.accent),
      );
    }

    if (controller.error != null) {
      return _ErrorView(message: controller.error!);
    }

    final schedules = controller.runwaySchedules;
    final hasReservations = schedules.isNotEmpty;

    if (!hasReservations) {
      return _EmptyDayView(
        selectedDate: controller.selectedDate,
        isViewingToday: controller.isViewingToday,
      );
    }

    return switch (controller.viewMode) {
      DisplayViewMode.row => RowScheduleView(schedules: schedules),
      DisplayViewMode.timeline => TimelineScheduleView(
          key: ValueKey(controller.selectedDate),
        ),
    };
  }
}

class _EmptyDayView extends StatelessWidget {
  final DateTime selectedDate;
  final bool isViewingToday;

  const _EmptyDayView({
    required this.selectedDate,
    required this.isViewingToday,
  });

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('EEEE, d. MMMM yyyy.', 'bs');
    final message = isViewingToday
        ? 'Nema rezervacija za danas'
        : 'Nema rezervacija za ${dateFormat.format(selectedDate)}';

    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.event_busy_outlined,
            size: 72,
            color: AppColors.textSecondary.withValues(alpha: 0.5),
          ),
          const SizedBox(height: 16),
          Text(
            message,
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  color: AppColors.textSecondary,
                ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class _ErrorView extends StatelessWidget {
  final String message;

  const _ErrorView({required this.message});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(48),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.cloud_off, size: 64, color: Colors.redAccent),
            const SizedBox(height: 16),
            Text(
              'Greška pri učitavanju rasporeda',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 8),
            Text(
              message,
              style: Theme.of(context).textTheme.bodyLarge,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
