import 'package:flutter_test/flutter_test.dart';

import 'package:foodly_ai/app.dart';

void main() {
  testWidgets('Foodly AI starts', (tester) async {
    await tester.pumpWidget(const FoodlyApp());

    expect(find.text('Foodly AI'), findsOneWidget);
  });
}