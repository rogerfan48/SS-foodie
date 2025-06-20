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
    apiKey: 'AIzaSyCTtxssYFoJ8otNLQdkkktQOlGqaxepmrU',
    appId: '1:346523381880:web:3205cd3d27cd436b43bd8d',
    messagingSenderId: '346523381880',
    projectId: 'foodie-4dee6',
    authDomain: 'foodie-4dee6.firebaseapp.com',
    storageBucket: 'foodie-4dee6.firebasestorage.app',
    measurementId: 'G-X8QC682NEV',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyAaXOLS1zHnH0i6O_rQ463beejzBlMOWJI',
    appId: '1:346523381880:android:1db3a9c0da80f54643bd8d',
    messagingSenderId: '346523381880',
    projectId: 'foodie-4dee6',
    storageBucket: 'foodie-4dee6.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyBy9Odska4qJEy2qdbBXZE4vGibDxmkTCA',
    appId: '1:346523381880:ios:d15d146b1d5bf29c43bd8d',
    messagingSenderId: '346523381880',
    projectId: 'foodie-4dee6',
    storageBucket: 'foodie-4dee6.firebasestorage.app',
    androidClientId: '346523381880-14lluom2q7sdfiram1537psenvojd7k7.apps.googleusercontent.com',
    iosClientId: '346523381880-dpjam4uq2hjghiocod0m9gbvfp8nevvm.apps.googleusercontent.com',
    iosBundleId: 'com.nthucs.foodie',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyBy9Odska4qJEy2qdbBXZE4vGibDxmkTCA',
    appId: '1:346523381880:ios:33ae6de00acc339d43bd8d',
    messagingSenderId: '346523381880',
    projectId: 'foodie-4dee6',
    storageBucket: 'foodie-4dee6.firebasestorage.app',
    androidClientId: '346523381880-14lluom2q7sdfiram1537psenvojd7k7.apps.googleusercontent.com',
    iosClientId: '346523381880-t4qi800lknk7m7udn0504cc1iu90u8g9.apps.googleusercontent.com',
    iosBundleId: 'com.example.foodie',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyCTtxssYFoJ8otNLQdkkktQOlGqaxepmrU',
    appId: '1:346523381880:web:3695a861c7e2474e43bd8d',
    messagingSenderId: '346523381880',
    projectId: 'foodie-4dee6',
    authDomain: 'foodie-4dee6.firebaseapp.com',
    storageBucket: 'foodie-4dee6.firebasestorage.app',
    measurementId: 'G-CRJKCH0PXY',
  );

  
}