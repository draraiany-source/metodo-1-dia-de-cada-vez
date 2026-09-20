import 'package:flutter_test/flutter_test.dart';
import 'package:metodo_1_dia/core/utils/youtube_url.dart';
import 'package:metodo_1_dia/features/personal_amanda/domain/amanda_asset_models.dart';
import 'package:metodo_1_dia/features/personal_trainer/domain/pt_models.dart';

void main() {
  group('StudentAnamnesis', () {
    test('grava updatedAt e relê os campos do aluno', () {
      const original = StudentAnamnesis(
        studentId: 'aluna_1',
        trainerId: 'personal_1',
        mainObjective: 'Saúde',
        notes: 'Retomar com calma',
      );
      final map = original.toMap();
      expect(map['studentId'], 'aluna_1');
      expect(map['trainerId'], 'personal_1');
      expect(map['updatedAt'], isNotEmpty);
      expect(map.containsKey('createdAt'), isFalse);

      final lido = StudentAnamnesis.fromMap('aluna_1', {
        ...map,
        'createdAt': '2026-09-01T10:00:00.000Z',
      });
      expect(lido.mainObjective, 'Saúde');
      expect(lido.notes, 'Retomar com calma');
      expect(lido.trainerId, 'personal_1');
      expect(lido.createdAt, isNotNull);
      expect(lido.updatedAt, isNotNull);
    });

    test('doc vazio vira ficha em branco do mesmo aluno', () {
      final vazio = StudentAnamnesis.fromMap('aluna_2', null);
      expect(vazio.studentId, 'aluna_2');
      expect(vazio.mainObjective, isEmpty);
    });
  });

  group('AmandaAsset', () {
    test('preserva storagePath no round-trip', () {
      const asset = AmandaAsset(
        id: 'foto1',
        category: AmandaAssetCategory.capa,
        url: 'https://exemplo.com/a.jpg',
        active: true,
        order: 2,
        storagePath: 'public/amanda_assets/capa/1.jpg',
      );
      final volta = AmandaAsset.fromMap('foto1', asset.toMap());
      expect(volta.storagePath, 'public/amanda_assets/capa/1.jpg');
      expect(volta.category, AmandaAssetCategory.capa);
      expect(volta.order, 2);
    });
  });

  group('Shorts da biblioteca', () {
    test('os 3 IDs continuam reconhecidos sem URL hardcoded no player', () {
      const ids = ['34PHGKECMTY', '3T0HDPX4jkk', 'zRSTnW3EMF8'];
      for (final id in ids) {
        expect(
          YoutubeUrl.extractVideoId('https://youtube.com/shorts/$id?si=x'),
          id,
        );
      }
    });
  });
}
