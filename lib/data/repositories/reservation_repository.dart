import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:pomodoro_windows/data/firestore_constants.dart';
import 'package:pomodoro_windows/data/models/reservation.dart';

class ReservationRepository {
  final CollectionReference<Map<String, dynamic>> _collection;

  ReservationRepository(FirebaseFirestore firestore)
      : _collection = firestore.collection(FirestoreCollections.reservations);

  Stream<List<Reservation>> watchDayReservations(DateTime day) {
    final start = DateTime(day.year, day.month, day.day);
    final end = start.add(const Duration(days: 1));

    return _collection
        .where('reserved_at', isGreaterThanOrEqualTo: start.millisecondsSinceEpoch)
        .where('reserved_at', isLessThan: end.millisecondsSinceEpoch)
        .orderBy('reserved_at')
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => Reservation.fromJson(doc.data()))
              .toList(),
        );
  }
}
