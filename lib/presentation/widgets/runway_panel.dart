import 'package:flutter/material.dart';
import 'package:pomodoro_windows/app/theme.dart';
import 'package:pomodoro_windows/presentation/display/display_controller.dart';
import 'package:pomodoro_windows/presentation/widgets/reservation_card.dart';

class RunwayPanel extends StatelessWidget {
  final RunwaySchedule schedule;

  const RunwayPanel({super.key, required this.schedule});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.surfaceLight),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            decoration: const BoxDecoration(
              color: AppColors.surfaceLight,
              borderRadius: BorderRadius.vertical(top: Radius.circular(15)),
            ),
            child: Text(
              DisplayController.formatRunwayLabel(schedule.runwayId),
              style: Theme.of(context).textTheme.headlineMedium,
              textAlign: TextAlign.center,
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  if (schedule.active != null)
                    ReservationCard(
                      reservation: schedule.active!,
                      status: ReservationStatus.active,
                      fontScale: 2,
                    )
                  else
                    _EmptySlot(
                      label: 'Nema aktivnog vozila',
                      icon: Icons.local_car_wash_outlined,
                    ),
                  const SizedBox(height: 16),
                  Text(
                    'SLJEDEĆI TERMINI',
                    style: Theme.of(context).textTheme.labelLarge,
                  ),
                  const SizedBox(height: 8),
                  Expanded(
                    child: schedule.upcoming.isEmpty
                        ? _EmptySlot(
                            label: 'Nema zakazanih termina',
                            icon: Icons.event_available_outlined,
                            compact: true,
                          )
                        : ListView.separated(
                            itemCount: schedule.upcoming.length,
                            separatorBuilder: (_, __) =>
                                const SizedBox(height: 8),
                            itemBuilder: (context, index) {
                              return ReservationCard(
                                reservation: schedule.upcoming[index],
                                status: ReservationStatus.upcoming,
                                compact: true,
                              );
                            },
                          ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptySlot extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool compact;

  const _EmptySlot({
    required this.label,
    required this.icon,
    this.compact = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(compact ? 16 : 24),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.surfaceLight,
          style: BorderStyle.solid,
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: AppColors.textSecondary, size: compact ? 20 : 28),
          const SizedBox(width: 12),
          Text(
            label,
            style: (compact
                    ? Theme.of(context).textTheme.bodyMedium
                    : Theme.of(context).textTheme.titleMedium)
                ?.copyWith(color: AppColors.textSecondary),
          ),
        ],
      ),
    );
  }
}
