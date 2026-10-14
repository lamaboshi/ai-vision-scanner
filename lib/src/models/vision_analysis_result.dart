class VisionLabel {
  const VisionLabel({required this.text, required this.confidence});

  final String text;
  final double confidence;

  String get confidencePercent => '${(confidence * 100).round()}%';
}

class VisionAnalysisResult {
  const VisionAnalysisResult({
    required this.recognizedText,
    required this.labels,
  });

  final String recognizedText;
  final List<VisionLabel> labels;

  bool get hasText => recognizedText.trim().isNotEmpty;
  bool get hasLabels => labels.isNotEmpty;
}
