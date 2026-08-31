import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../core/services/feedback_service.dart';
import '../../../core/widgets/lili_animated.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/date_format.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/animations.dart';
import '../../../core/widgets/lili_widgets.dart';

/// Uma entrada do diário.
class DiaryEntry {
  DiaryEntry({required this.date, required this.mood, required this.text});
  final DateTime date;
  final int mood; // índice em _moods
  final String text;

  Map<String, dynamic> toMap() =>
      {'date': date.toIso8601String(), 'mood': mood, 'text': text};

  static DiaryEntry fromMap(Map<String, dynamic> m) => DiaryEntry(
        date: DateTime.parse(m['date'] as String),
        mood: m['mood'] as int,
        text: m['text'] as String,
      );
}

/// Diário pessoal — registra como foi o dia. Persiste localmente.
class DiaryScreen extends ConsumerStatefulWidget {
  const DiaryScreen({super.key});

  @override
  ConsumerState<DiaryScreen> createState() => _DiaryScreenState();
}

class _DiaryScreenState extends ConsumerState<DiaryScreen> {
  static const _kKey = 'diary_entries';
  static const _moods = ['😄', '🙂', '😐', '😔', '😫'];

  final _controller = TextEditingController();
  int _mood = 1;
  List<DiaryEntry> _entries = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getStringList(_kKey) ?? [];
    // Parse defensivo: entrada corrompida não derruba o diário.
    final parsed = <DiaryEntry>[];
    for (final s in raw) {
      try {
        parsed.add(DiaryEntry.fromMap(jsonDecode(s) as Map<String, dynamic>));
      } catch (_) {/* entrada inválida descartada */}
    }
    parsed.sort((a, b) => b.date.compareTo(a.date));
    if (!mounted) return;
    setState(() {
      _entries = parsed;
      _loading = false;
    });
  }

  Future<void> _save() async {
    if (_controller.text.trim().isEmpty) return;
    final entry = DiaryEntry(
        date: DateTime.now(), mood: _mood, text: _controller.text.trim());
    final prefs = await SharedPreferences.getInstance();
    final list = prefs.getStringList(_kKey) ?? [];
    list.add(jsonEncode(entry.toMap()));
    await prefs.setStringList(_kKey, list);
    _controller.clear();
    await FeedbackService.play(FeedbackEvent.sucesso);
    await _load();
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Entrada salva no diário 💜')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Meu Diário')),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
          children: [
            Row(
              children: [
                const AnimatedLiliMascot(
                    pose: MascotePose.coracao,
                    mood: LiliMood.respirando,
                    height: 84),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Como você se sentiu hoje? Escrever ajuda a manter a constância.',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Seletor de humor
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                for (var i = 0; i < _moods.length; i++)
                  GestureDetector(
                    onTap: () => setState(() => _mood = i),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: _mood == i
                            ? AppColors.primary.withOpacity(0.25)
                            : AppColors.surface,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: _mood == i
                              ? AppColors.primary
                              : Colors.transparent,
                          width: 2,
                        ),
                      ),
                      child: Text(_moods[i],
                          style: const TextStyle(fontSize: 26)),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 16),

            TextField(
              controller: _controller,
              maxLines: 4,
              decoration: const InputDecoration(
                hintText: 'Escreva sobre o seu dia...',
                alignLabelWithHint: true,
              ),
            ),
            const SizedBox(height: 12),
            ElevatedButton.icon(
              onPressed: _save,
              icon: const Icon(Icons.save_outlined),
              label: const Text('Salvar entrada'),
            ),
            const SizedBox(height: 24),

            Text('Entradas anteriores',
                style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),

            if (_loading)
              const Center(child: CircularProgressIndicator())
            else if (_entries.isEmpty)
              Column(
                children: const [
                  SizedBox(height: 12),
                  LiliMascot(pose: MascotePose.padrao, height: 120),
                  SizedBox(height: 8),
                  Text('Seu diário está vazio. Que tal começar hoje?',
                      style: TextStyle(color: AppColors.textSecondary)),
                ],
              )
            else
              ..._entries.map((e) => FadeInUp(
                    child: Container(
                      margin: const EdgeInsets.only(bottom: 10),
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius:
                            BorderRadius.circular(AppTheme.radius),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(_moods[e.mood],
                              style: const TextStyle(fontSize: 24)),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(DateFormatBr.dataHora(e.date),
                                    style: const TextStyle(
                                        color: AppColors.textSecondary,
                                        fontSize: 12)),
                                const SizedBox(height: 4),
                                Text(e.text,
                                    style: const TextStyle(
                                        color: Colors.white, height: 1.4)),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  )),
          ],
        ),
      ),
    );
  }

}
