import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/router/app_navigation.dart';
import '../../../core/router/app_router.dart';
import '../../../core/router/premium_app_bar.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/app_page.dart';
import '../domain/amanda_profile_models.dart';
import '../providers/amanda_assets_providers.dart';

/// Painel: Editar Quem Sou Eu (textos, CTAs, redes).
/// Fotos: [Routes.amandaAssetsAdmin].
class AmandaProfileEditScreen extends ConsumerStatefulWidget {
  const AmandaProfileEditScreen({super.key});

  @override
  ConsumerState<AmandaProfileEditScreen> createState() =>
      _AmandaProfileEditScreenState();
}

class _AmandaProfileEditScreenState
    extends ConsumerState<AmandaProfileEditScreen> {
  final _formKey = GlobalKey<FormState>();
  late final Map<String, TextEditingController> _c;
  AmandaCtaTarget _ctaTarget = AmandaCtaTarget.whatsapp;
  bool _hydrated = false;
  bool _saving = false;

  static const _keys = <String>[
    'fullName',
    'title',
    'location',
    'shortBio',
    'quote',
    'sportHistory',
    'formations',
    'whyPt',
    'markedTitle',
    'markedStory',
    'ownTransformation',
    'methodOrigin',
    'methodMantra',
    'methodMeaning',
    'methodAudience',
    'methodAudienceHighlight',
    'methodMainGoal',
    'methodDifference',
    'methodDifferenceHighlight',
    'accompanimentSteps',
    'accompanimentBody',
    'philosophyCards',
    'philosophyText',
    'trainingBalance',
    'trainingBalanceHighlight',
    'whenThinkQuit',
    'aboutMeCards',
    'aboutMeText',
    'loveProfession',
    'methodDream',
    'feelHereCards',
    'feelHereText',
    'closingMessage',
    'signatureTitle',
    'instagram',
    'instagramMetodo',
    'youtube',
    'tiktok',
    'facebook',
    'website',
    'plansUrl',
    'whatsapp',
    'contactLabel',
    'startCtaLabel',
    'startCtaUrl',
    'sportHistoryImageUrl',
    'whyPtImageUrl',
    'transformationImageUrl',
  ];

  @override
  void initState() {
    super.initState();
    _c = {for (final k in _keys) k: TextEditingController()};
    _apply(AmandaProfileContent.defaults);
  }

  void _apply(AmandaProfileContent p) {
    _c['fullName']!.text = p.fullName;
    _c['title']!.text = p.professionalTitle;
    _c['location']!.text = p.location;
    _c['shortBio']!.text = p.shortBio;
    _c['quote']!.text = p.highlightQuote;
    _c['sportHistory']!.text = p.sportHistory;
    _c['formations']!.text = p.formations
        .map((f) {
          final parts = [f.name];
          if (f.institution.isNotEmpty) parts.add(f.institution);
          if (f.year.isNotEmpty) parts.add(f.year);
          return parts.join(' | ');
        })
        .join('\n');
    _c['whyPt']!.text = p.whyPersonalTrainer;
    _c['markedTitle']!.text = p.markedStoryTitle;
    _c['markedStory']!.text = p.markedStory;
    _c['ownTransformation']!.text = p.ownTransformation;
    _c['methodOrigin']!.text = p.methodOrigin;
    _c['methodMantra']!.text = p.methodMantra;
    _c['methodMeaning']!.text = p.methodMeaning;
    _c['methodAudience']!.text = p.methodAudience.join('\n');
    _c['methodAudienceHighlight']!.text = p.methodAudienceHighlight;
    _c['methodMainGoal']!.text = p.methodMainGoal;
    _c['methodDifference']!.text = p.methodDifference;
    _c['methodDifferenceHighlight']!.text = p.methodDifferenceHighlight;
    _c['accompanimentSteps']!.text = p.accompanimentSteps.join('\n');
    _c['accompanimentBody']!.text = p.accompanimentBody;
    _c['philosophyCards']!.text = p.philosophyCards.join('\n');
    _c['philosophyText']!.text = p.philosophyText;
    _c['trainingBalance']!.text = p.trainingBalance;
    _c['trainingBalanceHighlight']!.text = p.trainingBalanceHighlight;
    _c['whenThinkQuit']!.text = p.whenThinkQuit;
    _c['aboutMeCards']!.text = p.aboutMeCards.join('\n');
    _c['aboutMeText']!.text = p.aboutMeText;
    _c['loveProfession']!.text = p.loveProfession;
    _c['methodDream']!.text = p.methodDream;
    _c['feelHereCards']!.text = p.feelHereCards.join('\n');
    _c['feelHereText']!.text = p.feelHereText;
    _c['closingMessage']!.text = p.closingMessage;
    _c['signatureTitle']!.text = p.signatureTitle;
    _c['instagram']!.text = p.instagramUrl;
    _c['instagramMetodo']!.text = p.instagramMetodoUrl;
    _c['youtube']!.text = p.youtubeUrl;
    _c['tiktok']!.text = p.tiktokUrl;
    _c['facebook']!.text = p.facebookUrl;
    _c['website']!.text = p.websiteUrl;
    _c['plansUrl']!.text = p.plansUrl;
    _c['whatsapp']!.text = p.whatsappNumber;
    _c['contactLabel']!.text = p.contactLabel;
    _c['startCtaLabel']!.text = p.startCtaLabel;
    _c['startCtaUrl']!.text = p.startCtaUrl;
    _c['sportHistoryImageUrl']!.text = p.sportHistoryImageUrl;
    _c['whyPtImageUrl']!.text = p.whyPtImageUrl;
    _c['transformationImageUrl']!.text = p.transformationImageUrl;
    _ctaTarget = p.startCtaTarget;
  }

  List<String> _lines(String key) => _c[key]!
      .text
      .split(RegExp(r'[\n,]'))
      .map((e) => e.trim())
      .where((e) => e.isNotEmpty)
      .toList();

  List<AmandaFormationItem> _parseFormations() {
    return _c['formations']!
        .text
        .split('\n')
        .map((e) => e.trim())
        .where((e) => e.isNotEmpty)
        .map((line) {
      final parts = line.split('|').map((e) => e.trim()).toList();
      return AmandaFormationItem(
        name: parts.isNotEmpty ? parts[0] : line,
        institution: parts.length > 1 ? parts[1] : '',
        year: parts.length > 2 ? parts[2] : '',
      );
    }).toList();
  }

  Future<void> _save() async {
    setState(() => _saving = true);
    try {
      final formations = _parseFormations();
      final content = AmandaProfileContent(
        fullName: _c['fullName']!.text.trim(),
        professionalTitle: _c['title']!.text.trim(),
        location: _c['location']!.text.trim(),
        shortBio: _c['shortBio']!.text.trim(),
        highlightQuote: _c['quote']!.text.trim(),
        sportHistory: _c['sportHistory']!.text.trim(),
        formations: formations.isEmpty
            ? AmandaProfileContent.defaults.formations
            : formations,
        whyPersonalTrainer: _c['whyPt']!.text.trim(),
        markedStoryTitle: _c['markedTitle']!.text.trim(),
        markedStory: _c['markedStory']!.text.trim(),
        ownTransformation: _c['ownTransformation']!.text.trim(),
        methodOrigin: _c['methodOrigin']!.text.trim(),
        methodMantra: _c['methodMantra']!.text.trim(),
        methodMeaning: _c['methodMeaning']!.text.trim(),
        methodAudience: _lines('methodAudience'),
        methodAudienceHighlight: _c['methodAudienceHighlight']!.text.trim(),
        methodMainGoal: _c['methodMainGoal']!.text.trim(),
        methodDifference: _c['methodDifference']!.text.trim(),
        methodDifferenceHighlight:
            _c['methodDifferenceHighlight']!.text.trim(),
        accompanimentSteps: _lines('accompanimentSteps'),
        accompanimentBody: _c['accompanimentBody']!.text.trim(),
        philosophyCards: _lines('philosophyCards'),
        philosophyText: _c['philosophyText']!.text.trim(),
        trainingBalance: _c['trainingBalance']!.text.trim(),
        trainingBalanceHighlight:
            _c['trainingBalanceHighlight']!.text.trim(),
        whenThinkQuit: _c['whenThinkQuit']!.text.trim(),
        aboutMeCards: _lines('aboutMeCards'),
        aboutMeText: _c['aboutMeText']!.text.trim(),
        loveProfession: _c['loveProfession']!.text.trim(),
        methodDream: _c['methodDream']!.text.trim(),
        feelHereCards: _lines('feelHereCards'),
        feelHereText: _c['feelHereText']!.text.trim(),
        closingMessage: _c['closingMessage']!.text.trim(),
        signatureTitle: _c['signatureTitle']!.text.trim(),
        specialties: AmandaProfileContent.defaults.specialties,
        methodology: AmandaProfileContent.defaults.methodology,
        certifications: formations.map((f) => f.name).toList(),
        story: _c['sportHistory']!.text.trim(),
        instagramUrl: _c['instagram']!.text.trim(),
        instagramMetodoUrl: _c['instagramMetodo']!.text.trim(),
        youtubeUrl: _c['youtube']!.text.trim(),
        tiktokUrl: _c['tiktok']!.text.trim(),
        facebookUrl: _c['facebook']!.text.trim(),
        websiteUrl: _c['website']!.text.trim(),
        plansUrl: _c['plansUrl']!.text.trim(),
        whatsappNumber: _c['whatsapp']!.text.replaceAll(RegExp(r'\D'), ''),
        contactLabel: _c['contactLabel']!.text.trim().isEmpty
            ? AmandaProfileContent.defaults.contactLabel
            : _c['contactLabel']!.text.trim(),
        startCtaLabel: _c['startCtaLabel']!.text.trim().isEmpty
            ? AmandaProfileContent.defaults.startCtaLabel
            : _c['startCtaLabel']!.text.trim(),
        startCtaTarget: _ctaTarget,
        startCtaUrl: _c['startCtaUrl']!.text.trim(),
        sportHistoryImageUrl: _c['sportHistoryImageUrl']!.text.trim(),
        whyPtImageUrl: _c['whyPtImageUrl']!.text.trim(),
        transformationImageUrl: _c['transformationImageUrl']!.text.trim(),
      );
      await ref.read(amandaProfileRepositoryProvider).save(content);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Quem Sou Eu atualizado. Já aparece no app.')),
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
    for (final c in _c.values) {
      c.dispose();
    }
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
          setState(() {
            _hydrated = true;
            _ctaTarget = p.startCtaTarget;
          });
        });
      }
    });

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: PremiumAppBar(
        title: 'Editar Quem Sou Eu',
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
                Container(
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
                        'Textos e links ficam no Firebase. '
                        'Capa, perfil e galeria ficam em “Fotos da Amanda”.',
                        style: TextStyle(
                            color: AppColors.textSecondary,
                            height: 1.4,
                            fontSize: 13),
                      ),
                      const SizedBox(height: 10),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          OutlinedButton.icon(
                            onPressed: () => AppNavigation.open(
                                context, Routes.amandaAssetsAdmin),
                            icon: const Icon(Icons.photo_library_outlined,
                                size: 18),
                            label: const Text('Gerenciar fotos'),
                          ),
                          OutlinedButton.icon(
                            onPressed: () => AppNavigation.open(
                                context, Routes.amandaProfile),
                            icon: const Icon(Icons.visibility_outlined,
                                size: 18),
                            label: const Text('Ver página'),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                _exp('Identidade e hero', [
                  _f('fullName', 'Nome'),
                  _f('title', 'Título profissional'),
                  _f('location', 'Localização'),
                  _f('quote', 'Frase de destaque'),
                  _f('shortBio', 'Apresentação curta', maxLines: 8),
                ]),
                _exp('Botão Quero começar', [
                  _f('startCtaLabel', 'Texto do botão'),
                  Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: DropdownButtonFormField<AmandaCtaTarget>(
                      value: _ctaTarget,
                      decoration: _dec('Destino do botão'),
                      items: const [
                        DropdownMenuItem(
                            value: AmandaCtaTarget.whatsapp,
                            child: Text('WhatsApp')),
                        DropdownMenuItem(
                            value: AmandaCtaTarget.url, child: Text('URL / formulário')),
                        DropdownMenuItem(
                            value: AmandaCtaTarget.plans,
                            child: Text('Planos / Premium')),
                      ],
                      onChanged: (v) =>
                          setState(() => _ctaTarget = v ?? _ctaTarget),
                    ),
                  ),
                  _f('startCtaUrl', 'URL (se destino = URL)'),
                  _f('plansUrl', 'URL dos planos (opcional)'),
                  _f('whatsapp', 'WhatsApp (DDI+DDD+número)'),
                  _f('contactLabel', 'Texto do botão WhatsApp'),
                ]),
                _exp('História e formação', [
                  _f('sportHistory', 'História com o esporte', maxLines: 8),
                  _f('sportHistoryImageUrl', 'URL foto (história)'),
                  _f('formations',
                      'Formação (uma por linha: Nome | Instituição | Ano)',
                      maxLines: 8),
                  _f('whyPt', 'Por que Personal Trainer', maxLines: 6),
                  _f('whyPtImageUrl', 'URL foto profissional'),
                  _f('markedTitle', 'Título história marcada'),
                  _f('markedStory', 'História marcada', maxLines: 7),
                  _f('ownTransformation', 'Minha transformação', maxLines: 7),
                  _f('transformationImageUrl', 'URL foto transformação'),
                ]),
                _exp('Método 1 Dia de Cada Vez', [
                  _f('methodOrigin', 'Como nasceu', maxLines: 7),
                  _f('methodMantra', 'Mantra / destaque', maxLines: 3),
                  _f('methodMeaning', 'O que significa', maxLines: 5),
                  _f('methodAudience', 'Para quem (uma por linha)', maxLines: 6),
                  _f('methodAudienceHighlight', 'Destaque para quem', maxLines: 3),
                  _f('methodMainGoal', 'Objetivo principal', maxLines: 5),
                  _f('methodDifference', 'O que diferencia', maxLines: 4),
                  _f('methodDifferenceHighlight', 'Destaque diferença',
                      maxLines: 3),
                  _f('accompanimentSteps', 'Passos (um por linha)', maxLines: 10),
                  _f('accompanimentBody', 'Texto acompanhamento', maxLines: 8),
                ]),
                _exp('Filosofia e mensagem', [
                  _f('philosophyCards', 'Cards filosofia (um por linha)'),
                  _f('philosophyText', 'Texto filosofia', maxLines: 4),
                  _f('trainingBalance', 'Treino e equilíbrio', maxLines: 5),
                  _f('trainingBalanceHighlight', 'Frase equilíbrio'),
                  _f('whenThinkQuit', 'Quando pensar em desistir', maxLines: 6),
                  _f('aboutMeCards', 'Sobre mim (cards)'),
                  _f('aboutMeText', 'Texto sobre mim', maxLines: 3),
                  _f('loveProfession', 'O que mais amo', maxLines: 5),
                  _f('methodDream', 'Sonho com o método', maxLines: 5),
                  _f('feelHereCards', 'Como se sentir (cards)'),
                  _f('feelHereText', 'Texto acolhimento', maxLines: 3),
                  _f('closingMessage', 'Mensagem final', maxLines: 5),
                  _f('signatureTitle', 'Assinatura (título)', maxLines: 2),
                ]),
                _exp('Redes sociais', [
                  _f('instagram', 'Instagram pessoal (URL)'),
                  _f('instagramMetodo', 'Instagram do Método (URL)'),
                  _f('youtube', 'YouTube (URL)'),
                  _f('tiktok', 'TikTok (URL)'),
                  _f('facebook', 'Facebook (URL)'),
                  _f('website', 'Site (URL)'),
                ]),
                const SizedBox(height: 12),
                FilledButton(
                  onPressed: _saving ? null : _save,
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.secondary,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  child: Text(_saving ? 'Salvando...' : 'Salvar Quem Sou Eu'),
                ),
                const SizedBox(height: 28),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _exp(String title, List<Widget> children) {
    return Theme(
      data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
      child: ExpansionTile(
        initiallyExpanded: title.startsWith('Identidade'),
        title: Text(title,
            style: const TextStyle(
                color: Colors.white, fontWeight: FontWeight.w700)),
        childrenPadding: const EdgeInsets.fromLTRB(0, 0, 0, 8),
        children: children,
      ),
    );
  }

  InputDecoration _dec(String label) => InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: AppColors.textSecondary),
        filled: true,
        fillColor: AppColors.surface,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.border),
        ),
      );

  Widget _f(String key, String label, {int maxLines = 1}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextFormField(
        controller: _c[key],
        maxLines: maxLines,
        style: const TextStyle(color: Colors.white),
        decoration: _dec(label),
      ),
    );
  }
}
