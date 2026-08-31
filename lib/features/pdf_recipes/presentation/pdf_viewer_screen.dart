import 'package:flutter/material.dart';
import '../../../core/widgets/app_icon_image.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:http/http.dart' as http;
import 'package:pdfx/pdfx.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../core/theme/app_colors.dart';
import '../../../models/app_user.dart';
import '../../auth/providers/auth_providers.dart';
import '../domain/pdf_recipe_models.dart';
import '../providers/pdf_recipe_providers.dart';

class PdfViewerScreen extends ConsumerStatefulWidget {
  const PdfViewerScreen({super.key, required this.recipe});
  final PdfRecipe recipe;

  @override
  ConsumerState<PdfViewerScreen> createState() => _PdfViewerScreenState();
}

class _PdfViewerScreenState extends ConsumerState<PdfViewerScreen> {
  PdfControllerPinch? _controller;
  bool _loading = true;
  String? _erro;

  /// URL resolvida pela Cloud Function protegida (§28). Nunca vem do
  /// documento público — sem fallback que permita bypass de Premium.
  String? _resolvedUrl;

  @override
  void initState() {
    super.initState();
    _carregar();
  }

  Future<void> _carregar() async {
    try {
      final result = await ref
          .read(pdfRecipesRepositoryProvider)
          .resolveFileUrl(widget.recipe.id);
      if (!result.ok) {
        if (!mounted) return;
        setState(() {
          _erro = result.error ?? 'Não consegui abrir a receita agora.';
          _loading = false;
        });
        return;
      }
      _resolvedUrl = result.url;
      final res = await http
          .get(Uri.parse(_resolvedUrl!))
          .timeout(const Duration(seconds: 20));
      if (res.statusCode != 200) throw Exception('status ${res.statusCode}');
      final controller = PdfControllerPinch(
        document: PdfDocument.openData(res.bodyBytes),
      );
      if (!mounted) return;
      setState(() {
        _controller = controller;
        _loading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _erro = 'Não consegui abrir o PDF agora. Você pode tentar abrir '
            'externamente pelo botão abaixo.';
        _loading = false;
      });
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final favoritos = ref.watch(pdfRecipeFavoritesProvider);
    final isFavorite = favoritos.contains(widget.recipe.id);
    final user = ref.watch(currentUserProvider) ?? AppUser.demo();
    final bloqueado = widget.recipe.isPremium && !user.isPremium;
    final r = widget.recipe;

    if (bloqueado) {
      return Scaffold(
        appBar: AppBar(title: Text(r.title)),
        body: SafeArea(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(32),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.workspace_premium,
                      size: 56, color: AppColors.warning),
                  const SizedBox(height: 16),
                  const Text('Receita exclusiva Premium',
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  Text('"${r.title}" é exclusiva para assinantes.',
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: AppColors.textSecondary)),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Voltar'),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(r.title, overflow: TextOverflow.ellipsis),
        actions: [
          IconButton(
            icon: FavoriteAssetIcon(active: isFavorite, size: 22),
            onPressed: () =>
                ref.read(pdfRecipeFavoritesProvider.notifier).toggle(r.id),
          ),
          IconButton(
            icon: const Icon(Icons.share_outlined),
            onPressed: () => Share.share(
                '"${r.title}" — receita do Método 1 Dia de Cada Vez 🥗'),
          ),
          IconButton(
            icon: const Icon(Icons.open_in_new),
            tooltip: 'Abrir externamente',
            onPressed: _resolvedUrl == null
                ? null
                : () => launchUrl(Uri.parse(_resolvedUrl!),
                    mode: LaunchMode.externalApplication),
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            AspectRatio(
              aspectRatio: 16 / 7,
              child: CachedNetworkImage(
                imageUrl: r.coverUrl,
                fit: BoxFit.cover,
                placeholder: (_, __) => Container(color: AppColors.surface),
                errorWidget: (_, __, ___) => Container(
                  color: AppColors.surface,
                  child: const Icon(Icons.restaurant,
                      size: 40, color: AppColors.textTertiary),
                ),
              ),
            ),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(14),
              color: AppColors.surface,
              child: Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  _Macro(icon: Icons.timer_outlined, label: '${r.minutes}min'),
                  _Macro(icon: Icons.bar_chart, label: r.difficulty.label),
                  _Macro(
                      icon: Icons.local_fire_department_outlined,
                      label: '${r.kcal} kcal'),
                  _Macro(icon: Icons.egg_outlined, label: '${r.protein}g proteína'),
                  _Macro(icon: Icons.grain, label: '${r.carbs}g carbo'),
                  _Macro(icon: Icons.water_drop_outlined, label: '${r.fat}g gordura'),
                ],
              ),
            ),
            Expanded(
              child: _loading
                  ? const Center(child: CircularProgressIndicator())
                  : _erro != null
                      ? Center(
                          child: Padding(
                            padding: const EdgeInsets.all(24),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(Icons.picture_as_pdf_outlined,
                                    size: 48, color: AppColors.textTertiary),
                                const SizedBox(height: 12),
                                Text(_erro!,
                                    textAlign: TextAlign.center,
                                    style: const TextStyle(
                                        color: AppColors.textSecondary)),
                                const SizedBox(height: 16),
                                ElevatedButton.icon(
                                  onPressed: _resolvedUrl == null
                                      ? null
                                      : () => launchUrl(
                                          Uri.parse(_resolvedUrl!),
                                          mode:
                                              LaunchMode.externalApplication),
                                  icon: const Icon(Icons.open_in_new),
                                  label: const Text('Abrir externamente'),
                                ),
                              ],
                            ),
                          ),
                        )
                      : PdfViewPinch(controller: _controller!),
            ),
          ],
        ),
      ),
    );
  }
}

class _Macro extends StatelessWidget {
  const _Macro({required this.icon, required this.label});
  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: AppColors.secondary),
          const SizedBox(width: 5),
          Text(label,
              style: const TextStyle(color: Colors.white, fontSize: 11)),
        ],
      ),
    );
  }
}
