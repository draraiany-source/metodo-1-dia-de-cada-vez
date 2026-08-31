# 🩺 Permissões — Health Connect / Google Fit / Apple Health

Cole estes trechos **depois** de rodar `flutter create .` e de adicionar
`health: ^11.1.0` ao `pubspec.yaml`.

---

## Android — `android/app/src/main/AndroidManifest.xml`

Dentro de `<manifest>`, antes de `<application>`:

```xml
<!-- Health Connect -->
<uses-permission android:name="android.permission.health.READ_STEPS"/>
<uses-permission android:name="android.permission.health.READ_DISTANCE"/>
<uses-permission android:name="android.permission.health.READ_TOTAL_CALORIES_BURNED"/>
<uses-permission android:name="android.permission.health.READ_ACTIVE_CALORIES_BURNED"/>
<uses-permission android:name="android.permission.health.READ_HEART_RATE"/>
<uses-permission android:name="android.permission.health.READ_WEIGHT"/>
<uses-permission android:name="android.permission.health.READ_BODY_FAT"/>
<uses-permission android:name="android.permission.health.READ_EXERCISE"/>
<uses-permission android:name="android.permission.health.READ_HYDRATION"/>

<!-- Escrita (opcional: devolver peso/hidratação ao Health Connect) -->
<uses-permission android:name="android.permission.health.WRITE_WEIGHT"/>
<uses-permission android:name="android.permission.health.WRITE_HYDRATION"/>

<!-- Necessário para o Health Connect aparecer na lista de apps -->
<queries>
  <package android:name="com.google.android.apps.healthdata"/>
</queries>
```

Dentro de `<application>`, na `MainActivity`:

```xml
<!-- Tela de justificativa exigida pelo Health Connect -->
<activity-alias
    android:name="ViewPermissionUsageActivity"
    android:exported="true"
    android:targetActivity=".MainActivity"
    android:permission="android.permission.START_VIEW_PERMISSION_USAGE">
    <intent-filter>
        <action android:name="android.intent.action.VIEW_PERMISSION_USAGE"/>
        <category android:name="android.intent.category.HEALTH_PERMISSIONS"/>
    </intent-filter>
</activity-alias>
```

E em `android/app/build.gradle`: **`minSdkVersion 26`** (exigência do Health Connect).

> **Google Fit**: a partir de 2024 o Google recomenda migrar do Fit API para o
> Health Connect. O pacote `health` já lê os dados que o Google Fit grava no
> Health Connect — não é preciso integrar a API antiga.

---

## iOS — HealthKit

1. No **Xcode** → target `Runner` → *Signing & Capabilities* → **+ Capability** → **HealthKit**.
2. Em `ios/Runner/Info.plist`:

```xml
<key>NSHealthShareUsageDescription</key>
<string>Usamos seus dados de saúde (passos, calorias, peso) para acompanhar sua evolução e personalizar seus treinos.</string>
<key>NSHealthUpdateUsageDescription</key>
<string>Permite salvar seu peso e hidratação no app Saúde.</string>
```

3. Em `ios/Runner/Runner.entitlements`:

```xml
<key>com.apple.developer.healthkit</key>
<true/>
<key>com.apple.developer.healthkit.access</key>
<array/>
```

---

## Ativando no código

1. `pubspec.yaml` → `health: ^11.1.0` → `flutter pub get`
2. Em `lib/features/health_sync/data/health_service.dart`, **descomente** a classe
   `PlatformHealthService` (ela já está escrita por completo).
3. Em `lib/features/health_sync/providers/health_providers.dart`, troque:

```dart
// de:
return LocalHealthService(...);
// para:
return PlatformHealthService();
```

Nenhuma tela precisa mudar — a UI conversa só com a interface `HealthService`.

---

## Se o usuário negar a permissão

O app **continua funcionando normalmente**. O `LocalHealthService` monta o
snapshot a partir dos registros manuais (água, peso, treinos) e a tela mostra
"Usando registros manuais". Métricas exclusivas da plataforma (passos, distância,
calorias, frequência cardíaca) aparecem como `—`, sem quebrar nada.
