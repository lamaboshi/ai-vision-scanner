import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';

import '../models/vision_analysis_result.dart';
import '../services/vision_analyzer.dart';
import '../widgets/section_card.dart';

class ScannerScreen extends StatefulWidget {
  const ScannerScreen({super.key, this.imagePicker, this.visionAnalyzer});

  final ImagePicker? imagePicker;
  final VisionAnalyzer? visionAnalyzer;

  @override
  State<ScannerScreen> createState() => _ScannerScreenState();
}

class _ScannerScreenState extends State<ScannerScreen> {
  late final ImagePicker _imagePicker;
  late final VisionAnalyzer _visionAnalyzer;

  XFile? _selectedImage;
  VisionAnalysisResult? _result;
  bool _isPicking = false;
  bool _isAnalyzing = false;
  String? _errorMessage;

  bool get _isBusy => _isPicking || _isAnalyzing;

  @override
  void initState() {
    super.initState();
    _imagePicker = widget.imagePicker ?? ImagePicker();
    _visionAnalyzer = widget.visionAnalyzer ?? VisionAnalyzer();
  }

  @override
  void dispose() {
    _visionAnalyzer.dispose();
    super.dispose();
  }

  Future<void> _pickAndAnalyze(ImageSource source) async {
    if (_isBusy) return;

    try {
      setState(() {
        _isPicking = true;
        _errorMessage = null;
      });

      final pickedImage = await _imagePicker.pickImage(
        source: source,
        imageQuality: 92,
        maxWidth: 2400,
      );

      if (pickedImage == null) {
        if (!mounted) return;
        setState(() {
          _isPicking = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Image selection cancelled.')),
        );
        return;
      }

      setState(() {
        _selectedImage = pickedImage;
        _result = null;
        _errorMessage = null;
        _isPicking = false;
        _isAnalyzing = true;
      });

      final result = await _visionAnalyzer.analyzeImage(pickedImage.path);
      if (!mounted) return;
      setState(() {
        _result = result;
        _isAnalyzing = false;
      });
    } on PlatformException catch (error) {
      if (!mounted) return;
      setState(() {
        _isPicking = false;
        _isAnalyzing = false;
        _errorMessage = _friendlyPickerError(error);
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _isPicking = false;
        _isAnalyzing = false;
        _errorMessage =
            'Unable to analyze this image. Try another photo with clearer content.';
      });
    }
  }

  String _friendlyPickerError(PlatformException error) {
    final code = error.code.toLowerCase();
    if (code.contains('permission') || code.contains('denied')) {
      return 'Permission was denied. Enable camera or photo access in Android settings and try again.';
    }
    return error.message ?? 'Image selection failed. Please try again.';
  }

  Future<void> _copyText() async {
    final text = _result?.recognizedText.trim();
    if (text == null || text.isEmpty) return;
    await Clipboard.setData(ClipboardData(text: text));
    if (!mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Recognized text copied.')));
  }

  void _clearImage() {
    if (_isBusy) return;
    setState(() {
      _selectedImage = null;
      _result = null;
      _errorMessage = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    final maxWidth = size.width >= 840 ? 760.0 : double.infinity;

    return Scaffold(
      appBar: AppBar(
        title: const Text('AI Vision Scanner'),
        actions: [
          if (_selectedImage != null)
            IconButton(
              tooltip: 'Analyze another image',
              onPressed: _isBusy ? null : _clearImage,
              icon: const Icon(Icons.refresh_rounded),
            ),
        ],
      ),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: maxWidth),
            child: ListView(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
              children: [
                _Header(isBusy: _isBusy),
                const SizedBox(height: 18),
                _ActionPanel(
                  isBusy: _isBusy,
                  onCamera: () => _pickAndAnalyze(ImageSource.camera),
                  onGallery: () => _pickAndAnalyze(ImageSource.gallery),
                ),
                const SizedBox(height: 18),
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 250),
                  child: _selectedImage == null
                      ? const _EmptyImageState()
                      : _ImagePreview(imagePath: _selectedImage!.path),
                ),
                if (_isAnalyzing) ...[
                  const SizedBox(height: 18),
                  const _LoadingState(),
                ],
                if (_errorMessage != null) ...[
                  const SizedBox(height: 18),
                  _ErrorState(message: _errorMessage!),
                ],
                if (_result != null) ...[
                  const SizedBox(height: 18),
                  _Results(result: _result!, onCopyText: _copyText),
                ],
                const SizedBox(height: 18),
                const _AboutSection(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({required this.isBusy});

  final bool isBusy;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        gradient: LinearGradient(
          colors: [colors.primary, colors.tertiary],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.document_scanner_rounded,
            color: colors.onPrimary,
            size: 38,
          ),
          const SizedBox(height: 18),
          Text(
            'On-device text and image understanding',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              color: colors.onPrimary,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            'Pick or capture a photo to extract Latin-script text and detect visual labels using Google ML Kit on Android.',
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              color: colors.onPrimary.withValues(alpha: 0.88),
              height: 1.45,
            ),
          ),
          if (isBusy) ...[
            const SizedBox(height: 18),
            LinearProgressIndicator(
              backgroundColor: colors.onPrimary.withValues(alpha: 0.24),
              color: colors.onPrimary,
            ),
          ],
        ],
      ),
    );
  }
}

class _ActionPanel extends StatelessWidget {
  const _ActionPanel({
    required this.isBusy,
    required this.onCamera,
    required this.onGallery,
  });

  final bool isBusy;
  final VoidCallback onCamera;
  final VoidCallback onGallery;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final stacked = constraints.maxWidth < 520;
        final cameraButton = FilledButton.icon(
          onPressed: isBusy ? null : onCamera,
          icon: const Icon(Icons.photo_camera_rounded),
          label: const Text('Camera'),
        );
        final galleryButton = OutlinedButton.icon(
          onPressed: isBusy ? null : onGallery,
          icon: const Icon(Icons.photo_library_rounded),
          label: const Text('Gallery'),
        );

        if (stacked) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [cameraButton, const SizedBox(height: 12), galleryButton],
          );
        }

        return Row(
          children: [
            Expanded(child: cameraButton),
            const SizedBox(width: 12),
            Expanded(child: galleryButton),
          ],
        );
      },
    );
  }
}

class _EmptyImageState extends StatelessWidget {
  const _EmptyImageState();

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return SectionCard(
      title: 'Ready to scan',
      icon: Icons.image_search_rounded,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 28, horizontal: 18),
        decoration: BoxDecoration(
          color: colors.surface.withValues(alpha: 0.7),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: colors.outlineVariant),
        ),
        child: Column(
          children: [
            Icon(
              Icons.add_photo_alternate_rounded,
              size: 52,
              color: colors.primary,
            ),
            const SizedBox(height: 12),
            Text(
              'Choose a clear image with text or recognizable objects.',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyLarge,
            ),
          ],
        ),
      ),
    );
  }
}

class _ImagePreview extends StatelessWidget {
  const _ImagePreview({required this.imagePath});

  final String imagePath;

  @override
  Widget build(BuildContext context) {
    return SectionCard(
      title: 'Selected image',
      icon: Icons.image_rounded,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: AspectRatio(
          aspectRatio: 4 / 3,
          child: Image.file(File(imagePath), fit: BoxFit.cover),
        ),
      ),
    );
  }
}

class _LoadingState extends StatelessWidget {
  const _LoadingState();

  @override
  Widget build(BuildContext context) {
    return SectionCard(
      title: 'Analyzing locally',
      icon: Icons.auto_awesome_rounded,
      child: Row(
        children: [
          const SizedBox(
            width: 24,
            height: 24,
            child: CircularProgressIndicator(strokeWidth: 3),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Text(
              'Running ML Kit text recognition and image labeling on this device.',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ),
        ],
      ),
    );
  }
}

class _ErrorState extends StatelessWidget {
  const _ErrorState({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return SectionCard(
      title: 'Something went wrong',
      icon: Icons.error_outline_rounded,
      child: Text(message, style: TextStyle(color: colors.error)),
    );
  }
}

class _Results extends StatelessWidget {
  const _Results({required this.result, required this.onCopyText});

  final VisionAnalysisResult result;
  final VoidCallback onCopyText;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SectionCard(
          title: 'Recognized text',
          icon: Icons.text_fields_rounded,
          action: IconButton(
            tooltip: 'Copy recognized text',
            onPressed: result.hasText ? onCopyText : null,
            icon: const Icon(Icons.copy_rounded),
          ),
          child: result.hasText
              ? SelectableText(result.recognizedText)
              : const Text('No Latin-script text was detected in this image.'),
        ),
        const SizedBox(height: 18),
        SectionCard(
          title: 'Image labels',
          icon: Icons.category_rounded,
          child: result.hasLabels
              ? Column(
                  children: result.labels
                      .map((label) => _LabelTile(label: label))
                      .toList(growable: false),
                )
              : const Text('No confident labels were detected.'),
        ),
      ],
    );
  }
}

class _LabelTile extends StatelessWidget {
  const _LabelTile({required this.label});

  final VisionLabel label;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  label.text,
                  style: const TextStyle(fontWeight: FontWeight.w700),
                ),
              ),
              Text(
                label.confidencePercent,
                style: TextStyle(
                  color: colors.primary,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          LinearProgressIndicator(
            value: label.confidence.clamp(0, 1),
            minHeight: 8,
            borderRadius: BorderRadius.circular(99),
          ),
        ],
      ),
    );
  }
}

class _AboutSection extends StatelessWidget {
  const _AboutSection();

  @override
  Widget build(BuildContext context) {
    return const SectionCard(
      title: 'About this project',
      icon: Icons.privacy_tip_rounded,
      child: Text(
        'Built with Flutter, Material 3, image_picker, and Google ML Kit. Images are processed locally for Latin text recognition and image labeling; this is ML-based recognition, not generative AI. ML Kit may download required on-device models on first use, so offline behavior should be verified after those models are available.',
      ),
    );
  }
}
