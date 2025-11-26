// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:aarogyan/main.dart';

void main() {
  testWidgets('App builds without errors', (WidgetTester tester) async {
    // Build the app and ensure it renders.
    await tester.pumpWidget(const AarogyanApp());
    await tester.pumpAndSettle();

    // Verify the app widget exists in the tree.
    expect(find.byType(AarogyanApp), findsOneWidget);
  });
}
