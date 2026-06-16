import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nova_cabs/main.dart';
import 'package:nova_cabs/features/splash/splash_screen.dart';

void main() {
  testWidgets('Nova Cabs app smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(
      const ProviderScope(child: NovaCabsApp()),
    );
    expect(find.byType(SplashScreen), findsOneWidget);
  });
}
