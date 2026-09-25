import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:metodo_1_dia/core/lily/lily_exercicio_assets.dart';

/// Guarda da troca de cadeiras Lily Fit (2026-09-23).
///
/// Confirma paths de abdutora/extensora, carga via AssetBundle e
/// flexora (`treino_063`) intocada.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Lily cadeiras — troca 2026-09-23', () {
    test('treino_034 aponta para cadeira extensora', () {
      expect(
        LilyExercicioAssets.pathForId('treino_034'),
        'assets/lily_exercicios/lily_fit_cadeira_extensora.jpeg',
      );
    });

    test('treino_046 aponta para cadeira abdutora', () {
      expect(
        LilyExercicioAssets.pathForId('treino_046'),
        'assets/lily_exercicios/lily_fit_cadeira_abdutora.jpeg',
      );
    });

    test('treino_063 continua treino_063.jpg (flexora intocada)', () {
      expect(
        LilyExercicioAssets.pathForId('treino_063'),
        'assets/lily_exercicios/treino_063.jpg',
      );
    });

    test('AssetBundle carrega abdutora e extensora', () async {
      final abd = await rootBundle.load(
        'assets/lily_exercicios/lily_fit_cadeira_abdutora.jpeg',
      );
      final ext = await rootBundle.load(
        'assets/lily_exercicios/lily_fit_cadeira_extensora.jpeg',
      );
      expect(abd.lengthInBytes, greaterThan(0));
      expect(ext.lengthInBytes, greaterThan(0));
    });

    test('AssetBundle carrega flexora treino_063.jpg', () async {
      final flex = await rootBundle.load(
        'assets/lily_exercicios/treino_063.jpg',
      );
      expect(flex.lengthInBytes, greaterThan(0));
    });
  });
}
