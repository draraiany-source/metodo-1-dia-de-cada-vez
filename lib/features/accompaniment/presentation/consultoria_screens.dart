import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../core/router/app_router.dart';
import '../../../core/router/premium_app_bar.dart';
import '../../../core/widgets/app_page.dart';
import '../../../core/widgets/lili_animated.dart';
import '../../../core/widgets/lili_widgets.dart';
import '../../../core/widgets/premium_ui.dart';
import '../../../models/app_user.dart';
import '../../auth/providers/auth_providers.dart';
import '../../personal_trainer/providers/pt_providers.dart';
import '../domain/accompaniment_models.dart';
import '../providers/accompaniment_providers.dart';

class ConsultoriaHomeScreen extends ConsumerWidget {
  const ConsultoriaHomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(currentUserProvider) ?? AppUser.uiFallback();
    final studentAsync = ref.watch(
      ptMyStudentProfileProvider((userId: user.id, email: user.email)),
    );

    return Scaffold(
      appBar: const PremiumAppBar(title: 'Consultoria com Amanda'),
      body: AppPage(
        child: studentAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (_, __) => const Text('Não foi possível abrir a consultoria.'),
          data: (student) {
            if (student == null) {
              return const Text(
                'Você precisa estar vinculada à Amanda para agendar.',
                style: TextStyle(color: AppColors.textSecondary),
              );
            }
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Agende sua consultoria',
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.w800)),
                const SizedBox(height: 8),
                const Text(
                  'Escolha o melhor dia e horário para conversar com a Amanda e revisar seus objetivos, treinos e evolução.',
                  style: TextStyle(color: AppColors.textSecondary, height: 1.4),
                ),
                const SizedBox(height: 20),
                PrimaryButton(
                  label: 'Agendar consultoria',
                  icon: Icons.event_available,
                  onPressed: () => context.push(Routes.consultoriaAgendar),
                ),
                const SizedBox(height: 10),
                PrimaryButton(
                  label: 'Minhas consultas',
                  icon: Icons.calendar_today_outlined,
                  onPressed: () => context.push(Routes.minhasConsultas),
                ),
                const SizedBox(height: 10),
                OutlinedButton.icon(
                  onPressed: () => context.push(Routes.minhasConsultas),
                  icon: const Icon(Icons.history),
                  label: const Text('Histórico'),
                ),
                const SizedBox(height: 24),
                const Text('Legenda',
                    style: TextStyle(
                        color: Colors.white, fontWeight: FontWeight.w700)),
                const SizedBox(height: 8),
                const Text('🟢 Disponível   🟣 Minha consulta   ⚫ Indisponível',
                    style: TextStyle(color: AppColors.textSecondary)),
                const SizedBox(height: 24),
                const Center(
                  child: AnimatedLiliMascot(
                    pose: MascotePose.checklist,
                    mood: LiliMood.respirando,
                    height: 96,
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class ConsultoriaBookScreen extends ConsumerStatefulWidget {
  const ConsultoriaBookScreen({super.key});

  @override
  ConsumerState<ConsultoriaBookScreen> createState() =>
      _ConsultoriaBookScreenState();
}

class _ConsultoriaBookScreenState extends ConsumerState<ConsultoriaBookScreen> {
  DateTime _day = DateTime.now();
  AppointmentService? _service;
  DateTime? _slot;

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(currentUserProvider) ?? AppUser.uiFallback();
    final student = ref
        .watch(ptMyStudentProfileProvider((userId: user.id, email: user.email)))
        .valueOrNull;
    if (student == null) {
      return const Scaffold(
        appBar: PremiumAppBar(title: 'Agendar'),
        body: Center(child: Text('Vínculo com a Personal não encontrado.')),
      );
    }
    final services =
        ref.watch(appointmentServicesProvider(student.trainerId)).valueOrNull ??
            [];
    _service ??= services.isEmpty ? null : services.first;

    return Scaffold(
      appBar: const PremiumAppBar(title: 'Agendar consultoria'),
      body: AppPage(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Tipo de consultoria',
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700)),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final s in services)
                  ChoiceChip(
                    label: Text(s.name),
                    selected: _service?.id == s.id,
                    onSelected: (_) => setState(() => _service = s),
                  ),
              ],
            ),
            const SizedBox(height: 16),
            CalendarDatePicker(
              initialDate: _day,
              firstDate: DateTime.now(),
              lastDate: DateTime.now().add(const Duration(days: 90)),
              onDateChanged: (d) => setState(() {
                _day = d;
                _slot = null;
              }),
            ),
            const SizedBox(height: 8),
            FutureBuilder<List<DateTime>>(
              future: ref.read(accompanimentRepositoryProvider).availableSlots(
                    trainerId: student.trainerId,
                    day: _day,
                    durationMinutes: _service?.durationMinutes ?? 45,
                  ),
              builder: (ctx, snap) {
                final slots = snap.data ?? [];
                if (slots.isEmpty) {
                  return const Text('Nenhum horário disponível neste dia.',
                      style: TextStyle(color: AppColors.textSecondary));
                }
                return Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    for (final t in slots)
                      ChoiceChip(
                        label: Text(DateFormat('HH:mm').format(t)),
                        selected: _slot == t,
                        onSelected: (_) => setState(() => _slot = t),
                      ),
                  ],
                );
              },
            ),
            const SizedBox(height: 24),
            PrimaryButton(
              label: 'Continuar',
              onPressed: _service == null || _slot == null
                  ? null
                  : () => context.push(
                        Routes.consultoriaConfirmar,
                        extra: ConsultancyAppointment(
                          id: '',
                          trainerId: student.trainerId,
                          studentId: student.id,
                          studentUserId: student.userId,
                          serviceId: _service!.id,
                          serviceName: _service!.name,
                          start: _slot!,
                          end: _slot!.add(
                            Duration(minutes: _service!.durationMinutes),
                          ),
                          modality: _service!.modality,
                          priceReais: _service!.priceReais,
                          studentName: student.name,
                        ),
                      ),
            ),
          ],
        ),
      ),
    );
  }
}

class ConsultoriaConfirmScreen extends ConsumerWidget {
  const ConsultoriaConfirmScreen({super.key, required this.draft});
  final ConsultancyAppointment draft;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final fmt = DateFormat("dd/MM/yyyy 'às' HH:mm");
    return Scaffold(
      appBar: const PremiumAppBar(title: 'Confirme sua consultoria'),
      body: AppPage(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AppCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _row('Serviço', draft.serviceName),
                  _row('Data e horário', fmt.format(draft.start)),
                  _row(
                    'Duração',
                    '${draft.end.difference(draft.start).inMinutes} min',
                  ),
                  _row('Modalidade', draft.modality),
                  if (draft.priceReais != null)
                    _row(
                      'Valor',
                      'R\$ ${draft.priceReais!.toStringAsFixed(2)}',
                    ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            PrimaryButton(
              label: 'Confirmar agendamento',
              onPressed: () async {
                final saved = await ref
                    .read(accompanimentRepositoryProvider)
                    .bookAppointment(draft);
                if (!context.mounted) return;
                if (saved == null) {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                    content: Text(
                      'Esse horário acabou de ficar indisponível. Escolha outro.',
                    ),
                  ));
                  return;
                }
                await showDialog<void>(
                  context: context,
                  builder: (ctx) => AlertDialog(
                    backgroundColor: AppColors.surface,
                    content: const Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        AnimatedLiliMascot(
                          pose: MascotePose.halteres,
                          mood: LiliMood.viva,
                          height: 90,
                        ),
                        SizedBox(height: 12),
                        Text('Consultoria agendada com sucesso 💜',
                            textAlign: TextAlign.center),
                      ],
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(ctx),
                        child: const Text('Ok'),
                      ),
                    ],
                  ),
                );
                if (context.mounted) context.go(Routes.minhasConsultas);
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _row(String k, String v) => Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: Row(
          children: [
            Expanded(
                child: Text(k,
                    style: const TextStyle(color: AppColors.textSecondary))),
            Text(v, style: const TextStyle(color: Colors.white)),
          ],
        ),
      );
}

class MyAppointmentsScreen extends ConsumerWidget {
  const MyAppointmentsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(currentUserProvider) ?? AppUser.uiFallback();
    final student = ref
        .watch(ptMyStudentProfileProvider((userId: user.id, email: user.email)))
        .valueOrNull;
    if (student == null) {
      return const Scaffold(
        appBar: PremiumAppBar(title: 'Minhas consultas'),
        body: Center(child: Text('Nenhuma consulta.')),
      );
    }
    final list = ref.watch(studentAppointmentsProvider(
        (trainerId: student.trainerId, studentId: student.id)));
    return Scaffold(
      appBar: const PremiumAppBar(title: 'Minhas consultas'),
      body: list.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (_, __) => const Center(child: Text('Não foi possível carregar.')),
        data: (items) {
          final now = DateTime.now();
          final upcoming = items
              .where((a) => a.isActive && a.start.isAfter(now))
              .toList();
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              const Text('Próxima consulta',
                  style: TextStyle(
                      color: Colors.white, fontWeight: FontWeight.w800)),
              const SizedBox(height: 8),
              if (upcoming.isEmpty)
                const Text('Nenhuma consulta agendada.',
                    style: TextStyle(color: AppColors.textSecondary))
              else
                for (final a in upcoming)
                  AppCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(a.serviceName,
                            style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w700)),
                        Text(DateFormat("dd/MM 'às' HH:mm").format(a.start.toLocal())),
                        Text('Status: ${a.status.name}'),
                        Row(
                          children: [
                            TextButton(
                              onPressed: () => context.push(
                                Routes.consultoriaAgendar,
                              ),
                              child: const Text('Reagendar'),
                            ),
                            TextButton(
                              onPressed: () async {
                                await ref
                                    .read(accompanimentRepositoryProvider)
                                    .updateAppointmentStatus(
                                      a.id,
                                      AppointmentStatus.cancelled,
                                      calendarSync: CalendarSyncState.pending,
                                    );
                                ref.invalidate(studentAppointmentsProvider);
                              },
                              child: const Text('Cancelar'),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
              const SizedBox(height: 16),
              const Text('Histórico',
                  style: TextStyle(
                      color: Colors.white, fontWeight: FontWeight.w800)),
              for (final a in items.where((e) => !upcoming.contains(e)))
                ListTile(
                  title: Text(a.serviceName),
                  subtitle: Text(
                    '${DateFormat('dd/MM/yyyy HH:mm').format(a.start.toLocal())} · ${a.status.name}',
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}
