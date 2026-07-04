import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:pomodoro_windows/data/models/reservation.dart';
import 'package:pomodoro_windows/data/models/work_hours.dart';
import 'package:pomodoro_windows/data/repositories/channel_repository.dart';
import 'package:pomodoro_windows/data/repositories/reservation_repository.dart';
import 'package:pomodoro_windows/data/repositories/work_hours_repository.dart';

enum ReservationStatus { active, upcoming, completed }

class RunwaySchedule {
  final String runwayId;
  final Reservation? active;
  final List<Reservation> upcoming;
  final List<Reservation> completed;

  const RunwaySchedule({
    required this.runwayId,
    this.active,
    this.upcoming = const [],
    this.completed = const [],
  });
}

class DisplayController extends ChangeNotifier {
  final ReservationRepository _reservationRepository;
  final WorkHoursRepository _workHoursRepository;
  final ChannelRepository _channelRepository;

  StreamSubscription<List<Reservation>>? _reservationSubscription;
  Timer? _clockTimer;

  List<Reservation> _reservations = [];
  Map<String, WorkHours> _workHours = {};
  DateTime _now = DateTime.now();
  bool _loading = true;
  String? _error;

  DisplayController({
    required ReservationRepository reservationRepository,
    required WorkHoursRepository workHoursRepository,
    required ChannelRepository channelRepository,
  })  : _reservationRepository = reservationRepository,
        _workHoursRepository = workHoursRepository,
        _channelRepository = channelRepository;

  List<Reservation> get reservations => _reservations;
  DateTime get now => _now;
  bool get loading => _loading;
  String? get error => _error;

  WorkHours? get todayWorkHours {
    if (_workHours.isEmpty) return null;
    final weekdayIndex = (_now.weekday - 1).toString();
    return _workHours[weekdayIndex];
  }

  List<String> get runwayIds {
    final ids = _reservations.map((r) => r.runwayId).toSet().toList();
    ids.sort();
    return ids;
  }

  List<RunwaySchedule> get runwaySchedules {
    final schedules = <RunwaySchedule>[];

    for (final runwayId in runwayIds) {
      final runwayReservations = _reservations
          .where((r) => r.runwayId == runwayId)
          .toList()
        ..sort((a, b) => a.reservedAt.compareTo(b.reservedAt));

      Reservation? active;
      final upcoming = <Reservation>[];
      final completed = <Reservation>[];

      for (final reservation in runwayReservations) {
        final status = _statusFor(reservation);
        switch (status) {
          case ReservationStatus.active:
            active ??= reservation;
          case ReservationStatus.upcoming:
            upcoming.add(reservation);
          case ReservationStatus.completed:
            completed.add(reservation);
        }
      }

      schedules.add(
        RunwaySchedule(
          runwayId: runwayId,
          active: active,
          upcoming: upcoming,
          completed: completed.reversed.take(2).toList(),
        ),
      );
    }

    return schedules;
  }

  Future<void> init() async {
    try {
      _workHours = await _workHoursRepository.getWorkHours();
    } catch (e) {
      if (kDebugMode) {
        debugPrint('[DisplayController] Failed to load work hours: $e');
      }
    }

    _watchReservations();
    _channelRepository.subscribe(() => _watchReservations());

    _clockTimer = Timer.periodic(const Duration(seconds: 30), (_) {
      _now = DateTime.now();
      notifyListeners();
    });
  }

  void _watchReservations() {
    _reservationSubscription?.cancel();

    _reservationSubscription =
        _reservationRepository.watchDayReservations(_now).listen(
      (reservations) {
        _reservations = reservations;
        _loading = false;
        _error = null;
        notifyListeners();
      },
      onError: (Object e) {
        _loading = false;
        _error = e.toString();
        notifyListeners();
      },
    );
  }

  ReservationStatus _statusFor(Reservation reservation) {
    if (reservation.isActiveAt(_now)) return ReservationStatus.active;
    if (reservation.isUpcomingAt(_now)) return ReservationStatus.upcoming;
    return ReservationStatus.completed;
  }

  static String formatRunwayLabel(String runwayId) {
    final match = RegExp(r'(\d+)').firstMatch(runwayId);
    if (match != null) {
      final number = int.parse(match.group(1)!) + 1;
      return 'Pista $number';
    }
    return runwayId.replaceAll('_', ' ').toUpperCase();
  }

  @override
  void dispose() {
    _reservationSubscription?.cancel();
    _clockTimer?.cancel();
    _channelRepository.dispose();
    super.dispose();
  }
}

DisplayController createDisplayController() {
  final firestore = FirebaseFirestore.instance;

  return DisplayController(
    reservationRepository: ReservationRepository(firestore),
    workHoursRepository: WorkHoursRepository(firestore),
    channelRepository: ChannelRepository(firestore),
  );
}
