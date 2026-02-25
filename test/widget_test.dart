import 'package:flutter_test/flutter_test.dart';
import 'package:quick_care_ai/main.dart';

void main() {
  testWidgets('QuickCare AI Smoke Test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const QuickCareAI());

    // Verify that the splash screen shows the app name
    expect(find.text('QuickCare'), findsOneWidget);
    expect(find.text('AI'), findsOneWidget);
  });
}
