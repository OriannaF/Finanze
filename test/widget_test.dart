import 'package:flutter_test/flutter_test.dart';
import 'package:finanze_app/main.dart';

void main() {
  testWidgets('App renders without error', (WidgetTester tester) async {
    await tester.pumpWidget(const FinanzeApp());
    expect(find.byType(FinanzeApp), findsOneWidget);
  });
}
