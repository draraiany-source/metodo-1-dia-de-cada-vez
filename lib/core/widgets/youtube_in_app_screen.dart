import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:webview_flutter_android/webview_flutter_android.dart';

import '../theme/app_colors.dart';

/// Reproduz um vídeo do YouTube dentro do app (WebView + embed).
/// O botão Voltar (AppBar e sistema) fecha esta tela e restaura a anterior.
class YoutubeInAppScreen extends StatefulWidget {
  const YoutubeInAppScreen({
    super.key,
    required this.videoId,
    this.title = 'Vídeo',
    this.watchUrl,
  });

  final String videoId;
  final String title;
  final Uri? watchUrl;

  @override
  State<YoutubeInAppScreen> createState() => _YoutubeInAppScreenState();
}

class _YoutubeInAppScreenState extends State<YoutubeInAppScreen> {
  WebViewController? _controller;
  var _loading = true;
  var _hasError = false;

  @override
  void initState() {
    super.initState();
    _initPlayer();
  }

  Future<void> _initPlayer() async {
    final embed = Uri.https(
      'www.youtube-nocookie.com',
      '/embed/${widget.videoId}',
      {
        'playsinline': '1',
        'rel': '0',
        'modestbranding': '1',
        'autoplay': '1',
      },
    );

    try {
      final controller = WebViewController()
        ..setJavaScriptMode(JavaScriptMode.unrestricted)
        ..setBackgroundColor(Colors.black)
        ..setNavigationDelegate(
          NavigationDelegate(
            onPageStarted: (_) {
              if (mounted) setState(() => _loading = true);
            },
            onPageFinished: (_) {
              if (mounted) setState(() => _loading = false);
            },
            onWebResourceError: (error) {
              if (error.isForMainFrame ?? true) {
                if (mounted) setState(() => _hasError = true);
              }
            },
            onNavigationRequest: (request) {
              final uri = Uri.tryParse(request.url);
              if (uri == null) return NavigationDecision.prevent;
              final host = uri.host.toLowerCase();
              if (host.contains('youtube.com') ||
                  host.contains('youtube-nocookie.com') ||
                  host.contains('youtu.be') ||
                  host.contains('google.com') ||
                  host.contains('gstatic.com') ||
                  host.contains('ytimg.com') ||
                  host.contains('ggpht.com')) {
                return NavigationDecision.navigate;
              }
              return NavigationDecision.prevent;
            },
          ),
        );

      if (!kIsWeb) {
        final platform = controller.platform;
        if (platform is AndroidWebViewController) {
          await platform.setMediaPlaybackRequiresUserGesture(false);
        }
      }

      await controller.loadRequest(embed);
      if (!mounted) return;
      setState(() {
        _controller = controller;
        _loading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _hasError = true;
        _loading = false;
      });
    }
  }

  Future<void> _openExternal() async {
    final uri = widget.watchUrl ??
        Uri.https('www.youtube.com', '/watch', {'v': widget.videoId});
    await launchUrl(uri, mode: LaunchMode.inAppBrowserView);
  }

  @override
  Widget build(BuildContext context) {
    final controller = _controller;
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        foregroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          tooltip: 'Voltar',
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
          onPressed: () => Navigator.of(context).maybePop(),
        ),
        title: Text(widget.title),
        actions: [
          IconButton(
            tooltip: 'Abrir no navegador',
            onPressed: _openExternal,
            icon: const Icon(Icons.open_in_browser_rounded),
          ),
        ],
      ),
      body: Stack(
        fit: StackFit.expand,
        children: [
          if (controller != null && !_hasError)
            WebViewWidget(controller: controller),
          if (_hasError)
            Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.error_outline, color: Colors.white70, size: 40),
                    const SizedBox(height: 12),
                    const Text(
                      'Não foi possível carregar o vídeo aqui.',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.white),
                    ),
                    const SizedBox(height: 16),
                    FilledButton(
                      onPressed: _openExternal,
                      style: FilledButton.styleFrom(
                        backgroundColor: AppColors.secondary,
                      ),
                      child: const Text('Abrir no YouTube'),
                    ),
                    const SizedBox(height: 8),
                    TextButton(
                      onPressed: () => Navigator.of(context).maybePop(),
                      child: const Text(
                        'Voltar ao treino',
                        style: TextStyle(color: Colors.white70),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          if (_loading && !_hasError)
            const Center(
              child: CircularProgressIndicator(color: AppColors.secondary),
            ),
        ],
      ),
    );
  }
}
