import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../core/router/app_router.dart';
import '../../../core/services/notifications_service.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/animations.dart';

/// Preferências de notificação — usa o [NotificationsService] real
/// (inscrição/desinscrição em tópicos FCM) já usado no app; os *horários*
/// de água/treino/refeições/pesagem continuam sendo geridos pela tela de
/// Lembretes já existente (`Routes.reminders`), pra não duplicar aquele
/// sistema aqui.
class NotificationPreferencesScreen extends StatefulWidget {
  const NotificationPreferencesScreen({super.key});

  @override
  State<NotificationPreferencesScreen> createState() =>
      _NotificationPreferencesScreenState();
}

class _NotificationPreferencesScreenState
    extends State<NotificationPreferencesScreen> {
  static const _key = 'notification_topics';

  static const _labels = {
    'lembrete_treino': 'Lembrete de treino',
    'lembrete_agua': 'Lembrete de água',
    'lembrete_refeicao': 'Lembrete de refeições',
    'lembrete_peso': 'Lembrete de peso',
    'motivacao_diaria': 'Mensagem motivacional',
    'sequencia_diaria': 'Sequência diária',
    'novas_receitas': 'Novas receitas',
    'novos_treinos': 'Novos treinos',
  };

  static const _defaults = {
    'lembrete_treino': true,
    'lembrete_agua': true,
    'lembrete_refeicao': true,
    'lembrete_peso': false,
    'motivacao_diaria': true,
    'sequencia_diaria': true,
    'novas_receitas': false,
    'novos_treinos': false,
  };

  Map<String, bool> _topics = Map.of(_defaults);
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_key);
    if (raw != null) {
      try {
        final m = jsonDecode(raw) as Map<String, dynamic>;
        _topics = {
          for (final k in _labels.keys) k: (m[k] as bool?) ?? _defaults[k]!,
        };
      } catch (_) {/* mantém default */}
    }
    if (mounted) setState(() => _loading = false);
  }

  Future<void> _toggle(String topic, bool value) async {
    setState(() => _topics[topic] = value);
    value
        ? NotificationsService.subscribe(topic)
        : NotificationsService.unsubscribe(topic);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_key, jsonEncode(_topics));
  }

  @override
  Widget build(BuildContext context) {
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
                    const Text('Notificações',
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
                          child: const Icon(Icons.arrow_back,
                              size: 18, color: Colors.white),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Expanded(
              child: _loading
                  ? const Center(
                      child: CircularProgressIndicator(color: AppColors.secondary))
                  : ListView(
                      padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
                      children: [
                        Container(
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: AppColors.surface,
                            borderRadius: BorderRadius.circular(AppTheme.radius),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.alarm, color: AppColors.secondary),
                              const SizedBox(width: 10),
                              const Expanded(
                                child: Text(
                                    'Quer escolher o horário de cada lembrete '
                                    '(água, treino, refeições, pesagem)?',
                                    style: TextStyle(color: Colors.white, fontSize: 12)),
                              ),
                              TextButton(
                                onPressed: () => context.push(Routes.reminders),
                                child: const Text('Configurar'),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 20),
                        const Text('O que você quer receber',
                            style: TextStyle(
                                color: Colors.white, fontWeight: FontWeight.w700)),
                        const SizedBox(height: 8),
                        for (final topic in _labels.keys)
                          Container(
                            margin: const EdgeInsets.only(bottom: 6),
                            decoration: BoxDecoration(
                              color: AppColors.surface,
                              borderRadius: BorderRadius.circular(14),
                            ),
                            child: SwitchListTile(
                              value: _topics[topic]!,
                              activeColor: AppColors.secondary,
                              title: Text(_labels[topic]!,
                                  style: const TextStyle(color: Colors.white)),
                              onChanged: (v) => _toggle(topic, v),
                            ),
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
