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
      'treinos, hidratação, evolução, alimentação, mensagens com a Personal '
      'e notificações que você ativar.\n\n'
      'Dados tratados no app (quando você usa o recurso):\n'
      '• Identificação: nome, e-mail, foto de perfil\n'
      '• Fitness: peso, altura, IMC, treinos, hidratação, alimentação, '
      'anamnese, fotos de progresso e de refeição\n'
      '• Comunicação: mensagens com a Personal, agenda de consultoria\n'
      '• Técnico: token de notificação, Analytics e Crashlytics (Firebase)\n'
      '• Localização: apenas na corrida com GPS, em primeiro plano\n\n'
      'Serviços verificados: Firebase (Auth, Firestore, Storage, Messaging, '
      'Analytics, Crashlytics, App Check, Functions), RevenueCat (assinatura, '
      'cobrança ainda desligada) e OpenAI só no servidor.\n\n'
      'Exclusão: Configurações → Excluir minha conta. Alguns registros '
      '(assinatura da loja, mensagens de chat, vínculo da Personal e logs) '
      'podem permanecer — a política oficial lista o que fica.\n\n'
      'Documento completo: https://metodo1dia-app.web.app/privacidade.html\n'
      'Dúvidas: 1diadecadavezsuporte@gmail.com.';

  static const String inAppTermsSummary =
      'Ao criar uma conta você concorda em usar o app de forma pessoal, '
      'não compartilhar a senha e entender que treinos, receitas, estimativas '
      'e a IA não substituem médico, nutricionista ou psicólogo.\n\n'
      'O app não garante resultado físico. Assinatura, se houver, cancela-se '
      'na Google Play ou na App Store — excluir a conta não cancela a loja.\n\n'
      'A Personal e o Admin acessam dados de alunas vinculadas.\n\n'
      'Documento completo: https://metodo1dia-app.web.app/termos.html\n'
      'Dúvidas: 1diadecadavezsuporte@gmail.com.';

  static const String accountDeletionSummary =
      'A exclusão remove a conta de login, o perfil, fotos em Storage da '
      'sua pasta, histórico que as regras permitem apagar e dados locais '
      'do chat da IA neste aparelho.\n\n'
      'Não some sozinho: assinatura da loja (cancele em Gerenciar assinatura), '
      'documento de assinatura no servidor, mensagens do chat com a Personal, '
      'cadastro em pt_students, logs de IA e eventos já enviados ao Analytics.\n\n'
      'Para um dado específico, use Solicitar exclusão de dados ou o e-mail '
      '1diadecadavezsuporte@gmail.com.';
}
