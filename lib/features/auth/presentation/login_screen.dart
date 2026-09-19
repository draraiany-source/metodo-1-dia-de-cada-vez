import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/auth/user_role.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/router/app_router.dart';
import '../../../core/services/feedback_service.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/firebase_error_mapper.dart';
import '../../../core/widgets/auth_hero_header.dart';
import '../../../core/widgets/lili_animated.dart';
import '../../../core/widgets/lili_widgets.dart';
import '../data/auth_repository.dart';
import '../providers/auth_providers.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _email = TextEditingController();
  final _password = TextEditingController();
  bool _loading = false;
  bool _obscure = true;

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    setState(() => _loading = true);
    try {
      final user = await ref
          .read(authRepositoryProvider)
          .signIn(_email.text, _password.text);
      ref.read(localSessionProvider.notifier).setUser(user);
      if (!mounted) return;
      if (context.mounted) {
        context.go(homePathForUser(
          isPersonalTrainer: user.isPersonalTrainer,
          isAdmin: user.isAdmin,
        ));
      }
    } catch (e) {
      FeedbackService.play(FeedbackEvent.erro);
      if (mounted && context.mounted) {
        final msg = e is AuthFailure
            ? e.message
            : FirebaseErrorMapper.toUserMessage(
                e,
                fallback: 'Não foi possível entrar. Verifique e-mail e senha.',
              );
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(msg)),
        );
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  /// "Entrar como visitante" — abre a Home direto, sem exigir cadastro.
  /// A escolha é persistida (ver [GuestSessionNotifier]) para sobreviver a
  /// um F5 no navegador, e não volta sozinha para o cadastro depois.
  Future<void> _continueAsGuest() async {
    await ref.read(guestSessionProvider.notifier).enter();
    if (!mounted) return;
    if (context.mounted) context.go(Routes.home);
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      child: Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Cabeçalho acolhedor — mascote maior, bem iluminada, dentro
            // de um card com gradiente da marca (não fica mais "boiando"
            // pequena e escura no fundo preto).
            const AuthHeroHeader(
              pose: MascotePose.boasVindas,
              mood: LiliMood.viva,
              title: 'Bem-vinda de volta',
              subtitle: 'Continue de onde parou, um dia de cada vez.',
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 28, 24, 24),
              child: AuthResponsiveBody(
                child: Column(
                  children: [
                    TextField(
                      controller: _email,
                      keyboardType: TextInputType.emailAddress,
                      decoration: const InputDecoration(
                        labelText: 'E-mail',
                        prefixIcon: Icon(Icons.mail_outline),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: _password,
                      obscureText: _obscure,
                      decoration: InputDecoration(
                        labelText: 'Senha',
                        prefixIcon: const Icon(Icons.lock_outline),
                        suffixIcon: IconButton(
                          icon: Icon(_obscure
                              ? Icons.visibility_off
                              : Icons.visibility),
                          onPressed: () =>
                              setState(() => _obscure = !_obscure),
                        ),
                      ),
                    ),
                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton(
                        onPressed: () async {
                          final email = _email.text.trim();
                          if (email.isEmpty) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                  content: Text(
                                      'Digite seu e-mail para recuperar a senha.')),
                            );
                            return;
                          }
                          try {
                            await ref
                                .read(authRepositoryProvider)
                                .resetPassword(email);
                            if (!context.mounted) return;
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                  content: Text(
                                      'Se o e-mail existir, enviamos um link.')),
                            );
                          } catch (e) {
                            if (!context.mounted) return;
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  FirebaseErrorMapper.toUserMessage(
                                    e,
                                    fallback:
                                        'Não foi possível enviar o e-mail de recuperação.',
                                  ),
                                ),
                              ),
                            );
                          }
                        },
                        child: const Text('Esqueci a senha'),
                      ),
                    ),
                    const SizedBox(height: 8),

                    // ---- Opção 1: Entrar ----
                    ElevatedButton(
                      onPressed: _loading ? null : _login,
                      child: _loading
                          ? const SizedBox(
                              height: 22,
                              width: 22,
                              child: CircularProgressIndicator(
                                  strokeWidth: 2, color: Colors.white),
                            )
                          : const Text('Entrar'),
                    ),
                    const SizedBox(height: 12),

                    // ---- Opção 2: Criar conta ----
                    OutlinedButton(
                      onPressed: () => context.go(Routes.register),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.primary,
                        side: const BorderSide(color: AppColors.primary),
                        minimumSize: const Size.fromHeight(52),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text('Criar conta'),
                    ),
                    const SizedBox(height: 12),

                    if (AppConstants.enableGuestMode) ...[
                      AuthGhostButton(
                        label: 'Entrar como visitante',
                        onPressed: _continueAsGuest,
                      ),
                      const SizedBox(height: 20),
                      Center(
                        child: Text(
                          'Conhecer o aplicativo sem compromisso — você pode '
                          'criar sua conta quando quiser.',
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                              color: AppColors.textSecondary, fontSize: 12),
                        ),
                      ),
                    ],
                    const SizedBox(height: 16),
                    Wrap(
                      alignment: WrapAlignment.center,
                      children: [
                        TextButton(
                          onPressed: () => context.push(Routes.privacy),
                          child: const Text('Privacidade'),
                        ),
                        TextButton(
                          onPressed: () => context.push(Routes.terms),
                          child: const Text('Termos'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    ),
    );
  }
}
