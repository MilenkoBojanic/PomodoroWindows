import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, TargetPlatform;

/// Firebase options for the Pomodoro Windows display app.
/// Uses the same Firestore project as the main Pomodoro mobile app.
class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    switch (defaultTargetPlatform) {
      case TargetPlatform.windows:
        return windows;
      default:
        throw UnsupportedError(
          'Pomodoro Windows is supported on Windows desktop only.',
        );
    }
  }

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyDlOqdYHXbI-wSTZ_PRJR90gadPJcPJm7c',
    appId: '1:127715059823:web:63453686ab986392ff059a',
    messagingSenderId: '127715059823',
    projectId: 'pomodoro-62cae',
    authDomain: 'pomodoro-62cae.firebaseapp.com',
    storageBucket: 'pomodoro-62cae.firebasestorage.app',
  );
}
