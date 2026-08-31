# Configuração Android & iOS

Estes trechos precisam ser aplicados nos arquivos nativos **depois** de rodar
`flutter create .` (que gera as pastas `android/` e `ios/`) e
`flutterfire configure` (que gera as configurações do Firebase).

---

## Android

### `android/app/src/main/AndroidManifest.xml`
Adicione, dentro de `<manifest>` (antes de `<application>`):

```xml
<uses-permission android:name="android.permission.INTERNET"/>
<uses-permission android:name="android.permission.ACCESS_FINE_LOCATION"/>
<uses-permission android:name="android.permission.ACCESS_COARSE_LOCATION"/>
<!-- Para rastrear corrida com a tela apagada (opcional): -->
<uses-permission android:name="android.permission.ACCESS_BACKGROUND_LOCATION"/>
<uses-permission android:name="android.permission.POST_NOTIFICATIONS"/>
```

Se usar Google Maps, dentro de `<application>`:
```xml
<meta-data
    android:name="com.google.android.geo.API_KEY"
    android:value="SUA_CHAVE_GOOGLE_MAPS"/>
```

### `android/app/build.gradle`
```gradle
android {
    defaultConfig {
        minSdkVersion 23   // Firebase Auth exige >= 23
        multiDexEnabled true
    }
}
```

O `flutterfire configure` cuida do plugin google-services automaticamente.

---

## iOS

### `ios/Runner/Info.plist`
Adicione:

```xml
<key>NSLocationWhenInUseUsageDescription</key>
<string>Usamos sua localização para rastrear suas corridas.</string>
<key>NSLocationAlwaysAndWhenInUseUsageDescription</key>
<string>Usamos sua localização para rastrear corridas mesmo em segundo plano.</string>
<key>NSCameraUsageDescription</key>
<string>Usado para adicionar fotos de progresso e perfil.</string>
<key>NSPhotoLibraryUsageDescription</key>
<string>Usado para escolher fotos de progresso e perfil.</string>
```

Se usar Google Maps, em `ios/Runner/AppDelegate.swift`:
```swift
import GoogleMaps
// dentro de application(_:didFinishLaunchingWithOptions:)
GMSServices.provideAPIKey("SUA_CHAVE_GOOGLE_MAPS")
```

### Podfile
```ruby
platform :ios, '13.0'   # Firebase exige >= 13
```
