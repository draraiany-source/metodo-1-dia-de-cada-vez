/// Contatos e documentos legais oficiais do Método 1 Dia de Cada Vez.
///
/// Valores padrão = endereços publicados. Podem ser sobrescritos no build:
///
/// ```
/// flutter build appbundle --release \
///   --dart-define=SUPPORT_EMAIL=1diadecadavezsuporte@gmail.com \
///   --dart-define=PRIVACY_POLICY_URL=https://metodo1dia-app.web.app/privacidade.html \
///   --dart-define=TERMS_URL=https://metodo1dia-app.web.app/termos.html
/// ```
class AppLegal {
  AppLegal._();

  static const String supportEmail = String.fromEnvironment(
    'SUPPORT_EMAIL',
    defaultValue: '1diadecadavezsuporte@gmail.com',
  );

  static const String privacyPolicyUrl = String.fromEnvironment(
    'PRIVACY_POLICY_URL',
    defaultValue: 'https://metodo1dia-app.web.app/privacidade.html',
  );

  static const String termsUrl = String.fromEnvironment(
    'TERMS_URL',
    defaultValue: 'https://metodo1dia-app.web.app/termos.html',
  );

  static bool get hasSupportEmail =>
      supportEmail.contains('@') && !supportEmail.contains('SEU-DOMINIO');

  static bool get hasPrivacyUrl =>
      privacyPolicyUrl.startsWith('https://') &&
      !privacyPolicyUrl.contains('SEU-DOMINIO');

  static bool get hasTermsUrl =>
      termsUrl.startsWith('https://') && !termsUrl.contains('SEU-DOMINIO');

  static const String inAppPrivacySummary =
      'O Método 1 Dia de Cada Vez trata dados para operar a conta, '
      'personalizar treinos, hidratação, evolução, mensagens com a Personal '
      'e notificações que você ativar.\n\n'
      'Dados tratados no app (quando você usa o recurso):\n'
      '• Identificação: nome, e-mail, foto de perfil\n'
      '• Saúde/fitness: peso, altura, IMC, treinos, hidratação, alimentação, '
      'anamnese, fotos de progresso\n'
      '• Comunicação: mensagens com a Personal, agenda de consultoria\n'
      '• Técnico: token de notificação, analytics/crash (Firebase)\n'
      '• Localização: apenas se você usar corrida com GPS\n\n'
      'Serviços: Firebase (Auth, Firestore, Storage, Messaging, Analytics, '
      'Crashlytics, App Check), RevenueCat (assinatura), OpenAI via Cloud '
      'Functions (IA — a chave não fica no app).\n\n'
      'A Política de Privacidade oficial está publicada em '
      'https://metodo1dia-app.web.app/privacidade.html e pode ser lida '
      'sem login. Dúvidas: 1diadecadavezsuporte@gmail.com.';

  static const String inAppTermsSummary =
      'Ao criar uma conta você concorda em usar o app de forma pessoal, '
      'não compartilhar a senha e entender que treinos, receitas e a Amanda '
      'não substituem orientação médica, nutricional ou psicológica.\n\n'
      'A Personal (Amanda) e administradoras autorizadas acessam dados de '
      'alunas vinculadas para acompanhamento.\n\n'
      'Os Termos de Uso oficiais estão publicados em '
      'https://metodo1dia-app.web.app/termos.html e podem ser lidos sem login. '
      'Dúvidas: 1diadecadavezsuporte@gmail.com.';
}
