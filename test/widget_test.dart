import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:video_surf_app/screen/initial_screen.dart';

void main() {
  testWidgets('InitialScreen displays welcome text', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const MaterialApp(home: InitialScreen()));

    expect(find.text('Bem vindo!'), findsOneWidget);
  });
}
