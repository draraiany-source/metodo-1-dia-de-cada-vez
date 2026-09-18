import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:metodo_1_dia/features/video_streaming/data/videos_repository.dart';
import 'package:metodo_1_dia/features/video_streaming/domain/video_models.dart';

/// O seed existe para a área de Vídeos nunca abrir em branco numa instalação
/// nova. Se ele quebrar, a tela volta a ficar vazia — daí estes testes.
void main() {
  late Map<String, dynamic> raw;
  late List<VideoContent> videos;

  setUpAll(() {
    final texto = File(VideosRepository.seedAssetPath).readAsStringSync();
    raw = jsonDecode(texto) as Map<String, dynamic>;
    videos = (raw['videos'] as List)
        .map((e) => Map<String, dynamic>.from(e as Map))
        .map((m) => VideoContent.fromMap('${m['id']}', m))
        .toList();
  });

  test('o asset do seed está declarado no pubspec', () {
    final pubspec = File('pubspec.yaml').readAsStringSync();
    // A pasta inteira é declarada, o que já inclui o JSON da biblioteca.
    expect(pubspec.contains('- assets/content/'), isTrue);
  });

  test('todo vídeo do seed tem id, título e categoria válidos', () {
    expect(videos, isNotEmpty);
    final ids = <String>{};
    for (final v in videos) {
      expect(v.id.trim(), isNotEmpty, reason: 'vídeo sem id no seed');
      expect(ids.add(v.id), isTrue, reason: 'id duplicado no seed: ${v.id}');
      expect(v.name.trim(), isNotEmpty, reason: '${v.id} sem título');
      // Categoria desconhecida cai em `especiais`; no seed queremos explícito.
      expect(
        VideoCategory.values.map((c) => c.name),
        contains(v.category.name),
      );
    }
  });

  test('o primeiro conteúdo é o vídeo de boas-vindas da Amanda', () {
    final primeiro = videos.reduce((a, b) => a.order <= b.order ? a : b);
    expect(primeiro.category, VideoCategory.boasVindas);
    expect(primeiro.name, contains('Boas-vindas'));
    expect(primeiro.teacher, 'Amanda Lopes');
    expect(primeiro.active, isTrue);
    // Ainda sem link: a biblioteca mostra "Em breve" em vez de abrir um player
    // que falharia. Quando a Amanda colar a URL no painel, isso deixa de valer.
    expect(primeiro.aguardandoUrl, isTrue);
  });

  test('nenhum vídeo do seed é Premium (conteúdo de entrada é aberto)', () {
    expect(videos.every((v) => !v.isPremium), isTrue);
  });
}
