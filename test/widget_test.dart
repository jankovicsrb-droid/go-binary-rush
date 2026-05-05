import 'package:flutter_test/flutter_test.dart';
import 'package:binary_game/main.dart';

void main() {
  testWidgets('App smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const BinaryRushApp());
    expect(find.text('TARGET'), findsOneWidget);
  });
}
