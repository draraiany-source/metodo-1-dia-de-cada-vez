import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/router/premium_app_bar.dart';
import '../../../core/services/feedback_service.dart';
import '../../../core/widgets/lili_animated.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/date_format.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/animations.dart';
import '../../../core/widgets/lili_widgets.dart';
import '../data/health_service.dart' show detectPlatformSource;
import '../domain/health_models.dart';
import '../providers/health_providers.dart';

class HealthSyncScreen extends ConsumerWidget {
  const HealthSyncScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(healthSyncProvider);
    final notifier = ref.read(healthSyncProvider.notifier);
    final plataforma = detectPlatformSource();

    return Scaffold(
      appBar: const PremiumAppBar(title: 'Sincronização de Saúde'),
      body: SafeArea(
        child: state.loading
            ? const Center(child: CircularProgressIndicator())
            : ListView(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
                children: [
                  _StatusCard(
                    state: state,
                    plataforma: plataforma,
                  ),
                  const SizedBox(height: 12),
                  const _ComingSoonBanner(),
                  const SizedBox(height: 16),

                  // Permissão / stub Health Connect
                  if (!state.conectado)
                    _PermissionCard(
                      plataforma: plataforma,
                      permission: state.permission,
                      onRequest: () async {
                        final perm = await notifier.requestPermission();
                        if (!context.mounted) return;
                        final msg = switch (perm) {
                          HealthPermission.concedida =>
                            'Conectado! Seus dados serão sincronizados. 💜',
                          HealthPermission.negada =>
                            'Sem problemas — o app continua funcionando com seus registros manuais.',
                          HealthPermission.indisponivel =>
                            'Em breve: configure o Health Connect / Apple Health. '
                            'Por enquanto usamos seus registros manuais.',
                          HealthPermission.naoSolicitada => 'Permissão pendente.',
                        };
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text(msg)),
                        );
                      },
                    ),
                  const SizedBox(height: 8),

                  // Dados do dia
                  Text('Dados de hoje',
                      style: Theme.of(context).textTheme.titleMedium),
                  const SizedBox(height: 8),
                  _MetricsGrid(
                      snapshot: state.snapshot,
                      indisponiveis: state.indisponiveis),
                  const SizedBox(height: 20),

                  // Sincronização automática
                  Container(
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(AppTheme.radius),
                    ),
                    child: SwitchListTile(
                      value: state.autoSync,
                      activeColor: AppColors.primary,
                      title: const Text('Sincronização automática',
                          style: TextStyle(color: Colors.white)),
                      subtitle: const Text(
                          'Atualiza os dados sempre que você abrir o app',
                          style: TextStyle(
                              color: AppColors.textSecondary, fontSize: 12)),
                      onChanged: notifier.setAutoSync,
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Sincronização manual
                  ElevatedButton.icon(
                    onPressed: state.syncing
                        ? null
                        : () {
                            FeedbackService.play(FeedbackEvent.sucesso);
                            notifier.sync();
                          },
                    icon: state.syncing
                        ? const SizedBox(
                            height: 18,
                            width: 18,
                            child: CircularProgressIndicator(
                                strokeWidth: 2, color: Colors.white))
                        : const Icon(Icons.sync),
                    label: Text(state.syncing
                        ? 'Sincronizando...'
                        : 'Sincronizar agora (+${HealthRewards.xpPorSync} XP · +${HealthRewards.moedasPorSync} 🪙)'),
                  ),

                  if (state.error != null) ...[
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppColors.danger.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(AppTheme.radius),
                        border: Border.all(color: AppColors.danger),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.error_outline,
                              color: AppColors.danger),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(state.error!,
                                style: const TextStyle(color: Colors.white)),
                          ),
                        ],
                      ),
                    ),
                  ],

                  const SizedBox(height: 20),
                  const _PrivacyNote(),
                ],
              ),
      ),
    );
  }
}

class _StatusCard extends StatelessWidget {
  const _StatusCard({required this.state, required this.plataforma});
  final HealthSyncState state;
  final HealthSource plataforma;

  @override
  Widget build(BuildContext context) {
    final conectado = state.conectado;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient:
            conectado ? AppColors.brandGradient : AppColors.premiumGradient,
        borderRadius: BorderRadius.circular(AppTheme.radius),
      ),
      child: Row(
        children: [
          AnimatedLiliMascot(
              pose: conectado ? MascotePose.joinha : MascotePose.apontando,
              mood: conectado ? LiliMood.comemorando : LiliMood.respirando,
              height: 80),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(conectado ? Icons.check_circle : Icons.info_outline,
                        color: Colors.white, size: 18),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                          conectado
                              ? 'Conectado ao ${plataforma.label}'
                              : 'Usando registros manuais',
                          style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w600)),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                    state.lastSync != null
                        ? 'Última sincronização: ${DateFormatBr.tempoRelativo(state.lastSync!)}'
                        : 'Nunca sincronizado',
                    style:
                        const TextStyle(color: Colors.white70, fontSize: 12)),
              ],
            ),
          ),
        ],
      ),
    );
  }

}

class _ComingSoonBanner extends StatelessWidget {
  const _ComingSoonBanner();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppTheme.radius),
        border: Border.all(color: AppColors.surface2),
      ),
      child: const Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.schedule, color: AppColors.primary, size: 20),
          SizedBox(width: 10),
          Expanded(
            child: Text(
              'Em breve: sincronização com Health Connect / Apple Health. '
              'Configure o app de saúde do sistema quando a integração for '
              'liberada. Até lá, o app usa só seus registros manuais — sem crash.',
              style: TextStyle(
                  color: AppColors.textSecondary, fontSize: 13, height: 1.4),
            ),
          ),
        ],
      ),
    );
  }
}

class _PermissionCard extends StatelessWidget {
  const _PermissionCard({
    required this.plataforma,
    required this.permission,
    required this.onRequest,
  });

  final HealthSource plataforma;
  final HealthPermission permission;
  final VoidCallback onRequest;

  @override
  Widget build(BuildContext context) {
    final indisponivel = permission == HealthPermission.indisponivel;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppTheme.radius),
        border: Border.all(color: AppColors.surface2),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
              indisponivel
                  ? 'Health Connect / Apple Health — em breve'
                  : 'Conectar ao ${plataforma.label}',
              style: const TextStyle(
                  color: Colors.white, fontWeight: FontWeight.w600)),
          const SizedBox(height: 6),
          Text(
            indisponivel
                ? 'A integração nativa ainda não está ativa neste build. '
                    'O app continua funcionando com registros manuais — '
                    'nada é perdido. Quando liberarmos, você poderá '
                    'configurar o Health Connect (Android) ou Apple Health (iOS).'
                : 'Permita o acesso para importar passos, distância, calorias, '
                    'frequência cardíaca e peso automaticamente.',
            style: const TextStyle(
                color: AppColors.textSecondary, fontSize: 13, height: 1.4),
          ),
          const SizedBox(height: 12),
          OutlinedButton.icon(
            onPressed: onRequest,
            icon: const Icon(Icons.health_and_safety_outlined),
            label: Text(indisponivel
                ? 'Verificar disponibilidade'
                : 'Conceder permissão'),
          ),
        ],
      ),
    );
  }
}

class _MetricsGrid extends StatelessWidget {
  const _MetricsGrid({required this.snapshot, required this.indisponiveis});
  final HealthSnapshot? snapshot;
  final List<HealthMetric> indisponiveis;

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 10,
      crossAxisSpacing: 10,
      childAspectRatio: 2.1,
      children: [
        for (final m in HealthMetric.values)
          FadeInUp(
            delayMs: m.index * 30,
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Row(
                    children: [
                      Text(m.emoji, style: const TextStyle(fontSize: 16)),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(m.label,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                                color: AppColors.textSecondary, fontSize: 12)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    snapshot?.formatted(m) ?? '—',
                    style: TextStyle(
                      color: (snapshot?.has(m) ?? false)
                          ? Colors.white
                          : AppColors.textTertiary,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }
}

class _PrivacyNote extends StatelessWidget {
  const _PrivacyNote();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppTheme.radius),
      ),
      child: const Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.lock_outline, color: AppColors.textSecondary, size: 18),
          SizedBox(width: 10),
          Expanded(
            child: Text(
              'Seus dados de saúde ficam no seu dispositivo. O app só lê o que '
              'você autorizar, e você pode revogar a permissão a qualquer momento '
              'nas configurações do sistema.',
              style: TextStyle(
                  color: AppColors.textSecondary, fontSize: 12, height: 1.4),
            ),
          ),
        ],
      ),
    );
  }
}
