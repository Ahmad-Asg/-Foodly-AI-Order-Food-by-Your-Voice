import 'package:flutter_test/flutter_test.dart';

import 'package:foodly_ai/app.dart';

void main() {
  testWidgets('Foodly AI starts', (tester) async {
    await tester.pumpWidget(const FoodlyApp());
    await tester.pump(const Duration(milliseconds: 1800));

    expect(find.text('Meet Foodly AI'), findsOneWidget);
  });
}
