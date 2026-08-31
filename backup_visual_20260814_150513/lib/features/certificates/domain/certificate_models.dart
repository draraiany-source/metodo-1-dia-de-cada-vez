import '../../../models/app_user.dart';

/// Contexto com os dados necessários pra avaliar quais certificados a
/// usuária já desbloqueou.
class CertificateContext {
  const CertificateContext({
    required this.user,
    required this.streak,
    required this.totalWorkouts,
    required this.totalKm,
    required this.memberDays,
  });

  final AppUser user;
  final int streak;
  final int totalWorkouts;
  final double totalKm;
  final int memberDays;
}

class CertificateDef {
  const CertificateDef({
    required this.id,
    required this.title,
    required this.description,
    required this.emoji,
    required this.isUnlocked,
  });

  final String id;
  final String title;
  final String description;
  final String emoji;
  final bool Function(CertificateContext ctx) isUnlocked;
}

/// Catálogo de certificados — Módulo 6 do prompt master.
class CertificatesCatalog {
  CertificatesCatalog._();

  static final List<CertificateDef> all = [
    CertificateDef(
      id: 'streak_30',
      title: '30 dias de constância',
      description: 'Você manteve sua sequência por 30 dias seguidos.',
      emoji: '🔥',
      isUnlocked: (ctx) => ctx.streak >= 30,
    ),
    CertificateDef(
      id: 'streak_90',
      title: '90 dias de constância',
      description: 'Três meses de disciplina, um dia de cada vez.',
      emoji: '🌟',
      isUnlocked: (ctx) => ctx.streak >= 90,
    ),
    CertificateDef(
      id: 'streak_365',
      title: '1 ano de jornada',
      description: 'Um ano inteiro cuidando de você.',
      emoji: '👑',
      isUnlocked: (ctx) => ctx.streak >= 365,
    ),
    CertificateDef(
      id: 'workouts_100',
      title: '100 treinos concluídos',
      description: 'Cem treinos! Sua disciplina fala por si.',
      emoji: '🏋️',
      isUnlocked: (ctx) => ctx.totalWorkouts >= 100,
    ),
    CertificateDef(
      id: 'km_500',
      title: '500 km percorridos',
      description: 'Meio milhar de quilômetros nas suas pernas.',
      emoji: '🏃',
      isUnlocked: (ctx) => ctx.totalKm >= 500,
    ),
    CertificateDef(
      id: 'km_1000',
      title: '1.000 km percorridos',
      description: 'Mil quilômetros — uma jornada e tanto.',
      emoji: '🏆',
      isUnlocked: (ctx) => ctx.totalKm >= 1000,
    ),
    CertificateDef(
      id: 'member_30',
      title: '1 mês no Método',
      description: '30 dias fazendo parte da comunidade Lili Fit.',
      emoji: '📅',
      isUnlocked: (ctx) => ctx.memberDays >= 30,
    ),
  ];
}
