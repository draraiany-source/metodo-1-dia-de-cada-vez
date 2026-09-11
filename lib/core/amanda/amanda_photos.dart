/// Catálogo local das 15 fotos reais da Amanda (academia).
/// Firebase/Admin sobrescreve via URL; estes WebP são o fallback bundled.
class AmandaPhotos {
  AmandaPhotos._();

  static const String optimized = 'assets/amanda/optimized/';
  static const String thumbs = 'assets/amanda/thumbs/';

  static const profile = '${optimized}amanda-profile.webp';
  static const welcome = '${optimized}amanda-welcome.webp';
  static const home = '${optimized}amanda-home.webp';
  static const about01 = '${optimized}amanda-about-01.webp';
  static const about02 = '${optimized}amanda-about-02.webp';
  static const workout01 = '${optimized}amanda-workout-01.webp';
  static const workout02 = '${optimized}amanda-workout-02.webp';
  static const workout03 = '${optimized}amanda-workout-03.webp';
  static const motivation01 = '${optimized}amanda-motivation-01.webp';
  static const motivation02 = '${optimized}amanda-motivation-02.webp';
  static const program = '${optimized}amanda-program.webp';
  static const challenge = '${optimized}amanda-challenge.webp';
  static const audio = '${optimized}amanda-audio.webp';
  static const banner01 = '${optimized}amanda-banner-01.webp';
  static const banner02 = '${optimized}amanda-banner-02.webp';

  /// Pacote completo (15) — ordem estável para galeria local.
  static const List<String> all = [
    profile,
    welcome,
    home,
    about01,
    about02,
    workout01,
    workout02,
    workout03,
    motivation01,
    motivation02,
    program,
    challenge,
    audio,
    banner01,
    banner02,
  ];

  static String thumbFor(String optimizedPath) =>
      optimizedPath.replaceFirst(optimized, thumbs);

  /// Fallback por categoria do CMS (índice 0 = principal da categoria).
  static List<String> forCategoryName(String categoryName) {
    switch (categoryName) {
      case 'principal':
        return const [profile, welcome];
      case 'profissional':
        return const [about01, about02, home];
      case 'capa':
        return const [welcome, profile, home];
      case 'banner':
        return const [banner01, banner02, home];
      case 'categoria':
        return const [home, program];
      case 'desafio':
        return const [challenge, motivation01];
      case 'motivacional':
        return const [motivation01, motivation02, challenge];
      case 'premium':
        return const [program, motivation02];
      case 'galeria':
        return const [
          home,
          about01,
          workout01,
          workout02,
          workout03,
          about02,
          program,
        ];
      case 'trajetoria':
        return const [about02, about01, program];
      case 'treinos':
        return const [workout01, workout02, workout03, program];
      default:
        return const [profile];
    }
  }

  static String? localFor(String categoryName, {int index = 0}) {
    final list = forCategoryName(categoryName);
    if (list.isEmpty) return null;
    if (index < 0 || index >= list.length) {
      return index == 0 ? list.first : null;
    }
    return list[index];
  }
}
