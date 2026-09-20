import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../theme/app_colors.dart';
import '../design_system/app_spacing.dart';
import '../design_system/app_typography.dart';
import '../utils/firebase_error_mapper.dart';
import 'animations.dart';
import 'lili_animated.dart';
import 'lili_widgets.dart';

/// ============================================================================
/// ESTADOS DE UI PADRONIZADOS — vazio, erro e carregamento (skeleton).
///
/// Centraliza os três estados que toda tela de dados precisa, mantendo a
/// identidade da mascote Lili e os tokens do design system. Substitui os
/// `CircularProgressIndicator` soltos por skeletons, e os textos de erro/vazio
/// improvisados por componentes consistentes e acolhedores.
///
/// Uso típico com Riverpod:
/// ```dart
/// final async = ref.watch(algumProvider);
/// return AppAsyncView<Lista>(
///   value: async,
///   onRetry: () => ref.invalidate(algumProvider),
///   skeleton: const AppListSkeleton(),
///   isEmpty: (data) => data.isEmpty,
///   emptyBuilder: (_) => const AppEmptyState(
///     title: 'Nada por aqui ainda',
///     message: 'Assim que houver conteúdo, ele aparece aqui.',
///   ),
///   data: (data) => ListView(...),
/// );
/// ```
/// ============================================================================

/// Estado VAZIO — nenhum dado para mostrar (lista sem itens, busca sem
/// resultado). Usa a Lili para deixar o momento leve, não frustrante.
class AppEmptyState extends StatelessWidget {
  const AppEmptyState({
    super.key,
    required this.title,
    this.message,
    this.pose = MascotePose.padrao,
    this.actionLabel,
    this.onAction,
    this.mascotHeight = 160,
  });

  final String title;
  final String? message;
  final MascotePose pose;
  final String? actionLabel;
  final VoidCallback? onAction;
  final double mascotHeight;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: FadeInUp(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              AnimatedLiliMascot(
                pose: pose,
                height: mascotHeight,
                mood: LiliMood.respirando,
              ),
              const SizedBox(height: AppSpacing.lg),
              Text(
                title,
                textAlign: TextAlign.center,
                style: AppTypography.h2,
              ),
              if (message != null) ...[
                const SizedBox(height: AppSpacing.sm),
                Text(
                  message!,
                  textAlign: TextAlign.center,
                  style: AppTypography.bodySecondary,
                ),
              ],
              if (actionLabel != null && onAction != null) ...[
                const SizedBox(height: AppSpacing.xl),
                PressableScale(
                  onTap: onAction!,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.xl,
                      vertical: AppSpacing.md,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Text(actionLabel!, style: AppTypography.button),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

/// Estado de ERRO — falha ao carregar. Mensagem amigável (nunca o stack trace
/// cru) + botão de "Tentar novamente". A mascote triste comunica empatia.
class AppErrorState extends StatelessWidget {
  const AppErrorState({
    super.key,
    this.title = 'Algo não saiu como esperado',
    this.message = 'Não foi possível carregar agora. Confira a conexão; se o conteúdo ainda não foi cadastrado, a lista pode aparecer vazia.',
    this.onRetry,
    this.retryLabel = 'Tentar novamente',
  });

  final String title;
  final String message;
  final VoidCallback? onRetry;
  final String retryLabel;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: FadeInUp(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const AnimatedLiliMascot(
                pose: MascotePose.triste,
                height: 150,
                mood: LiliMood.calma,
              ),
              const SizedBox(height: AppSpacing.lg),
              Text(title, textAlign: TextAlign.center, style: AppTypography.h2),
              const SizedBox(height: AppSpacing.sm),
              Text(
                message,
                textAlign: TextAlign.center,
                style: AppTypography.bodySecondary,
              ),
              if (onRetry != null) ...[
                const SizedBox(height: AppSpacing.xl),
                PressableScale(
                  onTap: onRetry!,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.xl,
                      vertical: AppSpacing.md,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.refresh_rounded,
                            size: 18, color: Colors.white),
                        const SizedBox(width: AppSpacing.sm),
                        Text(retryLabel, style: AppTypography.button),
                      ],
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

/// Loading padronizado — spinner da marca + texto opcional. Evita tela
/// branca e o indicador cinza solto.
class AppLoading extends StatelessWidget {
  const AppLoading({super.key, this.message});

  final String? message;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const CircularProgressIndicator(color: AppColors.secondary),
            if (message != null) ...[
              const SizedBox(height: AppSpacing.md),
              Text(
                message!,
                textAlign: TextAlign.center,
                style: AppTypography.bodySecondary,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// Skeleton de LISTA — n cartões em shimmer enquanto os dados chegam.
/// Reaproveita o [SkeletonBox] já existente para manter a estética.
class AppListSkeleton extends StatelessWidget {
  const AppListSkeleton({
    super.key,
    this.itemCount = 6,
    this.itemHeight = 76,
    this.padding = const EdgeInsets.all(AppSpacing.lg),
  });

  final int itemCount;
  final double itemHeight;
  final EdgeInsets padding;

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: padding,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: itemCount,
      separatorBuilder: (_, __) => const SizedBox(height: AppSpacing.md),
      itemBuilder: (_, __) => Row(
        children: [
          const SkeletonBox(width: 56, height: 56, radius: 14),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SkeletonBox(width: double.infinity, height: 14),
                const SizedBox(height: AppSpacing.sm),
                SkeletonBox(width: 140, height: 12),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Renderiza um [AsyncValue] de forma consistente: skeleton no loading,
/// [AppErrorState] no erro (com retry) e um estado vazio opcional. Evita
/// repetir o mesmo `.when(...)` improvisado em dezenas de telas.
class AppAsyncView<T> extends StatelessWidget {
  const AppAsyncView({
    super.key,
    required this.value,
    required this.data,
    this.skeleton,
    this.onRetry,
    this.isEmpty,
    this.emptyBuilder,
  });

  final AsyncValue<T> value;
  final Widget Function(T data) data;
  final Widget? skeleton;
  final VoidCallback? onRetry;
  final bool Function(T data)? isEmpty;
  final Widget Function(T data)? emptyBuilder;

  @override
  Widget build(BuildContext context) {
    return value.when(
      loading: () => skeleton ?? const AppListSkeleton(),
      error: (error, _) => AppErrorState(
        message: FirebaseErrorMapper.toUserMessage(error),
        onRetry: onRetry,
      ),
      data: (d) {
        if (isEmpty != null && isEmpty!(d) && emptyBuilder != null) {
          return emptyBuilder!(d);
        }
        return data(d);
      },
    );
  }
}
