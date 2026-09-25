# -*- coding: utf-8 -*-
from pathlib import Path

root = Path(r"C:\Users\Lenovo\Desktop\metodo 1 dia perfil premium 2")

# ---- 1) program_player_controller: no autoplay; better local resolve ----
ctrl = root / "lib/features/audio_programs/providers/program_player_controller.dart"
t = ctrl.read_text(encoding="utf-8")

old_open_tail = """      try {
        await repo.setCurrentAudio(programId, audio.id);
      } catch (_) {}
      await _engine.play();
      state = state.copyWith(isLoading: false);"""

new_open_tail = """      try {
        await repo.setCurrentAudio(programId, audio.id);
      } catch (_) {}
      // NÃO autoplay: no Web o gesto do usuário se perde após awaits e o
      // Chrome bloqueia play(). O áudio só começa no botão PLAY.
      state = state.copyWith(isLoading: false, isPlaying: false);"""

if old_open_tail not in t:
    raise SystemExit('open() play block not found')
t = t.replace(old_open_tail, new_open_tail)

# Improve _localAssetFallback to also accept day-prefixed / title-ish ids
old_fallback = """  String? _localAssetFallback(String audioId) {
    const ids = {
      '01_como_vencer_a_procrastinacao',
      '02_como_criar_disciplina',
      '03_como_vencer_a_preguica',
      '04_como_manter_a_constancia',
      '05_como_voltar_depois_de_errar',
      '06_como_criar_habitos_saudaveis',
      '07_como_acreditar_em_voce',
    };
    if (!ids.contains(audioId)) return null;
    return 'asset:///assets/audio_programs/$audioId.mp3';
  }"""

new_fallback = """  String? _localAssetFallback(String audioId) {
    return AudioProgramRepositoryImpl.localAssetUrlFor(audioId);
  }"""

if old_fallback not in t:
    raise SystemExit('fallback block not found')
t = t.replace(old_fallback, new_fallback)

# Ensure import for repository impl (for static helper) - already imports audio_program_providers which uses repo
# Add direct import
if 'audio_program_repository_impl.dart' not in t:
    t = t.replace(
        "import '../domain/entities/program_progress.dart';",
        "import '../domain/entities/program_progress.dart';\n"
        "import '../data/repositories/audio_program_repository_impl.dart';",
    )

ctrl.write_text(t, encoding='utf-8')
print('OK controller: removed autoplay + shared local resolver')

# ---- 2) repository: robust local resolution + canonicalize Firestore list ----
repo = root / "lib/features/audio_programs/data/repositories/audio_program_repository_impl.dart"
r = repo.read_text(encoding="utf-8")

# Replace _localAssetFor with public static helper + title/day matching
old_local = """  String? _localAssetFor(String audioId) {
    const ids = {
      '01_como_vencer_a_procrastinacao',
      '02_como_criar_disciplina',
      '03_como_vencer_a_preguica',
      '04_como_manter_a_constancia',
      '05_como_voltar_depois_de_errar',
      '06_como_criar_habitos_saudaveis',
      '07_como_acreditar_em_voce',
    };
    if (!ids.contains(audioId)) return null;
    return 'asset:///assets/audio_programs/$audioId.mp3';
  }"""

new_local = """  /// Slugs canônicos dos 7 MP3 em `assets/audio_programs/`.
  static const List<String> kPrograma7Slugs = [
    '01_como_vencer_a_procrastinacao',
    '02_como_criar_disciplina',
    '03_como_vencer_a_preguica',
    '04_como_manter_a_constancia',
    '05_como_voltar_depois_de_errar',
    '06_como_criar_habitos_saudaveis',
    '07_como_acreditar_em_voce',
  ];

  /// URL `asset:///` para just_audio, ou null se não for um dos 7.
  static String? localAssetUrlFor(String audioId, {int? day, String? title}) {
    final id = audioId.trim();
    if (kPrograma7Slugs.contains(id)) {
      return 'asset:///assets/audio_programs/$id.mp3';
    }
    // Firestore às vezes usa IDs diferentes — casa por dia 1..7.
    if (day != null && day >= 1 && day <= 7) {
      final slug = kPrograma7Slugs[day - 1];
      return 'asset:///assets/audio_programs/$slug.mp3';
    }
    // Casa por palavras do título.
    final key = (title ?? id)
        .toLowerCase()
        .replaceAll('á', 'a')
        .replaceAll('ã', 'a')
        .replaceAll('é', 'e')
        .replaceAll('ê', 'e')
        .replaceAll('í', 'i')
        .replaceAll('ó', 'o')
        .replaceAll('õ', 'o')
        .replaceAll('ú', 'u')
        .replaceAll('ç', 'c');
    const titleHints = <String, String>{
      'procrastina': '01_como_vencer_a_procrastinacao',
      'disciplina': '02_como_criar_disciplina',
      'preguica': '03_como_vencer_a_preguica',
      'constancia': '04_como_manter_a_constancia',
      'voltar': '05_como_voltar_depois_de_errar',
      'errar': '05_como_voltar_depois_de_errar',
      'habito': '06_como_criar_habitos_saudaveis',
      'acreditar': '07_como_acreditar_em_voce',
    };
    for (final e in titleHints.entries) {
      if (key.contains(e.key)) {
        return 'asset:///assets/audio_programs/${e.value}.mp3';
      }
    }
    return null;
  }

  String? _localAssetFor(String audioId, {int? day, String? title}) =>
      localAssetUrlFor(audioId, day: day, title: title);"""

if old_local not in r:
    raise SystemExit('repo _localAssetFor not found')
r = r.replace(old_local, new_local)

# Fix resolvePlaybackUrl to always try local first (even if premium flag wrong on free bundled tracks)
old_resolve_start = """  @override
  Future<String> resolvePlaybackUrl(
      String programId, ProgramAudio audio) async {
    // Offline-first: os 7 áudios do Programa 7 Dias estão em assets.
    // Evita CORS/Storage lento/URL remota quebrada e funciona sem login.
    if (!audio.premium) {
      final local = _localAssetFor(audio.id);
      if (local != null) return local;
    }"""

new_resolve_start = """  @override
  Future<String> resolvePlaybackUrl(
      String programId, ProgramAudio audio) async {
    // Offline-first: os 7 áudios do Programa 7 Dias estão SEMPRE em assets.
    // Não depender de Storage/CF/CORS — e ignora flag premium errada no doc.
    final local = _localAssetFor(
      audio.id,
      day: audio.day > 0 ? audio.day : audio.order,
      title: audio.title,
    );
    if (local != null) return local;"""

if old_resolve_start not in r:
    raise SystemExit('resolvePlaybackUrl start not found')
r = r.replace(old_resolve_start, new_resolve_start)

# Canonicalize watchProgramAudios list for programa 7 dias
old_watch = """    return _firestore
        .collection(kProgramsCollection)
        .doc(programId)
        .collection(kAudiosSubcollection)
        .orderBy('order')
        .snapshots()
        .map((snap) {
      final list = snap.docs
          .map((d) => ProgramAudio.fromMap(d.id, d.data()))
          .where((a) => a.active)
          .toList();
      if (list.isEmpty) return _demoAudios(programId);
      return list;
    });"""

new_watch = """    return _firestore
        .collection(kProgramsCollection)
        .doc(programId)
        .collection(kAudiosSubcollection)
        .orderBy('order')
        .snapshots()
        .map((snap) {
      final list = snap.docs
          .map((d) => ProgramAudio.fromMap(d.id, d.data()))
          .where((a) => a.active)
          .toList();
      if (list.isEmpty) return _demoAudios(programId);
      return _canonicalizePrograma7Audios(programId, list);
    });"""

if old_watch not in r:
    raise SystemExit('watchProgramAudios map not found')
r = r.replace(old_watch, new_watch)

# Insert canonicalize method before _demoPrograms
canon_method = '''
  /// Garante que os 7 áudios usem os IDs/slugs dos MP3 em assets.
  List<ProgramAudio> _canonicalizePrograma7Audios(
      String programId, List<ProgramAudio> list) {
    if (programId != kPrograma7DiasId) return list;
    final demo = _demoAudios(programId);
    if (list.every((a) => localAssetUrlFor(a.id) != null)) {
      // IDs ok — ainda assim força premium=false p/ playback local.
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
    // Remapeia por day/order para os slugs canônicos.
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
        description:
            src.description.isNotEmpty ? src.description : canonical.description,
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

if '_canonicalizePrograma7Audios' not in r:
    r = r.replace('  List<AudioProgram> _demoPrograms()', canon_method + '  List<AudioProgram> _demoPrograms()')

repo.write_text(r, encoding='utf-8')
print('OK repository: local-first + canonicalize')

# ---- 3) Shared engine: clearer load errors (no silent swallow) ----
eng = root / "lib/features/audio_programs/data/services/shared_audio_playback_engine.dart"
e = eng.read_text(encoding='utf-8')
old_load = """  @override
  Future<void> load(String url, {required String title, String? artUrl}) async {
    await _player.stop();
    if (url.startsWith('asset:///')) {
      final assetPath = url.replaceFirst('asset:///', '');
      await _player.setAsset(assetPath);
    } else {
      await _player.setUrl(url);
    }
  }"""
new_load = """  @override
  Future<void> load(String url, {required String title, String? artUrl}) async {
    await _player.stop();
    try {
      if (url.startsWith('asset:///')) {
        final assetPath = url.replaceFirst('asset:///', '');
        await _player.setAsset(assetPath);
      } else if (url.startsWith('assets/')) {
        await _player.setAsset(url);
      } else {
        await _player.setUrl(url);
      }
    } catch (e) {
      throw StateError(
        'Falha ao carregar áudio ($title). Fonte: $url. Detalhe: $e',
      );
    }
  }"""
if old_load not in e:
    raise SystemExit('engine load not found')
e = e.replace(old_load, new_load)
eng.write_text(e, encoding='utf-8')
print('OK engine load errors')

print('ALL PATCHES DONE')
