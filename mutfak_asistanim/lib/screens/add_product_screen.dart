import 'dart:typed_data';

import 'package:flutter/material.dart';

import '../services/backend_api_service.dart';
import '../theme/app_colors.dart';
import '../widgets/category_dropdown.dart';
import '../widgets/common_button.dart';
import '../widgets/custom_input_field.dart';
import '../widgets/dashboard_bottom_nav.dart';
import '../widgets/suggestion_chip.dart';

class AddProductScreen extends StatefulWidget {
  const AddProductScreen({
    super.key,
    this.prefilledProductName = '',
    this.prefilledCategory,
    this.prefilledDate = '',
    this.initialDateType = 'Son Kullanma Tarihi',
    this.detectedBarcode,
    this.quickSuggestions = const <String>[],
    this.scanContextTitle,
    this.scanContextValue,
    this.scanHelperText,
    this.scannedImageBytes,
    this.analysisTitle,
    this.analysisConfidenceLabel,
    this.analysisNotes = const <String>[],
  });

  static const String routeName = '/add-product';

  final String prefilledProductName;
  final String? prefilledCategory;
  final String prefilledDate;
  final String initialDateType;
  final String? detectedBarcode;
  final List<String> quickSuggestions;
  final String? scanContextTitle;
  final String? scanContextValue;
  final String? scanHelperText;
  final Uint8List? scannedImageBytes;
  final String? analysisTitle;
  final String? analysisConfidenceLabel;
  final List<String> analysisNotes;

  @override
  State<AddProductScreen> createState() => _AddProductScreenState();
}

class _AddProductScreenState extends State<AddProductScreen> {
  late final List<String> _categories;
  late final List<String> _quickSuggestions;
  late final List<String> _dateTypes;
  late final List<String> _unitLabels;

  final TextEditingController _productNameController = TextEditingController();
  final TextEditingController _barcodeController = TextEditingController();
  final TextEditingController _quantityController = TextEditingController();
  final TextEditingController _dateController = TextEditingController();

  String? _selectedCategory;
  String _selectedDateType = 'Son Kullanma Tarihi';
  String _selectedUnit = 'Adet';
  bool _isSubmitting = false;

  bool get _hasScanContext {
    return widget.detectedBarcode != null ||
        widget.scanContextTitle != null ||
        widget.scanContextValue != null ||
        widget.scanHelperText != null ||
        widget.scannedImageBytes != null;
  }

  bool get _hasAnalysis {
    return (widget.analysisTitle?.trim().isNotEmpty ?? false) ||
        (widget.analysisConfidenceLabel?.trim().isNotEmpty ?? false) ||
        widget.analysisNotes.isNotEmpty;
  }

  String get _scanTitle {
    if (widget.scanContextTitle != null &&
        widget.scanContextTitle!.trim().isNotEmpty) {
      return widget.scanContextTitle!.trim();
    }

    if (widget.detectedBarcode != null) {
      return 'Taranan Barkod';
    }

    return 'Taranan Urun';
  }

  String get _scanValue {
    if (widget.scanContextValue != null &&
        widget.scanContextValue!.trim().isNotEmpty) {
      return widget.scanContextValue!.trim();
    }

    return widget.detectedBarcode?.trim() ?? 'Gorsel kayda hazir.';
  }

  String get _scanHelperText {
    if (widget.scanHelperText != null &&
        widget.scanHelperText!.trim().isNotEmpty) {
      return widget.scanHelperText!.trim();
    }

    if (widget.detectedBarcode != null) {
      return 'Barkod geldiyse kontrol edin, gelmediyse alan bos birakilabilir.';
    }

    return 'Urun adini, miktarini ve son kullanma tarihini tamamlayin.';
  }

  @override
  void initState() {
    super.initState();

    _categories = List<String>.of(BackendApiService.supportedCategoryLabels);
    _unitLabels = List<String>.of(BackendApiService.supportedUnitLabels);
    _dateTypes = <String>['Son Kullanma Tarihi', 'TETT', 'Belirtilmemis'];

    final normalizedCategory = BackendApiService.instance
        .normalizeCategoryLabel(widget.prefilledCategory);
    if (!_categories.contains(normalizedCategory)) {
      _categories.insert(0, normalizedCategory);
    }

    _quickSuggestions = widget.quickSuggestions
        .map((suggestion) => suggestion.trim())
        .where((suggestion) => suggestion.isNotEmpty)
        .toList(growable: false);

    _selectedCategory = normalizedCategory;
    _selectedDateType = _dateTypes.contains(widget.initialDateType)
        ? widget.initialDateType
        : _dateTypes.first;
    _selectedUnit = _unitLabels.first;

    _productNameController.text = widget.prefilledProductName.trim();
    _barcodeController.text = widget.detectedBarcode?.trim() ?? '';
    _quantityController.text = '1';
    _dateController.text = _normalizeDateText(widget.prefilledDate.trim());
  }

  @override
  void dispose() {
    _productNameController.dispose();
    _barcodeController.dispose();
    _quantityController.dispose();
    _dateController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final selected = await showDatePicker(
      context: context,
      initialDate: now,
      firstDate: now.subtract(const Duration(days: 30)),
      lastDate: now.add(const Duration(days: 3650)),
    );

    if (selected == null || !mounted) {
      return;
    }

    setState(() {
      final month = selected.month.toString().padLeft(2, '0');
      final day = selected.day.toString().padLeft(2, '0');
      _dateController.text = '$day.$month.${selected.year}';
    });
  }

  void _applySuggestion(String suggestion) {
    setState(() {
      _productNameController.text = suggestion;
    });
  }

  Future<void> _submitProduct() async {
    final productName = _productNameController.text.trim();
    final barcodeInput = _barcodeController.text.trim();
    final quantityInput = _quantityController.text.trim().replaceAll(',', '.');
    final dateInput = _dateController.text.trim();
    final category = _selectedCategory;

    if (productName.isEmpty) {
      _showMessage('Urun adini girmeniz gerekiyor.');
      return;
    }
    if (category == null || category.isEmpty) {
      _showMessage('Kategori secmeniz gerekiyor.');
      return;
    }
    if (quantityInput.isEmpty) {
      _showMessage('Miktar bilgisi gerekiyor.');
      return;
    }

    final quantity = num.tryParse(quantityInput);
    if (quantity == null || quantity <= 0) {
      _showMessage('Lutfen gecerli bir miktar gir.');
      return;
    }

    final expirationDate = _parseDate(dateInput);
    if (expirationDate == null) {
      _showMessage('Lutfen gecerli bir tarih sec.');
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    try {
      final barcode = barcodeInput.isEmpty
          ? BackendApiService.instance.createFallbackBarcode(productName)
          : barcodeInput;

      await BackendApiService.instance.createProductAndInventory(
        productName: productName,
        barcode: barcode,
        categoryLabel: category,
        quantity: quantity,
        unitLabel: _selectedUnit,
        expirationDate: expirationDate,
      );

      if (!mounted) {
        return;
      }

      _showMessage('Urun envanterine basariyla eklendi.');
      Navigator.of(context).pop(true);
    } catch (error) {
      if (!mounted) {
        return;
      }

      setState(() {
        _isSubmitting = false;
      });
      _showMessage(error.toString());
    }
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        toolbarHeight: 72,
        leading: IconButton(
          onPressed: () => Navigator.of(context).pop(),
          icon: const Icon(Icons.arrow_back_rounded),
        ),
        title: Text(
          'MutfakAsistanim',
          style: textTheme.titleLarge?.copyWith(
            color: AppColors.primary,
            fontWeight: FontWeight.w800,
          ),
        ),
        centerTitle: true,
        actions: <Widget>[
          Padding(
            padding: const EdgeInsets.only(right: 10),
            child: IconButton(
              onPressed: () {},
              icon: const Icon(Icons.account_circle_rounded),
            ),
          ),
        ],
      ),
      body: SafeArea(
        top: false,
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 132),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 920),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  _HeroSection(textTheme: textTheme),
                  const SizedBox(height: 28),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(32),
                      boxShadow: const <BoxShadow>[
                        BoxShadow(
                          color: AppColors.shadow,
                          blurRadius: 32,
                          offset: Offset(0, 16),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        if (_hasScanContext) ...<Widget>[
                          _ScanSummaryCard(
                            title: _scanTitle,
                            value: _scanValue,
                            helperText: _scanHelperText,
                            imageBytes: widget.scannedImageBytes,
                            isBarcodeScan: widget.detectedBarcode != null,
                          ),
                          const SizedBox(height: 22),
                        ],
                        if (_hasAnalysis) ...<Widget>[
                          _AnalysisSummaryCard(
                            title:
                                widget.analysisTitle?.trim().isNotEmpty == true
                                ? widget.analysisTitle!.trim()
                                : 'Gorsel analiz',
                            confidenceLabel: widget.analysisConfidenceLabel
                                ?.trim(),
                            notes: widget.analysisNotes,
                          ),
                          const SizedBox(height: 22),
                        ],
                        CustomInputField(
                          label: 'Urun Adi',
                          hintText: 'Urun adi',
                          prefixIcon: Icons.edit_note_rounded,
                          controller: _productNameController,
                        ),
                        const SizedBox(height: 18),
                        CustomInputField(
                          label: 'Barkod',
                          hintText: 'Varsa barkod girin',
                          prefixIcon: Icons.qr_code_2_rounded,
                          controller: _barcodeController,
                        ),
                        const SizedBox(height: 22),
                        LayoutBuilder(
                          builder: (context, constraints) {
                            final stacked = constraints.maxWidth < 640;
                            final dateFields = _DateDetailsCard(
                              selectedDateType: _selectedDateType,
                              dateTypes: _dateTypes,
                              onDateTypeSelected: (value) {
                                setState(() {
                                  _selectedDateType = value;
                                });
                              },
                              dateController: _dateController,
                              onPickDate: _pickDate,
                            );

                            final quantityFields = _QuantityDetailsCard(
                              quantityController: _quantityController,
                              selectedUnit: _selectedUnit,
                              unitLabels: _unitLabels,
                              onUnitSelected: (value) {
                                setState(() {
                                  _selectedUnit = value;
                                });
                              },
                            );

                            if (stacked) {
                              return Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: <Widget>[
                                  CategoryDropdown(
                                    label: 'Kategori',
                                    value: _selectedCategory,
                                    items: _categories,
                                    onChanged: (value) {
                                      setState(() {
                                        _selectedCategory = value;
                                      });
                                    },
                                  ),
                                  const SizedBox(height: 22),
                                  quantityFields,
                                  const SizedBox(height: 22),
                                  dateFields,
                                ],
                              );
                            }

                            return Column(
                              children: <Widget>[
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: <Widget>[
                                    Expanded(
                                      child: CategoryDropdown(
                                        label: 'Kategori',
                                        value: _selectedCategory,
                                        items: _categories,
                                        onChanged: (value) {
                                          setState(() {
                                            _selectedCategory = value;
                                          });
                                        },
                                      ),
                                    ),
                                    const SizedBox(width: 18),
                                    Expanded(child: quantityFields),
                                  ],
                                ),
                                const SizedBox(height: 22),
                                dateFields,
                              ],
                            );
                          },
                        ),
                        const SizedBox(height: 24),
                        Text(
                          'Hizli Oneriler',
                          style: textTheme.labelMedium?.copyWith(
                            color: AppColors.textSecondary,
                          ),
                        ),
                        const SizedBox(height: 12),
                        if (_quickSuggestions.isEmpty)
                          Text(
                            'Kamera ile tarama yaptiginda sana uygun urun adi onerilerini burada gorebilirsin.',
                            style: textTheme.bodySmall?.copyWith(
                              color: AppColors.textSecondary,
                            ),
                          )
                        else
                          Wrap(
                            spacing: 10,
                            runSpacing: 10,
                            children: _quickSuggestions
                                .map(
                                  (suggestion) => SuggestionChip(
                                    label: suggestion,
                                    onTap: () => _applySuggestion(suggestion),
                                  ),
                                )
                                .toList(),
                          ),
                        const SizedBox(height: 28),
                        DecoratedBox(
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: <Color>[
                                AppColors.primary,
                                AppColors.primaryDim,
                              ],
                            ),
                            borderRadius: BorderRadius.circular(24),
                            boxShadow: const <BoxShadow>[
                              BoxShadow(
                                color: AppColors.shadow,
                                blurRadius: 28,
                                offset: Offset(0, 14),
                              ),
                            ],
                          ),
                          child: CommonButton(
                            label: _isSubmitting
                                ? 'Kaydediliyor...'
                                : 'Urun Ekle',
                            onPressed: _isSubmitting ? null : _submitProduct,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 24,
                              vertical: 20,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: AppColors.tertiaryContainer.withValues(
                        alpha: 0.36,
                      ),
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(color: AppColors.tertiaryContainer),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        const Padding(
                          padding: EdgeInsets.only(top: 2),
                          child: Icon(
                            Icons.tips_and_updates_rounded,
                            color: AppColors.primaryDim,
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Text.rich(
                            TextSpan(
                              text: 'Mutfak Ipucu: ',
                              style: textTheme.bodyMedium?.copyWith(
                                color: AppColors.primaryDim,
                                fontWeight: FontWeight.w700,
                              ),
                              children: <InlineSpan>[
                                TextSpan(
                                  text:
                                      'Urunu dogru takip edebilmek icin tarih alanini bos birakma ve miktari gercek degeriyle gir.',
                                  style: textTheme.bodyMedium?.copyWith(
                                    color: AppColors.textPrimary,
                                    fontWeight: FontWeight.w500,
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
        ),
      ),
      bottomNavigationBar: const DashboardBottomNav(
        activeTab: DashboardTab.kitchen,
      ),
    );
  }

  DateTime? _parseDate(String value) {
    if (value.trim().isEmpty) {
      return null;
    }

    final dotMatch = RegExp(r'^(\d{2})\.(\d{2})\.(\d{4})$').firstMatch(value);
    if (dotMatch != null) {
      return DateTime(
        int.parse(dotMatch.group(3)!),
        int.parse(dotMatch.group(2)!),
        int.parse(dotMatch.group(1)!),
      );
    }

    final dashMatch = RegExp(r'^(\d{2})-(\d{2})-(\d{4})$').firstMatch(value);
    if (dashMatch != null) {
      return DateTime(
        int.parse(dashMatch.group(3)!),
        int.parse(dashMatch.group(2)!),
        int.parse(dashMatch.group(1)!),
      );
    }

    final iso = DateTime.tryParse(value);
    if (iso != null) {
      return DateTime(iso.year, iso.month, iso.day);
    }

    return null;
  }

  String _normalizeDateText(String value) {
    final parsed = _parseDate(value);
    if (parsed == null) {
      return value;
    }

    final month = parsed.month.toString().padLeft(2, '0');
    final day = parsed.day.toString().padLeft(2, '0');
    return '$day.$month.${parsed.year}';
  }
}

class _HeroSection extends StatelessWidget {
  const _HeroSection({required this.textTheme});

  final TextTheme textTheme;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final stacked = constraints.maxWidth < 720;

        if (stacked) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                'Urunu\nKayda Hazirla',
                style: textTheme.displayMedium?.copyWith(
                  color: AppColors.primary,
                  height: 1.02,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'Urun bilgilerini adim adim girerek mutfak envanterini kolayca guncelle.',
                style: textTheme.bodyLarge,
              ),
              const SizedBox(height: 20),
              const _HeroVisual(),
            ],
          );
        }

        return Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: <Widget>[
            Expanded(
              flex: 3,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    'Urunu\nKayda Hazirla',
                    style: textTheme.displayMedium?.copyWith(
                      color: AppColors.primary,
                      height: 1.02,
                    ),
                  ),
                  const SizedBox(height: 12),
                  ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 420),
                    child: Text(
                      'Urun adi, kategori, miktar ve varsa son kullanma tarihi bilgisini ekleyerek envanterini duzenli tut.',
                      style: textTheme.bodyLarge,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 22),
            const Expanded(flex: 2, child: _HeroVisual()),
          ],
        );
      },
    );
  }
}

class _HeroVisual extends StatelessWidget {
  const _HeroVisual();

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Container(
      height: 190,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: <Color>[
            AppColors.surfaceContainerLow,
            AppColors.surfaceContainer,
          ],
        ),
      ),
      child: Stack(
        children: <Widget>[
          Positioned(
            right: -26,
            top: -24,
            child: Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: AppColors.primaryContainer.withValues(alpha: 0.7),
                shape: BoxShape.circle,
              ),
            ),
          ),
          const Center(
            child: Icon(
              Icons.inventory_2_rounded,
              size: 74,
              color: AppColors.primary,
            ),
          ),
          Positioned(
            left: 18,
            bottom: 18,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.8),
                borderRadius: BorderRadius.circular(999),
              ),
              child: Text(
                'Kayit Bilgisi',
                style: textTheme.labelMedium?.copyWith(
                  color: AppColors.primary,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ScanSummaryCard extends StatelessWidget {
  const _ScanSummaryCard({
    required this.title,
    required this.value,
    required this.helperText,
    required this.imageBytes,
    required this.isBarcodeScan,
  });

  final String title;
  final String value;
  final String helperText;
  final Uint8List? imageBytes;
  final bool isBarcodeScan;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.primaryContainer.withValues(alpha: 0.48),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.primaryContainer),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          _ScanSummaryLeading(
            imageBytes: imageBytes,
            isBarcodeScan: isBarcodeScan,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  title,
                  style: textTheme.labelLarge?.copyWith(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: textTheme.bodyMedium?.copyWith(
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  helperText,
                  style: textTheme.bodySmall?.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ScanSummaryLeading extends StatelessWidget {
  const _ScanSummaryLeading({
    required this.imageBytes,
    required this.isBarcodeScan,
  });

  final Uint8List? imageBytes;
  final bool isBarcodeScan;

  @override
  Widget build(BuildContext context) {
    if (imageBytes != null) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(18),
        child: Image.memory(
          imageBytes!,
          width: 68,
          height: 68,
          fit: BoxFit.cover,
        ),
      );
    }

    return Container(
      width: 68,
      height: 68,
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.75),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Icon(
        isBarcodeScan ? Icons.qr_code_2_rounded : Icons.photo_camera_rounded,
        color: AppColors.primary,
      ),
    );
  }
}

class _AnalysisSummaryCard extends StatelessWidget {
  const _AnalysisSummaryCard({
    required this.title,
    required this.confidenceLabel,
    required this.notes,
  });

  final String title;
  final String? confidenceLabel;
  final List<String> notes;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.secondaryContainer,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.primaryContainer),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.76),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Icon(
                  Icons.auto_awesome_rounded,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      title,
                      style: textTheme.titleMedium?.copyWith(
                        color: AppColors.primary,
                      ),
                    ),
                    if (confidenceLabel != null && confidenceLabel!.isNotEmpty)
                      Text(
                        confidenceLabel!,
                        style: textTheme.labelMedium?.copyWith(
                          color: AppColors.primaryDim,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
          if (notes.isNotEmpty) ...<Widget>[
            const SizedBox(height: 14),
            ...notes.map(
              (note) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    const Padding(
                      padding: EdgeInsets.only(top: 2),
                      child: Icon(
                        Icons.check_circle_rounded,
                        size: 16,
                        color: AppColors.primary,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        note,
                        style: textTheme.bodyMedium?.copyWith(
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _QuantityDetailsCard extends StatelessWidget {
  const _QuantityDetailsCard({
    required this.quantityController,
    required this.selectedUnit,
    required this.unitLabels,
    required this.onUnitSelected,
  });

  final TextEditingController quantityController;
  final String selectedUnit;
  final List<String> unitLabels;
  final ValueChanged<String> onUnitSelected;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        CustomInputField(
          label: 'Miktar',
          hintText: '1',
          prefixIcon: Icons.scale_rounded,
          controller: quantityController,
        ),
        const SizedBox(height: 12),
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 10),
          child: Text(
            'Birim',
            style: textTheme.labelMedium?.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
        ),
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: unitLabels.map((unit) {
            return _DateTypeChip(
              label: unit,
              selected: selectedUnit == unit,
              onTap: () => onUnitSelected(unit),
            );
          }).toList(),
        ),
      ],
    );
  }
}

class _DateDetailsCard extends StatelessWidget {
  const _DateDetailsCard({
    required this.selectedDateType,
    required this.dateTypes,
    required this.onDateTypeSelected,
    required this.dateController,
    required this.onPickDate,
  });

  final String selectedDateType;
  final List<String> dateTypes;
  final ValueChanged<String> onDateTypeSelected;
  final TextEditingController dateController;
  final VoidCallback onPickDate;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final dateFieldLabel = selectedDateType == 'Belirtilmemis'
        ? 'Tarih'
        : selectedDateType;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 10),
          child: Text(
            'Tarih Turu',
            style: textTheme.labelMedium?.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
        ),
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: dateTypes.map((dateType) {
            return _DateTypeChip(
              label: dateType,
              selected: selectedDateType == dateType,
              onTap: () => onDateTypeSelected(dateType),
            );
          }).toList(),
        ),
        const SizedBox(height: 16),
        CustomInputField(
          label: dateFieldLabel,
          hintText: 'Tarih secin',
          prefixIcon: Icons.event_rounded,
          controller: dateController,
          readOnly: true,
          onTap: onPickDate,
          suffix: const Icon(
            Icons.calendar_month_rounded,
            color: AppColors.outline,
          ),
        ),
        const SizedBox(height: 10),
        Text(
          'Bu urun icin son kullanma tarihi veya TETT secmelisin.',
          style: textTheme.bodySmall?.copyWith(color: AppColors.textSecondary),
        ),
      ],
    );
  }
}

class _DateTypeChip extends StatelessWidget {
  const _DateTypeChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(999),
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          curve: Curves.easeOutCubic,
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            color: selected
                ? AppColors.primaryContainer
                : AppColors.surfaceContainerLow,
            borderRadius: BorderRadius.circular(999),
            border: Border.all(
              color: selected
                  ? AppColors.primary
                  : AppColors.outlineVariant.withValues(alpha: 0.4),
            ),
          ),
          child: Text(
            label,
            style: textTheme.labelMedium?.copyWith(
              color: selected ? AppColors.primary : AppColors.textPrimary,
              fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
            ),
          ),
        ),
      ),
    );
  }
}
