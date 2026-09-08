import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';

/// Plays the local notification sound for new reservations.
class ReservationSoundService {
  static const assetPath = 'sounds/new_reservation.wav';

  final AudioPlayer _player = AudioPlayer();

  Future<void> playNewReservationNotification() async {
    try {
      await _player.stop();
      await _player.play(AssetSource(assetPath));
    } catch (e) {
      if (kDebugMode) {
        debugPrint('[ReservationSoundService] Failed to play sound: $e');
      }
    }
  }

  Future<void> dispose() async {
    await _player.dispose();
  }
}
