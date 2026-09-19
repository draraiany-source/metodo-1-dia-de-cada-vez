import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import '../../../core/widgets/app_icon_image.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/app_states.dart';
import '../../../core/widgets/common_widgets.dart';
import '../../../models/app_user.dart';
import '../../auth/providers/auth_providers.dart';
import '../../subscriptions/providers/subscription_providers.dart';
import '../domain/ebook_models.dart';
import '../providers/ebook_providers.dart';
import 'ebook_reader_screen.dart';

class EbooksScreen extends ConsumerStatefulWidget {
  const EbooksScreen({super.key});

  @override
  ConsumerState<EbooksScreen> createState() => _EbooksScreenState();
}

class _EbooksScreenState extends ConsumerState<EbooksScreen> {
  EbookCategory? _filtro;

  @override
  Widget build(BuildContext context) {
    final ebooksAsync = ref.watch(ebooksProvider);
    final favoritos = ref.watch(ebookFavoritesProvider);
    final user = ref.watch(currentUserProvider) ?? AppUser.uiFallback();

    return Scaffold(
      appBar: AppBar(title: const Text('E-books 📚')),
      body: SafeArea(
        child: ebooksAsync.when(
          loading: () => const AppListSkeleton(),
          error: (_, __) =>
              AppErrorState(onRetry: () => ref.invalidate(ebooksProvider)),
          data: (ebooks) {
            final filtrados = _filtro == null
                ? ebooks
                : ebooks.where((e) => e.category == _filtro).toList();

            return CustomScrollView(
              slivers: [
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
                  sliver: SliverToBoxAdapter(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Leia no seu ritmo, mesmo offline',
                            style: TextStyle(color: AppColors.textSecondary)),
                        const SizedBox(height: 16),
                        SizedBox(
                          height: 36,
                          child: ListView(
                            scrollDirection: Axis.horizontal,
                            children: [
                              _Chip(
                                  label: 'Todos',
                                  selected: _filtro == null,
                                  onTap: () => setState(() => _filtro = null)),
                              ...EbookCategory.values.map((c) => _Chip(
                                    label: c.label,
                                    selected: _filtro == c,
                                    onTap: () => setState(() => _filtro = c),
                                  )),
                            ],
                          ),
                        ),
                        const SizedBox(height: 20),
                        if (ebooks.isEmpty)
                          const Padding(
                            padding: EdgeInsets.only(top: 40),
                            child: ComingSoonView(
                              emoji: '📚',
                              title: 'Nenhum e-book disponível ainda',
                              description:
                                  'Assim que os e-books forem cadastrados, eles aparecem aqui automaticamente.',
                            ),
                          )
                        else if (filtrados.isEmpty)
                          const Padding(
                            padding: EdgeInsets.only(top: 40),
                            child: Center(
                              child: Text('Nenhum e-book nessa categoria ainda.',
                                  style:
                                      TextStyle(color: AppColors.textSecondary)),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
                if (filtrados.isNotEmpty)
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
                    sliver: SliverGrid(
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        mainAxisSpacing: 12,
                        crossAxisSpacing: 12,
                        childAspectRatio: 0.65,
                      ),
                      delegate: SliverChildBuilderDelegate(
                        (context, i) => _EbookCard(
                          ebook: filtrados[i],
                          isFavorite: favoritos.contains(filtrados[i].id),
                          locked: isContentLocked(ref, filtrados[i].isPremium),
                        ),
                        childCount: filtrados.length,
                      ),
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

class _Chip extends StatelessWidget {
  const _Chip(
      {required this.label, required this.selected, required this.onTap});
  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: ChoiceChip(
          label: Text(label), selected: selected, onSelected: (_) => onTap()),
    );
  }
}

class _EbookCard extends StatelessWidget {
  const _EbookCard(
      {required this.ebook, required this.isFavorite, required this.locked});
  final Ebook ebook;
  final bool isFavorite;
  final bool locked;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.of(context).push(MaterialPageRoute(
          builder: (_) => EbookReaderScreen(ebook: ebook))),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(AppTheme.radiusSm),
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Stack(
                fit: StackFit.expand,
                children: [
                  ebook.coverUrl.isEmpty
                      ? Container(
                          color: AppColors.background,
                          child: const Icon(Icons.menu_book_outlined,
                              color: AppColors.textTertiary, size: 32),
                        )
                      : CachedNetworkImage(
                          imageUrl: ebook.coverUrl, fit: BoxFit.cover),
                  if (locked)
                    Container(
                      color: Colors.black54,
                      child: const Center(
                          child: Icon(Icons.lock, color: Colors.white, size: 24)),
                    ),
                  Positioned(
                    right: 6,
                    top: 6,
                    child: FavoriteAssetIcon(active: isFavorite, size: 16),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(ebook.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                          color: Colors.white,
                          fontSize: 13,
                          fontWeight: FontWeight.w600)),
                  const SizedBox(height: 2),
                  Text(ebook.author,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                          color: AppColors.textSecondary, fontSize: 11)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
