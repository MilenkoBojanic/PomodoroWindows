import 'package:pomodoro_windows/data/models/reservation.dart';
import 'package:pomodoro_windows/data/models/reservation_service.dart';
import 'package:pomodoro_windows/data/models/user_vehicle.dart';
import 'package:pomodoro_windows/services/new_reservation_detector.dart';
import 'package:flutter_test/flutter_test.dart';

Reservation _reservation(String id) {
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
    reservedAt: DateTime(2026, 1, 1, 10),
    createdAt: DateTime(2026, 1, 1, 9),
    duration: const Duration(minutes: 30),
    runwayId: '0',
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
  group('NewReservationDetector', () {
    test('initial snapshot does not trigger sound', () {
      final detector = NewReservationDetector();

      final shouldPlay = detector.processSnapshot([
        _reservation('r1'),
        _reservation('r2'),
      ]);

      expect(shouldPlay, isFalse);
      expect(detector.knownReservationIds, {'r1', 'r2'});
    });

    test('identical subsequent snapshot does not trigger sound', () {
      final detector = NewReservationDetector();
      detector.processSnapshot([_reservation('r1')]);

      final shouldPlay = detector.processSnapshot([_reservation('r1')]);

      expect(shouldPlay, isFalse);
    });

    test('single new reservation triggers sound once', () {
      final detector = NewReservationDetector();
      detector.processSnapshot([_reservation('r1')]);

      final shouldPlay = detector.processSnapshot([
        _reservation('r1'),
        _reservation('r2'),
      ]);

      expect(shouldPlay, isTrue);
      expect(detector.knownReservationIds, {'r1', 'r2'});
    });

    test('multiple new reservations in one snapshot trigger sound once', () {
      final detector = NewReservationDetector();
      detector.processSnapshot([_reservation('r1')]);

      final shouldPlay = detector.processSnapshot([
        _reservation('r1'),
        _reservation('r2'),
        _reservation('r3'),
      ]);

      expect(shouldPlay, isTrue);
      expect(detector.knownReservationIds, {'r1', 'r2', 'r3'});
    });

    test('reset clears state and next snapshot is treated as initial', () {
      final detector = NewReservationDetector();
      detector.processSnapshot([_reservation('r1')]);

      detector.reset();

      expect(detector.initialSnapshotReceived, isFalse);
      expect(detector.knownReservationIds, isEmpty);

      final shouldPlay = detector.processSnapshot([
        _reservation('r1'),
        _reservation('r2'),
      ]);

      expect(shouldPlay, isFalse);
      expect(detector.knownReservationIds, {'r1', 'r2'});
    });

    test('updated existing reservation does not trigger sound', () {
      final detector = NewReservationDetector();
      final original = _reservation('r1');
      detector.processSnapshot([original]);

      final updated = Reservation(
        reservationId: original.reservationId,
        userId: original.userId,
        createdBy: original.createdBy,
        vehicle: original.vehicle,
        totalPrice: 99,
        reservedAt: original.reservedAt,
        createdAt: original.createdAt,
        duration: original.duration,
        runwayId: original.runwayId,
        primaryService: original.primaryService,
        services: original.services,
      );

      final shouldPlay = detector.processSnapshot([updated]);

      expect(shouldPlay, isFalse);
    });
  });
}
