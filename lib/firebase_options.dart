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
        return macos;
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
    apiKey: 'AIzaSyDbyqFmviKGpVkJi-72l4S0Vt09rHg00os',
    appId: '1:988844295608:web:1e6db3bc63fd0a4fbe7b4d',
    messagingSenderId: '988844295608',
    projectId: 'aps-online-academy-3c7ac',
    authDomain: 'aps-online-academy-3c7ac.firebaseapp.com',
    storageBucket: 'aps-online-academy-3c7ac.appspot.com',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyAom8h0_Z1MxKSUUS-qQnc7jatvUqreSUw',
    appId: '1:988844295608:android:7693cc2c3929ddb0be7b4d',
    messagingSenderId: '988844295608',
    projectId: 'aps-online-academy-3c7ac',
    storageBucket: 'aps-online-academy-3c7ac.appspot.com',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyD1hIQHtSOawUUQyR-z1P-ZEqnwVaQPdrE',
    appId: '1:988844295608:ios:d426363d093084bdbe7b4d',
    messagingSenderId: '988844295608',
    projectId: 'aps-online-academy-3c7ac',
    storageBucket: 'aps-online-academy-3c7ac.appspot.com',
    iosBundleId: 'com.example.aps',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyD1hIQHtSOawUUQyR-z1P-ZEqnwVaQPdrE',
    appId: '1:988844295608:ios:d426363d093084bdbe7b4d',
    messagingSenderId: '988844295608',
    projectId: 'aps-online-academy-3c7ac',
    storageBucket: 'aps-online-academy-3c7ac.appspot.com',
    iosBundleId: 'com.example.aps',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyDbyqFmviKGpVkJi-72l4S0Vt09rHg00os',
    appId: '1:988844295608:web:ec83ec3e490e87f6be7b4d',
    messagingSenderId: '988844295608',
    projectId: 'aps-online-academy-3c7ac',
    authDomain: 'aps-online-academy-3c7ac.firebaseapp.com',
    storageBucket: 'aps-online-academy-3c7ac.appspot.com',
  );
}
