import 'package:google_mlkit_image_labeling/google_mlkit_image_labeling.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';

import '../models/vision_analysis_result.dart';

class VisionAnalyzer {
  VisionAnalyzer({TextRecognizer? textRecognizer, ImageLabeler? imageLabeler})
    : _textRecognizer =
          textRecognizer ?? TextRecognizer(script: TextRecognitionScript.latin),
      _imageLabeler =
          imageLabeler ??
          ImageLabeler(options: ImageLabelerOptions(confidenceThreshold: 0.5));

  final TextRecognizer _textRecognizer;
  final ImageLabeler _imageLabeler;

  Future<VisionAnalysisResult> analyzeImage(String imagePath) async {
    final inputImage = InputImage.fromFilePath(imagePath);
    final recognizedText = await _textRecognizer.processImage(inputImage);
    final labels = await _imageLabeler.processImage(inputImage);

    final sortedLabels =
        labels
            .map(
              (label) =>
                  VisionLabel(text: label.label, confidence: label.confidence),
            )
            .toList()
          ..sort((a, b) => b.confidence.compareTo(a.confidence));

    return VisionAnalysisResult(
      recognizedText: recognizedText.text.trim(),
      labels: sortedLabels,
    );
  }

  Future<void> dispose() async {
    await _textRecognizer.close();
    await _imageLabeler.close();
  }
}
