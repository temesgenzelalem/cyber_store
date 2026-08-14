// ⚠️  REPLACE ALL VALUES with your Firebase project configuration.
// Generate this file automatically by running:
//   flutterfire configure
//
// Or fill in manually from: Firebase Console → Project Settings → Your Apps

import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart' show defaultTargetPlatform, kIsWeb, TargetPlatform;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) return web;
    switch (defaultTargetPlatform) {
      case TargetPlatform.android: return android;
      case TargetPlatform.iOS:     return ios;
      default:
        throw UnsupportedError('Unsupported platform');
    }
  }

  // ── Web ─────────────────────────────────────────────────────────────────
  static const FirebaseOptions web = FirebaseOptions(
    apiKey:            'YOUR-WEB-API-KEY',
    appId:             '1:000000000000:web:0000000000000000000000',
    messagingSenderId: '000000000000',
    projectId:         'YOUR-PROJECT-ID',
    authDomain:        'YOUR-PROJECT-ID.firebaseapp.com',
    storageBucket:     'YOUR-PROJECT-ID.appspot.com',
  );

  // ── Android ─────────────────────────────────────────────────────────────
  static const FirebaseOptions android = FirebaseOptions(
    apiKey:            'YOUR-ANDROID-API-KEY',
    appId:             '1:000000000000:android:0000000000000000000000',
    messagingSenderId: '000000000000',
    projectId:         'YOUR-PROJECT-ID',
    storageBucket:     'YOUR-PROJECT-ID.appspot.com',
  );

  // ── iOS ─────────────────────────────────────────────────────────────────
  static const FirebaseOptions ios = FirebaseOptions(
    apiKey:           'YOUR-IOS-API-KEY',
    appId:            '1:000000000000:ios:0000000000000000000000',
    messagingSenderId:'000000000000',
    projectId:        'YOUR-PROJECT-ID',
    storageBucket:    'YOUR-PROJECT-ID.appspot.com',
    iosBundleId:      'com.cyber.store',
  );
}
