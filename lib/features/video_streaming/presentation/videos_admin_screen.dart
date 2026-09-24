import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/router/premium_app_bar.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/youtube_launch.dart';
import '../../personal_cms/presentation/cms_confirm.dart';
import '../domain/video_models.dart';
import '../providers/video_providers.dart';
import 'video_editor_sheet.dart';

/// Painel da Amanda para a biblioteca de vídeos.
///
/// Tudo aqui é sem código: criar, colar link do YouTube, enviar capa, escrever
/// título e descrição, escolher categoria, arrastar para reordenar, editar,
/// publicar/despublicar e excluir.
class VideosAdminScreen extends ConsumerStatefulWidget {
  const VideosAdminScreen({
    super.key,
    this.onlyCategory,
    this.title = 'Biblioteca de Vídeos',
    this.fabLabel = 'Novo vídeo',
  });

  /// Quando preenchida, o painel gerencia só essa categoria (ex.: Meditação).
  final VideoCategory? onlyCategory;
  final String title;
  final String fabLabel;

  @override
  ConsumerState<VideosAdminScreen> createState() => _VideosAdminScreenState();
}

class _VideosAdminScreenState extends ConsumerState<VideosAdminScreen> {
  /// Ordem local enquanto a Amanda arrasta, para a lista responder na hora sem
  /// esperar o Firestore.
  List<VideoContent>? _ordemLocal;
  bool _salvandoOrdem = false;

  void _recarregar() {
    setState(() => _ordemLocal = null);
    ref.invalidate(videosProvider);
    ref.invalidate(videosAdminListProvider);
  }

  Future<void> _novo(int ordemSugerida) async {
    final salvo = await mostrarEditorDeVideo(
      context,
      ordemSugerida: ordemSugerida,
      categoriaFixa: widget.onlyCategory,
    );
    if (salvo != null) {
      _recarregar();
      if (mounted) _aviso('“${salvo.name}” salvo.');
    }
  }

  Future<void> _editar(VideoContent video) async {
    final salvo = await mostrarEditorDeVideo(context, existente: video);
    if (salvo != null) {
      _recarregar();
      if (mounted) _aviso('“${salvo.name}” atualizado.');
    }
  }

  Future<void> _alternarPublicacao(VideoContent video) async {
    if (video.active) {
      final ok = await confirmDeactivate(
        context,
        title: 'Despublicar “${video.name}”?',
        message: widget.onlyCategory == VideoCategory.meditacao
            ? 'A meditação some da área das alunas, mas continua aqui no painel.'
            : 'O vídeo sai da área de Vídeos das alunas, mas continua aqui '
                'no seu painel para você republicar quando quiser.',
        confirmLabel: 'Despublicar',
      );
      if (!ok) return;
    }
    try {
      // `upsert` em vez de `setActive` porque o vídeo pode ainda ser um item
      // semeado do app, sem documento no Firestore.
      await ref
          .read(videosAdminRepositoryProvider)
          .upsert(video.copyWith(active: !video.active));
      _recarregar();
      if (mounted) {
        _aviso(video.active ? 'Vídeo despublicado.' : 'Vídeo publicado.');
      }
    } catch (e) {
      if (mounted) _aviso('Não consegui alterar: $e');
    }
  }

  Future<void> _excluir(VideoContent video) async {
    final ok = await confirmDelete(
      context,
      title: 'Excluir “${video.name}”?',
      message: 'O vídeo é apagado do app de vez (o vídeo no YouTube continua '
          'intacto). Se você só quer esconder das alunas, use “Despublicar”.',
    );
    if (!ok) return;
    try {
      await ref.read(videosAdminRepositoryProvider).delete(video.id);
      _recarregar();
      if (mounted) _aviso('Vídeo excluído.');
    } catch (e) {
      if (mounted) _aviso('Não consegui excluir: $e');
    }
  }

  Future<void> _reordenar(List<VideoContent> lista, int de, int para) async {
    final nova = [...lista];
    final item = nova.removeAt(de);
    nova.insert(de < para ? para - 1 : para, item);

    setState(() {
      _ordemLocal = nova;
      _salvandoOrdem = true;
    });

    try {
      await ref.read(videosAdminRepositoryProvider).reorder(nova);
      ref.invalidate(videosProvider);
      ref.invalidate(videosAdminListProvider);
    } catch (e) {
      if (mounted) {
        setState(() => _ordemLocal = null);
        _aviso('Não consegui salvar a nova ordem: $e');
      }
    } finally {
      if (mounted) setState(() => _salvandoOrdem = false);
    }
  }

  List<VideoContent> _filtrar(List<VideoContent> lista) {
    if (widget.onlyCategory != null) {
      return lista.where((v) => v.category == widget.onlyCategory).toList();
    }
    return lista.where((v) => v.category.isVideoLibrary).toList();
  }

  void _aviso(String texto) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(texto)));
  }

  @override
  Widget build(BuildContext context) {
    final videosAsync = ref.watch(videosAdminListProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: PremiumAppBar(
        title: widget.title,
        showStaffSignOut: true,
        actions: [
          if (_salvandoOrdem)
            const Padding(
              padding: EdgeInsets.only(right: 16),
              child: Center(
                child: SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              ),
            ),
        ],
      ),
      floatingActionButton: videosAsync.maybeWhen(
        data: (lista) => FloatingActionButton.extended(
          backgroundColor: AppColors.primary,
          onPressed: () => _novo(_filtrar(lista).length),
          icon: const Icon(Icons.add),
          label: Text(widget.fabLabel),
        ),
        orElse: () => null,
      ),
      body: SafeArea(
        child: videosAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, __) => Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    'Não consegui carregar a biblioteca.',
                    style: TextStyle(color: Colors.white, fontSize: 16),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '$e',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                        color: AppColors.textSecondary, fontSize: 12),
                  ),
                  const SizedBox(height: 16),
                  FilledButton(
                    onPressed: _recarregar,
                    child: const Text('Tentar novamente'),
                  ),
                ],
              ),
            ),
          ),
          data: (lista) {
            final videos = _ordemLocal ?? _filtrar(lista);
            if (videos.isEmpty) {
              return _VazioAdmin(meditacao: widget.onlyCategory == VideoCategory.meditacao);
            }

            return Column(
              children: [
                const _CabecalhoAdmin(),
                Expanded(
                  child: ReorderableListView.builder(
                    padding: const EdgeInsets.fromLTRB(16, 4, 16, 100),
                    itemCount: videos.length,
                    // Cada linha traz seu próprio ícone de arrastar; sem isso o
                    // Flutter adicionaria uma segunda alça automática.
                    buildDefaultDragHandles: false,
                    onReorder: (de, para) => _reordenar(videos, de, para),
                    itemBuilder: (context, i) {
                      final v = videos[i];
                      return _LinhaAdmin(
                        key: ValueKey('video_${v.id}'),
                        video: v,
                        posicao: i + 1,
                        onEditar: () => _editar(v),
                        onPublicar: () => _alternarPublicacao(v),
                        onExcluir: () => _excluir(v),
                      );
                    },
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _CabecalhoAdmin extends StatelessWidget {
  const _CabecalhoAdmin();

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 12, 16, 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        gradient: AppColors.softCardGradient,
        borderRadius: BorderRadius.circular(AppTheme.radiusSm),
        border: Border.all(color: AppColors.borderSoft),
      ),
      child: const Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.drag_indicator, color: AppColors.accent, size: 20),
          SizedBox(width: 10),
          Expanded(
            child: Text(
              'Arraste pelo ícone à direita para mudar a ordem em que as alunas '
              'veem os vídeos. A ordem salva sozinha.',
              style: TextStyle(
                  color: AppColors.textSecondary, fontSize: 12, height: 1.35),
            ),
          ),
        ],
      ),
    );
  }
}

class _VazioAdmin extends StatelessWidget {
  const _VazioAdmin({this.meditacao = false});
  final bool meditacao;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.video_library_outlined,
                size: 52, color: AppColors.textTertiary),
            SizedBox(height: 16),
            Text(
              meditacao ? 'Nenhuma meditação ainda' : 'Nenhum vídeo ainda',
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 17,
                  fontWeight: FontWeight.w800),
            ),
            SizedBox(height: 8),
            Text(
              meditacao
                  ? 'Toque em “Nova meditação”, cole o Short do YouTube e publique.'
                  : 'Toque em “Novo vídeo”, cole o link do YouTube e escreva o título. '
                      'Só isso já publica na área de Vídeos.',
              textAlign: TextAlign.center,
              style: TextStyle(
                  color: AppColors.textSecondary, fontSize: 13, height: 1.4),
            ),
          ],
        ),
      ),
    );
  }
}

class _LinhaAdmin extends StatelessWidget {
  const _LinhaAdmin({
    super.key,
    required this.video,
    required this.posicao,
    required this.onEditar,
    required this.onPublicar,
    required this.onExcluir,
  });

  final VideoContent video;
  final int posicao;
  final VoidCallback onEditar;
  final VoidCallback onPublicar;
  final VoidCallback onExcluir;

  @override
  Widget build(BuildContext context) {
    final semUrl = video.aguardandoUrl;
    final capa = video.displayThumbnailUrl;

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppTheme.radiusSm),
        border: Border.all(
          color: semUrl ? AppColors.warning.withOpacity(0.5) : AppColors.borderSoft,
        ),
      ),
      clipBehavior: Clip.antiAlias,
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: Column(
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: SizedBox(
                    width: 92,
                    height: 52,
                    child: capa.isEmpty
                        ? Container(
                            color: AppColors.surfaceDeep,
                            child: const Icon(Icons.image_outlined,
                                color: AppColors.textTertiary, size: 20),
                          )
                        : CachedNetworkImage(
                            imageUrl: capa,
                            fit: BoxFit.cover,
                            errorWidget: (_, __, ___) => Container(
                              color: AppColors.surfaceDeep,
                              child: const Icon(Icons.broken_image_outlined,
                                  color: AppColors.textTertiary, size: 20),
                            ),
                          ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        video.name.trim().isEmpty
                            ? '(sem título)'
                            : video.name.trim(),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                          fontSize: 14,
                          height: 1.25,
                        ),
                      ),
                      const SizedBox(height: 5),
                      Text(
                        [
                          '#$posicao',
                          video.category.shortLabel,
                          if (video.durationLabel.isNotEmpty) video.durationLabel,
                          if (video.isPremium) 'Premium',
                        ].join(' · '),
                        style: const TextStyle(
                            color: AppColors.textSecondary, fontSize: 11.5),
                      ),
                      const SizedBox(height: 7),
                      Wrap(
                        spacing: 6,
                        runSpacing: 6,
                        children: [
                          _Tag(
                            texto: video.active ? 'Publicado' : 'Rascunho',
                            cor: video.active
                                ? AppColors.success
                                : AppColors.textTertiary,
                          ),
                          if (semUrl)
                            const _Tag(
                              texto: 'Falta o link do YouTube',
                              cor: AppColors.warning,
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
                ReorderableDragStartListener(
                  index: posicao - 1,
                  child: const Padding(
                    padding: EdgeInsets.only(left: 4, top: 4),
                    child: Icon(Icons.drag_handle,
                        color: AppColors.textTertiary, size: 22),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                Expanded(
                  child: TextButton.icon(
                    onPressed: semUrl
                        ? null
                        : () => YoutubeLaunch.open(
                              context,
                              video.youtubeUrl,
                              title: video.name,
                            ),
                    icon: const Icon(Icons.play_circle_outline, size: 17),
                    label: const Text('Visualizar'),
                  ),
                ),
                Expanded(
                  child: TextButton.icon(
                    onPressed: onEditar,
                    icon: const Icon(Icons.edit_outlined, size: 17),
                    label: const Text('Editar'),
                  ),
                ),
                Expanded(
                  child: TextButton.icon(
                    onPressed: onPublicar,
                    icon: Icon(
                      video.active
                          ? Icons.visibility_off_outlined
                          : Icons.visibility_outlined,
                      size: 17,
                    ),
                    label: Text(video.active ? 'Despublicar' : 'Publicar'),
                  ),
                ),
                IconButton(
                  tooltip: 'Excluir',
                  onPressed: onExcluir,
                  icon: const Icon(Icons.delete_outline,
                      color: AppColors.danger, size: 20),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _Tag extends StatelessWidget {
  const _Tag({required this.texto, required this.cor});
  final String texto;
  final Color cor;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: cor.withOpacity(0.16),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: cor.withOpacity(0.4)),
      ),
      child: Text(
        texto,
        style: TextStyle(
            color: cor, fontSize: 10.5, fontWeight: FontWeight.w700),
      ),
    );
  }
}
