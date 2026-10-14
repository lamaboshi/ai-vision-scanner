import 'package:ai_vision_scanner/main.dart';
import 'package:ai_vision_scanner/src/models/vision_analysis_result.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('VisionLabel formats confidence as a whole percentage', () {
    const label = VisionLabel(text: 'Document', confidence: 0.876);

    expect(label.confidencePercent, '88%');
  });

  test('VisionAnalysisResult exposes empty-state helpers', () {
    const empty = VisionAnalysisResult(recognizedText: '   ', labels: []);
    const populated = VisionAnalysisResult(
      recognizedText: 'Hello',
      labels: [VisionLabel(text: 'Text', confidence: 0.9)],
    );

    expect(empty.hasText, isFalse);
    expect(empty.hasLabels, isFalse);
    expect(populated.hasText, isTrue);
    expect(populated.hasLabels, isTrue);
  });

  testWidgets('App renders scanner actions and about section', (tester) async {
    await tester.pumpWidget(const AiVisionScannerApp());

    expect(find.text('AI Vision Scanner'), findsOneWidget);
    expect(find.byIcon(Icons.photo_camera_rounded), findsOneWidget);
    expect(find.byIcon(Icons.photo_library_rounded), findsOneWidget);
    await tester.drag(find.byType(ListView), const Offset(0, -500));
    await tester.pumpAndSettle();
    expect(find.text('About this project'), findsOneWidget);
  });

  testWidgets('Scanner actions lay out on a narrow screen', (tester) async {
    await tester.binding.setSurfaceSize(const Size(360, 740));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(const AiVisionScannerApp());

    expect(tester.takeException(), isNull);
    expect(find.text('Camera'), findsOneWidget);
    expect(find.text('Gallery'), findsOneWidget);
  });
}
