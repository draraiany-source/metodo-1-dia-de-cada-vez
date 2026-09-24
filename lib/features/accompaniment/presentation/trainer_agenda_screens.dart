import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../core/assets/personal_ai_icons.dart';
import '../../../core/router/app_router.dart';
import '../../../core/router/premium_app_bar.dart';
import '../../../core/widgets/app_icon_image.dart';
import '../../../core/widgets/app_page.dart';
import '../../../core/widgets/premium_ui.dart';
import '../../../models/app_user.dart';
import '../../auth/providers/auth_providers.dart';
import '../domain/accompaniment_models.dart';
import '../providers/accompaniment_providers.dart';

class TrainerAgendaScreen extends ConsumerWidget {
  const TrainerAgendaScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final trainer = ref.watch(currentUserProvider) ?? AppUser.uiFallback();
    final items = ref.watch(trainerAppointmentsProvider(trainer.id));
    final cal = ref.watch(calendarStatusProvider(trainer.id)).valueOrNull;

    return Scaffold(
      appBar: PremiumAppBar(
        title: 'Agenda da Personal',
        showStaffSignOut: true,
        actions: [
          IconButton(
            tooltip: 'Disponibilidade',
            onPressed: () => context.push(Routes.trainerAvailability),
            icon: const Icon(Icons.tune),
          ),
          IconButton(
            tooltip: 'Google Calendar',
            onPressed: () => context.push(Routes.googleCalendarSettings),
            icon: const Icon(Icons.sync),
          ),
        ],
      ),
      body: items.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (_, __) => const Center(child: Text('Agenda indisponível')),
        data: (list) {
          final today = DateTime.now();
          final ofToday = list.where((a) =>
              a.start.toLocal().year == today.year &&
              a.start.toLocal().month == today.month &&
              a.start.toLocal().day == today.day);
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              const Center(
                child: AppIconImage(
                  PersonalAiIcons.agendaConsultoria,
                  size: 72,
                  fallbackIcon: Icons.event_available,
                  semanticLabel: 'Agenda',
                ),
              ),
              const SizedBox(height: 12),
              AppCard(
                child: Text(
                  cal?.connected == true
                      ? 'Google Calendar: ${cal!.accountEmail}'
                      : 'Google Calendar não conectado',
                  style: const TextStyle(color: AppColors.textSecondary),
                ),
              ),
              const SizedBox(height: 12),
              const Text('Hoje',
                  style: TextStyle(
                      color: Colors.white, fontWeight: FontWeight.w800)),
              if (ofToday.isEmpty)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 8),
                  child: Text('Nenhuma consulta hoje.',
                      style: TextStyle(color: AppColors.textSecondary)),
                ),
              for (final a in ofToday) _tile(context, ref, a),
              const SizedBox(height: 16),
              const Text('Todas',
                  style: TextStyle(
                      color: Colors.white, fontWeight: FontWeight.w800)),
              for (final a in list) _tile(context, ref, a),
            ],
          );
        },
      ),
    );
  }

  Widget _tile(
      BuildContext context, WidgetRef ref, ConsultancyAppointment a) {
    final syncIcon = switch (a.calendarSync) {
      CalendarSyncState.synced => '✅',
      CalendarSyncState.pending => '⏳',
      CalendarSyncState.error => '⚠️',
      CalendarSyncState.disconnected => '',
    };
    return AppCard(
      child: ListTile(
        contentPadding: EdgeInsets.zero,
        title: Text('${a.serviceName} · ${a.studentName}',
            style: const TextStyle(color: Colors.white)),
        subtitle: Text(
          '${DateFormat('dd/MM HH:mm').format(a.start.toLocal())} · ${a.status.name} $syncIcon',
        ),
        trailing: PopupMenuButton<String>(
          onSelected: (v) async {
            final repo = ref.read(accompanimentRepositoryProvider);
            switch (v) {
              case 'confirm':
                await repo.updateAppointmentStatus(
                    a.id, AppointmentStatus.confirmed);
              case 'done':
                await repo.updateAppointmentStatus(
                    a.id, AppointmentStatus.completed);
              case 'cancel':
                await repo.updateAppointmentStatus(
                    a.id, AppointmentStatus.cancelled,
                    calendarSync: CalendarSyncState.pending);
              case 'noshow':
                await repo.updateAppointmentStatus(
                    a.id, AppointmentStatus.noShow);
              case 'retry':
                await repo.updateAppointmentStatus(a.id, a.status,
                    calendarSync: CalendarSyncState.pending);
                await ref
                    .read(googleCalendarRepositoryProvider)
                    .call('sync_appointment', {'appointmentId': a.id});
            }
            ref.invalidate(trainerAppointmentsProvider);
          },
          itemBuilder: (_) => const [
            PopupMenuItem(value: 'confirm', child: Text('Confirmar')),
            PopupMenuItem(value: 'done', child: Text('Concluída')),
            PopupMenuItem(value: 'cancel', child: Text('Cancelar')),
            PopupMenuItem(value: 'noshow', child: Text('Faltou')),
            PopupMenuItem(
                value: 'retry', child: Text('Tentar sincronizar novamente')),
          ],
        ),
      ),
    );
  }
}

class TrainerAvailabilityScreen extends ConsumerStatefulWidget {
  const TrainerAvailabilityScreen({super.key});

  @override
  ConsumerState<TrainerAvailabilityScreen> createState() =>
      _TrainerAvailabilityScreenState();
}

class _TrainerAvailabilityScreenState
    extends ConsumerState<TrainerAvailabilityScreen> {
  TrainerAvailability? _draft;

  static const _hours = [
    '08:00',
    '09:00',
    '10:30',
    '14:00',
    '15:30',
    '18:00',
  ];
  static const _days = {
    1: 'Seg',
    2: 'Ter',
    3: 'Qua',
    4: 'Qui',
    5: 'Sex',
    6: 'Sáb',
    7: 'Dom',
  };

  @override
  Widget build(BuildContext context) {
    final trainer = ref.watch(currentUserProvider) ?? AppUser.uiFallback();
    final avail = ref.watch(trainerAvailabilityProvider(trainer.id));
    return Scaffold(
      appBar: const PremiumAppBar(
        title: 'Disponibilidade',
        showStaffSignOut: true,
      ),
      body: avail.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (_, __) => const Center(child: Text('Erro')),
        data: (a) {
          _draft ??= a;
          final d = _draft!;
          return AppPage(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                for (final day in _days.entries) ...[
                  Text(day.value,
                      style: const TextStyle(
                          color: Colors.white, fontWeight: FontWeight.w700)),
                  Wrap(
                    spacing: 6,
                    children: [
                      for (final h in _hours)
                        FilterChip(
                          label: Text(h),
                          selected: (d.weekdaySlots[day.key] ?? [])
                              .contains(h),
                          onSelected: (sel) {
                            final next = Map<int, List<String>>.from(
                                d.weekdaySlots);
                            final list = [...(next[day.key] ?? <String>[])];
                            if (sel) {
                              list.add(h);
                            } else {
                              list.remove(h);
                            }
                            next[day.key] = list;
                            setState(() {
                              _draft = TrainerAvailability(
                                trainerId: d.trainerId,
                                weekdaySlots: next,
                                blockedDates: d.blockedDates,
                                cancelHoursNotice: d.cancelHoursNotice,
                                rescheduleHoursNotice: d.rescheduleHoursNotice,
                              );
                            });
                          },
                        ),
                    ],
                  ),
                  const SizedBox(height: 10),
                ],
                PrimaryButton(
                  label: 'Salvar horários',
                  onPressed: () async {
                    await ref
                        .read(accompanimentRepositoryProvider)
                        .saveAvailability(_draft!);
                    ref.invalidate(trainerAvailabilityProvider);
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Disponibilidade salva.')),
                      );
                    }
                  },
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class GoogleCalendarSettingsScreen extends ConsumerWidget {
  const GoogleCalendarSettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final trainer = ref.watch(currentUserProvider) ?? AppUser.uiFallback();
    final status = ref.watch(calendarStatusProvider(trainer.id));
    return Scaffold(
      appBar: const PremiumAppBar(
        title: 'Google Calendar',
        showStaffSignOut: true,
      ),
      body: AppPage(
        child: status.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (_, __) => const Text('Não foi possível carregar.'),
          data: (s) => Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(s.connected ? 'Conectado' : 'Não conectado',
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.w800)),
              if (s.accountEmail.isNotEmpty)
                Text('Conta: ${s.accountEmail}',
                    style: const TextStyle(color: AppColors.textSecondary)),
              Text('Calendário: ${s.calendarId}',
                  style: const TextStyle(color: AppColors.textSecondary)),
              if (s.lastSync != null)
                Text(
                  'Última sincronização: ${DateFormat('dd/MM HH:mm').format(s.lastSync!.toLocal())}',
                  style: const TextStyle(color: AppColors.textSecondary),
                ),
              const SizedBox(height: 16),
              if (!s.connected)
                PrimaryButton(
                  label: 'Conectar Google Calendar',
                  onPressed: () async {
                    final res = await ref
                        .read(googleCalendarRepositoryProvider)
                        .call('oauth_start');
                    if (!context.mounted) return;
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                      content: Text(
                        (res['authUrl'] as String?) ??
                            (res['error'] as String? ??
                                'Configure GOOGLE_CALENDAR_CLIENT_ID nas Cloud Functions.'),
                      ),
                    ));
                  },
                )
              else ...[
                PrimaryButton(
                  label: 'Sincronizar agora',
                  onPressed: () async {
                    await ref
                        .read(googleCalendarRepositoryProvider)
                        .call('sync_now');
                    ref.invalidate(calendarStatusProvider);
                  },
                ),
                const SizedBox(height: 8),
                OutlinedButton(
                  onPressed: () async {
                    await ref
                        .read(googleCalendarRepositoryProvider)
                        .call('disconnect');
                    ref.invalidate(calendarStatusProvider);
                  },
                  child: const Text('Desconectar'),
                ),
              ],
              const SizedBox(height: 16),
              const Text(
                'Horários ocupados no Google Calendar aparecem como indisponíveis para a aluna, sem exibir o nome do compromisso.',
                style: TextStyle(color: AppColors.textTertiary, height: 1.4),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
