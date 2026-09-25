import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:school_managements/main.dart';

void main() {
  testWidgets('Desktop ERP App Shell Smoke Test', (WidgetTester tester) async {
    // Configure standard desktop screen resolution
    tester.view.physicalSize = const Size(1920, 1080);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);

    await tester.pumpWidget(const SchoolErpApp());
    await tester.pump();

    expect(find.byType(SchoolErpApp), findsOneWidget);
    expect(find.text('Oakridge ERP'), findsOneWidget);
    expect(find.text('Administrator'), findsWidgets);
    expect(find.text('PostgreSQL Connected'), findsOneWidget);
  });
}
