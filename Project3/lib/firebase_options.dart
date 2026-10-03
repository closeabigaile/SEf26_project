// Firebase client settings retrieved with the Firebase CLI from wolfbyte-proj1.
// Web/Windows share the web registration; iOS/macOS share the same bundle ID.
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
    apiKey: 'AIzaSyAhittQ639M_BmEtKGB8J2iwKYGIzDd51g',
    appId: '1:108724297221:web:f1684df4d5c0b4f9cac66c',
    messagingSenderId: '108724297221',
    projectId: 'wolfbyte-proj1',
    authDomain: 'wolfbyte-proj1.firebaseapp.com',
    storageBucket: 'wolfbyte-proj1.firebasestorage.app',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyAOyrvRspFfoeE6CFZef4acr0Wov5kvIaU',
    appId: '1:108724297221:android:9b181d15eb9f18decac66c',
    messagingSenderId: '108724297221',
    projectId: 'wolfbyte-proj1',
    storageBucket: 'wolfbyte-proj1.firebasestorage.app',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyAhittQ639M_BmEtKGB8J2iwKYGIzDd51g',
    appId: '1:108724297221:web:f1684df4d5c0b4f9cac66c',
    messagingSenderId: '108724297221',
    projectId: 'wolfbyte-proj1',
    authDomain: 'wolfbyte-proj1.firebaseapp.com',
    storageBucket: 'wolfbyte-proj1.firebasestorage.app',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyDbGE7m6EFCiHDY3iH9h3o81_8KZWVlUnQ',
    appId: '1:108724297221:ios:e51d62978c53c753cac66c',
    messagingSenderId: '108724297221',
    projectId: 'wolfbyte-proj1',
    storageBucket: 'wolfbyte-proj1.firebasestorage.app',
    iosBundleId: 'com.example.wolfbite',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyDbGE7m6EFCiHDY3iH9h3o81_8KZWVlUnQ',
    appId: '1:108724297221:ios:e51d62978c53c753cac66c',
    messagingSenderId: '108724297221',
    projectId: 'wolfbyte-proj1',
    storageBucket: 'wolfbyte-proj1.firebasestorage.app',
    iosBundleId: 'com.example.wolfbite',
  );
}
