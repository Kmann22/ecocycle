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
    apiKey: 'AIzaSyAASXKARkRvh1qjfcyXZkXBhY94Ad0f5Bk',
    appId: '1:11127271775:web:8a9df4b9210595dee306ea',
    messagingSenderId: '11127271775',
    projectId: 'ecocycle-247aa',
    authDomain: 'ecocycle-247aa.firebaseapp.com',
    storageBucket: 'ecocycle-247aa.appspot.com',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyA6BZLGFXD2hsiKcjJ3DIfmD8LXi-H-sTs',
    appId: '1:11127271775:android:367526cfcde14824e306ea',
    messagingSenderId: '11127271775',
    projectId: 'ecocycle-247aa',
    storageBucket: 'ecocycle-247aa.appspot.com',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyAHYnrdx92fZXkrAEjv0Jdx_LpuPfF_S1s',
    appId: '1:11127271775:ios:21f0a29aaadaee63e306ea',
    messagingSenderId: '11127271775',
    projectId: 'ecocycle-247aa',
    storageBucket: 'ecocycle-247aa.appspot.com',
    iosBundleId: 'com.example.ecocylce',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyAHYnrdx92fZXkrAEjv0Jdx_LpuPfF_S1s',
    appId: '1:11127271775:ios:21f0a29aaadaee63e306ea',
    messagingSenderId: '11127271775',
    projectId: 'ecocycle-247aa',
    storageBucket: 'ecocycle-247aa.appspot.com',
    iosBundleId: 'com.example.ecocylce',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyAASXKARkRvh1qjfcyXZkXBhY94Ad0f5Bk',
    appId: '1:11127271775:web:d26302a573859275e306ea',
    messagingSenderId: '11127271775',
    projectId: 'ecocycle-247aa',
    authDomain: 'ecocycle-247aa.firebaseapp.com',
    storageBucket: 'ecocycle-247aa.appspot.com',
  );
}
