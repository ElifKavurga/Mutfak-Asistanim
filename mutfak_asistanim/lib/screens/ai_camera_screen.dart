import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../services/product_text_ocr_service.dart';
import '../services/tensorflow_kitchen_service.dart';
import '../theme/app_colors.dart';
import '../widgets/camera_action_button.dart';
import '../widgets/dashboard_bottom_nav.dart';
import 'add_product_screen.dart';

class AiCameraScreen extends StatefulWidget {
  const AiCameraScreen({super.key});

  static const String routeName = '/ai-camera';

  @override
  State<AiCameraScreen> createState() => _AiCameraScreenState();
}

class _AiCameraScreenState extends State<AiCameraScreen> {
  static const String _defaultTitle = 'Ürün Taramaya Hazır';
  static const String _defaultDescription =
      'Ürünü ve varsa son kullanma tarihi bilgisini kadraja al. Görsel hazır olduğunda bir sonraki ekranda bilgileri kolayca tamamlayabilirsin.';

  final ImagePicker _imagePicker = ImagePicker();

  bool _isBusy = false;
  Uint8List? _selectedImageBytes;
  _ProductScanDraft? _draft;

  bool get _supportsDirectCameraCapture {
    return kIsWeb ||
        defaultTargetPlatform == TargetPlatform.android ||
        defaultTargetPlatform == TargetPlatform.iOS;
  }

  Future<void> _captureFromCamera() async {
    if (!_supportsDirectCameraCapture) {
      _showFeatureMessage(
        'Bu cihazda doğrudan kamera kullanılamıyor. Galeriden ürün fotoğrafı seçebilir veya bilgileri elle girebilirsin.',
      );
      return;
    }

    await _pickProductImage(
      source: ImageSource.camera,
      productSource: _ProductImageSource.camera,
    );
  }

  Future<void> _pickFromGallery() async {
    await _pickProductImage(
      source: ImageSource.gallery,
      productSource: _ProductImageSource.gallery,
    );
  }

  Future<void> _pickProductImage({
    required ImageSource source,
    required _ProductImageSource productSource,
  }) async {
    if (_isBusy) {
      return;
    }

    final pendingTitle = source == ImageSource.camera
        ? 'Ürün Fotoğrafı Alınıyor'
        : 'Ürün Fotoğrafı Seçiliyor';
    final pendingDescription = source == ImageSource.camera
        ? 'Ürünü ve varsa tarih bilgisini net görünecek şekilde kadraja al.'
        : 'Galeriden ürünün ve tarih bilgisinin net göründüğü bir fotoğraf seç.';

    setState(() {
      _isBusy = true;
      _draft = _draft?.copyWith(
        title: pendingTitle,
        description: pendingDescription,
      );
    });

    try {
      final file = await _imagePicker.pickImage(
        source: source,
        imageQuality: 90,
      );

      if (!mounted) {
        return;
      }

      if (file == null) {
        setState(() {
          _isBusy = false;
        });
        return;
      }

      final bytes = await file.readAsBytes();
      if (!mounted) {
        return;
      }

      final ocrResult = await ProductTextOcrService.instance.readProductText(
        imagePath: file.path,
      );
      if (!mounted) {
        return;
      }

      final analysis = await TensorFlowKitchenService.instance
          .analyzeProductImage(
            imageBytes: bytes,
            imageName: file.name,
            recognizedText: ocrResult.recognizedText,
            ocrDetectedDate: ocrResult.dateText,
            ocrDetectedDateType: ocrResult.dateType,
            ocrInsights: ocrResult.insights,
            ocrAvailabilityNote: ocrResult.availabilityNote,
          );

      if (!mounted) {
        return;
      }

      final draft = _ProductScanDraft(
        title: productSource == _ProductImageSource.camera
            ? 'Ürün Görseli Hazır'
            : 'Galeriden Ürün Seçildi',
        description:
            'Ürün adını ve varsa son kullanma tarihi bilgisini eklemek için devam et.',
        sourceLabel: productSource == _ProductImageSource.camera
            ? 'Kamera ile ürün fotoğrafı alındı'
            : 'Galeriden ürün fotoğrafı seçildi',
        imageBytes: bytes,
        imageName: file.name,
      );

      final enrichedDraft = draft.copyWith(
        title: analysis.summaryTitle,
        description: analysis.summaryDescription,
        analysis: analysis,
      );

      setState(() {
        _selectedImageBytes = bytes;
        _draft = enrichedDraft;
        _isBusy = false;
      });
    } catch (_) {
      if (!mounted) {
        return;
      }

      setState(() {
        _isBusy = false;
      });
      _showFeatureMessage('Ürün görseli alınırken bir sorun oluştu.');
    }
  }

  void _resetDraft() {
    setState(() {
      _selectedImageBytes = null;
      _draft = null;
      _isBusy = false;
    });
  }

  Future<void> _openAddProductDraft() async {
    final draft = _draft;
    if (draft == null) {
      _showFeatureMessage('Önce bir ürün görseli ekle ya da elle giriş yap.');
      return;
    }

    final analysis = draft.analysis;

    final didSave = await Navigator.of(context).push<bool>(
      MaterialPageRoute<bool>(
        builder: (_) => AddProductScreen(
          prefilledProductName: analysis?.productName ?? '',
          prefilledCategory: analysis?.category,
          prefilledDate: analysis?.dateText ?? '',
          initialDateType: analysis?.dateType ?? 'Son Kullanma Tarihi',
          quickSuggestions: analysis?.quickSuggestions ?? const <String>[],
          scanContextTitle: 'Taranan Ürün Görseli',
          scanContextValue: analysis == null
              ? draft.sourceLabel
              : '${draft.sourceLabel} • ${analysis.confidenceLabel}',
          scanHelperText:
              analysis?.summaryDescription ??
              'Ürün adını ve varsa son kullanma tarihini aşağıdan tamamla.',
          scannedImageBytes: draft.imageBytes,
          analysisTitle: analysis == null ? null : 'Görsel ve metin analizi',
          analysisConfidenceLabel: analysis?.confidenceLabel,
          analysisNotes: analysis?.insights ?? const <String>[],
        ),
      ),
    );
    if (didSave == true && mounted) {
      _resetDraft();
      _showFeatureMessage('Urun envantere eklendi.');
    }
  }

  Future<void> _openManualEntry() async {
    final didSave = await Navigator.of(context).push<bool>(
      MaterialPageRoute<bool>(
        builder: (_) => const AddProductScreen(
          scanContextTitle: 'Manuel Ürün Girişi',
          scanContextValue:
              'Ürün bilgilerini kendin girerek envantere ekleyebilirsin.',
          scanHelperText:
              'Ürün adını ve varsa son kullanma tarihini elle gir.',
        ),
      ),
    );
    if (didSave == true && mounted) {
      _showFeatureMessage('Urun envantere eklendi.');
    }
  }

  void _showFeatureMessage(String message) {
    if (!mounted) {
      return;
    }

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final draft = _draft;

    return Scaffold(
      extendBody: true,
      backgroundColor: const Color(0xFF121715),
      appBar: AppBar(
        toolbarHeight: 72,
        leading: IconButton(
          onPressed: () => Navigator.of(context).pop(),
          icon: const Icon(Icons.arrow_back_rounded),
        ),
        title: Text(
          'MutfakAsistanım',
          style: textTheme.titleLarge?.copyWith(
            color: AppColors.primary,
            fontWeight: FontWeight.w800,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            onPressed: () {
              _showFeatureMessage(
                'Ürünün ön yüzünü ve varsa tarih bilgisini aynı karede göstermeye çalış. Barkod okutmana gerek yok.',
              );
            },
            icon: const Icon(Icons.info_outline_rounded),
          ),
          Padding(
            padding: const EdgeInsets.only(right: 10),
            child: IconButton(
              onPressed: () {
                _showFeatureMessage(
                  'Profil ayarlari daha sonra bu ekrana eklenecek.',
                );
              },
              icon: const Icon(Icons.account_circle_rounded),
            ),
          ),
        ],
      ),
      body: SafeArea(
        top: false,
        child: Stack(
          children: [
            const Positioned.fill(child: _ScannerBackdrop()),
            Positioned.fill(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.black.withValues(alpha: 0.08),
                      Colors.transparent,
                      Colors.black.withValues(alpha: 0.28),
                    ],
                  ),
                ),
              ),
            ),
            Positioned(
              left: 20,
              right: 20,
              top: 16,
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 960),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Wrap(
                        spacing: 10,
                        runSpacing: 10,
                        children: const [
                          _StatusPill(
                            icon: Icons.center_focus_strong_rounded,
                            label: 'Ürün Odaklı Tarama',
                          ),
                          _StatusPill(
                            icon: Icons.event_available_rounded,
                            label: 'Tarih Etiketi Desteği',
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Ürünü Tara',
                        style: textTheme.displaySmall?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 8),
                      ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 620),
                        child: Text(
                          'Barkod yerine ürünün kendisini ve varsa tarih bilgisini çek. Görsel hazır olduğunda ürün giriş ekranına geçip eksik bilgileri tamamla.',
                          style: textTheme.bodyLarge?.copyWith(
                            color: Colors.white.withValues(alpha: 0.82),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            Positioned(
              left: 20,
              right: 20,
              top: 170,
              bottom: 270,
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 520),
                  child: _ProductPreviewCard(
                    imageBytes: _selectedImageBytes,
                    imageName: draft?.imageName,
                  ),
                ),
              ),
            ),
            if (_isBusy)
              Positioned.fill(
                child: IgnorePointer(
                  child: ColoredBox(
                    color: Colors.black.withValues(alpha: 0.24),
                    child: const Center(
                      child: CircularProgressIndicator(
                        color: AppColors.primaryContainer,
                      ),
                    ),
                  ),
                ),
              ),
            Positioned(
              left: 20,
              right: 20,
              bottom: 124,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 420,
                    constraints: const BoxConstraints(
                      maxWidth: double.infinity,
                    ),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.93),
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.18),
                      ),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _ScanInfoLeading(imageBytes: _selectedImageBytes),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    draft?.title ?? _defaultTitle,
                                    style: textTheme.titleMedium?.copyWith(
                                      color: AppColors.textPrimary,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    draft?.description ?? _defaultDescription,
                                    style: textTheme.bodySmall?.copyWith(
                                      color: AppColors.textSecondary,
                                    ),
                                  ),
                                  if (draft != null) ...[
                                    const SizedBox(height: 10),
                                    Text(
                                      draft.analysis == null
                                          ? draft.sourceLabel
                                          : '${draft.analysis!.productName} • ${draft.analysis!.confidenceLabel}',
                                      style: textTheme.labelLarge?.copyWith(
                                        color: AppColors.primary,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                    if (draft.analysis?.dateText.isNotEmpty ??
                                        false)
                                      Padding(
                                        padding: const EdgeInsets.only(top: 4),
                                        child: Text(
                                          '${draft.analysis!.dateType}: ${draft.analysis!.dateText}',
                                          style: textTheme.bodySmall?.copyWith(
                                            color: AppColors.textSecondary,
                                          ),
                                        ),
                                      ),
                                  ],
                                ],
                              ),
                            ),
                            const Icon(
                              Icons.chevron_right_rounded,
                              color: AppColors.outline,
                            ),
                          ],
                        ),
                        if (draft != null) ...[
                          const SizedBox(height: 14),
                          Row(
                            children: [
                              Expanded(
                                child: OutlinedButton.icon(
                                  onPressed: _resetDraft,
                                  icon: const Icon(Icons.refresh_rounded),
                                  label: const Text('Yeniden Tara'),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: FilledButton.icon(
                                  onPressed: _openAddProductDraft,
                                  icon: const Icon(Icons.inventory_2_rounded),
                                  label: const Text('Bilgileri Gir'),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(height: 22),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      CameraActionButton(
                        icon: Icons.image_rounded,
                        onPressed: _pickFromGallery,
                      ),
                      CameraActionButton(
                        icon: Icons.photo_camera_rounded,
                        onPressed: _captureFromCamera,
                        large: true,
                      ),
                      CameraActionButton(
                        icon: Icons.edit_note_rounded,
                        onPressed: _openManualEntry,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: const DashboardBottomNav(
        activeTab: DashboardTab.scan,
        showScanTab: true,
      ),
    );
  }
}

class _ScannerBackdrop extends StatelessWidget {
  const _ScannerBackdrop();

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFF253029), Color(0xFF364739), Color(0xFF121715)],
        ),
      ),
      child: Stack(
        fit: StackFit.expand,
        children: [
          Positioned(
            left: -40,
            top: 120,
            child: Container(
              width: 220,
              height: 220,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFFD5E9BF).withValues(alpha: 0.08),
              ),
            ),
          ),
          Positioned(
            right: -30,
            bottom: 180,
            child: Container(
              width: 240,
              height: 240,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withValues(alpha: 0.05),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _StatusPill extends StatelessWidget {
  const _StatusPill({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: Colors.white.withValues(alpha: 0.16)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: AppColors.primaryContainer, size: 18),
          const SizedBox(width: 8),
          Text(
            label,
            style: textTheme.labelMedium?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _ProductPreviewCard extends StatelessWidget {
  const _ProductPreviewCard({
    required this.imageBytes,
    required this.imageName,
  });

  final Uint8List? imageBytes;
  final String? imageName;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return AspectRatio(
      aspectRatio: 3 / 4,
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.06),
          borderRadius: BorderRadius.circular(32),
          border: Border.all(color: Colors.white.withValues(alpha: 0.14)),
          boxShadow: const [
            BoxShadow(
              color: AppColors.shadow,
              blurRadius: 24,
              offset: Offset(0, 18),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(24),
          child: imageBytes == null
              ? DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.white.withValues(alpha: 0.08),
                        Colors.black.withValues(alpha: 0.16),
                      ],
                    ),
                  ),
                  child: Center(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 28),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 112,
                            height: 112,
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.08),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.photo_camera_back_rounded,
                              size: 52,
                              color: AppColors.primaryContainer,
                            ),
                          ),
                          const SizedBox(height: 22),
                          Text(
                            'Ürünü Kadraja Al',
                            textAlign: TextAlign.center,
                            style: textTheme.headlineSmall?.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 10),
                          Text(
                            'Ürün adı ile varsa son kullanma tarihinin görünmesine dikkat et.',
                            textAlign: TextAlign.center,
                            style: textTheme.bodyMedium?.copyWith(
                              color: Colors.white.withValues(alpha: 0.82),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                )
              : Stack(
                  fit: StackFit.expand,
                  children: [
                    Image.memory(imageBytes!, fit: BoxFit.cover),
                    DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.black.withValues(alpha: 0.12),
                            Colors.transparent,
                            Colors.black.withValues(alpha: 0.42),
                          ],
                        ),
                      ),
                    ),
                    Positioned(
                      left: 14,
                      right: 14,
                      bottom: 14,
                      child: Row(
                        children: [
                          Expanded(
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 14,
                                vertical: 10,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.black.withValues(alpha: 0.46),
                                borderRadius: BorderRadius.circular(18),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Görsel hazır',
                                    style: textTheme.labelLarge?.copyWith(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    imageName?.trim().isNotEmpty == true
                                        ? imageName!
                                        : 'Ürün görseli',
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: textTheme.bodySmall?.copyWith(
                                      color: Colors.white.withValues(
                                        alpha: 0.82,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
        ),
      ),
    );
  }
}

class _ScanInfoLeading extends StatelessWidget {
  const _ScanInfoLeading({required this.imageBytes});

  final Uint8List? imageBytes;

  @override
  Widget build(BuildContext context) {
    if (imageBytes != null) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(18),
        child: Image.memory(
          imageBytes!,
          width: 52,
          height: 52,
          fit: BoxFit.cover,
        ),
      );
    }

    return Container(
      width: 52,
      height: 52,
      decoration: BoxDecoration(
        color: AppColors.primaryContainer,
        borderRadius: BorderRadius.circular(18),
      ),
      child: const Icon(
        Icons.center_focus_strong_rounded,
        color: AppColors.primary,
      ),
    );
  }
}

class _ProductScanDraft {
  const _ProductScanDraft({
    required this.title,
    required this.description,
    required this.sourceLabel,
    required this.imageBytes,
    required this.imageName,
    this.analysis,
  });

  final String title;
  final String description;
  final String sourceLabel;
  final Uint8List imageBytes;
  final String imageName;
  final TensorFlowProductScanResult? analysis;

  _ProductScanDraft copyWith({
    String? title,
    String? description,
    String? sourceLabel,
    Uint8List? imageBytes,
    String? imageName,
    TensorFlowProductScanResult? analysis,
  }) {
    return _ProductScanDraft(
      title: title ?? this.title,
      description: description ?? this.description,
      sourceLabel: sourceLabel ?? this.sourceLabel,
      imageBytes: imageBytes ?? this.imageBytes,
      imageName: imageName ?? this.imageName,
      analysis: analysis ?? this.analysis,
    );
  }
}

enum _ProductImageSource { camera, gallery }
