# ProGuard / R8 — Método 1 Dia de Cada Vez
# minifyEnabled + shrinkResources estão ativos no build release.

# Flutter embedding
-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugin.** { *; }
-keep class io.flutter.util.** { *; }
-keep class io.flutter.view.** { *; }
-keep class io.flutter.** { *; }
-keep class io.flutter.plugins.** { *; }

# Firebase / Play Services
-keep class com.google.firebase.** { *; }
-keep class com.google.android.gms.** { *; }
-dontwarn com.google.firebase.**
-dontwarn com.google.android.gms.**
-keep class com.google.android.gms.location.** { *; }

# RevenueCat (purchases_flutter / Play Billing)
-keep class com.revenuecat.purchases.** { *; }
-dontwarn com.revenuecat.purchases.**
-keep class com.android.vending.billing.** { *; }
-dontwarn com.android.vending.billing.**

# Reflexão / anotações / enums
-keepattributes Signature
-keepattributes *Annotation*
-keepattributes EnclosingMethod
-keepattributes InnerClasses
-keepclassmembers enum * {
    public static **[] values();
    public static ** valueOf(java.lang.String);
}
-keepattributes SourceFile,LineNumberTable
-keep public class * extends java.lang.Exception

# Dependências opcionais / avisos comuns
-dontwarn com.shockwave.**
-keep class com.shockwave.** { *; }
-dontwarn com.google.android.exoplayer2.**
-dontwarn org.bouncycastle.**
-dontwarn org.conscrypt.**
-dontwarn org.openjsse.**

# Play Core / deferred components (Flutter embedding — classes opcionais)
-dontwarn com.google.android.play.core.splitcompat.SplitCompatApplication
-dontwarn com.google.android.play.core.splitinstall.**
-dontwarn com.google.android.play.core.tasks.**
