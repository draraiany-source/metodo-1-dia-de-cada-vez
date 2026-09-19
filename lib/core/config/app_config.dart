import 'package:flutter/foundation.dart';

/// Configuração central de credenciais externas.
///
/// **Nenhuma chave secreta fica aqui.** Os valores são injetados em tempo de
/// build via `--dart-define`, o que evita comitar segredo no repositório:
///
/// ```bash
/// flutter build appbundle --release \
///   --dart-define=REVENUECAT_ANDROID_KEY=goog_xxx \
///   --dart-define=REVENUECAT_IOS_KEY=appl_xxx \
///   --dart-define=AMANDA_FUNCTION_URL=https://us-central1-SEU-PROJETO.cloudfunctions.net/amandaChat \
///   --dart-define=MAPS_API_KEY=AIza_xxx
/// ```
///
/// A chave da **OpenAI nunca entra no app** — ela vive na Cloud Function.
class AppConfig {
  AppConfig._();

  // ---------------------------------------------------------------------------
  // ASSINATURA / COMPRAS (RevenueCat → Google Play Billing + Apple StoreKit)
  // ---------------------------------------------------------------------------

  static const String revenueCatAndroidKey =
      String.fromEnvironment('REVENUECAT_ANDROID_KEY', defaultValue: '');

  static const String revenueCatIosKey =
      String.fromEnvironment('REVENUECAT_IOS_KEY', defaultValue: '');

  /// Identificador do "entitlement" configurado no painel do RevenueCat.
  static const String premiumEntitlement = 'premium';

  /// IDs dos produtos criados na Play Console e no App Store Connect.
  /// Devem ser idênticos nos dois lados e no RevenueCat.
  /// Padrão já existente no projeto — não trocar sem alinhar as lojas.
  static const String productMonthly = 'metodo1dia_premium_mensal';
  static const String productQuarterly = 'metodo1dia_premium_trimestral';
  static const String productYearly = 'metodo1dia_premium_anual';

  /// Cobrança real. `false` até App Store / Play + RevenueCat estarem prontos.
  /// Ativar só com `--dart-define=PAYMENTS_ENABLED=true`.
  static const bool paymentsEnabled =
      bool.fromEnvironment('PAYMENTS_ENABLED', defaultValue: false);

  static bool get billingConfigured =>
      revenueCatAndroidKey.isNotEmpty || revenueCatIosKey.isNotEmpty;

  static bool get storePurchasesEnabled =>
      paymentsEnabled && billingConfigured && !kIsWeb;

  // ---------------------------------------------------------------------------
  // IA (Cloud Function que faz proxy da OpenAI)
  // ---------------------------------------------------------------------------

  static const String amandaFunctionUrl =
      String.fromEnvironment('AMANDA_FUNCTION_URL', defaultValue: '');

  static bool get aiConfigured =>
      amandaFunctionUrl.isNotEmpty &&
      !amandaFunctionUrl.contains('SEU-PROJETO');

  /// Endpoint da Cloud Function que estima calorias a partir de uma foto
  /// (proxy para a OpenAI Vision — a chave nunca fica no app).
  static const String calorieVisionFunctionUrl =
      String.fromEnvironment('CALORIE_VISION_FUNCTION_URL', defaultValue: '');

  static bool get calorieVisionConfigured =>
      calorieVisionFunctionUrl.isNotEmpty &&
      !calorieVisionFunctionUrl.contains('SEU-PROJETO');

  // ---------------------------------------------------------------------------
  // MAPAS (corrida com GPS)
  // ---------------------------------------------------------------------------

  static const String mapsApiKey =
      String.fromEnvironment('MAPS_API_KEY', defaultValue: '');

  static bool get mapsConfigured => mapsApiKey.isNotEmpty;

  // ---------------------------------------------------------------------------
  // NOTIFICAÇÕES PUSH (FCM)
  // ---------------------------------------------------------------------------

  /// Tópicos padrão que o app oferece ao usuário.
  static const List<String> notificationTopics = [
    'motivacao_diaria',
    'desafios',
    'lembrete_agua',
    'lembrete_treino',
    'mensagem_amanda',
    'consultoria',
    'anamnese',
  ];

  /// Canal de notificação Android (deve bater com o criado no nativo).
  static const String androidNotificationChannelId = 'metodo1dia_default';
  static const String androidNotificationChannelName = 'Lembretes e motivação';

  // ---------------------------------------------------------------------------
  // Diagnóstico — usado na tela de Admin/Debug para mostrar o que falta.
  // ---------------------------------------------------------------------------

  static Map<String, bool> get status => {
        'Billing (RevenueCat)': billingConfigured,
        'Cobrança real (PAYMENTS_ENABLED)': paymentsEnabled,
        'IA (Cloud Function)': aiConfigured,
        'Calorias por foto (Cloud Function)': calorieVisionConfigured,
        'Google Maps': mapsConfigured,
      };
}
