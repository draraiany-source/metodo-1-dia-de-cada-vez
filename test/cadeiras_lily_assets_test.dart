import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:metodo_1_dia/core/lily/lily_exercicio_assets.dart';

/// Guarda mínima: cadeiras abdutora/extensora (treino_046 / treino_034)
/// devem resolver para os JPEG Lily Fit e carregar do asset bundle.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const abdPath = 'assets/lily_exercicios/lily_fit_cadeira_abdutora.jpeg';
  const extPath = 'assets/lily_exercicios/lily_fit_cadeira_extensora.jpeg';
  const flexPath = 'assets/lily_exercicios/treino_063.jpg';

  test('treino_046 → abdutora e treino_034 → extensora', () {
    expect(LilyExercicioAssets.pathForId('treino_046'), abdPath);
    expect(LilyExercicioAssets.pathForId('treino_034'), extPath);
    expect(LilyExercicioAssets.pathForId('treino_063'), flexPath);
  });

  testWidgets('JPEG abdutora e extensora carregam do bundle', (tester) async {
    for (final path in [abdPath, extPath]) {
      final data = await rootBundle.load(path);
      expect(
        data.lengthInBytes,
        greaterThan(10 * 1024),
        reason: '$path ausente ou vazio no bundle',
      );
    }
  });
}
