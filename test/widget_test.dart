import 'package:flutter_test/flutter_test.dart';
import 'package:mobile_crossplatform_app/main.dart' as app;

void main() {
  testWidgets('Example smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const app.App());
    expect(find.text('Hello from Example Feature'), findsOneWidget);
  });
}
