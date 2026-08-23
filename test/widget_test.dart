import 'package:flutter_test/flutter_test.dart';

import 'package:fitness_ai/main.dart';

void main() {
  testWidgets('Fitness AI app starts', (tester) async {
    await tester.pumpWidget(const FitnessAiApp());

    expect(find.text('Fitness AI'), findsOneWidget);
  });
}
