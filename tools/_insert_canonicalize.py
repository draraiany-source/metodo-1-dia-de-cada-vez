# -*- coding: utf-8 -*-
from pathlib import Path
p = Path('lib/features/audio_programs/data/repositories/audio_program_repository_impl.dart')
t = p.read_text(encoding='utf-8', errors='replace')
method = r'''
  /// Garante que os 7 audios usem os IDs/slugs dos MP3 em assets.
  List<ProgramAudio> _canonicalizePrograma7Audios(
      String programId, List<ProgramAudio> list) {
    if (programId != kPrograma7DiasId) return list;
    final demo = _demoAudios(programId);
    if (list.every((a) => localAssetUrlFor(a.id) != null)) {
      return list
          .map((a) => ProgramAudio(
                id: a.id,
                day: a.day,
                order: a.order,
                title: a.title,
                description: a.description,
                audioUrl: a.audioUrl,
                storagePath: a.storagePath,
                coverUrl: a.coverUrl,
                durationSeconds: a.durationSeconds > 0
                    ? a.durationSeconds
                    : demo
                        .firstWhere((d) => d.id == a.id,
                            orElse: () => demo.first)
                        .durationSeconds,
                active: a.active,
                premium: false,
              ))
          .toList();
    }
    final byDay = <int, ProgramAudio>{};
    for (final a in list) {
      final day = a.day > 0 ? a.day : a.order;
      if (day >= 1 && day <= 7) byDay[day] = a;
    }
    return List.generate(7, (i) {
      final day = i + 1;
      final canonical = demo[i];
      final src = byDay[day];
      if (src == null) return canonical;
      return ProgramAudio(
        id: canonical.id,
        day: day,
        order: src.order > 0 ? src.order : day,
        title: src.title.isNotEmpty ? src.title : canonical.title,
        description: src.description.isNotEmpty
            ? src.description
            : canonical.description,
        audioUrl: '',
        storagePath: canonical.storagePath,
        coverUrl: src.coverUrl,
        durationSeconds: src.durationSeconds > 0
            ? src.durationSeconds
            : canonical.durationSeconds,
        active: src.active,
        premium: false,
      );
    });
  }

'''
needle = '  List<AudioProgram> _demoPrograms()'
if 'List<ProgramAudio> _canonicalizePrograma7Audios' in t:
    print('already defined')
else:
    if needle not in t:
        raise SystemExit('needle missing')
    t = t.replace(needle, method + needle, 1)
    p.write_text(t, encoding='utf-8')
    print('inserted method')
print('def count', t.count('List<ProgramAudio> _canonicalizePrograma7Audios'))
# also ensure localAssetUrlFor exists
if 'static String? localAssetUrlFor' not in t:
    print('WARNING missing localAssetUrlFor')
else:
    print('localAssetUrlFor OK')
