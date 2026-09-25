import 'dart:io';

import 'package:flutter/material.dart';
import '../../../core/widgets/app_icon_image.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:http/http.dart' as http;
import 'package:pdfx/pdfx.dart';
import 'package:share_plus/share_plus.dart';

import '../../../core/router/app_router.dart';
import '../../../core/router/premium_app_bar.dart';
import '../../../core/theme/app_colors.dart';
import '../../../models/app_user.dart';
import '../../auth/providers/auth_providers.dart';
import '../../subscriptions/presentation/premium_gate_sheet.dart';
import '../../subscriptions/providers/subscription_providers.dart';
import '../domain/ebook_models.dart';
import '../providers/ebook_providers.dart';

class EbookReaderScreen extends ConsumerStatefulWidget {
  const EbookReaderScreen({super.key, required this.ebook});
  final Ebook ebook;

  @override
  ConsumerState<EbookReaderScreen> createState() => _EbookReaderScreenState();
}

class _EbookReaderScreenState extends ConsumerState<EbookReaderScreen> {
  PdfControllerPinch? _controller;
  bool _loading = true;
  String? _erro;
  bool _baixando = false;
  double _progresso = 0;

  @override
  void initState() {
    super.initState();
    _carregar();
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  Future<void> _carregar() async {
    setState(() {
      _loading = true;
      _erro = null;
    });

    // Se já baixado, abre do arquivo local (funciona offline).
    final baixados = await ref.read(ebookDownloadServiceProvider).list();
    final local =
        baixados.where((d) => d.contentId == widget.ebook.id).toList();

    if (local.isNotEmpty && await File(local.first.path).exists()) {
      setState(() {
        _controller =
            PdfControllerPinch(document: PdfDocument.openFile(local.first.path));
        _loading = false;
      });
      return;
    }

    final result = await ref
        .read(ebooksRepositoryProvider)
        .resolveFileUrl(widget.ebook.id);
    if (!result.ok) {
      setState(() {
        _loading = false;
        _erro = result.error;
      });
      return;
    }

    try {
      final res = await http
          .get(Uri.parse(result.url!))
          .timeout(const Duration(seconds: 30));
      setState(() {
        _controller =
            PdfControllerPinch(document: PdfDocument.openData(res.bodyBytes));
        _loading = false;
      });
    } catch (_) {
      setState(() {
        _loading = false;
        _erro = 'Não consegui abrir este e-book.';
      });
    }
  }

  Future<void> _baixar() async {
    setState(() {
      _baixando = true;
      _progresso = 0;
    });
    final result = await ref
        .read(ebooksRepositoryProvider)
        .resolveFileUrl(widget.ebook.id);
    if (!result.ok) {
      setState(() => _baixando = false);
      return;
    }
    await ref.read(ebookDownloadServiceProvider).download(
          widget.ebook.id,
          result.url!,
          extension: 'pdf',
          onProgress: (p) {
            if (mounted) setState(() => _progresso = p);
          },
        );
    if (mounted) setState(() => _baixando = false);
  }

  @override
  Widget build(BuildContext context) {
    final favoritos = ref.watch(ebookFavoritesProvider);
    final isFavorite = favoritos.contains(widget.ebook.id);
    final user = ref.watch(currentUserProvider) ?? AppUser.uiFallback();
    final bloqueado = isContentLocked(ref, widget.ebook.isPremium);

    return Scaffold(
      appBar: PremiumAppBar(
        title: widget.ebook.title,
        actions: [
          if (!bloqueado) ...[
            IconButton(
              icon: FavoriteAssetIcon(active: isFavorite, size: 22),
              onPressed: () => ref
                  .read(ebookFavoritesProvider.notifier)
                  .toggle(widget.ebook.id),
            ),
            IconButton(
              icon: const Icon(Icons.share_outlined),
              onPressed: () => Share.share(
                  '"${widget.ebook.title}" de ${widget.ebook.author} — '
                  'disponível no Método 1 Dia de Cada Vez 💜'),
            ),
            IconButton(
              icon: _baixando
                  ? SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                          strokeWidth: 2, value: _progresso))
                  : const Icon(Icons.download_outlined),
              onPressed: _baixando ? null : _baixar,
            ),
          ],
        ],
      ),
      body: SafeArea(
        child: bloqueado
            ? PremiumLockBody(contentName: widget.ebook.title)
            : _loading
                ? const Center(child: CircularProgressIndicator())
                : _erro != null
                    ? Center(
                        child: Text(_erro!,
                            style: const TextStyle(
                                color: AppColors.textSecondary)))
                    : PdfViewPinch(
                        controller: _controller!,
                        onPageChanged: (page) => ref
                            .read(ebookProgressProvider.notifier)
                            .update(widget.ebook.id, page),
                      ),
      ),
    );
  }
}

