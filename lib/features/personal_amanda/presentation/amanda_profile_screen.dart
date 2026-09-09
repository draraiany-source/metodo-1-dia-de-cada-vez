import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../core/assets/app_icons.dart';
import '../../../core/router/premium_app_bar.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/app_icon_image.dart';
import '../../../core/widgets/app_page.dart';
import '../domain/amanda_asset_models.dart';
import '../domain/amanda_profile_models.dart';
import '../providers/amanda_assets_providers.dart';
import 'amanda_image.dart';
import 'amanda_photo_gallery.dart';

/// Perfil público premium — Quem Sou Eu (conteúdo 100% editável no Firebase).
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
    final uri = Uri.parse('https://wa.me/${p.whatsappNumber}');
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }

  void _scrollToStory() {
    final ctx = _storyKey.currentContext;
    if (ctx == null) return;
    Scrollable.ensureVisible(
      ctx,
      duration: const Duration(milliseconds: 450),
      curve: Curves.easeOutCubic,
    );
  }

  @override
  Widget build(BuildContext context) {
    final profile =
        ref.watch(amandaProfileContentProvider).valueOrNull ??
            AmandaProfileContent.defaults;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: const PremiumAppBar(title: 'Quem Sou Eu'),
      body: SafeArea(
        child: AppPage(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const AmandaMainPortrait(),
              const SizedBox(height: 12),
              Center(
                child: Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: AppColors.background, width: 4),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.secondary.withOpacity(0.35),
                        blurRadius: 18,
                        offset: const Offset(0, 8),
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
              const SizedBox(height: 14),
              Text(
                profile.fullName,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 26,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                profile.professionalTitle,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: AppColors.secondary,
                  fontWeight: FontWeight.w700,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  AppIconImage(
                    AppIcons.personal,
                    size: 16,
                    fallbackIcon: Icons.sports_gymnastics_rounded,
                  ),
                  const SizedBox(width: 6),
                  const Text(
                    'Método 1 Dia de Cada Vez',
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Text(
                profile.shortBio,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: AppColors.textSecondary,
                  height: 1.45,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 16),
              FilledButton(
                onPressed: _scrollToStory,
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.secondary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                child: const Text('Conheça minha história'),
              ),
              if (profile.hasWhatsApp) ...[
                const SizedBox(height: 10),
                OutlinedButton.icon(
                  onPressed: () => _openWhatsApp(profile),
                  icon: const Icon(Icons.chat_rounded),
                  label: Text(profile.contactLabel),
                ),
              ],
              if (profile.highlightQuote.trim().isNotEmpty) ...[
                const SizedBox(height: 22),
                _QuoteCard(quote: profile.highlightQuote),
              ],
              const SizedBox(height: 26),
              const _SectionTitle(title: 'Especialidades'),
              const SizedBox(height: 10),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  for (final s in profile.specialties)
                    Chip(
                      label: Text(s),
                      backgroundColor: AppColors.surface2,
                      side: const BorderSide(color: AppColors.border),
                      labelStyle: const TextStyle(
                          color: Colors.white, fontSize: 12.5),
                    ),
                ],
              ),
              const SizedBox(height: 26),
              KeyedSubtree(
                key: _storyKey,
                child: _TextCard(
                  title: 'Minha história',
                  body: profile.story,
                ),
              ),
              const SizedBox(height: 16),
              _TextCard(
                title: 'Metodologia',
                body: profile.methodology,
              ),
              const SizedBox(height: 26),
              const AmandaPhotoSection(
                title: 'Galeria',
                subtitle:
                    'Treinos, academia, eventos e rotina. Toque para ampliar.',
                child: AmandaFullGalleryGrid(),
              ),
              const SizedBox(height: 26),
              const _SectionTitle(title: 'Formação e certificações'),
              const SizedBox(height: 10),
              for (final c in profile.certifications)
                Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(Icons.verified_rounded,
                          color: AppColors.secondary, size: 18),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(c,
                            style: const TextStyle(
                                color: Colors.white, height: 1.35)),
                      ),
                    ],
                  ),
                ),
              const SizedBox(height: 16),
              const AmandaPhotoSection(
                title: 'Trajetória em fotos',
                subtitle: 'Formação, certificações e momentos da carreira.',
                child: AmandaPhotoGallery(
                  category: AmandaAssetCategory.trajetoria,
                  count: 4,
                  aspectRatio: 1,
                ),
              ),
              if (profile.hasAnySocial || profile.hasWhatsApp) ...[
                const SizedBox(height: 26),
                const _SectionTitle(title: 'Redes e contato'),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: [
                    if (profile.instagramUrl.isNotEmpty)
                      _SocialChip(
                        label: 'Instagram',
                        icon: Icons.camera_alt_outlined,
                        onTap: () => _openUrl(profile.instagramUrl),
                      ),
                    if (profile.youtubeUrl.isNotEmpty)
                      _SocialChip(
                        label: 'YouTube',
                        icon: Icons.play_circle_outline,
                        onTap: () => _openUrl(profile.youtubeUrl),
                      ),
                    if (profile.tiktokUrl.isNotEmpty)
                      _SocialChip(
                        label: 'TikTok',
                        icon: Icons.music_note_outlined,
                        onTap: () => _openUrl(profile.tiktokUrl),
                      ),
                    if (profile.facebookUrl.isNotEmpty)
                      _SocialChip(
                        label: 'Facebook',
                        icon: Icons.facebook,
                        onTap: () => _openUrl(profile.facebookUrl),
                      ),
                    if (profile.websiteUrl.isNotEmpty)
                      _SocialChip(
                        label: 'Site',
                        icon: Icons.language,
                        onTap: () => _openUrl(profile.websiteUrl),
                      ),
                    if (profile.hasWhatsApp)
                      _SocialChip(
                        label: profile.contactLabel,
                        icon: Icons.chat_rounded,
                        onTap: () => _openWhatsApp(profile),
                      ),
                  ],
                ),
              ],
              const SizedBox(height: 28),
            ],
          ),
        ),
      ),
    );
  }
}

class _QuoteCard extends StatelessWidget {
  const _QuoteCard({required this.quote});
  final String quote;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: AppColors.softCardGradient,
        borderRadius: BorderRadius.circular(AppTheme.radius),
        border: Border.all(color: AppColors.border),
      ),
      child: Text(
        '"$quote"',
        textAlign: TextAlign.center,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 15,
          height: 1.45,
          fontStyle: FontStyle.italic,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}

class _TextCard extends StatelessWidget {
  const _TextCard({required this.title, required this.body});
  final String title;
  final String body;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
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
        ],
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({required this.title});
  final String title;

  @override
  Widget build(BuildContext context) {
    return Text(title,
        style: const TextStyle(
            color: Colors.white, fontWeight: FontWeight.w800, fontSize: 16));
  }
}

class _SocialChip extends StatelessWidget {
  const _SocialChip({
    required this.label,
    required this.icon,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ActionChip(
      onPressed: onTap,
      avatar: Icon(icon, size: 16, color: AppColors.secondary),
      label: Text(label),
      backgroundColor: AppColors.surface2,
      side: const BorderSide(color: AppColors.border),
      labelStyle: const TextStyle(color: Colors.white, fontSize: 12.5),
    );
  }
}
