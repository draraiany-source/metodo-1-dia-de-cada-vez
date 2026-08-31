import 'package:flutter/material.dart';

import '../design_system/app_gradients.dart';
import '../theme/app_colors.dart';
import 'lili_animated.dart';
import 'lili_widgets.dart';

/// Cabeçalho "hero" acolhedor para as telas de autenticação (Login/Cadastro).
///
/// Antes, a mascote aparecia pequena, sozinha e escura, boiando no meio do
/// fundo preto — o que passava uma sensação pesada/triste. Este widget:
///  - Coloca a mascote dentro de um card com gradiente roxo → lilás → rosa
///    da própria identidade visual (não escurece a imagem);
///  - Dá mais destaque/tamanho a ela, com um glow suave atrás (a arte tem
///    fundo transparente, então o glow evita que ela pareça "flutuando"
///    isolada no vazio);
///  - Adiciona elementos leves de motivação/saúde (ícones decorativos);
///  - É responsivo: a altura da mascote se ajusta à altura disponível da
///    tela (celular pequeno, tablet, desktop/web) e o conteúdo é limitado
///    a uma largura máxima central em telas largas.
class AuthHeroHeader extends StatelessWidget {
  const AuthHeroHeader({
    super.key,
    required this.title,
    required this.subtitle,
    this.pose = MascotePose.boasVindas,
    this.mood = LiliMood.viva,
  });

  final String title;
  final String subtitle;
  final MascotePose pose;
  final LiliMood mood;

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.sizeOf(context).height;
    // Responsivo: nunca deixa a mascote gigante em telas baixas (celular em
    // paisagem) nem minúscula em telas altas — fica entre 150 e 210 px.
    final mascotHeight = (screenHeight * 0.22).clamp(150.0, 210.0);

    return ClipRRect(
      borderRadius: const BorderRadius.only(
        bottomLeft: Radius.circular(32),
        bottomRight: Radius.circular(32),
      ),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.fromLTRB(24, 20, 24, 28),
        decoration: const BoxDecoration(gradient: AppGradients.vibe),
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            // Elementos decorativos leves de saúde/bem-estar/motivação —
            // discretos, não competem com a mascote nem com o texto.
            const Positioned(
              top: -6,
              right: 8,
              child: Opacity(
                opacity: 0.25,
                child: Icon(Icons.favorite_rounded,
                    color: Colors.white, size: 30),
              ),
            ),
            const Positioned(
              bottom: 10,
              left: 4,
              child: Opacity(
                opacity: 0.22,
                child:
                    Icon(Icons.auto_awesome_rounded, color: Colors.white, size: 24),
              ),
            ),
            const Positioned(
              top: 46,
              left: -4,
              child: Opacity(
                opacity: 0.18,
                child: Icon(Icons.fitness_center_rounded,
                    color: Colors.white, size: 26),
              ),
            ),
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(height: 4),
                // Glow suave atrás da mascote — a arte é PNG transparente,
                // então sem isso ela parecia "flutuando" isolada no fundo.
                SizedBox(
                  height: mascotHeight,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      Container(
                        width: mascotHeight * 0.85,
                        height: mascotHeight * 0.85,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: RadialGradient(
                            colors: [
                              Colors.white.withOpacity(0.28),
                              Colors.white.withOpacity(0.0),
                            ],
                          ),
                        ),
                      ),
                      AnimatedLiliMascot(
                        pose: pose,
                        mood: mood,
                        height: mascotHeight,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  title,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        color: Colors.white,
                        fontSize: 22,
                      ),
                ),
                const SizedBox(height: 6),
                Text(
                  subtitle,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 13.5,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// Envolve o conteúdo das telas de autenticação garantindo boa leitura em
/// telas grandes (web/tablet): centraliza e limita a largura, evitando que
/// os campos de formulário fiquem esticados de ponta a ponta em um monitor.
class AuthResponsiveBody extends StatelessWidget {
  const AuthResponsiveBody({super.key, required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 480),
        child: child,
      ),
    );
  }
}

/// Botão secundário de destaque — usado para "Entrar como visitante".
/// Contraste alto e visual convidativo, sem competir com o CTA principal.
class AuthGhostButton extends StatelessWidget {
  const AuthGhostButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon = Icons.explore_outlined,
  });

  final String label;
  final VoidCallback onPressed;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return OutlinedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon, size: 20, color: AppColors.secondary),
      label: Text(label),
      style: OutlinedButton.styleFrom(
        foregroundColor: AppColors.secondary,
        side: BorderSide(color: AppColors.secondary.withOpacity(0.6)),
        minimumSize: const Size.fromHeight(52),
        textStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }
}
