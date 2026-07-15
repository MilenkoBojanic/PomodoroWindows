import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show TargetPlatform, defaultTargetPlatform, kIsWeb;

/// Firebase options for the Pomodoro display app.
/// Uses the same Firestore project as the main Pomodoro mobile app.
class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      return web;
    }

    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.windows:
        return windows;
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not configured for this platform.',
        );
    }
  }

  /// Same web Firebase app used by the Windows desktop build.
  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyDlOqdYHXbI-wSTZ_PRJR90gadPJcPJm7c',
    appId: '1:127715059823:web:63453686ab986392ff059a',
    messagingSenderId: '127715059823',
    projectId: 'pomodoro-62cae',
    authDomain: 'pomodoro-62cae.firebaseapp.com',
    storageBucket: 'pomodoro-62cae.firebasestorage.app',
  );

  static const FirebaseOptions windows = web;

  /// Android app registered in Firebase project `pomodoro-62cae`.
  /// Package name: `com.pomodoro.display`
  ///
  /// If Android Firebase fails to initialize, add an Android app in the
  /// Firebase console for this package and replace [appId] / [apiKey] (or run
  /// `flutterfire configure`).
  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyDlOqdYHXbI-wSTZ_PRJR90gadPJcPJm7c',
    appId: '1:127715059823:web:63453686ab986392ff059a',
    messagingSenderId: '127715059823',
    projectId: 'pomodoro-62cae',
    storageBucket: 'pomodoro-62cae.firebasestorage.app',
  );
}
