import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:pomodoro_windows/app/theme.dart';
import 'package:pomodoro_windows/data/models/reservation.dart';
import 'package:pomodoro_windows/presentation/display/display_controller.dart';

class ReservationCard extends StatelessWidget {
  final Reservation reservation;
  final ReservationStatus status;
  final bool compact;
  final double fontScale;

  const ReservationCard({
    super.key,
    required this.reservation,
    required this.status,
    this.compact = false,
    this.fontScale = 1,
  });

  @override
  Widget build(BuildContext context) {
    final timeFormat = DateFormat('HH:mm');
    final priceFormat = NumberFormat('0.00', 'bs_BA');
    final color = _statusColor();
    final textTheme = Theme.of(context).textTheme;

    return MediaQuery(
      data: MediaQuery.of(context).copyWith(
        textScaler: TextScaler.linear(fontScale),
      ),
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.all(compact ? 12 : 20),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withValues(alpha: 0.6), width: 2),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                _StatusBadge(status: status),
                const Spacer(),
                Text(
                  '${timeFormat.format(reservation.reservedAt)} – ${timeFormat.format(reservation.endsAt)}',
                  style: textTheme.titleMedium?.copyWith(
                    color: AppColors.textPrimary,
                    fontFeatures: const [FontFeature.tabularFigures()],
                  ),
                ),
              ],
            ),
            SizedBox(height: compact ? 8 : 12),
            Text(
              reservation.vehicle.name,
              style: textTheme.titleMedium?.copyWith(
                color: AppColors.textPrimary,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            SizedBox(height: compact ? 4 : 6),
            Text(
              reservation.primaryService.name,
              style: textTheme.bodyMedium?.copyWith(
                color: AppColors.accentBright,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            if (reservation.services.isNotEmpty) ...[
              SizedBox(height: compact ? 2 : 4),
              Text(
                reservation.services.map((service) => service.name).join(', '),
                style: textTheme.bodySmall,
                maxLines: compact ? 2 : 3,
                overflow: TextOverflow.ellipsis,
              ),
            ],
            SizedBox(height: compact ? 4 : 6),
            Text(
              '${priceFormat.format(reservation.totalPrice)} KM',
              style: textTheme.labelLarge?.copyWith(
                color: AppColors.textPrimary,
              ),
            ),
            if (!compact) ...[
              const SizedBox(height: 8),
              Text(
                '${reservation.duration.inMinutes} min',
                style: textTheme.labelLarge,
              ),
            ],
          ],
        ),
      ),
    );
  }

  Color _statusColor() {
    return switch (status) {
      ReservationStatus.active => AppColors.active,
      ReservationStatus.upcoming => AppColors.upcoming,
      ReservationStatus.completed => AppColors.completed,
    };
  }
}

class _StatusBadge extends StatelessWidget {
  final ReservationStatus status;

  const _StatusBadge({required this.status});

  @override
  Widget build(BuildContext context) {
    final (label, color) = switch (status) {
      ReservationStatus.active => ('U TOKU', AppColors.active),
      ReservationStatus.upcoming => ('SLJEDEĆI', AppColors.upcoming),
      ReservationStatus.completed => ('ZAVRŠENO', AppColors.completed),
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.labelLarge?.copyWith(
              color: Colors.white,
              fontSize: 12,
            ),
      ),
    );
  }
}
