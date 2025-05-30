// File generated by FlutterFire CLI.
// ignore_for_file: type=lint
import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

/// Default [FirebaseOptions] for use with your Firebase apps.
///
/// Example:
/// ```dart
/// import 'firebase_options.dart';
/// // ...
/// await Firebase.initializeApp(
///   options: DefaultFirebaseOptions.currentPlatform,
/// );
/// ```
class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      return web;
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      case TargetPlatform.macOS:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for macos - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      case TargetPlatform.windows:
        return windows;
      case TargetPlatform.linux:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for linux - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyCMIus6JZ5Wff65cwLVQMh72bKKrxUWd-o',
    appId: '1:644602495453:web:6033433562c54df0f33634',
    messagingSenderId: '644602495453',
    projectId: 'doctor-myrank',
    authDomain: 'doctor-myrank.firebaseapp.com',
    storageBucket: 'doctor-myrank.firebasestorage.app',
    measurementId: 'G-C88GGVN5P5',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyA0xNemBcbyJn1Dd8ioJbBBaaba_3poGck',
    appId: '1:644602495453:android:a8b58a189553cb3af33634',
    messagingSenderId: '644602495453',
    projectId: 'doctor-myrank',
    storageBucket: 'doctor-myrank.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyDBJL0LqubWH8_CyypYSj62wXtqg7BvdKg',
    appId: '1:644602495453:ios:aadd0414a89a5e5ff33634',
    messagingSenderId: '644602495453',
    projectId: 'doctor-myrank',
    storageBucket: 'doctor-myrank.firebasestorage.app',
    iosBundleId: 'com.example.medicalapp',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyCMIus6JZ5Wff65cwLVQMh72bKKrxUWd-o',
    appId: '1:644602495453:web:efbf152e4fa05af7f33634',
    messagingSenderId: '644602495453',
    projectId: 'doctor-myrank',
    authDomain: 'doctor-myrank.firebaseapp.com',
    storageBucket: 'doctor-myrank.firebasestorage.app',
    measurementId: 'G-6PG92MGCNC',
  );
}
