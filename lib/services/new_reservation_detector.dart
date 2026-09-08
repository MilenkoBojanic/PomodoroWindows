import 'package:pomodoro_windows/data/models/reservation.dart';

/// Tracks known reservation IDs and reports when a snapshot contains
/// genuinely new reservations (not present in any prior snapshot).
class NewReservationDetector {
  final Set<String> _knownReservationIds = {};
  bool _initialSnapshotReceived = false;

  /// Processes [reservations] from a Firestore stream emission.
  ///
  /// Returns `true` when at least one reservation ID was not seen before.
  /// The first snapshot is always treated as initial load (returns `false`).
  bool processSnapshot(List<Reservation> reservations) {
    final currentIds = reservations.map((r) => r.reservationId).toSet();

    if (!_initialSnapshotReceived) {
      _knownReservationIds.addAll(currentIds);
      _initialSnapshotReceived = true;
      return false;
    }

    final newIds = currentIds.difference(_knownReservationIds);
    if (newIds.isEmpty) {
      return false;
    }

    _knownReservationIds.addAll(newIds);
    return true;
  }

  /// Visible for testing.
  Set<String> get knownReservationIds => Set.unmodifiable(_knownReservationIds);

  /// Visible for testing.
  bool get initialSnapshotReceived => _initialSnapshotReceived;

  /// Clears tracked IDs so the next snapshot is treated as initial load.
  void reset() {
    _knownReservationIds.clear();
    _initialSnapshotReceived = false;
  }
}
