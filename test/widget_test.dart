import 'package:flutter_test/flutter_test.dart';

import 'package:foodly_ai/app.dart';
import 'package:foodly_ai/features/auth/data/auth_session.dart';

void main() {
  testWidgets('Foodly AI shows sign in when no stored session exists', (tester) async {
    await tester.pumpWidget(FoodlyApp(authSession: _LoggedOutSession()));
    await tester.pump(const Duration(milliseconds: 1800));
    await tester.pumpAndSettle();

    expect(find.text('Welcome back'), findsOneWidget);
  });
}

class _LoggedOutSession extends AuthSession {
  @override
  Future<AuthUser?> restoreSession() async => null;
}
