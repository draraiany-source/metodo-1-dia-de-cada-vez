import 'package:flutter/foundation.dart';

import '../../firebase_options.dart';

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

  /// Offering padrão no painel do RevenueCat (current).
  static const String defaultOffering = 'default';

  /// Cobrança real de produção. Permanece `false` até autorização explícita.
  static const bool paymentsEnabled =
      bool.fromEnvironment('PAYMENTS_ENABLED', defaultValue: false);

  /// Libera o sheet da loja só para sandbox (Play license testers / StoreKit).
  /// Não é produção. Default `false`. Nunca enviar release de loja com isto
  /// no lugar de [paymentsEnabled].
  static const bool billingSandbox =
      bool.fromEnvironment('BILLING_SANDBOX', defaultValue: false);

  static bool get billingConfigured =>
      revenueCatAndroidKey.isNotEmpty || revenueCatIosKey.isNotEmpty;

  /// Pode abrir o fluxo da loja (sandbox ou produção autorizada).
  static bool get storePurchasesAllowed =>
      billingConfigured &&
      !kIsWeb &&
      (paymentsEnabled || billingSandbox);

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

  /// Carimbo de build de homologação (injetado via `--dart-define=HOMOLOG_BUILD_ID=`).
  /// Vazio em builds sem o define. Serve para confirmar que o canal/APK não é antigo.
  static const String homologBuildId =
      String.fromEnvironment('HOMOLOG_BUILD_ID', defaultValue: '');

  static String get homologBuildLabel {
    if (homologBuildId.isEmpty) return 'build sem carimbo';
    return 'homolog $homologBuildId';
  }

  // ---------------------------------------------------------------------------
  // Diagnóstico — usado na tela de Admin/Debug para mostrar o que falta.
  // ---------------------------------------------------------------------------

  static Map<String, bool> get status => {
        'Billing (RevenueCat)': billingConfigured,
        'Cobrança real (PAYMENTS_ENABLED)': paymentsEnabled,
        'Sandbox da loja (BILLING_SANDBOX)': billingSandbox,
        'IA (Cloud Function)': aiConfigured,
        'Calorias por foto (Cloud Function)': calorieVisionConfigured,
        'Google Maps': mapsConfigured,
        'Firebase iOS (não REPLACE_ME)': DefaultFirebaseOptions.iosFirebaseReady,
      };
}
