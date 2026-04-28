import 'package:crisp_weather/main.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('App smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const CrispWeatherApp());
    expect(find.byType(AppShell), findsOneWidget);
  });
}
