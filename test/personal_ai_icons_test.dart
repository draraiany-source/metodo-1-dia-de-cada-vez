import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:metodo_1_dia/core/assets/app_icons.dart';
import 'package:metodo_1_dia/core/assets/personal_ai_icons.dart';
import 'package:metodo_1_dia/core/widgets/feature_icon_card.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('PersonalAiIcons: os 10 PNGs existem no bundle', () async {
    expect(PersonalAiIcons.assets.length, 10);
    expect(PersonalAiIcons.personalAiIcons.length, 10);

    for (final path in PersonalAiIcons.assets) {
      expect(path.startsWith('assets/icons/personal-ai/'), isTrue, reason: path);
      expect(path.toLowerCase(), path, reason: 'nome em minúsculas: $path');
      final data = await rootBundle.load(path);
      expect(data.lengthInBytes, greaterThan(1000), reason: path);
    }
  });

  test('AppIcons aliases apontam para o pacote Personal-IA', () {
    expect(AppIcons.chatAmanda, PersonalAiIcons.chatAmanda);
    expect(AppIcons.agendaConsultoria, PersonalAiIcons.agendaConsultoria);
    expect(AppIcons.areaPersonal, PersonalAiIcons.areaPersonal);
    expect(AppIcons.anamnese, PersonalAiIcons.anamnese);
    expect(AppIcons.analisarIA, PersonalAiIcons.analisarIA);
    expect(AppIcons.assistenteIA, PersonalAiIcons.assistenteIA);
    expect(AppIcons.insightsIA, PersonalAiIcons.insightsIA);
    expect(AppIcons.sugestaoResposta, PersonalAiIcons.sugestaoResposta);
    expect(AppIcons.resumoConversa, PersonalAiIcons.resumoConversa);
    expect(AppIcons.pontosAtencao, PersonalAiIcons.pontosAtencao);
    expect(AppIcons.personal, isNot(PersonalAiIcons.areaPersonal));
  });

  testWidgets('FeatureIconCard renderiza título e dispara onPress', (tester) async {
    var tapped = false;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: FeatureIconCard(
            icon: PersonalAiIcons.chatAmanda,
            title: 'Fale com Amanda',
            subtitle: 'Chat com a Personal',
            onPress: () => tapped = true,
          ),
        ),
      ),
    );

    expect(find.text('Fale com Amanda'), findsOneWidget);
    expect(find.text('Chat com a Personal'), findsOneWidget);
    await tester.tap(find.byType(FeatureIconCard));
    expect(tapped, isTrue);
  });
}
