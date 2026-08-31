import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../design_system/app_spacing.dart';
import '../design_system/app_shadows.dart';

/// Conteúdo visual (medalhas, banners, cenas) desenhado nativamente no Flutter.
///
/// Motivo: `flutter_svg` não renderiza `<text>`/emoji de forma confiável.
/// Os SVGs equivalentes em `assets/` servem como export para web/marketing;
/// dentro do app usamos estes widgets para garantir emoji + texto perfeitos,
/// mantendo exatamente o mesmo visual (gradiente + glow premium).

// ---------------------------------------------------------------------------
// MEDALHAS / CONQUISTAS
// ---------------------------------------------------------------------------

class TierStyle {
  final List<Color> colors;
  final String emoji;
  const TierStyle(this.colors, this.emoji);
}

const Map<String, TierStyle> kTiers = {
  'bronze': TierStyle([Color(0xFFE8A15C), Color(0xFF8C5A2B)], '🥉'),
  'prata': TierStyle([Color(0xFFEDF0F4), Color(0xFF98A0AC)], '🥈'),
  'ouro': TierStyle([Color(0xFFFFDD70), Color(0xFFE5A400)], '🥇'),
  'diamante': TierStyle([Color(0xFF8FEBFF), Color(0xFF2F9BFF)], '💎'),
  'elite': TierStyle([Color(0xFFC08BFF), Color(0xFF6A2CE0)], '⭐'),
  'master': TierStyle([Color(0xFFFF8FBF), Color(0xFFC42B6B)], '👑'),
  'lendario': TierStyle([Color(0xFFFFC24B), Color(0xFFFF4FA0)], '🔥'),
  'premium': TierStyle([Color(0xFFFFDD70), Color(0xFF9B5DE5)], '✨'),
  'vip': TierStyle([Color(0xFFFFD86B), Color(0xFF111111)], '💜'),
};

/// Medalha circular com fita, gradiente e brilho.
class LiliMedal extends StatelessWidget {
  const LiliMedal({
    super.key,
    required this.tier,
    this.size = 120,
    this.label,
    this.locked = false,
  });
  final String tier;
  final double size;
  final String? label;
  final bool locked;

  @override
  Widget build(BuildContext context) {
    final style = kTiers[tier] ?? kTiers['ouro']!;
    final medal = Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: style.colors,
            ),
            border: Border.all(color: Colors.white.withOpacity(0.35), width: 3),
            boxShadow: locked ? null : AppShadows.card,
          ),
          child: Center(
            child: Text(style.emoji,
                style: TextStyle(fontSize: size * 0.42)),
          ),
        ),
        if (label != null) ...[
          const SizedBox(height: 6),
          Text(label!.toUpperCase(),
              style: TextStyle(
                  fontSize: size * 0.11,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1,
                  color: Colors.white)),
        ],
      ],
    );
    if (!locked) return medal;
    return Opacity(
      opacity: 0.4,
      child: ColorFiltered(
        colorFilter: const ColorFilter.mode(Colors.grey, BlendMode.saturation),
        child: medal,
      ),
    );
  }
}

class AchievementStyle {
  final String emoji;
  final String label;
  final List<Color> colors;
  const AchievementStyle(this.emoji, this.label, this.colors);
}

const Map<String, AchievementStyle> kAchievements = {
  'primeiro_treino': AchievementStyle('💪', '1º Treino', [Color(0xFF9B5DE5), Color(0xFF5A189A)]),
  '7_dias': AchievementStyle('🔥', '7 Dias', [Color(0xFFFF8A5B), Color(0xFFE5484D)]),
  '15_dias': AchievementStyle('🔥', '15 Dias', [Color(0xFFFF7AA2), Color(0xFFC42B6B)]),
  '30_dias': AchievementStyle('🏆', '30 Dias', [Color(0xFFFFDD70), Color(0xFFE5A400)]),
  '60_dias': AchievementStyle('🏆', '60 Dias', [Color(0xFF8FEBFF), Color(0xFF2F9BFF)]),
  '90_dias': AchievementStyle('💎', '90 Dias', [Color(0xFFC08BFF), Color(0xFF6A2CE0)]),
  '180_dias': AchievementStyle('💎', '180 Dias', [Color(0xFFFF8FBF), Color(0xFFC42B6B)]),
  '365_dias': AchievementStyle('👑', '365 Dias', [Color(0xFFFFC24B), Color(0xFFFF4FA0)]),
  'meta_concluida': AchievementStyle('🎯', 'Meta OK', [Color(0xFF00C896), Color(0xFF0A8F6E)]),
  'peso_perdido': AchievementStyle('⚖️', 'Peso -', [Color(0xFF00C896), Color(0xFF2F9BFF)]),
  'alimentacao_perfeita': AchievementStyle('🥗', 'Nutrição', [Color(0xFF7BD88F), Color(0xFF0A8F6E)]),
  'agua_completa': AchievementStyle('💧', 'Água 100%', [Color(0xFF8FEBFF), Color(0xFF2F9BFF)]),
  'constancia': AchievementStyle('📅', 'Constância', [Color(0xFFC08BFF), Color(0xFF6A2CE0)]),
  'superacao': AchievementStyle('🚀', 'Superação', [Color(0xFFFFDD70), Color(0xFF9B5DE5)]),
};

/// Conquista quadrada arredondada com emoji e rótulo.
class LiliAchievement extends StatelessWidget {
  const LiliAchievement({
    super.key,
    required this.id,
    this.size = 110,
    this.locked = false,
  });
  final String id;
  final double size;
  final bool locked;

  @override
  Widget build(BuildContext context) {
    final s = kAchievements[id] ?? kAchievements['primeiro_treino']!;
    final w = Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: s.colors,
            ),
            borderRadius: BorderRadius.circular(size * 0.25),
            border: Border.all(color: Colors.white.withOpacity(0.4), width: 3),
            boxShadow: locked ? null : AppShadows.card,
          ),
          child: Center(
              child: Text(s.emoji, style: TextStyle(fontSize: size * 0.42))),
        ),
        const SizedBox(height: 6),
        Text(s.label,
            style: TextStyle(
                fontSize: size * 0.13,
                fontWeight: FontWeight.w700,
                color: const Color(0xFFEDEBF3))),
      ],
    );
    if (!locked) return w;
    return Opacity(opacity: 0.4, child: w);
  }
}

// ---------------------------------------------------------------------------
// BANNERS
// ---------------------------------------------------------------------------

class BannerStyle {
  final String title;
  final String subtitle;
  final String emoji;
  final List<Color> colors;
  const BannerStyle(this.title, this.subtitle, this.emoji, this.colors);
}

const Map<String, BannerStyle> kBanners = {
  'premium': BannerStyle('Premium', 'Desbloqueie sua melhor versão', '👑', [Color(0xFFF59E0B), Color(0xFF5A189A)]),
  'assinatura': BannerStyle('Assine já', 'Tudo liberado, sem limites', '✨', [Color(0xFF9B5DE5), Color(0xFFF15BB5)]),
  'desafios': BannerStyle('Desafios', 'Supere seus limites', '🔥', [Color(0xFFFF6B6B), Color(0xFF7C1D6F)]),
  'ranking': BannerStyle('Ranking', 'Suba no pódio da semana', '🏆', [Color(0xFFFFD86B), Color(0xFFC42B6B)]),
  'conquistas': BannerStyle('Conquistas', 'Colecione suas medalhas', '🎖️', [Color(0xFF8FEBFF), Color(0xFF5A189A)]),
  'alimentacao': BannerStyle('Nutrição', 'Coma bem, se sinta melhor', '🥗', [Color(0xFF00C896), Color(0xFF0A5E5A)]),
  'treinos': BannerStyle('Treinos', 'Treine no seu ritmo', '💪', [Color(0xFF9B5DE5), Color(0xFF2A1055)]),
};

class LiliBanner extends StatelessWidget {
  const LiliBanner({super.key, required this.id, this.onTap, this.height = 150});
  final String id;
  final VoidCallback? onTap;
  final double height;

  @override
  Widget build(BuildContext context) {
    final b = kBanners[id] ?? kBanners['treinos']!;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: height,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: b.colors,
          ),
          borderRadius: BorderRadius.circular(AppRadii.xl),
          boxShadow: AppShadows.card,
        ),
        child: Stack(
          children: [
            Positioned(
              right: -6,
              bottom: -10,
              child: Text(b.emoji,
                  style: TextStyle(
                      fontSize: height * 0.75,
                      color: Colors.white.withOpacity(0.18))),
            ),
            Padding(
              padding: const EdgeInsets.all(18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('LILI FIT',
                      style: TextStyle(
                          color: Colors.white.withOpacity(0.85),
                          fontWeight: FontWeight.w800,
                          fontSize: 12,
                          letterSpacing: 2)),
                  const SizedBox(height: 6),
                  Text(b.title,
                      style: const TextStyle(
                          color: Colors.white,
                          fontSize: 26,
                          fontWeight: FontWeight.w800)),
                  const SizedBox(height: 2),
                  Text(b.subtitle,
                      style: TextStyle(
                          color: Colors.white.withOpacity(0.9), fontSize: 14)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// CENAS (onboarding / empty / error)
// ---------------------------------------------------------------------------

class LiliScene extends StatelessWidget {
  const LiliScene({
    super.key,
    required this.emoji,
    required this.title,
    this.subtitle = 'Um dia de cada vez 💜',
    this.colors = const [Color(0xFF2A1055), Color(0xFF0E0A18)],
    this.accent = AppColors.primary,
  });
  final String emoji;
  final String title;
  final String subtitle;
  final List<Color> colors;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        gradient: RadialGradient(colors: colors, radius: 0.9),
        borderRadius: BorderRadius.circular(AppRadii.xl),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 150,
            height: 150,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: accent.withOpacity(0.15),
              border: Border.all(color: accent.withOpacity(0.5), width: 2),
            ),
            child: Center(child: Text(emoji, style: const TextStyle(fontSize: 72))),
          ),
          const SizedBox(height: 20),
          Text(title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                  color: Color(0xFFEDEBF3),
                  fontSize: 20,
                  fontWeight: FontWeight.w700)),
          const SizedBox(height: 6),
          Text(subtitle,
              textAlign: TextAlign.center,
              style: const TextStyle(color: AppColors.accent, fontSize: 14)),
        ],
      ),
    );
  }
}
