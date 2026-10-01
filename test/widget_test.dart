import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:oms/main.dart';

void main() {
  testWidgets('OmsApp smoke test', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1280, 800);
    tester.view.devicePixelRatio = 1.0;

    await tester.pumpWidget(const OmsApp());
    await tester.pumpAndSettle();

    expect(find.text('Leaves'), findsWidgets);

    addTearDown(tester.view.resetPhysicalSize);
  });
}
