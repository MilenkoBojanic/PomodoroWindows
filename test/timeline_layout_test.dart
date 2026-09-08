import 'package:flutter_test/flutter_test.dart';
import 'package:pomodoro_windows/data/models/reservation.dart';
import 'package:pomodoro_windows/data/models/reservation_service.dart';
import 'package:pomodoro_windows/data/models/user_vehicle.dart';
import 'package:pomodoro_windows/presentation/widgets/timeline/timeline_layout.dart';

Reservation _reservation({
  required String id,
  required DateTime start,
  required int durationMinutes,
  String runwayId = '0',
}) {
  return Reservation(
    reservationId: id,
    userId: 'user-1',
    createdBy: 'user-1',
    vehicle: const UserVehicle(
      name: 'Test Car',
      color: 'red',
      vehicleTypeId: 'type-1',
    ),
    totalPrice: 25,
    reservedAt: start,
    createdAt: start.subtract(const Duration(hours: 1)),
    duration: Duration(minutes: durationMinutes),
    runwayId: runwayId,
    primaryService: const ReservationService(
      serviceId: 'svc-1',
      name: 'Wash',
      price: 25,
      duration: 30,
    ),
    services: const [],
  );
}

void main() {
  group('resolveTimelineRange', () {
    test('uses fixed 07:00 to 20:00 window', () {
      final day = DateTime(2026, 1, 1);
      final range = resolveTimelineRange(day: day);

      expect(range.start, DateTime(2026, 1, 1, 7));
      expect(range.end, DateTime(2026, 1, 1, 20));
    });
  });

  group('layoutRunwayReservations', () {
    test('positions reservation by start time and duration', () {
      final range = TimelineRange(
        start: DateTime(2026, 1, 1, 8),
        end: DateTime(2026, 1, 1, 19),
      );
      final reservation = _reservation(
        id: 'r1',
        start: DateTime(2026, 1, 1, 9),
        durationMinutes: 40,
      );

      final layouts = layoutRunwayReservations(
        reservations: [reservation],
        range: range,
      );

      expect(layouts, hasLength(1));
      expect(layouts.first.top, 60 * TimelineMetrics.pixelsPerMinute);
      expect(
        layouts.first.height,
        40 * TimelineMetrics.pixelsPerMinute,
      );
    });

    test('splits overlapping reservations into columns', () {
      final range = TimelineRange(
        start: DateTime(2026, 1, 1, 8),
        end: DateTime(2026, 1, 1, 19),
      );
      final first = _reservation(
        id: 'r1',
        start: DateTime(2026, 1, 1, 9),
        durationMinutes: 90,
      );
      final second = _reservation(
        id: 'r2',
        start: DateTime(2026, 1, 1, 9, 30),
        durationMinutes: 60,
      );

      final layouts = layoutRunwayReservations(
        reservations: [first, second],
        range: range,
      );

      expect(layouts, hasLength(2));
      expect(layouts[0].columnIndex, 0);
      expect(layouts[1].columnIndex, 1);
      expect(layouts[0].columnCount, 2);
      expect(layouts[1].columnCount, 2);
      expect(layouts[0].widthFraction, 0.5);
      expect(layouts[1].widthFraction, 0.5);
    });
  });

  group('currentTimeOffset', () {
    test('returns null outside work hours', () {
      final range = TimelineRange(
        start: DateTime(2026, 1, 1, 8),
        end: DateTime(2026, 1, 1, 19),
      );

      expect(
        currentTimeOffset(DateTime(2026, 1, 1, 7, 30), range),
        isNull,
      );
      expect(
        currentTimeOffset(DateTime(2026, 1, 1, 19), range),
        isNull,
      );
    });

    test('returns offset within work hours', () {
      final range = TimelineRange(
        start: DateTime(2026, 1, 1, 8),
        end: DateTime(2026, 1, 1, 19),
      );

      final offset = currentTimeOffset(DateTime(2026, 1, 1, 10, 18), range);

      expect(offset, 138 * TimelineMetrics.pixelsPerMinute);
    });
  });
}
