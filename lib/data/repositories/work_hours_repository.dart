import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:pomodoro_windows/data/firestore_constants.dart';
import 'package:pomodoro_windows/data/models/work_hours.dart';

class WorkHoursRepository {
  final CollectionReference<Map<String, dynamic>> _collection;

  WorkHoursRepository(FirebaseFirestore firestore)
      : _collection = firestore.collection(FirestoreCollections.workHours);

  Future<Map<String, WorkHours>> getWorkHours() async {
    final snapshot = await _collection.get();
    final result = <String, WorkHours>{};

    for (var i = 0; i < snapshot.docs.length; i++) {
      result[i.toString()] = WorkHours.fromJson(snapshot.docs[i].data());
    }

    return result;
  }
}
