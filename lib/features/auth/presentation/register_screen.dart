import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/auth/user_role.dart';
import '../../../core/router/app_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/firebase_error_mapper.dart';
import '../../../core/widgets/auth_hero_header.dart';
import '../../../core/widgets/lili_animated.dart';
import '../../../core/widgets/lili_widgets.dart';
import '../providers/auth_providers.dart';

class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({super.key});

  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> {
  final _name = TextEditingController();
  final _email = TextEditingController();
  final _password = TextEditingController();
  final _referralCode = TextEditingController();
  bool _loading = false;
  bool _acceptedLegal = false;

  @override
  void dispose() {
    _name.dispose();
    _email.dispose();
    _password.dispose();
    _referralCode.dispose();
    super.dispose();
  }

  Future<void> _register() async {
    final email = _email.text.trim();
    final emailOk = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(email);
    if (_name.text.trim().isEmpty || !emailOk || _password.text.length < 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text(
                'Preencha nome, e-mail válido e senha com no mínimo 6 caracteres.')),
      );
      return;
    }
    if (!_acceptedLegal) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text(
                'Para criar a conta, confirme que leu os Termos e a Política de privacidade.')),
      );
      return;
    }
    setState(() => _loading = true);
    try {
      final user = await ref.read(authRepositoryProvider).register(
            _name.text,
            _email.text,
            _password.text,
            referredByCode: _referralCode.text.trim().isEmpty
                ? null
                : _referralCode.text.trim(),
          );
      ref.read(localSessionProvider.notifier).setUser(user);
      if (mounted) {
        context.go(homePathForUser(
          isPersonalTrainer: user.isPersonalTrainer,
          isAdmin: user.isAdmin,
        ));
      }
    } catch (e) {
      if (mounted) {
        FirebaseErrorMapper.showSnack(context, e);
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
        padding: EdgeInsets.only(
          bottom: MediaQuery.viewInsetsOf(context).bottom,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Cabeçalho acolhedor: mascote maior, bem iluminada, dentro de
            // um card com gradiente roxo/lilás/rosa — substitui a imagem
            // pequena e isolada que ficava boiando no fundo preto.
            const AuthHeroHeader(
              pose: MascotePose.apontando,
              mood: LiliMood.viva,
              title: 'Criar conta',
              subtitle: 'Comece hoje. Um dia de cada vez. 💜',
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 28, 24, 24),
              child: AuthResponsiveBody(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    TextField(
                      controller: _name,
                      decoration: const InputDecoration(
                        labelText: 'Nome',
                        prefixIcon: Icon(Icons.person_outline),
                      ),
                    ),
                    const SizedBox(height: 16),
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
                      obscureText: true,
                      decoration: const InputDecoration(
                        labelText: 'Senha',
                        prefixIcon: Icon(Icons.lock_outline),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: _referralCode,
                      textCapitalization: TextCapitalization.characters,
                      decoration: const InputDecoration(
                        labelText: 'Código de indicação (opcional)',
                        prefixIcon: Icon(Icons.card_giftcard_outlined),
                      ),
                    ),
                    const SizedBox(height: 16),
                    CheckboxListTile(
                      value: _acceptedLegal,
                      onChanged: (v) =>
                          setState(() => _acceptedLegal = v ?? false),
                      controlAffinity: ListTileControlAffinity.leading,
                      contentPadding: EdgeInsets.zero,
                      title: Wrap(
                        crossAxisAlignment: WrapCrossAlignment.center,
                        children: [
                          const Text('Li e concordo com os ',
                              style: TextStyle(
                                  color: AppColors.textSecondary, fontSize: 13)),
                          GestureDetector(
                            onTap: () => context.push(Routes.terms),
                            child: const Text('Termos de uso',
                                style: TextStyle(
                                    color: AppColors.secondary,
                                    fontWeight: FontWeight.w700,
                                    fontSize: 13)),
                          ),
                          const Text(' e a ',
                              style: TextStyle(
                                  color: AppColors.textSecondary, fontSize: 13)),
                          GestureDetector(
                            onTap: () => context.push(Routes.privacy),
                            child: const Text('Política de privacidade',
                                style: TextStyle(
                                    color: AppColors.secondary,
                                    fontWeight: FontWeight.w700,
                                    fontSize: 13)),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: _loading ? null : _register,
                      child: _loading
                          ? const SizedBox(
                              height: 22,
                              width: 22,
                              child: CircularProgressIndicator(
                                  strokeWidth: 2, color: Colors.white),
                            )
                          : const Text('Criar conta'),
                    ),
                    const SizedBox(height: 16),
                    Center(
                      child: GestureDetector(
                        onTap: () => context.go(Routes.login),
                        child: const Text('Já tenho conta',
                            style: TextStyle(color: AppColors.secondary)),
                      ),
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
