import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../widgets/decorative_background.dart';

class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const _InfoPageScreen(
      title: 'Gizlilik Politikasi',
      sections: [
        _InfoSection(
          heading: 'Veri Kullanimi',
          body:
              'MutfakAsistanim, uygulama deneyimini iyilestirmek icin gerekli temel bilgileri guvenli sekilde islemeyi hedefler.',
        ),
        _InfoSection(
          heading: 'Bilgi Guvenligi',
          body:
              'Hesap ve kullanim verilerinin korunmasi icin guncel guvenlik yaklasimlari benimsenir.',
        ),
        _InfoSection(
          heading: 'Kullanici Kontrolu',
          body:
              'Hesap ayarlari ve destek kanallari uzerinden verilerinle ilgili taleplerini iletebilirsin.',
        ),
      ],
    );
  }
}

class TermsOfUseScreen extends StatelessWidget {
  const TermsOfUseScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const _InfoPageScreen(
      title: 'Kullanim Sartlari',
      sections: [
        _InfoSection(
          heading: 'Hizmet Kapsami',
          body:
              'MutfakAsistanim; envanter takibi, tarif onerileri ve mutfak planlamasi gibi alanlarda kullaniciya rehberlik eder.',
        ),
        _InfoSection(
          heading: 'Kullanim Sorumlulugu',
          body:
              'Uygulamadaki icerikler bilgilendirme amaclidir. Nihai karar ve kullanim sorumlulugu kullaniciya aittir.',
        ),
        _InfoSection(
          heading: 'Guncellemeler',
          body:
              'Uygulama deneyimini gelistirmek icin ekranlar, ozellikler ve icerikler zamanla guncellenebilir.',
        ),
      ],
    );
  }
}

class HelpSupportScreen extends StatelessWidget {
  const HelpSupportScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const _InfoPageScreen(
      title: 'Yardim ve Destek',
      sections: [
        _InfoSection(
          heading: 'Sik Sorulan Konular',
          body:
              'Giris, kayit, envanter takibi, tarif onerileri ve bildirimler ile ilgili temel yardim basliklari burada yer alir.',
        ),
        _InfoSection(
          heading: 'Destek Talebi',
          body:
              'Bir sorun yasarsan uygulama ici destek alani veya iletisim kanallari uzerinden bize ulasabilirsin.',
        ),
        _InfoSection(
          heading: 'Hizli Yonlendirme',
          body:
              'Sorun yasadiginda once internet baglantini, giris bilgilerini ve guncel uygulama surumunu kontrol etmen faydali olur.',
        ),
      ],
    );
  }
}

class _InfoPageScreen extends StatelessWidget {
  const _InfoPageScreen({required this.title, required this.sections});

  final String title;
  final List<_InfoSection> sections;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: DecorativeBackground(
        child: SafeArea(
          top: false,
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 860),
                child: Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(32),
                    boxShadow: const [
                      BoxShadow(
                        color: AppColors.shadow,
                        blurRadius: 36,
                        offset: Offset(0, 16),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: textTheme.headlineLarge?.copyWith(
                          color: AppColors.primary,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'Bu sayfa uygulamayi daha rahat kullanabilmen icin temel bilgilendirme icerigi sunar.',
                        style: textTheme.bodyLarge,
                      ),
                      const SizedBox(height: 24),
                      ...sections.map(
                        (section) => Padding(
                          padding: const EdgeInsets.only(bottom: 20),
                          child: _InfoSectionCard(section: section),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _InfoSectionCard extends StatelessWidget {
  const _InfoSectionCard({required this.section});

  final _InfoSection section;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            section.heading,
            style: textTheme.titleMedium?.copyWith(color: AppColors.primary),
          ),
          const SizedBox(height: 8),
          Text(section.body, style: textTheme.bodyMedium),
        ],
      ),
    );
  }
}

class _InfoSection {
  const _InfoSection({required this.heading, required this.body});

  final String heading;
  final String body;
}
