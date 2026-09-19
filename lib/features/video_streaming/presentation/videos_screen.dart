import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/router/premium_app_bar.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/firebase_error_mapper.dart';
import '../../../core/widgets/app_icon_image.dart';
import '../../../core/widgets/app_states.dart';
import '../../../core/widgets/common_widgets.dart';
import '../../../models/app_user.dart';
import '../../auth/providers/auth_providers.dart';
import '../../subscriptions/providers/subscription_providers.dart';
import '../data/videos_repository.dart';
import '../domain/video_models.dart';
import '../domain/video_watch_state.dart';
import '../providers/video_providers.dart';
import 'video_open.dart';

/// Biblioteca de conteúdos em vídeo da Personal Amanda Lopes.
///
/// Não confundir com a área de Treinos: aqui não há série, carga, repetição nem
/// cronômetro. É conteúdo (boas-vindas, método, motivação, orientações…), com
/// capa, categoria, duração, "continuar assistindo" e marca de já assistido.
class VideosScreen extends ConsumerStatefulWidget {
  const VideosScreen({super.key});

  @override
  ConsumerState<VideosScreen> createState() => _VideosScreenState();
}

class _VideosScreenState extends ConsumerState<VideosScreen> {
  VideoCategory? _filtro;

  @override
  Widget build(BuildContext context) {
    final videosAsync = ref.watch(videosProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: const PremiumAppBar(title: 'Vídeos da Amanda 🎬'),
      body: SafeArea(
        child: videosAsync.when(
          loading: () => const AppListSkeleton(itemHeight: 210, itemCount: 3),
          error: (error, _) => AppErrorState(
            message: error is VideosFetchException
                ? error.userMessage
                : FirebaseErrorMapper.toUserMessage(error),
            onRetry: () => ref.invalidate(videosProvider),
          ),
          data: (videos) => _Conteudo(
            videos: videos,
            filtro: _filtro,
            onFiltro: (c) => setState(() => _filtro = c),
          ),
        ),
      ),
    );
  }
}

class _Conteudo extends ConsumerWidget {
  const _Conteudo({
    required this.videos,
    required this.filtro,
    required this.onFiltro,
  });

  final List<VideoContent> videos;
  final VideoCategory? filtro;
  final ValueChanged<VideoCategory?> onFiltro;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (videos.isEmpty) {
      return const Padding(
        padding: EdgeInsets.all(24),
        child: ComingSoonView(
          emoji: '🎬',
          title: 'A biblioteca está sendo montada',
          description: 'A Amanda está preparando os primeiros vídeos. '
              'Assim que publicar, eles aparecem aqui automaticamente.',
        ),
      );
    }

    final categorias = VideoCategory.values
        .where((c) => videos.any((v) => v.category == c))
        .toList(growable: false);

    final filtrados = filtro == null
        ? videos
        : videos.where((v) => v.category == filtro).toList(growable: false);

    final continuar = ref.watch(continuarAssistindoProvider);

    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 4, 20, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Conteúdos da Personal Amanda Lopes, um dia de cada vez.',
                  style: TextStyle(color: AppColors.textSecondary, height: 1.35),
                ),
                const SizedBox(height: 18),
                if (continuar.isNotEmpty) ...[
                  const _TituloSecao(
                    icone: Icons.play_circle_outline,
                    texto: 'Continuar assistindo',
                  ),
                  const SizedBox(height: 10),
                  _TrilhaContinuar(videos: continuar),
                  const SizedBox(height: 22),
                ],
                if (categorias.length > 1) ...[
                  SizedBox(
                    height: 38,
                    child: ListView(
                      scrollDirection: Axis.horizontal,
                      children: [
                        _Chip(
                          label: 'Todas',
                          selected: filtro == null,
                          onTap: () => onFiltro(null),
                        ),
                        ...categorias.map(
                          (c) => _Chip(
                            label: c.shortLabel,
                            selected: filtro == c,
                            onTap: () => onFiltro(c),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 18),
                ],
                if (filtrados.isEmpty)
                  const Padding(
                    padding: EdgeInsets.only(top: 32),
                    child: ComingSoonView(
                      emoji: '🎬',
                      title: 'Nenhum vídeo nesta categoria',
                      description:
                          'Escolha “Todas” ou outra categoria para ver o que já está no ar.',
                    ),
                  ),
              ],
            ),
          ),
        ),
        // Lazy de verdade: só constrói os cards visíveis.
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 28),
          sliver: SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, i) => _VideoCard(
                video: filtrados[i],
                playlist: filtrados,
              ),
              childCount: filtrados.length,
            ),
          ),
        ),
      ],
    );
  }
}

class _TituloSecao extends StatelessWidget {
  const _TituloSecao({required this.icone, required this.texto});
  final IconData icone;
  final String texto;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icone, size: 18, color: AppColors.accent),
        const SizedBox(width: 8),
        Text(
          texto,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w800,
            fontSize: 15,
          ),
        ),
      ],
    );
  }
}

/// Carrossel horizontal compacto do "continuar assistindo".
class _TrilhaContinuar extends ConsumerWidget {
  const _TrilhaContinuar({required this.videos});
  final List<VideoContent> videos;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final estados = ref.watch(videoWatchStateProvider);

    return SizedBox(
      height: 132,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: videos.length,
        separatorBuilder: (_, __) => const SizedBox(width: 12),
        itemBuilder: (context, i) {
          final v = videos[i];
          final estado = estados[v.id] ?? const VideoWatchState();
          final progresso = estado.progresso(v.durationSeconds);

          return GestureDetector(
            onTap: () => abrirVideo(context, ref, v, playlist: videos),
            child: SizedBox(
              width: 200,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(AppTheme.radiusSm),
                    child: Stack(
                      children: [
                        _Capa(video: v, width: 200, height: 96),
                        Positioned(
                          left: 0,
                          right: 0,
                          bottom: 0,
                          child: _BarraProgresso(valor: progresso),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    v.name,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12.5,
                      fontWeight: FontWeight.w600,
                      height: 1.25,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class _BarraProgresso extends StatelessWidget {
  const _BarraProgresso({required this.valor});
  final double valor;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 4,
      color: Colors.black45,
      child: FractionallySizedBox(
        alignment: Alignment.centerLeft,
        // Sem duração cadastrada não há progresso estimável; mostramos um traço
        // mínimo só pra sinalizar "já começou".
        widthFactor: valor <= 0 ? 0.06 : valor,
        child: Container(
          decoration: const BoxDecoration(gradient: AppColors.brandGradient),
        ),
      ),
    );
  }
}

class _Capa extends StatelessWidget {
  const _Capa({required this.video, this.width, this.height});
  final VideoContent video;
  final double? width;
  final double? height;

  @override
  Widget build(BuildContext context) {
    final url = video.displayThumbnailUrl;

    Widget placeholder() => Container(
          width: width,
          height: height,
          decoration: const BoxDecoration(gradient: AppColors.softCardGradient),
          child: const Center(
            child: Icon(Icons.play_circle_outline,
                color: AppColors.textTertiary, size: 38),
          ),
        );

    if (url.isEmpty) return placeholder();

    return CachedNetworkImage(
      imageUrl: url,
      width: width,
      height: height,
      fit: BoxFit.cover,
      placeholder: (_, __) => placeholder(),
      errorWidget: (_, __, ___) => placeholder(),
    );
  }
}

class _Chip extends StatelessWidget {
  const _Chip({
    required this.label,
    required this.selected,
    required this.onTap,
  });
  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: ChoiceChip(
        label: Text(label),
        selected: selected,
        onSelected: (_) => onTap(),
      ),
    );
  }
}

class _VideoCard extends ConsumerWidget {
  const _VideoCard({required this.video, required this.playlist});
  final VideoContent video;
  final List<VideoContent> playlist;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(currentUserProvider) ?? AppUser.uiFallback();
    final favoritos = ref.watch(videoFavoritesProvider);
    final estado =
        ref.watch(videoWatchStateProvider)[video.id] ?? const VideoWatchState();

    final bloqueado = isContentLocked(ref, video.isPremium);
    final assistido = estado.completed;
    final emAndamento = estado.iniciado && !assistido;
    final progresso = estado.progresso(video.durationSeconds);

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppTheme.radius),
        border: Border.all(
          color: assistido ? AppColors.primary.withOpacity(0.45) : AppColors.borderSoft,
        ),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          GestureDetector(
            onTap: () => abrirVideo(context, ref, video, playlist: playlist),
            child: AspectRatio(
              aspectRatio: 16 / 9,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  _Capa(video: video),
                  // Escurece a base pra leitura dos selos sobre qualquer capa.
                  const DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [Colors.transparent, Colors.black54],
                        stops: [0.55, 1],
                      ),
                    ),
                  ),
                  if (!bloqueado && !video.aguardandoUrl)
                    const Center(
                      child: Icon(Icons.play_circle_fill,
                          color: Colors.white70, size: 52),
                    ),
                  if (bloqueado)
                    Container(
                      color: Colors.black54,
                      child: const Center(
                        child: Icon(Icons.lock, color: Colors.white, size: 30),
                      ),
                    ),
                  if (video.isPremium)
                    const Positioned(
                      left: 10,
                      top: 10,
                      child: _Selo(
                        texto: 'PREMIUM',
                        cor: AppColors.warning,
                        corTexto: Colors.black,
                      ),
                    ),
                  if (assistido)
                    const Positioned(
                      right: 10,
                      top: 10,
                      child: _Selo(
                        texto: 'ASSISTIDO',
                        cor: AppColors.primary,
                        corTexto: Colors.white,
                        icone: Icons.check,
                      ),
                    ),
                  if (video.durationLabel.isNotEmpty)
                    Positioned(
                      right: 10,
                      bottom: 10,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.65),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          video.durationLabel,
                          style: const TextStyle(
                              color: Colors.white,
                              fontSize: 11,
                              fontWeight: FontWeight.w600),
                        ),
                      ),
                    ),
                  if (emAndamento)
                    Positioned(
                      left: 0,
                      right: 0,
                      bottom: 0,
                      child: _BarraProgresso(valor: progresso),
                    ),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 14, 14, 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Text(
                        video.name,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w800,
                          fontSize: 15.5,
                          height: 1.25,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    GestureDetector(
                      onTap: () => ref
                          .read(videoFavoritesProvider.notifier)
                          .toggle(video.id),
                      child: Padding(
                        padding: const EdgeInsets.only(top: 2),
                        child: FavoriteAssetIcon(
                          active: favoritos.contains(video.id),
                          size: 18,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                _EtiquetaCategoria(categoria: video.category),
                if (video.description.trim().isNotEmpty) ...[
                  const SizedBox(height: 10),
                  Text(
                    video.description.trim(),
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 13,
                      height: 1.4,
                    ),
                  ),
                ],
                const SizedBox(height: 14),
                Row(
                  children: [
                    Expanded(
                      child: SizedBox(
                        height: 44,
                        child: video.aguardandoUrl
                            ? OutlinedButton.icon(
                                onPressed: null,
                                icon: const Icon(Icons.schedule, size: 18),
                                label: const Text('Em breve'),
                              )
                            : FilledButton.icon(
                                onPressed: () => abrirVideo(
                                  context,
                                  ref,
                                  video,
                                  playlist: playlist,
                                ),
                                icon: Icon(
                                  bloqueado
                                      ? Icons.lock_outline
                                      : Icons.play_arrow_rounded,
                                  size: 20,
                                ),
                                label: Text(
                                  bloqueado
                                      ? 'Conteúdo Premium'
                                      : assistido
                                          ? 'Assistir de novo'
                                          : emAndamento
                                              ? 'Continuar assistindo'
                                              : 'Assistir',
                                ),
                              ),
                      ),
                    ),
                    if (!video.aguardandoUrl && !bloqueado) ...[
                      const SizedBox(width: 8),
                      IconButton(
                        tooltip: assistido
                            ? 'Desmarcar como assistido'
                            : 'Marcar como assistido',
                        onPressed: () => ref
                            .read(videoWatchStateProvider.notifier)
                            .definirAssistido(video.id, !assistido),
                        icon: Icon(
                          assistido
                              ? Icons.check_circle
                              : Icons.check_circle_outline,
                          color: assistido
                              ? AppColors.primary
                              : AppColors.textTertiary,
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Selo extends StatelessWidget {
  const _Selo({
    required this.texto,
    required this.cor,
    required this.corTexto,
    this.icone,
  });
  final String texto;
  final Color cor;
  final Color corTexto;
  final IconData? icone;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
      decoration: BoxDecoration(
        color: cor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icone != null) ...[
            Icon(icone, size: 11, color: corTexto),
            const SizedBox(width: 3),
          ],
          Text(
            texto,
            style: TextStyle(
              color: corTexto,
              fontSize: 9.5,
              fontWeight: FontWeight.w900,
              letterSpacing: 0.4,
            ),
          ),
        ],
      ),
    );
  }
}

class _EtiquetaCategoria extends StatelessWidget {
  const _EtiquetaCategoria({required this.categoria});
  final VideoCategory categoria;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: AppColors.primary.withOpacity(0.16),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.primary.withOpacity(0.35)),
      ),
      child: Text(
        categoria.label,
        style: const TextStyle(
          color: AppColors.accent,
          fontSize: 11,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}
