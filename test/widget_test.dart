import 'package:flutter_test/flutter_test.dart';

import 'package:fitness_ai/app/app.dart';

void main() {
  testWidgets('Fitness AI app starts', (tester) async {
    await tester.pumpWidget(const FitnessAiApp());

    expect(find.text('FITNESS AI'), findsOneWidget);
    expect(find.text('¿Qué quieres\nmejorar?'), findsOneWidget);
    expect(find.text('CONTINUAR'), findsOneWidget);
  });
}
