import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/youtube_launch.dart';
import '../../../core/utils/youtube_url.dart';
import '../data/videos_admin_repository.dart';
import '../domain/video_models.dart';

final videosAdminRepositoryProvider = Provider((ref) => VideosAdminRepository());

/// Formulário de criação/edição de vídeo do Painel da Personal.
///
/// Devolve o [VideoContent] salvo, ou null se a Amanda cancelou. Quem chama é
/// responsável por invalidar os providers da lista.
Future<VideoContent?> mostrarEditorDeVideo(
  BuildContext context, {
  VideoContent? existente,
  int ordemSugerida = 0,
  VideoCategory? categoriaFixa,
}) {
  return showModalBottomSheet<VideoContent>(
    context: context,
    backgroundColor: Colors.transparent,
    isScrollControlled: true,
    useSafeArea: true,
    builder: (_) => _VideoEditorSheet(
      existente: existente,
      ordemSugerida: ordemSugerida,
      categoriaFixa: categoriaFixa,
    ),
  );
}

class _VideoEditorSheet extends ConsumerStatefulWidget {
  const _VideoEditorSheet({
    required this.existente,
    required this.ordemSugerida,
    this.categoriaFixa,
  });
  final VideoContent? existente;
  final int ordemSugerida;
  final VideoCategory? categoriaFixa;

  @override
  ConsumerState<_VideoEditorSheet> createState() => _VideoEditorSheetState();
}

class _VideoEditorSheetState extends ConsumerState<_VideoEditorSheet> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _titulo;
  late final TextEditingController _descricao;
  late final TextEditingController _url;
  late final TextEditingController _minutos;
  late final TextEditingController _segundos;

  late VideoCategory _categoria;
  late bool _premium;
  late bool _publicado;
  late String _capaUrl;

  /// Id definitivo do documento. Criado já na abertura do formulário porque a
  /// capa é enviada para um caminho no Storage que inclui o id.
  late final String _videoId;

  bool _enviandoCapa = false;
  bool _salvando = false;

  bool get _editando => widget.existente != null;

  @override
  void initState() {
    super.initState();
    final v = widget.existente;

    _videoId = (v?.id.trim().isNotEmpty ?? false)
        ? v!.id.trim()
        : ref.read(videosAdminRepositoryProvider).newId();

    _titulo = TextEditingController(text: v?.name ?? '');
    _descricao = TextEditingController(text: v?.description ?? '');
    _url = TextEditingController(text: v?.youtubeUrl ?? '');

    final total = v?.durationSeconds ?? 0;
    _minutos = TextEditingController(text: total > 0 ? '${total ~/ 60}' : '');
    _segundos = TextEditingController(text: total > 0 ? '${total % 60}' : '');

    _categoria =
        v?.category ?? widget.categoriaFixa ?? VideoCategory.boasVindas;
    _premium = v?.isPremium ?? false;
    _publicado = v?.active ?? true;
    _capaUrl = v?.thumbnailUrl ?? '';
  }

  @override
  void dispose() {
    _titulo.dispose();
    _descricao.dispose();
    _url.dispose();
    _minutos.dispose();
    _segundos.dispose();
    super.dispose();
  }

  int get _duracaoSegundos {
    final m = int.tryParse(_minutos.text.trim()) ?? 0;
    final s = int.tryParse(_segundos.text.trim()) ?? 0;
    return (m * 60) + s;
  }

  /// Capa mostrada na prévia: a enviada tem prioridade, senão a automática do
  /// YouTube derivada da URL digitada.
  String get _capaPreview {
    if (_capaUrl.trim().isNotEmpty) return _capaUrl.trim();
    return YoutubeUrl.thumbnailUrl(_url.text) ?? '';
  }

  Future<void> _enviarCapa() async {
    final picker = ImagePicker();
    final arquivo = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 88,
      maxWidth: 1920,
    );
    if (arquivo == null) return;

    setState(() => _enviandoCapa = true);
    try {
      final bytes = await arquivo.readAsBytes();
      final contentType =
          arquivo.name.toLowerCase().endsWith('.png') ? 'image/png' : 'image/jpeg';
      final url = await ref.read(videosAdminRepositoryProvider).uploadCover(
            _videoId,
            bytes,
            contentType: contentType,
          );
      if (!mounted) return;
      setState(() => _capaUrl = url);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Não consegui enviar a capa: $e')),
      );
    } finally {
      if (mounted) setState(() => _enviandoCapa = false);
    }
  }

  String? _validarUrl(String? valor) {
    final texto = (valor ?? '').trim();
    if (texto.isEmpty) {
      // Permitido salvar como rascunho sem URL; só não pode publicar.
      return _publicado
          ? 'Cole a URL do YouTube para publicar (ou desligue "Publicado" e salve como rascunho).'
          : null;
    }
    if (YoutubeUrl.extractVideoId(texto) == null) {
      return 'Não reconheci esse link do YouTube. Cole o endereço completo do vídeo.';
    }
    return null;
  }

  Future<void> _salvar() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    setState(() => _salvando = true);
    final video = VideoContent(
      id: _videoId,
      category: _categoria,
      subcategory: widget.existente?.subcategory ?? '',
      name: _titulo.text.trim(),
      description: _descricao.text.trim(),
      teacher: widget.existente?.teacher.trim().isNotEmpty == true
          ? widget.existente!.teacher.trim()
          : 'Amanda Lopes',
      thumbnailUrl: _capaUrl.trim(),
      durationSeconds: _duracaoSegundos,
      level: widget.existente?.level ?? VideoLevel.iniciante,
      isPremium: _premium,
      order: widget.existente?.order ?? widget.ordemSugerida,
      active: _publicado,
      youtubeUrl: _url.text.trim(),
      publishedAt: widget.existente?.publishedAt ?? DateTime.now(),
    );

    try {
      await ref.read(videosAdminRepositoryProvider).upsert(video);
      if (!mounted) return;
      Navigator.pop(context, video);
    } catch (e) {
      if (!mounted) return;
      setState(() => _salvando = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Não consegui salvar: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: DraggableScrollableSheet(
        initialChildSize: 0.92,
        minChildSize: 0.5,
        maxChildSize: 0.96,
        expand: false,
        builder: (context, scrollController) => Container(
          decoration: const BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Form(
            key: _formKey,
            child: ListView(
              controller: scrollController,
              padding: const EdgeInsets.fromLTRB(20, 14, 20, 28),
              children: [
                Center(
                  child: Container(
                    width: 44,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.white24,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ),
                const SizedBox(height: 18),
                Text(
                  _editando ? 'Editar vídeo' : 'Novo vídeo',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 20),

                _Rotulo('Título', obrigatorio: true),
                TextFormField(
                  controller: _titulo,
                  textCapitalization: TextCapitalization.sentences,
                  decoration: const InputDecoration(
                    hintText: 'Ex.: Boas-vindas ao Método 1 Dia de Cada Vez',
                  ),
                  validator: (v) => (v ?? '').trim().isEmpty
                      ? 'O título é obrigatório.'
                      : null,
                ),
                const SizedBox(height: 16),

                _Rotulo('Descrição'),
                TextFormField(
                  controller: _descricao,
                  maxLines: 4,
                  textCapitalization: TextCapitalization.sentences,
                  decoration: const InputDecoration(
                    hintText: 'Conte pra aluna o que ela vai ver neste vídeo.',
                  ),
                ),
                const SizedBox(height: 16),

                if (widget.categoriaFixa == null) ...[
                  _Rotulo('Categoria'),
                  DropdownButtonFormField<VideoCategory>(
                    value: _categoria,
                    isExpanded: true,
                    dropdownColor: AppColors.surfaceElevated,
                    items: VideoCategory.values
                        .map((c) => DropdownMenuItem(
                              value: c,
                              child: Text(c.label,
                                  overflow: TextOverflow.ellipsis),
                            ))
                        .toList(),
                    onChanged: (v) =>
                        setState(() => _categoria = v ?? _categoria),
                  ),
                ] else ...[
                  _Rotulo('Categoria'),
                  Text(
                    widget.categoriaFixa!.label,
                    style: const TextStyle(
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
                const SizedBox(height: 16),

                _Rotulo('Link do YouTube'),
                TextFormField(
                  controller: _url,
                  keyboardType: TextInputType.url,
                  autocorrect: false,
                  decoration: InputDecoration(
                    hintText: 'https://youtube.com/shorts/... ou watch?v=...',
                    suffixIcon: IconButton(
                      tooltip: 'Colar',
                      icon: const Icon(Icons.content_paste_rounded, size: 20),
                      onPressed: () async {
                        final dados = await Clipboard.getData('text/plain');
                        final texto = dados?.text?.trim();
                        if (texto == null || texto.isEmpty) return;
                        setState(() => _url.text = texto);
                      },
                    ),
                  ),
                  onChanged: (_) => setState(() {}),
                  validator: _validarUrl,
                ),
                const SizedBox(height: 8),
                const _Dica(
                  'Aceita Shorts (youtube.com/shorts/ID), watch?v=, youtu.be e '
                  'embed. No YouTube, use “Não listado” ou “Público”. “Privado” '
                  'não toca no app.',
                ),
                if (YoutubeUrl.extractVideoId(_url.text) != null) ...[
                  const SizedBox(height: 10),
                  OutlinedButton.icon(
                    onPressed: () {
                      YoutubeLaunch.open(
                        context,
                        _url.text.trim(),
                        title: _titulo.text.trim().isEmpty
                            ? 'Prévia do vídeo'
                            : _titulo.text.trim(),
                      );
                    },
                    icon: const Icon(Icons.play_circle_outline, size: 18),
                    label: const Text('Visualizar antes de publicar'),
                  ),
                ],
                const SizedBox(height: 20),

                _Rotulo('Capa'),
                _PreviaCapa(
                  url: _capaPreview,
                  automatica: _capaUrl.trim().isEmpty && _capaPreview.isNotEmpty,
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: _enviandoCapa ? null : _enviarCapa,
                        icon: _enviandoCapa
                            ? const SizedBox(
                                width: 16,
                                height: 16,
                                child:
                                    CircularProgressIndicator(strokeWidth: 2),
                              )
                            : const Icon(Icons.image_outlined, size: 18),
                        label: Text(
                          _enviandoCapa
                              ? 'Enviando...'
                              : _capaUrl.trim().isEmpty
                                  ? 'Enviar capa'
                                  : 'Trocar capa',
                        ),
                      ),
                    ),
                    if (_capaUrl.trim().isNotEmpty) ...[
                      const SizedBox(width: 8),
                      IconButton(
                        tooltip: 'Usar a capa automática do YouTube',
                        onPressed: () => setState(() => _capaUrl = ''),
                        icon: const Icon(Icons.restart_alt,
                            color: AppColors.textSecondary),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 20),

                _Rotulo('Duração'),
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _minutos,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          hintText: '0',
                          suffixText: 'min',
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: TextFormField(
                        controller: _segundos,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          hintText: '0',
                          suffixText: 'seg',
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                const _Dica(
                  'A duração aparece na capa e é o que permite calcular o '
                  '“continuar assistindo”. Se deixar zerada, o app só marca que '
                  'a aluna começou.',
                ),
                const SizedBox(height: 18),

                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  value: _publicado,
                  activeColor: AppColors.primary,
                  title: const Text('Publicado',
                      style: TextStyle(color: Colors.white)),
                  subtitle: Text(
                    _publicado
                        ? 'Visível para as alunas na área de Vídeos.'
                        : 'Fica só no seu painel, como rascunho.',
                    style: const TextStyle(
                        color: AppColors.textSecondary, fontSize: 12),
                  ),
                  onChanged: (v) {
                    setState(() => _publicado = v);
                    // Revalida: publicar exige URL.
                    _formKey.currentState?.validate();
                  },
                ),
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  value: _premium,
                  activeColor: AppColors.warning,
                  title: const Text('Somente Premium',
                      style: TextStyle(color: Colors.white)),
                  subtitle: const Text(
                    'Alunas sem assinatura veem o card bloqueado.',
                    style: TextStyle(
                        color: AppColors.textSecondary, fontSize: 12),
                  ),
                  onChanged: (v) => setState(() => _premium = v),
                ),
                const SizedBox(height: 20),

                SizedBox(
                  height: 52,
                  child: FilledButton(
                    onPressed: _salvando ? null : _salvar,
                    child: _salvando
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : Text(_editando ? 'Salvar alterações' : 'Salvar vídeo'),
                  ),
                ),
                const SizedBox(height: 8),
                Center(
                  child: TextButton(
                    onPressed:
                        _salvando ? null : () => Navigator.pop(context),
                    child: const Text('Cancelar'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _Rotulo extends StatelessWidget {
  const _Rotulo(this.texto, {this.obrigatorio = false});
  final String texto;
  final bool obrigatorio;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Text(
            texto,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 13,
              fontWeight: FontWeight.w700,
            ),
          ),
          if (obrigatorio)
            const Text(' *', style: TextStyle(color: AppColors.secondary)),
        ],
      ),
    );
  }
}

class _Dica extends StatelessWidget {
  const _Dica(this.texto);
  final String texto;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Icon(Icons.info_outline, size: 15, color: AppColors.textTertiary),
        const SizedBox(width: 7),
        Expanded(
          child: Text(
            texto,
            style: const TextStyle(
              color: AppColors.textTertiary,
              fontSize: 11.5,
              height: 1.35,
            ),
          ),
        ),
      ],
    );
  }
}

class _PreviaCapa extends StatelessWidget {
  const _PreviaCapa({required this.url, required this.automatica});
  final String url;
  final bool automatica;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(AppTheme.radiusSm),
      child: AspectRatio(
        aspectRatio: 16 / 9,
        child: Stack(
          fit: StackFit.expand,
          children: [
            if (url.isEmpty)
              Container(
                decoration:
                    const BoxDecoration(gradient: AppColors.softCardGradient),
                child: const Center(
                  child: Text(
                    'Sem capa ainda.\nEnvie uma imagem ou cole o link do YouTube.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        color: AppColors.textTertiary, fontSize: 12, height: 1.4),
                  ),
                ),
              )
            else
              CachedNetworkImage(
                imageUrl: url,
                fit: BoxFit.cover,
                errorWidget: (_, __, ___) => Container(
                  color: AppColors.surfaceDeep,
                  child: const Center(
                    child: Text(
                      'Não consegui carregar esta capa.',
                      style: TextStyle(
                          color: AppColors.textTertiary, fontSize: 12),
                    ),
                  ),
                ),
              ),
            if (automatica)
              Positioned(
                left: 8,
                bottom: 8,
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.65),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Text(
                    'Capa automática do YouTube',
                    style: TextStyle(color: Colors.white, fontSize: 10),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
