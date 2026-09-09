import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/router/app_router.dart';
import '../../../core/router/app_navigation.dart';
import '../../../core/router/premium_app_bar.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/app_page.dart';
import '../domain/amanda_profile_models.dart';
import '../providers/amanda_assets_providers.dart';

/// Painel: Editar meu perfil (textos, redes, contato).
/// Fotos continuam em [Routes.amandaAssetsAdmin].
class AmandaProfileEditScreen extends ConsumerStatefulWidget {
  const AmandaProfileEditScreen({super.key});

  @override
  ConsumerState<AmandaProfileEditScreen> createState() =>
      _AmandaProfileEditScreenState();
}

class _AmandaProfileEditScreenState
    extends ConsumerState<AmandaProfileEditScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _fullName;
  late final TextEditingController _title;
  late final TextEditingController _shortBio;
  late final TextEditingController _story;
  late final TextEditingController _methodology;
  late final TextEditingController _quote;
  late final TextEditingController _specialties;
  late final TextEditingController _certifications;
  late final TextEditingController _instagram;
  late final TextEditingController _youtube;
  late final TextEditingController _tiktok;
  late final TextEditingController _facebook;
  late final TextEditingController _website;
  late final TextEditingController _whatsapp;
  late final TextEditingController _contactLabel;

  bool _hydrated = false;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    final d = AmandaProfileContent.defaults;
    _fullName = TextEditingController(text: d.fullName);
    _title = TextEditingController(text: d.professionalTitle);
    _shortBio = TextEditingController(text: d.shortBio);
    _story = TextEditingController(text: d.story);
    _methodology = TextEditingController(text: d.methodology);
    _quote = TextEditingController(text: d.highlightQuote);
    _specialties = TextEditingController(text: d.specialties.join('\n'));
    _certifications =
        TextEditingController(text: d.certifications.join('\n'));
    _instagram = TextEditingController();
    _youtube = TextEditingController();
    _tiktok = TextEditingController();
    _facebook = TextEditingController();
    _website = TextEditingController();
    _whatsapp = TextEditingController();
    _contactLabel = TextEditingController(text: d.contactLabel);
  }

  void _apply(AmandaProfileContent p) {
    _fullName.text = p.fullName;
    _title.text = p.professionalTitle;
    _shortBio.text = p.shortBio;
    _story.text = p.story;
    _methodology.text = p.methodology;
    _quote.text = p.highlightQuote;
    _specialties.text = p.specialties.join('\n');
    _certifications.text = p.certifications.join('\n');
    _instagram.text = p.instagramUrl;
    _youtube.text = p.youtubeUrl;
    _tiktok.text = p.tiktokUrl;
    _facebook.text = p.facebookUrl;
    _website.text = p.websiteUrl;
    _whatsapp.text = p.whatsappNumber;
    _contactLabel.text = p.contactLabel;
  }

  List<String> _lines(String raw) => raw
      .split(RegExp(r'[\n,]'))
      .map((e) => e.trim())
      .where((e) => e.isNotEmpty)
      .toList();

  Future<void> _save() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    setState(() => _saving = true);
    try {
      final content = AmandaProfileContent(
        fullName: _fullName.text.trim(),
        professionalTitle: _title.text.trim(),
        shortBio: _shortBio.text.trim(),
        story: _story.text.trim(),
        specialties: _lines(_specialties.text),
        methodology: _methodology.text.trim(),
        certifications: _lines(_certifications.text),
        highlightQuote: _quote.text.trim(),
        instagramUrl: _instagram.text.trim(),
        youtubeUrl: _youtube.text.trim(),
        tiktokUrl: _tiktok.text.trim(),
        facebookUrl: _facebook.text.trim(),
        websiteUrl: _website.text.trim(),
        whatsappNumber: _whatsapp.text.replaceAll(RegExp(r'\D'), ''),
        contactLabel: _contactLabel.text.trim().isEmpty
            ? AmandaProfileContent.defaults.contactLabel
            : _contactLabel.text.trim(),
      );
      await ref.read(amandaProfileRepositoryProvider).save(content);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Perfil atualizado. Já aparece no app.')),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao salvar: $e')),
      );
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  void dispose() {
    _fullName.dispose();
    _title.dispose();
    _shortBio.dispose();
    _story.dispose();
    _methodology.dispose();
    _quote.dispose();
    _specialties.dispose();
    _certifications.dispose();
    _instagram.dispose();
    _youtube.dispose();
    _tiktok.dispose();
    _facebook.dispose();
    _website.dispose();
    _whatsapp.dispose();
    _contactLabel.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final async = ref.watch(amandaProfileContentProvider);
    async.whenData((p) {
      if (!_hydrated) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (!mounted || _hydrated) return;
          _apply(p);
          setState(() => _hydrated = true);
        });
      }
    });

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: PremiumAppBar(
        title: 'Editar meu perfil',
        actions: [
          TextButton(
            onPressed: _saving ? null : _save,
            child: _saving
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Text('Salvar',
                    style: TextStyle(color: AppColors.secondary)),
          ),
        ],
      ),
      body: SafeArea(
        child: AppPage(
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _HintCard(
                  onPhotos: () =>
                      AppNavigation.open(context, Routes.amandaAssetsAdmin),
                  onPreview: () =>
                      AppNavigation.open(context, Routes.amandaProfile),
                ),
                const SizedBox(height: 18),
                const _SectionLabel('Identidade'),
                _field(_fullName, 'Nome completo', required: true),
                _field(_title, 'Título profissional', required: true),
                _field(_shortBio, 'Apresentação curta', maxLines: 3),
                _field(_quote, 'Frase de destaque', maxLines: 2),
                const SizedBox(height: 12),
                const _SectionLabel('História e metodologia'),
                _field(_story, 'História pessoal/profissional', maxLines: 6),
                _field(_methodology, 'Metodologia de trabalho', maxLines: 5),
                const SizedBox(height: 12),
                const _SectionLabel('Especialidades (uma por linha)'),
                _field(_specialties, 'Especialidades', maxLines: 6),
                const SizedBox(height: 12),
                const _SectionLabel('Formação / certificações (uma por linha)'),
                _field(_certifications, 'Certificações', maxLines: 5),
                const SizedBox(height: 12),
                const _SectionLabel('Redes sociais'),
                _field(_instagram, 'Instagram (URL)'),
                _field(_youtube, 'YouTube (URL)'),
                _field(_tiktok, 'TikTok (URL)'),
                _field(_facebook, 'Facebook (URL)'),
                _field(_website, 'Site (URL)'),
                const SizedBox(height: 12),
                const _SectionLabel('Contato'),
                _field(_whatsapp,
                    'WhatsApp (DDI+DDD+número, só números)',
                    keyboard: TextInputType.phone),
                _field(_contactLabel, 'Texto do botão de contato'),
                const SizedBox(height: 20),
                FilledButton(
                  onPressed: _saving ? null : _save,
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.secondary,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: Text(_saving ? 'Salvando...' : 'Salvar alterações'),
                ),
                const SizedBox(height: 28),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _field(
    TextEditingController c,
    String label, {
    int maxLines = 1,
    bool required = false,
    TextInputType? keyboard,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextFormField(
        controller: c,
        maxLines: maxLines,
        keyboardType: keyboard,
        style: const TextStyle(color: Colors.white),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(color: AppColors.textSecondary),
          filled: true,
          fillColor: AppColors.surface,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: AppColors.border),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: AppColors.border),
          ),
        ),
        validator: required
            ? (v) =>
                (v == null || v.trim().isEmpty) ? 'Preencha este campo' : null
            : null,
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  const _SectionLabel(this.text);
  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(text,
          style: const TextStyle(
              color: Colors.white, fontWeight: FontWeight.w800, fontSize: 15)),
    );
  }
}

class _HintCard extends StatelessWidget {
  const _HintCard({required this.onPhotos, required this.onPreview});
  final VoidCallback onPhotos;
  final VoidCallback onPreview;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppTheme.radius),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Aqui você edita textos, especialidades, formação e redes. '
            'Fotos de perfil, capa e galeria ficam em “Fotos da Amanda”.',
            style: TextStyle(
                color: AppColors.textSecondary, height: 1.4, fontSize: 13),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              OutlinedButton.icon(
                onPressed: onPhotos,
                icon: const Icon(Icons.photo_library_outlined, size: 18),
                label: const Text('Gerenciar fotos'),
              ),
              OutlinedButton.icon(
                onPressed: onPreview,
                icon: const Icon(Icons.visibility_outlined, size: 18),
                label: const Text('Ver Quem Sou Eu'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
