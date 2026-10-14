import 'package:flutter/material.dart';

import 'src/screens/scanner_screen.dart';
import 'src/theme/app_theme.dart';

void main() {
  runApp(const AiVisionScannerApp());
}

class AiVisionScannerApp extends StatelessWidget {
  const AiVisionScannerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'AI Vision Scanner',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(),
      darkTheme: AppTheme.dark(),
      home: const ScannerScreen(),
    );
  }
}
