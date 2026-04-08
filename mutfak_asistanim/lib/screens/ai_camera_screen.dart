import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../theme/app_colors.dart';
import '../widgets/camera_action_button.dart';
import '../widgets/dashboard_bottom_nav.dart';
import '../widgets/detection_box.dart';
import '../widgets/scan_overlay.dart';

class AiCameraScreen extends StatefulWidget {
  const AiCameraScreen({super.key});

  static const String routeName = '/ai-camera';

  @override
  State<AiCameraScreen> createState() => _AiCameraScreenState();
}

class _AiCameraScreenState extends State<AiCameraScreen>
    with WidgetsBindingObserver {
  final ImagePicker _imagePicker = ImagePicker();

  CameraController? _cameraController;
  List<CameraDescription> _cameras = const [];
  int _selectedCameraIndex = 0;
  bool _isInitializing = true;
  bool _isBusy = false;
  bool _isFlashOn = false;
  String? _cameraError;
  String _analysisTitle = '3 Malzeme Tanındı';
  String _analysisDescription =
      'Canlı önizleme hazır. Backend bağlandığında analiz sonuçları burada gösterilecek.';

  bool get _supportsCameraPlatform {
    return kIsWeb ||
        defaultTargetPlatform == TargetPlatform.android ||
        defaultTargetPlatform == TargetPlatform.iOS;
  }

  bool get _isCameraReady {
    final controller = _cameraController;
    return controller != null &&
        controller.value.isInitialized &&
        !_isInitializing &&
        _cameraError == null;
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _initializeCameraSetup();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _disposeCameraController();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (!_supportsCameraPlatform || _cameras.isEmpty) {
      return;
    }

    final controller = _cameraController;
    if (controller == null || !controller.value.isInitialized) {
      return;
    }

    if (state == AppLifecycleState.inactive) {
      _disposeCameraController();
    } else if (state == AppLifecycleState.resumed) {
      _initializeCameraController(_selectedCameraIndex);
    }
  }

  void _disposeCameraController() {
    final controller = _cameraController;
    _cameraController = null;
    controller?.dispose();
  }

  Future<void> _initializeCameraSetup() async {
    if (!_supportsCameraPlatform) {
      setState(() {
        _isInitializing = false;
        _cameraError =
            'Canlı kamera önizlemesi bu platformda desteklenmiyor.';
      });
      return;
    }

    setState(() {
      _isInitializing = true;
      _cameraError = null;
    });

    try {
      final cameras = await availableCameras();
      if (cameras.isEmpty) {
        setState(() {
          _isInitializing = false;
          _cameraError = 'Kullanılabilir kamera bulunamadı.';
        });
        return;
      }

      _cameras = cameras;
      _selectedCameraIndex = cameras.indexWhere(
        (camera) => camera.lensDirection == CameraLensDirection.back,
      );
      if (_selectedCameraIndex < 0) {
        _selectedCameraIndex = 0;
      }

      await _initializeCameraController(_selectedCameraIndex);
    } on CameraException catch (error) {
      if (!mounted) {
        return;
      }

      setState(() {
        _isInitializing = false;
        _cameraError = _cameraMessageFromCode(error.code);
      });
    } catch (_) {
      if (!mounted) {
        return;
      }

      setState(() {
        _isInitializing = false;
        _cameraError = 'Kamera başlatılırken beklenmeyen bir sorun oluştu.';
      });
    }
  }

  Future<void> _initializeCameraController(int cameraIndex) async {
    if (_cameras.isEmpty) {
      return;
    }

    final previousController = _cameraController;
    if (mounted) {
      setState(() {
        _isInitializing = true;
        _cameraError = null;
      });
    }

    _cameraController = null;
    await previousController?.dispose();

    final controller = CameraController(
      _cameras[cameraIndex],
      ResolutionPreset.high,
      enableAudio: false,
      imageFormatGroup: ImageFormatGroup.jpeg,
    );

    _cameraController = controller;

    try {
      await controller.initialize();
      await controller.setFlashMode(_isFlashOn ? FlashMode.torch : FlashMode.off);
      if (!mounted) {
        return;
      }

      setState(() {
        _selectedCameraIndex = cameraIndex;
        _isInitializing = false;
      });
    } on CameraException catch (error) {
      if (!mounted) {
        return;
      }

      setState(() {
        _isInitializing = false;
        _cameraError = _cameraMessageFromCode(error.code);
      });
    }
  }

  Future<void> _toggleFlash() async {
    final controller = _cameraController;
    if (controller == null || !controller.value.isInitialized) {
      _showFeatureMessage('Flaş yalnızca aktif kamera ile kullanılabilir.');
      return;
    }

    final nextFlashState = !_isFlashOn;
    try {
      await controller.setFlashMode(
        nextFlashState ? FlashMode.torch : FlashMode.off,
      );
      if (!mounted) {
        return;
      }

      setState(() {
        _isFlashOn = nextFlashState;
      });
    } on CameraException {
      _showFeatureMessage('Flaş şu anda değiştirilemiyor.');
    }
  }

  Future<void> _flipCamera() async {
    if (_cameras.length < 2) {
      _showFeatureMessage('Bu cihazda ikinci kamera bulunamadı.');
      return;
    }

    final nextIndex = (_selectedCameraIndex + 1) % _cameras.length;
    await _initializeCameraController(nextIndex);
  }

  Future<void> _captureImage() async {
    final controller = _cameraController;
    if (controller == null ||
        !controller.value.isInitialized ||
        controller.value.isTakingPicture ||
        _isBusy) {
      _showFeatureMessage('Kamera hazır olduğunda yeniden deneyin.');
      return;
    }

    setState(() {
      _isBusy = true;
    });

    try {
      final file = await controller.takePicture();
      if (!mounted) {
        return;
      }

      final fileName = file.name.isNotEmpty ? file.name : 'Görüntü';
      setState(() {
        _analysisTitle = 'Görüntü Hazır';
        _analysisDescription =
            '$fileName kaydedildi. Backend bağlandığında ürün analizi burada gösterilecek.';
      });
    } on CameraException {
      _showFeatureMessage('Fotoğraf alınırken bir sorun oluştu.');
    } finally {
      if (mounted) {
        setState(() {
          _isBusy = false;
        });
      }
    }
  }

  Future<void> _pickFromGallery() async {
    if (_isBusy) {
      return;
    }

    setState(() {
      _isBusy = true;
    });

    try {
      final file = await _imagePicker.pickImage(source: ImageSource.gallery);
      if (!mounted || file == null) {
        return;
      }

      setState(() {
        _analysisTitle = 'Galeri Görseli Seçildi';
        _analysisDescription =
            '${file.name} hazır. Backend bağlandığında ürün analizi burada gösterilecek.';
      });
    } catch (_) {
      _showFeatureMessage('Galeriden görsel seçilirken bir sorun oluştu.');
    } finally {
      if (mounted) {
        setState(() {
          _isBusy = false;
        });
      }
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

  String _cameraMessageFromCode(String code) {
    switch (code) {
      case 'CameraAccessDenied':
        return 'Kamera erişimi reddedildi. Ayarlardan izin vermeniz gerekiyor.';
      case 'CameraAccessDeniedWithoutPrompt':
        return 'Kamera izni daha önce reddedildi. Ayarlardan izin açılmalı.';
      case 'CameraAccessRestricted':
        return 'Kamera erişimi bu cihazda kısıtlanmış.';
      case 'AudioAccessDenied':
        return 'Mikrofon erişimi reddedildi. Ses kullanmıyoruz ancak cihaz izin isteyebilir.';
      default:
        return 'Kamera başlatılırken bir sorun oluştu.';
    }
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      extendBody: true,
      backgroundColor: Colors.black,
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
            onPressed: _toggleFlash,
            icon: Icon(
              _isFlashOn ? Icons.flash_on_rounded : Icons.flash_off_rounded,
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(right: 10),
            child: IconButton(
              onPressed: () {
                _showFeatureMessage('Profil ayarları daha sonra bağlanacak.');
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
            Positioned.fill(child: _buildCameraLayer()),
            if (_cameraError == null)
              const Positioned.fill(child: IgnorePointer(child: ScanOverlay())),
            if (_isCameraReady)
              Positioned.fill(
                child: IgnorePointer(
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      return Stack(
                        children: [
                          DetectionBox(
                            label: 'Kırmızı Elma %98',
                            width: constraints.maxWidth * 0.26,
                            height: constraints.maxWidth * 0.26,
                            left: constraints.maxWidth * 0.16,
                            top: constraints.maxHeight * 0.20,
                          ),
                          DetectionBox(
                            label: 'Taze Marul %94',
                            width: constraints.maxWidth * 0.30,
                            height: constraints.maxHeight * 0.22,
                            left: constraints.maxWidth * 0.56,
                            top: constraints.maxHeight * 0.42,
                          ),
                          DetectionBox(
                            label: 'Domates %91',
                            width: constraints.maxWidth * 0.18,
                            height: constraints.maxWidth * 0.18,
                            left: constraints.maxWidth * 0.40,
                            top: constraints.maxHeight * 0.34,
                          ),
                        ],
                      );
                    },
                  ),
                ),
              ),
            Positioned(
              top: 20,
              right: 18,
              child: Column(
                children: [
                  _HudButton(
                    icon: Icons.settings_voice_rounded,
                    onTap: () {
                      _showFeatureMessage(
                        'Sesli yönlendirme arayüzü hazır, işlev daha sonra bağlanacak.',
                      );
                    },
                  ),
                  const SizedBox(height: 10),
                  _HudButton(
                    icon: Icons.info_rounded,
                    onTap: () {
                      _showFeatureMessage(
                        'Kamerayı ürüne yaklaştırın ve çekim düğmesine basın.',
                      );
                    },
                  ),
                  const SizedBox(height: 10),
                  _HudButton(
                    icon: Icons.history_rounded,
                    onTap: () {
                      _showFeatureMessage(
                        'Tarama geçmişi backend hazır olduğunda gösterilecek.',
                      );
                    },
                  ),
                ],
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
                    constraints: const BoxConstraints(maxWidth: double.infinity),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.9),
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.2),
                      ),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 52,
                          height: 52,
                          decoration: BoxDecoration(
                            color: AppColors.primaryContainer,
                            borderRadius: BorderRadius.circular(18),
                          ),
                          child: Icon(
                            _cameraError == null
                                ? Icons.auto_awesome_rounded
                                : Icons.info_outline_rounded,
                            color: AppColors.primary,
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                _cameraError == null
                                    ? _analysisTitle
                                    : 'Kamera Hazır Değil',
                                style: textTheme.titleMedium?.copyWith(
                                  color: AppColors.textPrimary,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                _cameraError ?? _analysisDescription,
                                style: textTheme.bodySmall?.copyWith(
                                  color: AppColors.textSecondary,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const Icon(
                          Icons.chevron_right_rounded,
                          color: AppColors.outline,
                        ),
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
                        icon: Icons.camera_alt_rounded,
                        onPressed: _captureImage,
                        large: true,
                      ),
                      CameraActionButton(
                        icon: Icons.flip_camera_ios_rounded,
                        onPressed: _flipCamera,
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

  Widget _buildCameraLayer() {
    final controller = _cameraController;

    if (_cameraError != null) {
      return _FallbackCameraViewport(message: _cameraError!);
    }

    if (_isInitializing || controller == null || !controller.value.isInitialized) {
      return const Stack(
        fit: StackFit.expand,
        children: [
          _FallbackCameraViewport(
            message: 'Kamera hazırlanıyor. Lütfen bekleyin.',
          ),
          Center(
            child: CircularProgressIndicator(
              color: AppColors.primaryContainer,
            ),
          ),
        ],
      );
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final previewSize = controller.value.previewSize;
        if (previewSize == null) {
          return const _FallbackCameraViewport(
            message: 'Kamera önizlemesi hazırlanamadı.',
          );
        }

        final previewAspectRatio = previewSize.height / previewSize.width;
        final screenAspectRatio = constraints.maxHeight / constraints.maxWidth;

        return ClipRect(
          child: Stack(
            fit: StackFit.expand,
            children: [
              OverflowBox(
                alignment: Alignment.center,
                maxWidth: screenAspectRatio > previewAspectRatio
                    ? constraints.maxHeight / previewAspectRatio
                    : constraints.maxWidth,
                maxHeight: screenAspectRatio > previewAspectRatio
                    ? constraints.maxHeight
                    : constraints.maxWidth * previewAspectRatio,
                child: CameraPreview(controller),
              ),
              DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.black.withValues(alpha: 0.18),
                      Colors.transparent,
                      Colors.black.withValues(alpha: 0.36),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _FallbackCameraViewport extends StatelessWidget {
  const _FallbackCameraViewport({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

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
              width: 200,
              height: 200,
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
              width: 220,
              height: 220,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withValues(alpha: 0.05),
              ),
            ),
          ),
          Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 28),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.camera_alt_rounded,
                    size: 104,
                    color: Colors.white.withValues(alpha: 0.18),
                  ),
                  const SizedBox(height: 18),
                  Text(
                    'Kamera Tarama Alanı',
                    textAlign: TextAlign.center,
                    style: textTheme.headlineSmall?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 10),
                  ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 340),
                    child: Text(
                      message,
                      textAlign: TextAlign.center,
                      style: textTheme.bodyMedium?.copyWith(
                        color: Colors.white.withValues(alpha: 0.82),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withValues(alpha: 0.12),
                    Colors.transparent,
                    Colors.black.withValues(alpha: 0.28),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _HudButton extends StatelessWidget {
  const _HudButton({required this.icon, required this.onTap});

  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(999),
        child: Ink(
          width: 52,
          height: 52,
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.82),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: AppColors.primary),
        ),
      ),
    );
  }
}
