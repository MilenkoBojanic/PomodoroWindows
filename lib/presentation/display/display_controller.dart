import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:pomodoro_windows/data/models/reservation.dart';
import 'package:pomodoro_windows/data/models/work_hours.dart';
import 'package:pomodoro_windows/data/repositories/channel_repository.dart';
import 'package:pomodoro_windows/data/repositories/reservation_repository.dart';
import 'package:pomodoro_windows/data/repositories/work_hours_repository.dart';
import 'package:pomodoro_windows/services/new_reservation_detector.dart';
import 'package:pomodoro_windows/services/reservation_sound_service.dart';

enum ReservationStatus { active, upcoming, completed }

enum DisplayViewMode { row, timeline }

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
  final NewReservationDetector _newReservationDetector;
  final ReservationSoundService _reservationSoundService;

  StreamSubscription<List<Reservation>>? _reservationSubscription;
  Timer? _clockTimer;

  List<Reservation> _reservations = [];
  Map<String, WorkHours> _workHours = {};
  DateTime _now = DateTime.now();
  DateTime _selectedDate = _dateOnly(DateTime.now());
  bool _loading = true;
  String? _error;
  DisplayViewMode _viewMode = DisplayViewMode.row;

  static DateTime _dateOnly(DateTime dateTime) =>
      DateTime(dateTime.year, dateTime.month, dateTime.day);

  static bool _isSameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;

  DisplayController({
    required ReservationRepository reservationRepository,
    required WorkHoursRepository workHoursRepository,
    required ChannelRepository channelRepository,
    NewReservationDetector? newReservationDetector,
    ReservationSoundService? reservationSoundService,
  })  : _reservationRepository = reservationRepository,
        _workHoursRepository = workHoursRepository,
        _channelRepository = channelRepository,
        _newReservationDetector =
            newReservationDetector ?? NewReservationDetector(),
        _reservationSoundService =
            reservationSoundService ?? ReservationSoundService();

  List<Reservation> get reservations => _reservations;
  DateTime get now => _now;
  DateTime get selectedDate => _selectedDate;
  bool get isViewingToday => _isSameDay(_selectedDate, _now);
  bool get loading => _loading;
  String? get error => _error;
  DisplayViewMode get viewMode => _viewMode;

  void selectDate(DateTime date) {
    final normalized = _dateOnly(date);
    final today = _dateOnly(DateTime.now());
    if (normalized.isBefore(today) || _selectedDate == normalized) {
      return;
    }

    _selectedDate = normalized;
    _newReservationDetector.reset();
    _loading = true;
    _watchReservations();
    notifyListeners();
  }

  void goToToday() {
    final today = _dateOnly(DateTime.now());
    if (_selectedDate == today) return;

    _selectedDate = today;
    _newReservationDetector.reset();
    _loading = true;
    _watchReservations();
    notifyListeners();
  }

  void setViewMode(DisplayViewMode mode) {
    if (_viewMode == mode) return;
    _viewMode = mode;
    notifyListeners();
  }

  ReservationStatus statusFor(Reservation reservation) =>
      _statusFor(reservation);

  WorkHours? get todayWorkHours {
    if (_workHours.isEmpty) return null;
    final weekdayIndex = (_selectedDate.weekday - 1).toString();
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
        _reservationRepository.watchDayReservations(_selectedDate).listen(
      (reservations) {
        final shouldPlaySound = isViewingToday &&
            _newReservationDetector.processSnapshot(reservations);

        _reservations = reservations;
        _loading = false;
        _error = null;
        notifyListeners();

        if (shouldPlaySound) {
          _reservationSoundService.playNewReservationNotification();
        }
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
    _reservationSoundService.dispose();
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
