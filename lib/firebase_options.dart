// Firebase options — projeto metodo1dia-app.
//
// Android + Web: credenciais reais do Console (google-services.json / web app).
// iOS: projectId / messagingSenderId / storageBucket já alinhados ao projeto.
// apiKey e appId iOS permanecem REPLACE_ME de propósito — no repositório NÃO
// existe GoogleService-Info.plist nem app iOS registrado com IDs reais.
// NÃO copiar apiKey/appId do Android (Firebase rejeita appId de outra
// plataforma). Preencher somente após:
//   1) Firebase Console → Add app iOS (bundle com.metodo1dia.app)
//   2) baixar GoogleService-Info.plist OU `flutterfire configure`
// Até lá, FirebaseService faz graceful degradation no iOS (modo local).

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

  /// `false` até Amanda registrar o app iOS e rodar `flutterfire configure`.
  /// Não inventar apiKey/appId — Firebase rejeita IDs de outra plataforma.
  static bool get iosFirebaseReady => ios.apiKey != 'REPLACE_ME';

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyDhIwHcQc34jmYJanLXDe9O9vP2mf7X6L8',
    appId: '1:990266923824:web:6b70fdb655198c7cd886f5',
    messagingSenderId: '990266923824',
    projectId: 'metodo1dia-app',
    authDomain: 'metodo1dia-app.firebaseapp.com',
    storageBucket: 'metodo1dia-app.firebasestorage.app',
  );
}
