/// Conteúdo textual do perfil público da Amanda (Quem Sou Eu).
/// Fotos continuam em `amanda_assets`; textos/links neste documento.
class AmandaProfileContent {
  const AmandaProfileContent({
    required this.fullName,
    required this.professionalTitle,
    required this.shortBio,
    required this.story,
    required this.specialties,
    required this.methodology,
    required this.certifications,
    required this.highlightQuote,
    required this.instagramUrl,
    required this.youtubeUrl,
    required this.tiktokUrl,
    required this.facebookUrl,
    required this.websiteUrl,
    required this.whatsappNumber,
    required this.contactLabel,
  });

  final String fullName;
  final String professionalTitle;
  final String shortBio;
  final String story;
  final List<String> specialties;
  final String methodology;
  final List<String> certifications;
  final String highlightQuote;
  final String instagramUrl;
  final String youtubeUrl;
  final String tiktokUrl;
  final String facebookUrl;
  final String websiteUrl;

  /// Somente dígitos com DDI, ex.: 5511999999999
  final String whatsappNumber;
  final String contactLabel;

  static const defaults = AmandaProfileContent(
    fullName: 'Amanda Lopes',
    professionalTitle: 'Treinadora Pessoal On-line',
    shortBio:
        'Personal trainer oficial do Método 1 Dia de Cada Vez. Monta treinos, '
        'orienta a rotina e acompanha a sua evolução — um dia de cada vez.',
    story:
        'A Amanda acredita que transformação real acontece com constância, '
        'cuidado e planos feitos sob medida. No aplicativo, ela reúne treino, '
        'orientação e motivação para você avançar no seu ritmo.',
    specialties: [
      'Treino personalizado online',
      'Emagrecimento saudável',
      'Hipertrofia e definição',
      'Iniciantes e retorno aos treinos',
      'Rotina fitness sustentável',
    ],
    methodology:
        'O Método 1 Dia de Cada Vez prioriza hábitos simples, progressão segura '
        'e acompanhamento contínuo. Cada treino e orientação é pensado para a '
        'sua realidade — sem perfeição, com presença.',
    certifications: [
      'Personal Trainer',
      'Especialização em treinamento online',
    ],
    highlightQuote:
        'Você não precisa ser perfeita. Só precisa começar — um dia de cada vez.',
    instagramUrl: '',
    youtubeUrl: '',
    tiktokUrl: '',
    facebookUrl: '',
    websiteUrl: '',
    whatsappNumber: '',
    contactLabel: 'Falar no WhatsApp',
  );

  Map<String, dynamic> toMap() => {
        'fullName': fullName,
        'professionalTitle': professionalTitle,
        'shortBio': shortBio,
        'story': story,
        'specialties': specialties,
        'methodology': methodology,
        'certifications': certifications,
        'highlightQuote': highlightQuote,
        'instagramUrl': instagramUrl,
        'youtubeUrl': youtubeUrl,
        'tiktokUrl': tiktokUrl,
        'facebookUrl': facebookUrl,
        'websiteUrl': websiteUrl,
        'whatsappNumber': whatsappNumber,
        'contactLabel': contactLabel,
        'updatedAt': DateTime.now().toIso8601String(),
      };

  factory AmandaProfileContent.fromMap(Map<String, dynamic>? m) {
    if (m == null || m.isEmpty) return defaults;
    List<String> list(dynamic v) {
      if (v is List) {
        return v.map((e) => e.toString().trim()).where((e) => e.isNotEmpty).toList();
      }
      if (v is String && v.trim().isNotEmpty) {
        return v
            .split(RegExp(r'[\n,]'))
            .map((e) => e.trim())
            .where((e) => e.isNotEmpty)
            .toList();
      }
      return const [];
    }

    String s(String key, String fallback) {
      final v = (m[key] ?? '').toString().trim();
      return v.isEmpty ? fallback : v;
    }

    final specs = list(m['specialties']);
    final certs = list(m['certifications']);

    return AmandaProfileContent(
      fullName: s('fullName', defaults.fullName),
      professionalTitle: s('professionalTitle', defaults.professionalTitle),
      shortBio: s('shortBio', defaults.shortBio),
      story: s('story', defaults.story),
      specialties: specs.isEmpty ? defaults.specialties : specs,
      methodology: s('methodology', defaults.methodology),
      certifications: certs.isEmpty ? defaults.certifications : certs,
      highlightQuote: s('highlightQuote', defaults.highlightQuote),
      instagramUrl: (m['instagramUrl'] ?? '').toString().trim(),
      youtubeUrl: (m['youtubeUrl'] ?? '').toString().trim(),
      tiktokUrl: (m['tiktokUrl'] ?? '').toString().trim(),
      facebookUrl: (m['facebookUrl'] ?? '').toString().trim(),
      websiteUrl: (m['websiteUrl'] ?? '').toString().trim(),
      whatsappNumber: (m['whatsappNumber'] ?? '')
          .toString()
          .replaceAll(RegExp(r'\D'), ''),
      contactLabel: s('contactLabel', defaults.contactLabel),
    );
  }

  AmandaProfileContent copyWith({
    String? fullName,
    String? professionalTitle,
    String? shortBio,
    String? story,
    List<String>? specialties,
    String? methodology,
    List<String>? certifications,
    String? highlightQuote,
    String? instagramUrl,
    String? youtubeUrl,
    String? tiktokUrl,
    String? facebookUrl,
    String? websiteUrl,
    String? whatsappNumber,
    String? contactLabel,
  }) =>
      AmandaProfileContent(
        fullName: fullName ?? this.fullName,
        professionalTitle: professionalTitle ?? this.professionalTitle,
        shortBio: shortBio ?? this.shortBio,
        story: story ?? this.story,
        specialties: specialties ?? this.specialties,
        methodology: methodology ?? this.methodology,
        certifications: certifications ?? this.certifications,
        highlightQuote: highlightQuote ?? this.highlightQuote,
        instagramUrl: instagramUrl ?? this.instagramUrl,
        youtubeUrl: youtubeUrl ?? this.youtubeUrl,
        tiktokUrl: tiktokUrl ?? this.tiktokUrl,
        facebookUrl: facebookUrl ?? this.facebookUrl,
        websiteUrl: websiteUrl ?? this.websiteUrl,
        whatsappNumber: whatsappNumber ?? this.whatsappNumber,
        contactLabel: contactLabel ?? this.contactLabel,
      );

  bool get hasWhatsApp => whatsappNumber.length >= 10;
  bool get hasAnySocial =>
      instagramUrl.isNotEmpty ||
      youtubeUrl.isNotEmpty ||
      tiktokUrl.isNotEmpty ||
      facebookUrl.isNotEmpty ||
      websiteUrl.isNotEmpty;
}
