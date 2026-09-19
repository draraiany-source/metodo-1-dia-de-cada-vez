import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../core/assets/app_icons.dart';
import '../../../core/auth/session_sign_out.dart';
import '../../../core/config/app_legal.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/router/app_router.dart';
import '../../../core/router/app_navigation.dart';
import '../../../core/services/feedback_service.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/animations.dart';
import '../../../core/widgets/app_icon_image.dart';
import '../../auth/providers/auth_providers.dart';
import '../providers/audio_preferences_providers.dart';

/// Configurações gerais do app.
///
/// Reaproveita [feedbackPrefsProvider] (som/vibração de UI, já existente) e
/// adiciona [audioPreferencesProvider] (preferências específicas de áudio
/// de conteúdo — volume, autoplay, reprodução em segundo plano, velocidade,
/// download por Wi-Fi). "Sair" e "Excluir conta" usam o
/// [authRepositoryProvider] real, sem simular nada.
class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  Future<void> _sair(BuildContext context, WidgetRef ref) async {
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: const Text('Sair da conta'),
        content: const Text('Deseja realmente sair da sua conta?'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Cancelar')),
          TextButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: const Text('Sair')),
        ],
      ),
    );
    if (confirmar != true) return;
    await signOutAndGoToLogin(context, ref);
  }

  Future<void> _excluirConta(BuildContext context, WidgetRef ref) async {
    final controller = TextEditingController();
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (ctx) => StatefulBuilder(builder: (ctx, setDialogState) {
        return AlertDialog(
          backgroundColor: AppColors.surface,
          title: const Text('Excluir minha conta'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                  'Tem certeza de que deseja excluir sua conta?\n\n'
                  'Essa ação é permanente: perfil, progresso e dados '
                  'vinculados à conta serão excluídos. Informações que a lei '
                  'obrigar manter (por exemplo, registros fiscais de compra) '
                  'podem ser retidas pelo prazo legal. Digite EXCLUIR para '
                  'confirmar.',
                  style: TextStyle(color: AppColors.textSecondary)),
              const SizedBox(height: 12),
              TextField(
                controller: controller,
                style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration(hintText: 'EXCLUIR'),
                onChanged: (_) => setDialogState(() {}),
              ),
            ],
          ),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(ctx, false),
                child: const Text('Cancelar')),
            TextButton(
              onPressed: controller.text.trim().toUpperCase() == 'EXCLUIR'
                  ? () => Navigator.pop(ctx, true)
                  : null,
              child: const Text('Excluir',
                  style: TextStyle(color: AppColors.danger)),
            ),
          ],
        );
      }),
    );
    controller.dispose();
    if (confirmar != true) return;

    try {
      await ref.read(authRepositoryProvider).deleteAccount();
      ref.read(localSessionProvider.notifier).clear();
      await ref.read(guestSessionProvider.notifier).exit();
      if (context.mounted) context.go(Routes.login);
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(_mensagemAmigavel(e))),
        );
      }
    }
  }

  String _mensagemAmigavel(Object e) {
    final raw = e.toString().trim();
    if (raw.isEmpty ||
        raw.contains('Exception') ||
        raw.contains('firebase') ||
        raw.contains('Firebase') ||
        raw.contains('Stack')) {
      return 'Não foi possível concluir. Tente novamente.';
    }
    return raw;
  }

  void _infoDialog(BuildContext context, String title, String body) {
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: Text(title),
        content: Text(body, style: const TextStyle(color: AppColors.textSecondary)),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx), child: const Text('Fechar')),
        ],
      ),
    );
  }

  void _openAudioSettings(BuildContext context, WidgetRef ref) {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: AppColors.surface,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => const _AudioSettingsSheet(),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final feedback = ref.watch(feedbackPrefsProvider);
    final feedbackNotifier = ref.read(feedbackPrefsProvider.notifier);
    final audio = ref.watch(audioPreferencesProvider);
    final audioNotifier = ref.read(audioPreferencesProvider.notifier);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 8, 12, 0),
              child: SizedBox(
                height: 44,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    const Text('Configurações',
                        style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                            fontSize: 17)),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: PressableScale(
                        onTap: () => Navigator.of(context).maybePop(),
                        child: Container(
                          width: 38,
                          height: 38,
                          decoration: BoxDecoration(
                            color: AppColors.surface,
                            borderRadius: BorderRadius.circular(AppTheme.radiusSm),
                          ),
                          child: const AppIconImage(
                            AppIcons.back,
                            size: 20,
                            fallbackIcon: Icons.arrow_back,
                            semanticLabel: 'Voltar',
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
                children: [
                  const _SectionLabel('Geral'),
                  _Row(
                    icon: Icons.dark_mode_outlined,
                    title: 'Tema do aplicativo',
                    subtitle: 'Escuro premium (padrão do app)',
                    onTap: () => _infoDialog(context, 'Tema',
                        'Por enquanto o app usa somente o tema escuro premium — combina com a identidade visual da marca. Um tema claro pode virar opção no futuro.'),
                  ),
                  _Row(
                    icon: Icons.language,
                    title: 'Idioma',
                    subtitle: 'Português (Brasil)',
                    onTap: () => _infoDialog(context, 'Idioma',
                        'O app está disponível em Português (Brasil). Outros idiomas ainda não foram implementados.'),
                  ),
                  const SizedBox(height: 16),
                  const _SectionLabel('Áudio'),
                  SwitchListTile(
                    value: feedback.sound,
                    activeColor: AppColors.secondary,
                    tileColor: AppColors.surface,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14)),
                    title: const Text('Sons do app',
                        style: TextStyle(color: Colors.white)),
                    onChanged: feedbackNotifier.setSound,
                  ),
                  const SizedBox(height: 6),
                  SwitchListTile(
                    value: feedback.haptics,
                    activeColor: AppColors.secondary,
                    tileColor: AppColors.surface,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14)),
                    title: const Text('Vibração',
                        style: TextStyle(color: Colors.white)),
                    onChanged: feedbackNotifier.setHaptics,
                  ),
                  const SizedBox(height: 6),
                  _Row(
                    icon: Icons.headphones_outlined,
                    iconAsset: AppIcons.audio,
                    title: 'Áudios e aulas',
                    subtitle:
                        'Volume ${(audio.volume * 100).round()}% · ${audio.speed}x'
                        '${audio.autoplay ? ' · autoplay' : ''}',
                    onTap: () => _openAudioSettings(context, ref),
                  ),
                  SwitchListTile(
                    value: audio.downloadOverWifiOnly,
                    activeColor: AppColors.secondary,
                    tileColor: AppColors.surface,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14)),
                    title: const Text('Baixar áudios só por Wi-Fi',
                        style: TextStyle(color: Colors.white)),
                    onChanged: (v) => audioNotifier
                        .update((p) => p.copyWith(downloadOverWifiOnly: v)),
                  ),
                  const SizedBox(height: 16),
                  const _SectionLabel('Privacidade e segurança'),
                  _Row(
                    icon: Icons.lock_reset_outlined,
                    iconAsset: AppIcons.security,
                    title: 'Alterar senha',
                    onTap: () async {
                      final user = ref.read(currentUserProvider);
                      if (user == null || user.email.isEmpty) {
                        _infoDialog(context, 'Alterar senha',
                            'Entre com uma conta de e-mail para poder redefinir a senha.');
                        return;
                      }
                      try {
                        await ref
                            .read(authRepositoryProvider)
                            .resetPassword(user.email);
                        if (context.mounted) {
                          _infoDialog(context, 'Alterar senha',
                              'Enviamos um e-mail para ${user.email} com as instruções para redefinir sua senha.');
                        }
                      } catch (e) {
                        if (context.mounted) {
                          _infoDialog(
                            context,
                            'Alterar senha',
                            _mensagemAmigavel(e),
                          );
                        }
                      }
                    },
                  ),
                  _Row(
                    icon: Icons.folder_shared_outlined,
                    title: 'Gerenciar dados pessoais',
                    onTap: () => _infoDialog(context, 'Dados pessoais',
                        'Seus dados de perfil, progresso e preferências ficam salvos na sua conta e neste dispositivo. Para alterações específicas, use Editar perfil.'),
                  ),
                  _Row(
                    icon: Icons.download_outlined,
                    title: 'Baixar meus dados',
                    onTap: () => _infoDialog(context, 'Baixar meus dados',
                        'A exportação completa dos seus dados ainda não está disponível — em breve você poderá solicitar uma cópia por aqui.'),
                  ),
                  _Row(
                    icon: Icons.description_outlined,
                    title: 'Termos de uso',
                    onTap: () => AppNavigation.open(context, Routes.terms),
                  ),
                  _Row(
                    icon: Icons.privacy_tip_outlined,
                    iconAsset: AppIcons.privacy,
                    title: 'Política de privacidade',
                    onTap: () => AppNavigation.open(context, Routes.privacy),
                  ),
                  _Row(
                    icon: Icons.support_agent_outlined,
                    iconAsset: AppIcons.support,
                    title: 'Suporte',
                    onTap: () async {
                      if (AppLegal.hasSupportEmail) {
                        await launchUrl(
                          Uri(
                            scheme: 'mailto',
                            path: AppLegal.supportEmail,
                          ),
                          mode: LaunchMode.externalApplication,
                        );
                        return;
                      }
                      _infoDialog(
                        context,
                        'Suporte',
                        'O e-mail de suporte ainda não foi configurado '
                            '(SUPPORT_EMAIL). Use Configurações quando a '
                            'proprietária informar o endereço oficial.',
                      );
                    },
                  ),
                  _Row(
                    icon: Icons.info_outline,
                    title: 'Sobre o aplicativo',
                    onTap: () async {
                      final info = await PackageInfo.fromPlatform();
                      if (!context.mounted) return;
                      _infoDialog(
                        context,
                        AppConstants.appName,
                        'Versão ${info.version} (${info.buildNumber})\n\n'
                        '${AppConstants.appName} — 1 dia de cada vez.',
                      );
                    },
                  ),
                  const SizedBox(height: 24),
                  OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(
                      minimumSize: const Size.fromHeight(50),
                    ),
                    onPressed: () => _sair(context, ref),
                    icon: const Icon(Icons.logout),
                    label: const Text('Sair da conta'),
                  ),
                  const SizedBox(height: 10),
                  OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.danger,
                      side: const BorderSide(color: AppColors.danger),
                      minimumSize: const Size.fromHeight(50),
                    ),
                    onPressed: () => _excluirConta(context, ref),
                    icon: const Icon(Icons.delete_forever_outlined),
                    label: const Text('Excluir minha conta'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  const _SectionLabel(this.text);
  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8, top: 4),
      child: Text(text,
          style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 12,
              fontWeight: FontWeight.w700)),
    );
  }
}

class _Row extends StatelessWidget {
  const _Row({
    required this.icon,
    required this.title,
    this.subtitle,
    this.iconAsset,
    required this.onTap,
  });
  final IconData icon;
  final String? iconAsset;
  final String title;
  final String? subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(14),
          ),
          child: Row(
            children: [
              if (iconAsset != null)
                AppIconImage(
                  iconAsset!,
                  size: 24,
                  fallbackIcon: icon,
                  semanticLabel: title,
                )
              else
                Icon(icon, color: AppColors.secondary, size: 20),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title,
                        style: const TextStyle(
                            color: Colors.white, fontWeight: FontWeight.w600)),
                    if (subtitle != null)
                      Text(subtitle!,
                          style: const TextStyle(
                              color: AppColors.textSecondary, fontSize: 11)),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right, color: AppColors.textTertiary),
            ],
          ),
        ),
      ),
    );
  }
}

class _AudioSettingsSheet extends ConsumerWidget {
  const _AudioSettingsSheet();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final audio = ref.watch(audioPreferencesProvider);
    final notifier = ref.read(audioPreferencesProvider.notifier);

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Áudios e aulas', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 16),
            Text('Volume · ${(audio.volume * 100).round()}%',
                style: const TextStyle(color: AppColors.textSecondary, fontSize: 12)),
            Slider(
              value: audio.volume,
              activeColor: AppColors.secondary,
              onChanged: (v) => notifier.update((p) => p.copyWith(volume: v)),
            ),
            const SizedBox(height: 8),
            const Text('Velocidade de reprodução',
                style: TextStyle(color: AppColors.textSecondary, fontSize: 12)),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: [
                for (final s in AudioPreferences.speedOptions)
                  ChoiceChip(
                    label: Text('${s}x'),
                    selected: audio.speed == s,
                    onSelected: (_) =>
                        notifier.update((p) => p.copyWith(speed: s)),
                  ),
              ],
            ),
            const SizedBox(height: 8),
            SwitchListTile(
              value: audio.autoplay,
              activeColor: AppColors.secondary,
              contentPadding: EdgeInsets.zero,
              title: const Text('Reprodução automática',
                  style: TextStyle(color: Colors.white)),
              subtitle: const Text('Tocar a próxima aula automaticamente',
                  style: TextStyle(color: AppColors.textSecondary, fontSize: 11)),
              onChanged: (v) => notifier.update((p) => p.copyWith(autoplay: v)),
            ),
            SwitchListTile(
              value: audio.backgroundPlayback,
              activeColor: AppColors.secondary,
              contentPadding: EdgeInsets.zero,
              title: const Text('Continuar em segundo plano',
                  style: TextStyle(color: Colors.white)),
              onChanged: (v) =>
                  notifier.update((p) => p.copyWith(backgroundPlayback: v)),
            ),
          ],
        ),
      ),
    );
  }
}
