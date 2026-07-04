import 'package:pomodoro_windows/data/models/reservation_service.dart';
import 'package:pomodoro_windows/data/models/user_vehicle.dart';

class Reservation {
  final String reservationId;
  final String userId;
  final String createdBy;
  final UserVehicle vehicle;
  final double totalPrice;
  final DateTime reservedAt;
  final DateTime createdAt;
  final Duration duration;
  final String runwayId;
  final ReservationService primaryService;
  final List<ReservationService> services;

  DateTime get endsAt => reservedAt.add(duration);

  const Reservation({
    required this.reservationId,
    required this.userId,
    required this.createdBy,
    required this.vehicle,
    required this.totalPrice,
    required this.reservedAt,
    required this.createdAt,
    required this.duration,
    required this.runwayId,
    required this.primaryService,
    required this.services,
  });

  factory Reservation.fromJson(Map<String, dynamic> data) {
    final services = <ReservationService>[];

    for (final service in data['services'] as List<dynamic>) {
      services.add(
        ReservationService.fromJson(service as Map<String, dynamic>),
      );
    }

    return Reservation(
      reservationId: data['reservation_id'] as String,
      userId: data['user_id'] as String,
      createdBy: data['created_by'] as String,
      vehicle: UserVehicle.fromJson(data['vehicle'] as Map<String, dynamic>),
      totalPrice: double.parse(data['total_price'].toString()),
      reservedAt: DateTime.fromMillisecondsSinceEpoch(data['reserved_at'] as int),
      createdAt: DateTime.fromMillisecondsSinceEpoch(data['created_at'] as int),
      duration: Duration(minutes: int.parse(data['duration'].toString())),
      runwayId: data['runway_id'] as String,
      primaryService: ReservationService.fromJson(
        data['primary_service'] as Map<String, dynamic>,
      ),
      services: services,
    );
  }

  bool isActiveAt(DateTime now) =>
      !reservedAt.isAfter(now) && endsAt.isAfter(now);

  bool isUpcomingAt(DateTime now) => reservedAt.isAfter(now);

  bool isCompletedAt(DateTime now) => !endsAt.isAfter(now);
}
