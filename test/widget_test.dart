// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter_test/flutter_test.dart';
import 'package:camera/camera.dart';

import 'package:quiz_automation/main.dart';

void main() {
  testWidgets('MCQ Checker app smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const MCQCheckerApp());

    // Verify that our app title is displayed.
    expect(find.text('MCQ Checker'), findsOneWidget);

    // Verify that camera preview area is present
    expect(
        find.byType(CameraPreview), findsNothing); // Camera not initialized yet

    // Verify that gallery button is present
    expect(find.text('Gallery'), findsOneWidget);
  });
}
