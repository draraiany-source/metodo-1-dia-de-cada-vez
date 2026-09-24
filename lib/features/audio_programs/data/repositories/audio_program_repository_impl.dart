import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import '../../../../core/constants/app_constants.dart';
import '../../../../core/services/auth_http_headers.dart';
import '../../../../core/services/firebase_service.dart';
import '../../../../core/utils/youtube_url.dart';
import '../../domain/entities/audio_program.dart';
import '../../domain/entities/program_progress.dart';
import '../../domain/repositories/audio_program_repository.dart';

/// Coleção genérica de programas (áudio hoje; expansível).
const String kProgramsCollection = 'programs';
const String kAudiosSubcollection = 'audios';
const String kUserProgressSubcollection = 'programProgress';
const String kPrograma7DiasId = 'programa_7_dias_um_dia_de_cada_vez';

/// Firestore:
/// ```
/// programs/{programId}
/// programs/{programId}/audios/{audioId}
/// programs/{programId}/private/audios
/// users/{uid}/programProgress/{programId}
/// ```
class AudioProgramRepositoryImpl implements AudioProgramRepository {
  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;
  final FirebaseStorage _storage;

  AudioProgramRepositoryImpl({
    FirebaseFirestore? firestore,
    FirebaseAuth? auth,
    FirebaseStorage? storage,
  })  : _firestore = firestore ?? FirebaseFirestore.instance,
        _auth = auth ?? FirebaseAuth.instance,
        _storage = storage ?? FirebaseStorage.instance;

  bool get _isFirebaseAvailable => FirebaseService.isReady;

  String? get _uid => _auth.currentUser?.uid;

  @override
  Stream<List<AudioProgram>> watchPrograms() {
    if (!_isFirebaseAvailable) {
      return Stream.value(kDebugMode ? _demoPrograms() : const []);
    }
    return _firestore
        .collection(kProgramsCollection)
        .orderBy('orderIndex')
        .snapshots()
        .map((snap) => snap.docs
            .map((d) => AudioProgram.fromMap(d.id, d.data()))
            .where((p) => p.active)
            .toList());
  }

  @override
  Future<AudioProgram?> getProgram(String programId) async {
    if (!_isFirebaseAvailable) {
      if (!kDebugMode) return null;
      return _demoPrograms().where((p) => p.id == programId).firstOrNull;
    }
    try {
      final doc =
          await _firestore.collection(kProgramsCollection).doc(programId).get();
      if (!doc.exists) {
        if (!kDebugMode) return null;
        return _demoPrograms().where((p) => p.id == programId).firstOrNull;
      }
      return AudioProgram.fromMap(doc.id, doc.data()!);
    } catch (_) {
      if (!kDebugMode) return null;
      return _demoPrograms().where((p) => p.id == programId).firstOrNull;
    }
  }

  @override
  Stream<List<ProgramAudio>> watchProgramAudios(String programId) {
    if (!_isFirebaseAvailable) {
      return Stream.value(kDebugMode ? _demoAudios(programId) : const []);
    }
    return _firestore
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
      // Lista vazia = sem conteúdo publicado. Demo só em debug.
      if (list.isEmpty) {
        return kDebugMode ? _demoAudios(programId) : <ProgramAudio>[];
      }
      return _canonicalizePrograma7Audios(programId, list);
    }).timeout(
      const Duration(seconds: 12),
      onTimeout: (sink) {
        // Timeout não deve fingir catálogo publicado em release.
        sink.add(kDebugMode ? _demoAudios(programId) : <ProgramAudio>[]);
      },
    );
  }

  @override
  Future<String> resolvePlaybackUrl(
      String programId, ProgramAudio audio) async {
    // Os 7 áudios do Programa 7 Dias tocam no YouTube (mesmos Shorts da
    // área de Meditação). Sem MP3 no APK.
    final youtube = youtubeUrlFor(
      audio.id,
      day: audio.day > 0 ? audio.day : audio.order,
      title: audio.title,
    );
    if (youtube != null) return youtube;
    if (YoutubeUrl.extractVideoId(audio.audioUrl) != null) {
      return audio.audioUrl;
    }

    if (!audio.premium && audio.audioUrl.isNotEmpty) {
      return audio.audioUrl;
    }

    if (!_isFirebaseAvailable) {
      if (audio.audioUrl.isNotEmpty) return audio.audioUrl;
      throw StateError(
          'Arquivo de áudio ainda não disponível neste dispositivo.');
    }

    if (_auth.currentUser == null) {
      throw StateError('Entre na sua conta pra ouvir este conteúdo.');
    }

    if (!audio.premium && audio.storagePath.isNotEmpty) {
      try {
        return await _storage
            .ref(audio.storagePath)
            .getDownloadURL()
            .timeout(const Duration(seconds: 5));
      } catch (_) {
        // CF / audioUrl abaixo
      }
    }

    if (audio.premium || audio.storagePath.isNotEmpty) {
      const functionUrl = AppConstants.getContentUrlFunctionUrl;
      if (!functionUrl.contains('SEU-PROJETO')) {
        try {
          final headers = await AuthHttpHeaders.forCloudFunction();
          final res = await http
              .post(
                Uri.parse(functionUrl),
                headers: headers,
                body: jsonEncode({
                  'collection': kProgramsCollection,
                  'docId': programId,
                }),
              )
              .timeout(const Duration(seconds: 8));

          final body = jsonDecode(res.body) as Map<String, dynamic>;
          if (res.statusCode == 200 && body['data'] != null) {
            final map = body['data'] as Map<String, dynamic>;
            final url = map[audio.id] as String?;
            if (url != null && url.isNotEmpty) return url;
          }
          if (audio.premium) {
            final err = (body['error'] ??
                    'Áudio não configurado. Verifique private/audios.')
                as String;
            throw StateError(err);
          }
        } catch (e) {
          if (audio.premium) {
            if (e is StateError) rethrow;
            throw StateError('Não consegui carregar este áudio agora.');
          }
        }
      }
    }

    if (audio.audioUrl.isNotEmpty) return audio.audioUrl;

    throw StateError(
        'Áudio não disponível no momento. Tente de novo em instantes.');
  }

  /// Slugs canônicos dos 7 dias (IDs de progresso / Firestore).
  static const List<String> kPrograma7Slugs = [
    '01_como_vencer_a_procrastinacao',
    '02_como_criar_disciplina',
    '03_como_vencer_a_preguica',
    '04_como_manter_a_constancia',
    '05_como_voltar_depois_de_errar',
    '06_como_criar_habitos_saudaveis',
    '07_como_acreditar_em_voce',
  ];

  /// Mesmos IDs da área de Meditação (YouTube Shorts testados no Android).
  static const Map<String, String> kPrograma7YoutubeIds = {
    '01_como_vencer_a_procrastinacao': 'UH5zs7CtPvs',
    '02_como_criar_disciplina': 'lLpZMeMNbcU',
    '03_como_vencer_a_preguica': 'nZempKMRbe0',
    '04_como_manter_a_constancia': '36WIOOoo-3I',
    '05_como_voltar_depois_de_errar': 'JXnM5Kw5rtQ',
    '06_como_criar_habitos_saudaveis': 'gTS3NisvXBg',
    '07_como_acreditar_em_voce': 'p1fnlTzTLyE',
  };

  static String? canonicalSlugFor(String audioId, {int? day, String? title}) {
    final id = audioId.trim();
    if (kPrograma7Slugs.contains(id)) return id;
    if (day != null && day >= 1 && day <= 7) return kPrograma7Slugs[day - 1];
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
      if (key.contains(e.key)) return e.value;
    }
    return null;
  }

  static String? youtubeUrlFor(String audioId, {int? day, String? title}) {
    final slug = canonicalSlugFor(audioId, day: day, title: title);
    if (slug == null) return null;
    final videoId = kPrograma7YoutubeIds[slug];
    if (videoId == null) return null;
    return 'https://www.youtube.com/shorts/$videoId';
  }

  DocumentReference<Map<String, dynamic>> _progressDoc(String programId) {
    final uid = _uid;
    if (uid == null) {
      throw StateError('User must be authenticated to track program progress.');
    }
    return _firestore
        .collection('users')
        .doc(uid)
        .collection(kUserProgressSubcollection)
        .doc(programId);
  }

  @override
  Stream<ProgramProgress> watchProgress(String programId) {
    if (!_isFirebaseAvailable || _uid == null) {
      return Stream.value(ProgramProgress.empty(programId));
    }
    return _progressDoc(programId).snapshots().map((doc) {
      if (!doc.exists) return ProgramProgress.empty(programId);
      return ProgramProgress.fromMap(programId, doc.data()!);
    });
  }

  @override
  Future<void> markCompleted(String programId, String audioId) async {
    if (!_isFirebaseAvailable || _uid == null) return;
    await _progressDoc(programId).set({
      'completedAudioIds': FieldValue.arrayUnion([audioId]),
      'completedAt.$audioId': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  @override
  Future<void> savePlaybackPosition(
      String programId, String audioId, int positionSeconds) async {
    if (!_isFirebaseAvailable || _uid == null) return;
    await _progressDoc(programId).set({
      'lastPositionSeconds.$audioId': positionSeconds,
      'currentAudioId': audioId,
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  @override
  Future<void> setCurrentAudio(String programId, String audioId) async {
    if (!_isFirebaseAvailable || _uid == null) return;
    await _progressDoc(programId).set({
      'currentAudioId': audioId,
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  @override
  Future<void> toggleFavorite(
      String programId, String audioId, bool isFavorite) async {
    if (!_isFirebaseAvailable || _uid == null) return;
    await _progressDoc(programId).set({
      'favoriteAudioIds': isFavorite
          ? FieldValue.arrayUnion([audioId])
          : FieldValue.arrayRemove([audioId]),
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }


  /// Garante que os 7 áudios usem os slugs canônicos + URL do YouTube.
  List<ProgramAudio> _canonicalizePrograma7Audios(
      String programId, List<ProgramAudio> list) {
    if (programId != kPrograma7DiasId) return list;
    final demo = _demoAudios(programId);
    if (list.every((a) => youtubeUrlFor(a.id) != null)) {
      return list
          .map((a) => ProgramAudio(
                id: a.id,
                day: a.day,
                order: a.order,
                title: a.title,
                description: a.description,
                audioUrl: youtubeUrlFor(a.id) ?? a.audioUrl,
                storagePath: a.storagePath,
                coverUrl: a.coverUrl.isNotEmpty
                    ? a.coverUrl
                    : (YoutubeUrl.thumbnailUrl(youtubeUrlFor(a.id) ?? '') ??
                        ''),
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
        audioUrl: canonical.audioUrl,
        storagePath: '',
        coverUrl: src.coverUrl.isNotEmpty ? src.coverUrl : canonical.coverUrl,
        durationSeconds: src.durationSeconds > 0
            ? src.durationSeconds
            : canonical.durationSeconds,
        active: src.active,
        premium: false,
      );
    });
  }

  List<AudioProgram> _demoPrograms() => [
        const AudioProgram(
          id: kPrograma7DiasId,
          title: 'Programa 7 Dias — Um Dia de Cada Vez',
          description:
              'Sequência de 7 áudios para foco, disciplina, mudança de hábitos, '
              'constância e autoconfiança.',
          category: 'Foco, Disciplina e Mudança de Hábitos',
          author: 'Amanda Lopes',
          coverUrl: '',
          active: true,
          premium: false,
          totalDays: 7,
          orderIndex: 0,
        ),
      ];

  List<ProgramAudio> _demoAudios(String programId) {
    const meta = <List<Object>>[
      [
        'Como Vencer a Procrastinação',
        'Aprenda a sair do adiamento e começar com pequenas atitudes possíveis hoje.',
        85
      ],
      [
        'Como Criar Disciplina',
        'Entenda como construir disciplina mesmo nos dias em que a motivação estiver baixa.',
        62
      ],
      [
        'Como Vencer a Preguiça',
        'Estratégias simples para vencer a inércia e colocar o corpo e a mente em movimento.',
        56
      ],
      [
        'Como Manter a Constância',
        'Descubra como continuar mesmo quando os resultados ainda parecem pequenos.',
        51
      ],
      [
        'Como Voltar Depois de Errar',
        'Aprenda a retomar sem culpa e sem abandonar todo o processo por causa de um deslize.',
        44
      ],
      [
        'Como Criar Hábitos Saudáveis',
        'Transforme pequenas escolhas em uma rotina mais saudável e sustentável.',
        41
      ],
      [
        'Como Acreditar em Você',
        'Fortaleça sua confiança e reconheça que você é capaz de continuar evoluindo.',
        51
      ],
    ];
    const slugs = [
      '01_como_vencer_a_procrastinacao',
      '02_como_criar_disciplina',
      '03_como_vencer_a_preguica',
      '04_como_manter_a_constancia',
      '05_como_voltar_depois_de_errar',
      '06_como_criar_habitos_saudaveis',
      '07_como_acreditar_em_voce',
    ];
    return List.generate(7, (i) {
      final day = i + 1;
      final slug = slugs[i];
      return ProgramAudio(
        id: slug,
        day: day,
        order: day,
        title: meta[i][0] as String,
        description: meta[i][1] as String,
        audioUrl: youtubeUrlFor(slug) ?? '',
        storagePath: '',
        coverUrl: YoutubeUrl.thumbnailUrl(youtubeUrlFor(slug) ?? '') ?? '',
        durationSeconds: meta[i][2] as int,
        active: true,
        premium: false,
      );
    });
  }
}

extension _FirstOrNullExt<T> on Iterable<T> {
  T? get firstOrNull => isEmpty ? null : first;
}
