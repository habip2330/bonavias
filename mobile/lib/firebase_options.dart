import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

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
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for windows - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
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
    apiKey: 'AIzaSyD0s6-YNGZJp8JQJ5R2eDtOi-PjK8m8GtY',
    appId: '1:1234567890:web:abcdef123456',
    messagingSenderId: '1234567890',
    projectId: 'bona-5d3a3',
    authDomain: 'bona-5d3a3.firebaseapp.com',
    storageBucket: 'bona-5d3a3.appspot.com',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyD0s6-YNGZJp8JQJ5R2eDtOi-PjK8m8GtY',
    appId: '1:1234567890:android:abcdef123456',
    messagingSenderId: '1234567890',
    projectId: 'bona-5d3a3',
    storageBucket: 'bona-5d3a3.appspot.com',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyD0s6-YNGZJp8JQJ5R2eDtOi-PjK8m8GtY',
    appId: '1:1234567890:ios:abcdef123456',
    messagingSenderId: '1234567890',
    projectId: 'bona-5d3a3',
    storageBucket: 'bona-5d3a3.appspot.com',
    iosClientId: '1234567890-abcdefg.apps.googleusercontent.com',
    iosBundleId: 'com.bonavias.desserts',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyD0s6-YNGZJp8JQJ5R2eDtOi-PjK8m8GtY',
    appId: '1:1234567890:ios:abcdef123456',
    messagingSenderId: '1234567890',
    projectId: 'bona-5d3a3',
    storageBucket: 'bona-5d3a3.appspot.com',
    iosClientId: '1234567890-abcdefg.apps.googleusercontent.com',
    iosBundleId: 'com.bonavias.desserts',
  );
} 