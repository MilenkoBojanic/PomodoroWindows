import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:pomodoro_windows/app/theme.dart';
import 'package:pomodoro_windows/data/models/reservation.dart';
import 'package:pomodoro_windows/presentation/display/display_controller.dart';

class TimelineReservationBlock extends StatelessWidget {
  final Reservation reservation;
  final ReservationStatus status;

  const TimelineReservationBlock({
    super.key,
    required this.reservation,
    required this.status,
  });

  @override
  Widget build(BuildContext context) {
    final color = _statusColor();
    final timeFormat = DateFormat('HH:mm');
    final priceFormat = NumberFormat('0.00', 'bs_BA');
    final textTheme = Theme.of(context).textTheme;
    final timeLabel =
        '${timeFormat.format(reservation.reservedAt)} – ${timeFormat.format(reservation.endsAt)}';

    return LayoutBuilder(
      builder: (context, constraints) {
        final height = constraints.maxHeight;
        final tiny = height < 44;
        final compact = height < 68;
        final medium = height < 96;

        return Container(
          decoration: BoxDecoration(
            color: color.withValues(
              alpha: status == ReservationStatus.active ? 0.28 : 0.18,
            ),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: color.withValues(alpha: 0.85),
              width: status == ReservationStatus.active ? 2.5 : 1.5,
            ),
          ),
          padding: EdgeInsets.all(tiny ? 3 : compact ? 5 : 6),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (!tiny)
                Row(
                  children: [
                    _StatusBadge(status: status, compact: compact),
                    const Spacer(),
                    Flexible(
                      child: Text(
                        timeLabel,
                        style: textTheme.bodySmall?.copyWith(
                          color: AppColors.textPrimary,
                          fontFeatures: const [FontFeature.tabularFigures()],
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        textAlign: TextAlign.right,
                      ),
                    ),
                  ],
                ),
              if (!tiny) SizedBox(height: compact ? 2 : 4),
              Text(
                reservation.vehicle.name,
                style: (compact ? textTheme.bodyMedium : textTheme.titleMedium)
                    ?.copyWith(
                  color: AppColors.textPrimary,
                  fontWeight: status == ReservationStatus.active
                      ? FontWeight.w700
                      : FontWeight.w500,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              if (!compact) ...[
                SizedBox(height: medium ? 2 : 3),
                Text(
                  reservation.primaryService.name,
                  style: textTheme.bodySmall?.copyWith(
                    color: AppColors.accentBright,
                  ),
                  maxLines: medium ? 1 : 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
              if (!medium && reservation.services.isNotEmpty) ...[
                const SizedBox(height: 2),
                Text(
                  reservation.services.map((service) => service.name).join(', '),
                  style: textTheme.bodySmall,
                  maxLines: compact ? 1 : 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
              if (!medium) ...[
                const Spacer(),
                Text(
                  '${priceFormat.format(reservation.totalPrice)} KM',
                  style: textTheme.labelLarge?.copyWith(
                    color: AppColors.textPrimary,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
              if (!compact && height >= 108) ...[
                const SizedBox(height: 2),
                Text(
                  '${reservation.duration.inMinutes} min',
                  style: textTheme.labelLarge,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ],
          ),
        );
      },
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
  final bool compact;

  const _StatusBadge({
    required this.status,
    this.compact = false,
  });

  @override
  Widget build(BuildContext context) {
    final (label, color) = switch (status) {
      ReservationStatus.active => ('U TOKU', AppColors.active),
      ReservationStatus.upcoming => ('SLJEDEĆI', AppColors.upcoming),
      ReservationStatus.completed => ('ZAVRŠENO', AppColors.completed),
    };

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: compact ? 6 : 8,
        vertical: compact ? 2 : 3,
      ),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.labelLarge?.copyWith(
              color: Colors.white,
              fontSize: compact ? 9 : 10,
            ),
      ),
    );
  }
}
