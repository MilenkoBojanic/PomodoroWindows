import 'package:pomodoro_windows/data/models/reservation.dart';

/// Layout constants for the timeline view.
class TimelineMetrics {
  static const timeColumnWidth = 52.0;
  static const headerHeight = 44.0;
  static const slotMinutes = 30;
  static const slotHeight = 40.0;
  static const startHour = 7;
  static const endHour = 20;
  static const topPadding = 16.0;

  static double get pixelsPerMinute => slotHeight / slotMinutes;

  static double contentHeight(double timelineHeight) =>
      timelineHeight + topPadding;
}

/// Computed vertical position and column placement for one reservation block.
class TimelineBlockLayout {
  final Reservation reservation;
  final double top;
  final double height;
  final int columnIndex;
  final int columnCount;

  const TimelineBlockLayout({
    required this.reservation,
    required this.top,
    required this.height,
    required this.columnIndex,
    required this.columnCount,
  });

  double get leftFraction => columnIndex / columnCount;
  double get widthFraction => 1 / columnCount;
}

/// Resolved start/end of the visible timeline window for a given day.
class TimelineRange {
  final DateTime start;
  final DateTime end;

  const TimelineRange({required this.start, required this.end});

  Duration get duration => end.difference(start);

  double get totalHeight =>
      duration.inMinutes * TimelineMetrics.pixelsPerMinute;
}

TimelineRange resolveTimelineRange({required DateTime day}) {
  return TimelineRange(
    start: DateTime(day.year, day.month, day.day, TimelineMetrics.startHour),
    end: DateTime(day.year, day.month, day.day, TimelineMetrics.endHour),
  );
}

double minutesFromRangeStart(DateTime time, DateTime rangeStart) {
  return time.difference(rangeStart).inMinutes.toDouble();
}

double? currentTimeOffset(DateTime now, TimelineRange range) {
  if (now.isBefore(range.start) || !now.isBefore(range.end)) {
    return null;
  }
  return minutesFromRangeStart(now, range.start) * TimelineMetrics.pixelsPerMinute;
}

List<TimelineBlockLayout> layoutRunwayReservations({
  required List<Reservation> reservations,
  required TimelineRange range,
}) {
  if (reservations.isEmpty) {
    return const [];
  }

  final sorted = [...reservations]
    ..sort((a, b) => a.reservedAt.compareTo(b.reservedAt));

  final columnEnds = <DateTime>[];
  final columnByReservation = <Reservation, int>{};

  for (final reservation in sorted) {
    var column = 0;
    for (; column < columnEnds.length; column++) {
      if (!columnEnds[column].isAfter(reservation.reservedAt)) {
        break;
      }
    }

    if (column == columnEnds.length) {
      columnEnds.add(reservation.endsAt);
    } else {
      columnEnds[column] = reservation.endsAt;
    }

    columnByReservation[reservation] = column;
  }

  bool overlaps(Reservation a, Reservation b) {
    return a.reservedAt.isBefore(b.endsAt) && b.reservedAt.isBefore(a.endsAt);
  }

  return sorted.map((reservation) {
    final columnIndex = columnByReservation[reservation]!;
    var columnCount = columnIndex + 1;

    for (final other in sorted) {
      if (overlaps(reservation, other)) {
        final otherColumn = columnByReservation[other]!;
        if (otherColumn + 1 > columnCount) {
          columnCount = otherColumn + 1;
        }
      }
    }

    final top = minutesFromRangeStart(reservation.reservedAt, range.start) *
        TimelineMetrics.pixelsPerMinute;
    final height = reservation.duration.inMinutes *
        TimelineMetrics.pixelsPerMinute;

    return TimelineBlockLayout(
      reservation: reservation,
      top: top,
      height: height.clamp(18, double.infinity),
      columnIndex: columnIndex,
      columnCount: columnCount,
    );
  }).toList();
}

/// Half-hour tick positions within [range].
List<double> halfHourGridOffsets(TimelineRange range) {
  final offsets = <double>[];
  var tick = range.start;

  if (range.start.minute % 30 != 0) {
    final minutesToNextHalfHour = 30 - (range.start.minute % 30);
    tick = range.start.add(Duration(minutes: minutesToNextHalfHour));
  }

  while (tick.isBefore(range.end)) {
    offsets.add(
      minutesFromRangeStart(tick, range.start) * TimelineMetrics.pixelsPerMinute,
    );
    tick = tick.add(const Duration(minutes: TimelineMetrics.slotMinutes));
  }

  return offsets;
}

/// Full-hour tick positions and labels within [range].
List<({double offset, DateTime time})> hourGridTicks(TimelineRange range) {
  final ticks = <({double offset, DateTime time})>[];
  var tick = DateTime(
    range.start.year,
    range.start.month,
    range.start.day,
    range.start.hour,
  );

  if (tick.isBefore(range.start)) {
    tick = tick.add(const Duration(hours: 1));
  }

  while (tick.isBefore(range.end)) {
    ticks.add((
      offset: minutesFromRangeStart(tick, range.start) *
          TimelineMetrics.pixelsPerMinute,
      time: tick,
    ));
    tick = tick.add(const Duration(hours: 1));
  }

  return ticks;
}
