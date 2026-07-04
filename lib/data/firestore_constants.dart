/// Firestore collection names — mirrors the main Pomodoro app schema.
class FirestoreCollections {
  static const reservations = 'reservations';
  static const workHours = 'work_hours';
  static const channels = 'channels';
}

/// Pub/sub channel topics used by the main app.
class ChannelTopics {
  static const reservations = 'reservations';
}
