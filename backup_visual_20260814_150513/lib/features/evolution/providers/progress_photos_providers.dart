import 'dart:convert';
import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Ângulo da foto de progresso.
enum PhotoAngle { frontal, lateral, costas }

extension PhotoAngleX on PhotoAngle {
  String get label => switch (this) {
        PhotoAngle.frontal => 'Frontal',
        PhotoAngle.lateral => 'Lateral',
        PhotoAngle.costas => 'Costas',
      };
}

/// Uma foto de evolução corporal — guardada só no dispositivo (nunca
/// enviada a nenhum servidor ou área pública/social do app).
class ProgressPhoto {
  const ProgressPhoto({
    required this.id,
    required this.date,
    required this.angle,
    required this.path,
  });

  final String id;
  final DateTime date;
  final PhotoAngle angle;

  /// Caminho local no armazenamento privado do app
  /// (`ApplicationDocumentsDirectory/progress_photos/`).
  final String path;

  Map<String, dynamic> toMap() => {
        'id': id,
        'date': date.toIso8601String(),
        'angle': angle.name,
        'path': path,
      };

  static ProgressPhoto fromMap(Map<String, dynamic> m) => ProgressPhoto(
        id: m['id'] as String,
        date: DateTime.parse(m['date'] as String),
        angle: PhotoAngle.values.firstWhere((a) => a.name == m['angle'],
            orElse: () => PhotoAngle.frontal),
        path: m['path'] as String,
      );
}

/// Histórico de fotos de progresso — mesmo padrão local-first já usado no
/// peso e nas medidas ([WeightHistoryNotifier], [MeasurementHistoryNotifier]):
/// persiste um índice em SharedPreferences; os arquivos em si ficam na pasta
/// privada de documentos do app (nunca em galeria pública, nunca em nuvem).
class ProgressPhotosNotifier extends StateNotifier<List<ProgressPhoto>> {
  ProgressPhotosNotifier() : super([]) {
    _load();
  }

  static const _key = 'progress_photos_index';

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getStringList(_key) ?? [];
    final parsed = <ProgressPhoto>[];
    for (final s in raw) {
      try {
        final photo =
            ProgressPhoto.fromMap(jsonDecode(s) as Map<String, dynamic>);
        // Só mantém no índice fotos cujo arquivo ainda existe no disco —
        // evita miniaturas quebradas se o app foi reinstalado, por exemplo.
        if (await File(photo.path).exists()) parsed.add(photo);
      } catch (_) {/* entrada corrompida descartada */}
    }
    parsed.sort((a, b) => a.date.compareTo(b.date));
    state = parsed;
  }

  Future<void> _persist() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(
        _key, state.map((e) => jsonEncode(e.toMap())).toList());
  }

  /// Abre a câmera/galeria, copia a foto escolhida para a pasta privada do
  /// app e adiciona ao histórico. Retorna `true` se uma foto foi salva.
  Future<bool> addFromSource(PhotoAngle angle, ImageSource source) async {
    final picker = ImagePicker();
    final xfile = await picker.pickImage(
      source: source,
      imageQuality: 80,
      maxWidth: 1440,
    );
    if (xfile == null) return false;

    final docsDir = await getApplicationDocumentsDirectory();
    final folder = Directory('${docsDir.path}/progress_photos');
    if (!await folder.exists()) await folder.create(recursive: true);

    final filename =
        '${DateTime.now().microsecondsSinceEpoch}_${angle.name}.jpg';
    final savedPath = '${folder.path}/$filename';
    await File(xfile.path).copy(savedPath);

    final entry = ProgressPhoto(
      id: DateTime.now().microsecondsSinceEpoch.toString(),
      date: DateTime.now(),
      angle: angle,
      path: savedPath,
    );
    state = [...state, entry];
    await _persist();
    return true;
  }

  Future<void> remove(String id) async {
    final target = state.where((p) => p.id == id).toList();
    state = state.where((p) => p.id != id).toList();
    await _persist();
    for (final p in target) {
      final f = File(p.path);
      if (await f.exists()) await f.delete();
    }
  }
}

final progressPhotosProvider =
    StateNotifierProvider<ProgressPhotosNotifier, List<ProgressPhoto>>((ref) {
  return ProgressPhotosNotifier();
});
