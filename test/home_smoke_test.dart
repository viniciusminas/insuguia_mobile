import 'package:flutter_test/flutter_test.dart';
import 'package:insuguia_mobile/main.dart';

void main() {
  testWidgets('Home exibe título e botões principais', (tester) async {
    await tester.pumpWidget(const MyApp());
    expect(find.text('InsuGuia — Protótipo Didático'), findsOneWidget);
    expect(find.text('Novo paciente'), findsOneWidget);
    expect(find.text('Sobre'), findsOneWidget);
  });

  testWidgets('Fluxo: Novo paciente -> Sugestão', (tester) async {
    await tester.pumpWidget(const MyApp());

    await tester.tap(find.text('Novo paciente'));
    await tester.pumpAndSettle();

    await tester.enterText(find.bySemanticsLabel('Nome (fictício)'), 'João');
    await tester.enterText(find.bySemanticsLabel('Peso (kg)'), '80,5');

    await tester.tap(find.text('Gerar sugestão (simulado)'));
    await tester.pumpAndSettle();

    expect(find.textContaining('Sugestão (SIMULADO)'), findsOneWidget);
    expect(find.textContaining('João'), findsOneWidget);
  });
}
