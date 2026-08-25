import 'package:flutter_test/flutter_test.dart';
import 'package:tabibi_app/main.dart';

void main() {
  testWidgets('TABIBI app starts', (WidgetTester tester) async {
    await tester.pumpWidget(const TabibiApp());
    await tester.pump();
  });
}
