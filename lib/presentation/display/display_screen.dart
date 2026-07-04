import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:pomodoro_windows/app/theme.dart';
import 'package:pomodoro_windows/presentation/display/display_controller.dart';
import 'package:pomodoro_windows/presentation/widgets/display_header.dart';
import 'package:pomodoro_windows/presentation/widgets/runway_panel.dart';
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
          if (controller.loading) {
            return const Center(
              child: CircularProgressIndicator(color: AppColors.accent),
            );
          }

          if (controller.error != null) {
            return _ErrorView(message: controller.error!);
          }

          final schedules = controller.runwaySchedules;

          return Column(
            children: [
              const DisplayHeader(),
              Expanded(
                child: schedules.isEmpty
                    ? _EmptyDayView()
                    : Padding(
                        padding: const EdgeInsets.all(24),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            for (var i = 0; i < schedules.length; i++) ...[
                              if (i > 0) const SizedBox(width: 20),
                              Expanded(child: RunwayPanel(schedule: schedules[i])),
                            ],
                          ],
                        ),
                      ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _EmptyDayView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
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
            'Nema rezervacija za danas',
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  color: AppColors.textSecondary,
                ),
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
