import 'dart:async';

import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_theme.dart';

/// Balão de conversa da Lili, com fala "digitada" caractere a caractere.
///
/// A sincronização é simples e eficaz: o texto revela ~28 caracteres por
/// segundo, com pausa maior em pontuação — o ritmo de alguém falando.
/// Tocar no balão revela o texto inteiro imediatamente (respeita quem tem pressa).
class LiliSpeechBubble extends StatefulWidget {
  const LiliSpeechBubble({
    super.key,
    required this.text,
    this.charsPerSecond = 28,
    this.animate = true,
    this.pointsLeft = true,
    this.trailing,
  });

  final String text;
  final int charsPerSecond;

  /// Quando false, mostra o texto inteiro de imediato (acessibilidade).
  final bool animate;

  /// Direção do "bico" do balão (true = mascote à esquerda).
  final bool pointsLeft;

  /// Widget opcional abaixo da fala (ex.: botão de ação).
  final Widget? trailing;

  @override
  State<LiliSpeechBubble> createState() => _LiliSpeechBubbleState();
}

class _LiliSpeechBubbleState extends State<LiliSpeechBubble> {
  Timer? _timer;
  int _visiveis = 0;

  @override
  void initState() {
    super.initState();
    _start();
  }

  @override
  void didUpdateWidget(covariant LiliSpeechBubble old) {
    super.didUpdateWidget(old);
    if (old.text != widget.text) {
      _timer?.cancel();
      _visiveis = 0;
      _start();
    }
  }

  void _start() {
    if (!widget.animate) {
      _visiveis = widget.text.length;
      return;
    }
    final passo = Duration(milliseconds: (1000 / widget.charsPerSecond).round());
    _timer = Timer.periodic(passo, (t) {
      if (!mounted) {
        t.cancel();
        return;
      }
      if (_visiveis >= widget.text.length) {
        t.cancel();
        return;
      }
      setState(() => _visiveis++);
    });
  }

  void _revelarTudo() {
    _timer?.cancel();
    setState(() => _visiveis = widget.text.length);
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final completo = _visiveis >= widget.text.length;
    final visivel = widget.text.substring(0, _visiveis.clamp(0, widget.text.length));

    return GestureDetector(
      onTap: completo ? null : _revelarTudo,
      child: Semantics(
        // Leitores de tela recebem a frase inteira, não a digitação.
        label: widget.text,
        excludeSemantics: true,
        child: CustomPaint(
          painter: _BubbleTailPainter(pointsLeft: widget.pointsLeft),
          child: Container(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(AppTheme.radius),
              border: Border.all(color: AppColors.primary.withOpacity(0.25)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                RichText(
                  text: TextSpan(
                    style: const TextStyle(
                        color: Colors.white, fontSize: 15, height: 1.45),
                    children: [
                      TextSpan(text: visivel),
                      // Cursor sutil enquanto "fala".
                      if (!completo)
                        const TextSpan(
                          text: '▌',
                          style: TextStyle(color: AppColors.primary),
                        ),
                    ],
                  ),
                ),
                if (widget.trailing != null && completo) ...[
                  const SizedBox(height: 10),
                  widget.trailing!,
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Desenha o "bico" do balão apontando para a mascote.
class _BubbleTailPainter extends CustomPainter {
  const _BubbleTailPainter({required this.pointsLeft});
  final bool pointsLeft;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColors.surface
      ..style = PaintingStyle.fill;

    final y = size.height * 0.42;
    final path = Path();
    if (pointsLeft) {
      path
        ..moveTo(0, y)
        ..lineTo(-9, y + 6)
        ..lineTo(0, y + 14);
    } else {
      path
        ..moveTo(size.width, y)
        ..lineTo(size.width + 9, y + 6)
        ..lineTo(size.width, y + 14);
    }
    path.close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(_BubbleTailPainter old) => old.pointsLeft != pointsLeft;
}
