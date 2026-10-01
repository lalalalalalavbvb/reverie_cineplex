// ignore_for_file: type=lint
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
    apiKey: 'AIzaSyBsE3KCFEnXo-JiyTEubSjuSV_vqjxSpsk',
    appId: '1:681095925789:web:f1f5596bdf803a368cf6f4',
    messagingSenderId: '681095925789',
    projectId: 'reverie-cineplex',
    authDomain: 'reverie-cineplex.firebaseapp.com',
    storageBucket: 'reverie-cineplex.firebasestorage.app',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyAbTAfp70E76WDu7ZRPey3SMYyksj4bD_I',
    appId: '1:681095925789:android:5acbbf3dcd2d131a8cf6f4',
    messagingSenderId: '681095925789',
    projectId: 'reverie-cineplex',
    storageBucket: 'reverie-cineplex.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyB9H0DHLaMKuwBSipCG8pDW4eAjDET_2Vc',
    appId: '1:681095925789:ios:4ccbf9517ce078608cf6f4',
    messagingSenderId: '681095925789',
    projectId: 'reverie-cineplex',
    storageBucket: 'reverie-cineplex.firebasestorage.app',
    iosBundleId: 'com.example.reverieCineplex',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyB9H0DHLaMKuwBSipCG8pDW4eAjDET_2Vc',
    appId: '1:681095925789:ios:4ccbf9517ce078608cf6f4',
    messagingSenderId: '681095925789',
    projectId: 'reverie-cineplex',
    storageBucket: 'reverie-cineplex.firebasestorage.app',
    iosBundleId: 'com.example.reverieCineplex',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyBsE3KCFEnXo-JiyTEubSjuSV_vqjxSpsk',
    appId: '1:681095925789:web:54bb20d27e0119c58cf6f4',
    messagingSenderId: '681095925789',
    projectId: 'reverie-cineplex',
    authDomain: 'reverie-cineplex.firebaseapp.com',
    storageBucket: 'reverie-cineplex.firebasestorage.app',
  );
}
