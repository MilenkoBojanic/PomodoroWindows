import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:pomodoro_windows/data/firestore_constants.dart';

/// Listens to the same Firestore channel documents as the main Pomodoro app
/// to trigger schedule refreshes when reservations change.
class ChannelRepository {
  final DocumentReference<Map<String, dynamic>> _reservationsChannel;

  StreamSubscription<DocumentSnapshot<Map<String, dynamic>>>? _subscription;
  DateTime? _subscribedAt;

  ChannelRepository(FirebaseFirestore firestore)
      : _reservationsChannel = firestore
            .collection(FirestoreCollections.channels)
            .doc(ChannelTopics.reservations);

  void subscribe(void Function() onUpdate) {
    _subscribedAt = DateTime.now();

    _subscription?.cancel();
    _subscription = _reservationsChannel.snapshots().listen((event) {
      if (!event.exists || _subscribedAt == null) return;

      final createdAt = DateTime.fromMillisecondsSinceEpoch(
        event.data()!['created_at'] as int,
      );

      if (createdAt.isAfter(_subscribedAt!)) {
        onUpdate();
      }
    });
  }

  void dispose() {
    _subscription?.cancel();
    _subscription = null;
    _subscribedAt = null;
  }
}
