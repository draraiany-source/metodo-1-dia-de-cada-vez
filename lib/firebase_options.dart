// Firebase options — Android configurado para o projeto metodo1dia-app.
//
// iOS: projectId / messagingSenderId / storageBucket alinhados ao Android.
// apiKey e appId continuam REPLACE_ME até rodar `flutterfire configure`
// (ou colar GoogleService-Info.plist real). Sem isso o FirebaseService
// faz graceful degradation no iOS e o app roda em modo local.

import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) return web;
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      default:
        throw UnsupportedError(
          'Plataforma não configurada. Rode `flutterfire configure`.',
        );
    }
  }

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyD8Jv09MJseLLibPMAONmvqf5_f3m3dtGI',
    appId: '1:990266923824:android:2febdfc7c2fc1e03d886f5',
    messagingSenderId: '990266923824',
    projectId: 'metodo1dia-app',
    storageBucket: 'metodo1dia-app.firebasestorage.app',
  );

  // ACTION NEEDED: substituir apiKey/appId via `flutterfire configure`
  // após registrar o app iOS no Firebase Console.
  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'REPLACE_ME',
    appId: 'REPLACE_ME',
    messagingSenderId: '990266923824',
    projectId: 'metodo1dia-app',
    storageBucket: 'metodo1dia-app.firebasestorage.app',
    iosBundleId: 'com.metodo1dia.app',
  );

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyDhIwHcQc34jmYJanLXDe9O9vP2mf7X6L8',
    appId: '1:990266923824:web:6b70fdb655198c7cd886f5',
    messagingSenderId: '990266923824',
    projectId: 'metodo1dia-app',
    authDomain: 'metodo1dia-app.firebaseapp.com',
    storageBucket: 'metodo1dia-app.firebasestorage.app',
  );
}
