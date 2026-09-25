# -*- coding: utf-8 -*-
from pathlib import Path
import json

root = Path(r"C:\Users\Lenovo\Desktop\metodo 1 dia perfil premium 2")

# 1) firebase_options web
fo = root / "lib/firebase_options.dart"
t = fo.read_text(encoding="utf-8")
old = """  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'REPLACE_ME',
    appId: 'REPLACE_ME',
    messagingSenderId: '990266923824',
    projectId: 'metodo1dia-app',
    authDomain: 'metodo1dia-app.firebaseapp.com',
    storageBucket: 'metodo1dia-app.firebasestorage.app',
  );"""
new = """  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyDhIwHcQc34jmYJanLXDe9O9vP2mf7X6L8',
    appId: '1:990266923824:web:6b70fdb655198c7cd886f5',
    messagingSenderId: '990266923824',
    projectId: 'metodo1dia-app',
    authDomain: 'metodo1dia-app.firebaseapp.com',
    storageBucket: 'metodo1dia-app.firebasestorage.app',
  );"""
if old not in t:
    raise SystemExit('web FirebaseOptions block not found')
fo.write_text(t.replace(old, new), encoding='utf-8')
print('OK firebase_options web')

# 2) firebase.json add hosting without removing existing keys
fj_path = root / "firebase.json"
data = json.loads(fj_path.read_text(encoding='utf-8'))
data['hosting'] = {
    "public": "build/web",
    "ignore": [
        "firebase.json",
        "**/.*",
        "**/node_modules/**"
    ],
    "rewrites": [
        {"source": "**", "destination": "/index.html"}
    ],
    "headers": [
        {
            "source": "/index.html",
            "headers": [
                {"key": "Cache-Control", "value": "no-cache, no-store, must-revalidate"}
            ]
        },
        {
            "source": "**/*.@(js|css|wasm|mp3|png|jpg|jpeg|webp|woff2)",
            "headers": [
                {"key": "Cache-Control", "value": "public, max-age=3600"}
            ]
        }
    ]
}
fj_path.write_text(json.dumps(data, indent=2, ensure_ascii=False) + "\n", encoding='utf-8')
print('OK firebase.json hosting')

# 3) ensure guest on for homolog staging, premium unlock off
ac = root / "lib/core/constants/app_constants.dart"
a = ac.read_text(encoding='utf-8')
if 'enableGuestMode = false' in a:
    a = a.replace(
        'static const bool enableGuestMode = false;',
        'static const bool enableGuestMode = true; // TEMP homolog web staging — revert before prod',
    )
    ac.write_text(a, encoding='utf-8')
    print('guest enabled for staging')
else:
    print('guest already true or custom')
if 'debugUnlockAllPremiumContent = true' in a:
    raise SystemExit('premium unlock must stay false')
print('premium unlock still false (checked pattern)')
