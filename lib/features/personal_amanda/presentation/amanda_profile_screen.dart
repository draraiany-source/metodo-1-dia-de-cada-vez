import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../core/router/app_router.dart';
import '../../../core/router/app_navigation.dart';
import '../../../core/router/premium_app_bar.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/app_page.dart';
import '../domain/amanda_asset_models.dart';
import '../domain/amanda_profile_models.dart';
import '../providers/amanda_assets_providers.dart';
import 'amanda_image.dart';
import 'amanda_photo_gallery.dart';

/// Perfil público — Quem Sou Eu / Conheça a Amanda (Firebase).
class AmandaProfileScreen extends ConsumerStatefulWidget {
  const AmandaProfileScreen({super.key});

  @override
  ConsumerState<AmandaProfileScreen> createState() =>
      _AmandaProfileScreenState();
}

class _AmandaProfileScreenState extends ConsumerState<AmandaProfileScreen> {
  final _storyKey = GlobalKey();

  Future<void> _openUrl(String raw) async {
    final uri = Uri.tryParse(raw.trim());
    if (uri == null) return;
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }

  Future<void> _openWhatsApp(AmandaProfileContent p) async {
    if (!p.hasWhatsApp) return;
    await launchUrl(
      Uri.parse('https://wa.me/${p.whatsappNumber}'),
      mode: LaunchMode.externalApplication,
    );
  }

  Future<void> _startCta(AmandaProfileContent p) async {
    switch (p.startCtaTarget) {
      case AmandaCtaTarget.whatsapp:
        if (p.hasWhatsApp) {
          await _openWhatsApp(p);
        } else if (p.startCtaUrl.isNotEmpty) {
          await _openUrl(p.startCtaUrl);
        }
        break;
      case AmandaCtaTarget.plans:
        if (p.plansUrl.isNotEmpty) {
          await _openUrl(p.plansUrl);
        } else {
          AppNavigation.open(context, Routes.premium);
        }
        break;
      case AmandaCtaTarget.url:
        if (p.startCtaUrl.isNotEmpty) await _openUrl(p.startCtaUrl);
        break;
    }
  }

  void _scrollToStory() {
    final ctx = _storyKey.currentContext;
    if (ctx == null) return;
    Scrollable.ensureVisible(
      ctx,
      duration: const Duration(milliseconds: 480),
      curve: Curves.easeOutCubic,
    );
  }

  @override
  Widget build(BuildContext context) {
    final profile = ref.watch(amandaProfileContentProvider).valueOrNull ??
        AmandaProfileContent.defaults;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: const PremiumAppBar(title: 'Conheça a Amanda'),
      body: SafeArea(
        child: AppPage(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _Hero(
                profile: profile,
                onStory: _scrollToStory,
                onStart: () => _startCta(profile),
              ),
              const SizedBox(height: 22),
              KeyedSubtree(
                key: _storyKey,
                child: _Section(
                  title: 'Apresentação',
                  child: Column(
                    children: [
                      _BodyText(profile.shortBio),
                      const SizedBox(height: 14),
                      _Quote(profile.highlightQuote),
                    ],
                  ),
                ),
              ),
              _Section(
                title: 'Minha história com o esporte',
                child: Column(
                  children: [
                    if (profile.sportHistoryImageUrl.isNotEmpty) ...[
                      _RemotePhoto(profile.sportHistoryImageUrl),
                      const SizedBox(height: 12),
                    ] else ...[
                      const AmandaPhotoGallery(
                        category: AmandaAssetCategory.trajetoria,
                        count: 1,
                        aspectRatio: 1.35,
                      ),
                      const SizedBox(height: 12),
                    ],
                    _BodyText(profile.sportHistory),
                  ],
                ),
              ),
              _Section(
                title: 'Minha formação',
                child: Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: [
                    for (final f in profile.formations)
                      _FormationCard(item: f),
                  ],
                ),
              ),
              _Section(
                title: 'Por que escolhi ser Personal Trainer',
                child: Column(
                  children: [
                    if (profile.whyPtImageUrl.isNotEmpty) ...[
                      _RemotePhoto(profile.whyPtImageUrl),
                      const SizedBox(height: 12),
                    ] else
                      const Padding(
                        padding: EdgeInsets.only(bottom: 12),
                        child: SizedBox(
                          width: double.infinity,
                          height: 180,
                          child: AmandaImage(
                            category: AmandaAssetCategory.profissional,
                            fallbacks: [AmandaAssetCategory.principal],
                            width: 400,
                            height: 180,
                            shape: BoxShape.rectangle,
                            borderRadius: BorderRadius.all(Radius.circular(16)),
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                    _BodyText(profile.whyPersonalTrainer),
                  ],
                ),
              ),
              _FeatureCard(
                title: profile.markedStoryTitle,
                body: profile.markedStory,
                accent: true,
              ),
              _Section(
                title: 'Minha própria transformação',
                child: Column(
                  children: [
                    if (profile.transformationImageUrl.isNotEmpty) ...[
                      _RemotePhoto(profile.transformationImageUrl),
                      const SizedBox(height: 12),
                    ],
                    _BodyText(profile.ownTransformation),
                  ],
                ),
              ),
              _Section(
                title: 'Como nasceu o Método 1 Dia de Cada Vez',
                child: Column(
                  children: [
                    _BodyText(profile.methodOrigin),
                    const SizedBox(height: 14),
                    _Quote(profile.methodMantra),
                  ],
                ),
              ),
              _Section(
                title: 'O que significa 1 dia de cada vez',
                child: _BodyText(profile.methodMeaning),
              ),
              _Section(
                title: 'Para quem o método foi criado',
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    for (final item in profile.methodAudience)
                      _BulletCard(item),
                    const SizedBox(height: 12),
                    _Quote(profile.methodAudienceHighlight),
                  ],
                ),
              ),
              _Section(
                title: 'Principal objetivo do método',
                child: _BodyText(profile.methodMainGoal),
              ),
              _Section(
                title: 'O que diferencia o método',
                child: Column(
                  children: [
                    _BodyText(profile.methodDifference),
                    const SizedBox(height: 12),
                    _Quote(profile.methodDifferenceHighlight),
                  ],
                ),
              ),
              _Section(
                title: 'Como funciona o acompanhamento',
                child: Column(
                  children: [
                    for (var i = 0; i < profile.accompanimentSteps.length; i++)
                      _StepRow(
                        index: i + 1,
                        label: profile.accompanimentSteps[i],
                      ),
                    const SizedBox(height: 14),
                    _BodyText(profile.accompanimentBody),
                  ],
                ),
              ),
              _Section(
                title: 'Minha filosofia',
                child: Column(
                  children: [
                    Row(
                      children: [
                        for (final c in profile.philosophyCards.take(3))
                          Expanded(
                            child: Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 4),
                              child: _BigValueCard(c),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    _BodyText(profile.philosophyText),
                  ],
                ),
              ),
              _Section(
                title: 'Treino e equilíbrio',
                child: Column(
                  children: [
                    _BodyText(profile.trainingBalance),
                    const SizedBox(height: 12),
                    _Quote(profile.trainingBalanceHighlight),
                  ],
                ),
              ),
              _FeatureCard(
                title: 'Quando você pensar em desistir',
                body: profile.whenThinkQuit,
              ),
              _Section(
                title: 'Um pouco mais sobre mim',
                child: Column(
                  children: [
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        for (final c in profile.aboutMeCards)
                          _ChipValue(c),
                      ],
                    ),
                    const SizedBox(height: 12),
                    _BodyText(profile.aboutMeText),
                    const SizedBox(height: 10),
                    _Quote(profile.highlightQuote),
                  ],
                ),
              ),
              _Section(
                title: 'O que mais amo na minha profissão',
                child: _BodyText(profile.loveProfession),
              ),
              _Section(
                title: 'Meu sonho com o Método',
                child: _BodyText(profile.methodDream),
              ),
              _Section(
                title: 'Como quero que você se sinta aqui',
                child: Column(
                  children: [
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        for (final c in profile.feelHereCards)
                          _ChipValue(c),
                      ],
                    ),
                    const SizedBox(height: 12),
                    _BodyText(profile.feelHereText),
                  ],
                ),
              ),
              const AmandaPhotoSection(
                title: 'Galeria da Amanda',
                subtitle:
                    'Profissional, treinos, academia, esporte e rotina. Toque para ampliar.',
                child: AmandaFullGalleryGrid(),
              ),
              const SizedBox(height: 22),
              _FeatureCard(
                title: 'Mensagem final',
                body: profile.closingMessage,
                accent: true,
                footer: Column(
                  children: [
                    const SizedBox(height: 10),
                    Text(profile.fullName,
                        style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w800,
                            fontSize: 16)),
                    Text(profile.signatureTitle,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                            color: AppColors.secondary,
                            height: 1.35,
                            fontSize: 13)),
                  ],
                ),
              ),
              const SizedBox(height: 18),
              _Section(
                title: 'Contato',
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    if (profile.instagramUrl.isNotEmpty)
                      _LinkButton(
                        label: 'Instagram · @AmandalopesPersonalTrainer',
                        onTap: () => _openUrl(profile.instagramUrl),
                      ),
                    if (profile.instagramMetodoUrl.isNotEmpty)
                      _LinkButton(
                        label: 'Método · @metodo1decadavez',
                        onTap: () => _openUrl(profile.instagramMetodoUrl),
                      ),
                    if (profile.hasWhatsApp)
                      _LinkButton(
                        label: profile.contactLabel,
                        onTap: () => _openWhatsApp(profile),
                      ),
                    const SizedBox(height: 8),
                    FilledButton(
                      onPressed: () => _startCta(profile),
                      style: FilledButton.styleFrom(
                        backgroundColor: AppColors.secondary,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      child: Text(profile.startCtaLabel),
                    ),
                    if (profile.plansUrl.isNotEmpty) ...[
                      const SizedBox(height: 8),
                      OutlinedButton(
                        onPressed: () => _openUrl(profile.plansUrl),
                        child: const Text('Conhecer os planos'),
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }
}

class _Hero extends StatelessWidget {
  const _Hero({
    required this.profile,
    required this.onStory,
    required this.onStart,
  });

  final AmandaProfileContent profile;
  final VoidCallback onStory;
  final VoidCallback onStart;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const AmandaMainPortrait(),
        const SizedBox(height: 10),
        Center(
          child: Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: AppColors.background, width: 4),
              boxShadow: [
                BoxShadow(
                  color: AppColors.secondary.withOpacity(0.35),
                  blurRadius: 16,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: const AmandaImage(
              category: AmandaAssetCategory.principal,
              fallbacks: [
                AmandaAssetCategory.profissional,
                AmandaAssetCategory.banner,
              ],
              size: 104,
              shape: BoxShape.circle,
              fit: BoxFit.cover,
              placeholderIcon: Icons.person_rounded,
            ),
          ),
        ),
        const SizedBox(height: 12),
        Text(profile.fullName,
            textAlign: TextAlign.center,
            style: const TextStyle(
                color: Colors.white,
                fontSize: 26,
                fontWeight: FontWeight.w800)),
        const SizedBox(height: 4),
        Text(profile.professionalTitle,
            textAlign: TextAlign.center,
            style: const TextStyle(
                color: AppColors.secondary,
                fontWeight: FontWeight.w700,
                fontSize: 13.5,
                height: 1.3)),
        if (profile.location.isNotEmpty) ...[
          const SizedBox(height: 6),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.location_on_outlined,
                  size: 14, color: AppColors.textSecondary),
              const SizedBox(width: 4),
              Text(profile.location,
                  style: const TextStyle(
                      color: AppColors.textSecondary, fontSize: 12.5)),
            ],
          ),
        ],
        const SizedBox(height: 16),
        FilledButton(
          onPressed: onStory,
          style: FilledButton.styleFrom(
            backgroundColor: AppColors.secondary,
            minimumSize: const Size.fromHeight(46),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          ),
          child: const Text('Conheça minha história'),
        ),
        const SizedBox(height: 8),
        OutlinedButton(
          onPressed: onStart,
          style: OutlinedButton.styleFrom(
            minimumSize: const Size.fromHeight(46),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          ),
          child: Text(profile.startCtaLabel),
        ),
      ],
    );
  }
}

class _Section extends StatelessWidget {
  const _Section({required this.title, required this.child});
  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 26),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title,
              style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w800,
                  fontSize: 17)),
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }
}

class _BodyText extends StatelessWidget {
  const _BodyText(this.text);
  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(text,
        style: const TextStyle(
            color: AppColors.textSecondary, height: 1.5, fontSize: 14));
  }
}

class _Quote extends StatelessWidget {
  const _Quote(this.text);
  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: AppColors.softCardGradient,
        borderRadius: BorderRadius.circular(AppTheme.radius),
        border: Border.all(color: AppColors.border),
      ),
      child: Text(
        text,
        textAlign: TextAlign.center,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 14.5,
          height: 1.45,
          fontStyle: FontStyle.italic,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

class _FeatureCard extends StatelessWidget {
  const _FeatureCard({
    required this.title,
    required this.body,
    this.accent = false,
    this.footer,
  });

  final String title;
  final String body;
  final bool accent;
  final Widget? footer;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 22),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: accent ? null : AppColors.surface,
        gradient: accent ? AppColors.softCardGradient : null,
        borderRadius: BorderRadius.circular(AppTheme.radius),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title,
              style: const TextStyle(
                  color: Colors.white, fontWeight: FontWeight.w800)),
          const SizedBox(height: 8),
          Text(body,
              style: const TextStyle(
                  color: AppColors.textSecondary, height: 1.5, fontSize: 14)),
          if (footer != null) footer!,
        ],
      ),
    );
  }
}

class _FormationCard extends StatelessWidget {
  const _FormationCard({required this.item});
  final AmandaFormationItem item;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 160,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (item.imageUrl.isNotEmpty)
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: CachedNetworkImage(
                imageUrl: item.imageUrl,
                height: 72,
                width: double.infinity,
                fit: BoxFit.cover,
              ),
            )
          else
            const Icon(Icons.school_outlined, color: AppColors.secondary),
          const SizedBox(height: 8),
          Text(item.name,
              style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                  fontSize: 12.5,
                  height: 1.25)),
          if (item.institution.isNotEmpty) ...[
            const SizedBox(height: 4),
            Text(item.institution,
                style: const TextStyle(
                    color: AppColors.textSecondary, fontSize: 11)),
          ],
          if (item.year.isNotEmpty)
            Text(item.year,
                style: const TextStyle(
                    color: AppColors.textTertiary, fontSize: 11)),
        ],
      ),
    );
  }
}

class _BulletCard extends StatelessWidget {
  const _BulletCard(this.text);
  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.check_circle_outline,
              color: AppColors.secondary, size: 18),
          const SizedBox(width: 8),
          Expanded(
            child: Text(text,
                style: const TextStyle(
                    color: Colors.white, height: 1.35, fontSize: 13.5)),
          ),
        ],
      ),
    );
  }
}

class _StepRow extends StatelessWidget {
  const _StepRow({required this.index, required this.label});
  final int index;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          CircleAvatar(
            radius: 14,
            backgroundColor: AppColors.secondary.withOpacity(0.2),
            child: Text('$index',
                style: const TextStyle(
                    color: AppColors.secondary,
                    fontWeight: FontWeight.w800,
                    fontSize: 12)),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(label,
                style: const TextStyle(color: Colors.white, fontSize: 13.5)),
          ),
        ],
      ),
    );
  }
}

class _BigValueCard extends StatelessWidget {
  const _BigValueCard(this.label);
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 6),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
      ),
      child: Text(label,
          textAlign: TextAlign.center,
          style: const TextStyle(
              color: AppColors.secondary,
              fontWeight: FontWeight.w800,
              fontSize: 11,
              height: 1.2)),
    );
  }
}

class _ChipValue extends StatelessWidget {
  const _ChipValue(this.label);
  final String label;

  @override
  Widget build(BuildContext context) {
    return Chip(
      label: Text(label),
      backgroundColor: AppColors.surface2,
      side: const BorderSide(color: AppColors.border),
      labelStyle: const TextStyle(
          color: Colors.white, fontWeight: FontWeight.w700, fontSize: 12),
    );
  }
}

class _LinkButton extends StatelessWidget {
  const _LinkButton({required this.label, required this.onTap});
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: OutlinedButton(
        onPressed: onTap,
        style: OutlinedButton.styleFrom(
          alignment: Alignment.centerLeft,
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        ),
        child: Text(label),
      ),
    );
  }
}

class _RemotePhoto extends StatelessWidget {
  const _RemotePhoto(this.url);
  final String url;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: AspectRatio(
        aspectRatio: 1.35,
        child: CachedNetworkImage(
          imageUrl: url,
          fit: BoxFit.cover,
          placeholder: (_, __) => const ColoredBox(color: AppColors.surface2),
          errorWidget: (_, __, ___) => const ColoredBox(
            color: AppColors.surface2,
            child: Icon(Icons.broken_image_outlined),
          ),
        ),
      ),
    );
  }
}
