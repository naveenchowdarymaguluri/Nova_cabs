import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nova_cabs/main.dart';

void main() {
  testWidgets('Nova Cabs app smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(
      const ProviderScope(child: NovaCabsApp()),
    );
    expect(find.text('NOVA CABS'), findsOneWidget);
  });
}
