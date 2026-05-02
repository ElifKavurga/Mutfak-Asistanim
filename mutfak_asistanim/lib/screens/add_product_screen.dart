import 'dart:typed_data';

import 'package:flutter/material.dart';

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
    this.quickSuggestions = const [],
    this.scanContextTitle,
    this.scanContextValue,
    this.scanHelperText,
    this.scannedImageBytes,
    this.analysisTitle,
    this.analysisConfidenceLabel,
    this.analysisNotes = const [],
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

  final TextEditingController _productNameController = TextEditingController();
  final TextEditingController _dateController = TextEditingController();

  String? _selectedCategory;
  String _selectedDateType = 'Son Kullanma Tarihi';

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

    return 'Taranan Ürün';
  }

  String get _scanValue {
    if (widget.scanContextValue != null &&
        widget.scanContextValue!.trim().isNotEmpty) {
      return widget.scanContextValue!.trim();
    }

    return widget.detectedBarcode?.trim() ?? 'Görsel kayda hazır.';
  }

  String get _scanHelperText {
    if (widget.scanHelperText != null &&
        widget.scanHelperText!.trim().isNotEmpty) {
      return widget.scanHelperText!.trim();
    }

    if (widget.detectedBarcode != null) {
      return 'Ürün adı otomatik geldiyse kontrol edin, gelmediyse elle tamamlayabilirsiniz.';
    }

    return 'Ürün adını ve varsa Son Kullanma Tarihi / TETT bilgisini aşağıdan tamamlayın.';
  }

  @override
  void initState() {
    super.initState();

    _categories = <String>[
      'Diğer',
      'Süt Ürünleri',
      'İçecekler',
      'Atıştırmalık',
      'Meyve & Sebze',
      'Et & Tavuk',
      'Dondurulmuş',
      'Kuru Gıda',
      'Baharat & Sos',
      'Konserve',
    ];

    _dateTypes = <String>['Son Kullanma Tarihi', 'TETT', 'Belirtilmemiş'];

    final prefilledCategory = widget.prefilledCategory?.trim();
    if (prefilledCategory != null &&
        prefilledCategory.isNotEmpty &&
        !_categories.contains(prefilledCategory)) {
      _categories.insert(0, prefilledCategory);
    }

    _quickSuggestions = widget.quickSuggestions
        .map((suggestion) => suggestion.trim())
        .where((suggestion) => suggestion.isNotEmpty)
        .toList(growable: false);

    _selectedCategory = prefilledCategory ?? _categories.first;
    _selectedDateType = _dateTypes.contains(widget.initialDateType)
        ? widget.initialDateType
        : _dateTypes.first;
    _productNameController.text = widget.prefilledProductName.trim();
    _dateController.text = widget.prefilledDate.trim();
  }

  @override
  void dispose() {
    _productNameController.dispose();
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

  void _submitDraft() {
    final productName = _productNameController.text.trim();
    final dateValue = _dateController.text.trim();
    final dateType = _selectedDateType == 'Belirtilmemiş'
        ? 'Tarih'
        : _selectedDateType;

    if (productName.isEmpty) {
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          const SnackBar(content: Text('Ürün adını girmeniz gerekiyor.')),
        );
      return;
    }

    final message = dateValue.isEmpty
        ? '$productName kayda hazır.'
        : '$productName kayda hazır. $dateType: $dateValue';

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
          'MutfakAsistanım',
          style: textTheme.titleLarge?.copyWith(
            color: AppColors.primary,
            fontWeight: FontWeight.w800,
          ),
        ),
        centerTitle: true,
        actions: [
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
                children: [
                  _HeroSection(textTheme: textTheme),
                  const SizedBox(height: 28),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(32),
                      boxShadow: const [
                        BoxShadow(
                          color: AppColors.shadow,
                          blurRadius: 32,
                          offset: Offset(0, 16),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (_hasScanContext) ...[
                          _ScanSummaryCard(
                            title: _scanTitle,
                            value: _scanValue,
                            helperText: _scanHelperText,
                            imageBytes: widget.scannedImageBytes,
                            isBarcodeScan: widget.detectedBarcode != null,
                          ),
                          const SizedBox(height: 22),
                        ],
                        if (_hasAnalysis) ...[
                          _AnalysisSummaryCard(
                            title:
                                widget.analysisTitle?.trim().isNotEmpty == true
                                ? widget.analysisTitle!.trim()
                                : 'TensorFlow on analizi',
                            confidenceLabel: widget.analysisConfidenceLabel
                                ?.trim(),
                            notes: widget.analysisNotes,
                          ),
                          const SizedBox(height: 22),
                        ],
                        CustomInputField(
                          label: 'Ürün Adı',
                          hintText: 'Ürün adı',
                          prefixIcon: Icons.edit_note_rounded,
                          controller: _productNameController,
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

                            if (stacked) {
                              return Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
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
                                  dateFields,
                                ],
                              );
                            }

                            return Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
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
                                Expanded(child: dateFields),
                              ],
                            );
                          },
                        ),
                        const SizedBox(height: 24),
                        Text(
                          'Hızlı Öneriler',
                          style: textTheme.labelMedium?.copyWith(
                            color: AppColors.textSecondary,
                          ),
                        ),
                        const SizedBox(height: 12),
                        if (_quickSuggestions.isEmpty)
                          Text(
                            'Tarama sonrası ürün adı önerileri burada görünecek.',
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
                              colors: [AppColors.primary, AppColors.primaryDim],
                            ),
                            borderRadius: BorderRadius.circular(24),
                            boxShadow: const [
                              BoxShadow(
                                color: AppColors.shadow,
                                blurRadius: 28,
                                offset: Offset(0, 14),
                              ),
                            ],
                          ),
                          child: CommonButton(
                            label: 'Ürün Ekle',
                            onPressed: _submitDraft,
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
                      children: [
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
                              text: 'Mutfak İpucu: ',
                              style: textTheme.bodyMedium?.copyWith(
                                color: AppColors.primaryDim,
                                fontWeight: FontWeight.w700,
                              ),
                              children: [
                                TextSpan(
                                  text:
                                      'TETT ya da son kullanma tarihi çoğu üründe kapak, üst yüzey veya yan etiket üzerinde yer alır. Ürünü taradıktan sonra bu alanı kontrol ederek tarihi hemen ekleyin.',
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
            children: [
              Text(
                'Ürünü\nKayda Hazırla',
                style: textTheme.displayMedium?.copyWith(
                  color: AppColors.primary,
                  height: 1.02,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'Ürün adını, kategorisini ve varsa Son Kullanma Tarihi / TETT bilgisini ekleyerek envanterinizi güncel tutun.',
                style: textTheme.bodyLarge,
              ),
              const SizedBox(height: 20),
              const _HeroVisual(),
            ],
          );
        }

        return Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Expanded(
              flex: 3,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Ürünü\nKayda Hazırla',
                    style: textTheme.displayMedium?.copyWith(
                      color: AppColors.primary,
                      height: 1.02,
                    ),
                  ),
                  const SizedBox(height: 12),
                  ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 420),
                    child: Text(
                      'Ürün adını, kategorisini ve varsa Son Kullanma Tarihi / TETT bilgisini ekleyerek envanterinizi güncel tutun.',
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
          colors: [AppColors.surfaceContainerLow, AppColors.surfaceContainer],
        ),
      ),
      child: Stack(
        children: [
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
                'Ürün kaydı',
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
        children: [
          _ScanSummaryLeading(
            imageBytes: imageBytes,
            isBarcodeScan: isBarcodeScan,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
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
        children: [
          Row(
            children: [
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
                  children: [
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
          if (notes.isNotEmpty) ...[
            const SizedBox(height: 14),
            ...notes.map(
              (note) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
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
    final dateFieldLabel = selectedDateType == 'Belirtilmemiş'
        ? 'Tarih'
        : selectedDateType;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 10),
          child: Text(
            'Tarih Türü',
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
          hintText: 'Tarih seçin',
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
          'Üründe hangisi yazıyorsa onu seçin. Son Kullanma Tarihi ya da TETT bilgisi yoksa bu alanı boş bırakabilirsiniz.',
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
