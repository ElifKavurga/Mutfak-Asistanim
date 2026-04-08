import 'package:flutter_test/flutter_test.dart';
import 'package:mutfak_asistanim/main.dart';

void main() {
  testWidgets('intro flow renders splash and onboarding', (tester) async {
    await tester.pumpWidget(const KitchenAssistantApp());

    expect(find.text('MutfakAsistanım'), findsOneWidget);
    expect(find.text('Akıllı mutfak deneyimi'), findsOneWidget);

    await tester.pump(const Duration(milliseconds: 2300));
    await tester.pumpAndSettle();

    expect(find.text('İsrafı Önle'), findsOneWidget);
  });
}
