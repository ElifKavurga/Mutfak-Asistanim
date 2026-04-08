import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../widgets/decorative_background.dart';

class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const _InfoPageScreen(
      title: 'Gizlilik Politikası',
      sections: [
        _InfoSection(
          heading: 'Veri Kullanımı',
          body:
              'MutfakAsistanım, uygulama deneyimini iyileştirmek için gerekli temel kullanıcı bilgilerini güvenli şekilde işler. Bu ekran örnek içerik amacıyla hazırlanmıştır.',
        ),
        _InfoSection(
          heading: 'Bilgi Güvenliği',
          body:
              'Kişisel verilerinizin korunması için güncel güvenlik yaklaşımlarını benimsemeyi hedefliyoruz. Üretim sürümünde ayrıntılı hukuki metin burada yer alacaktır.',
        ),
        _InfoSection(
          heading: 'Kontrol Sizde',
          body:
              'Hesap ayarlarınız ve destek kanallarımız üzerinden verilerinizle ilgili taleplerinizi iletebilirsiniz.',
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
      title: 'Kullanım Şartları',
      sections: [
        _InfoSection(
          heading: 'Hizmet Kapsamı',
          body:
              'MutfakAsistanım; malzeme takibi, tarif önerileri ve mutfak planlaması gibi deneyimlere yönelik bir yardımcı arayüz sunar.',
        ),
        _InfoSection(
          heading: 'Sorumluluk',
          body:
              'Uygulama içeriği bilgilendirme amaçlıdır. Nihai kullanım koşulları ve yasal metinler yayın öncesinde detaylandırılacaktır.',
        ),
        _InfoSection(
          heading: 'Güncellemeler',
          body:
              'Deneyimi geliştirmek için arayüzler ve özellikler zaman içinde güncellenebilir. Devam eden kullanım, güncel şartların kabulü anlamına gelir.',
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
      title: 'Yardım ve Destek',
      sections: [
        _InfoSection(
          heading: 'Sık Sorulan Konular',
          body:
              'Hesap erişimi, tarif önerileri, bildirimler ve malzeme takibiyle ilgili temel yönlendirmeler burada listelenebilir.',
        ),
        _InfoSection(
          heading: 'Destek Talebi',
          body:
              'Bir sorun yaşarsanız uygulama içi destek formu veya e-posta desteği üzerinden bize ulaşabileceğiniz alan bu sayfada yer alacaktır.',
        ),
        _InfoSection(
          heading: 'Hızlı Yardım',
          body:
              'Şimdilik bu ekran örnek içerik gösterir. Yayın sürümünde detaylı yardım başlıkları ve iletişim seçenekleri eklenecektir.',
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
                        'Bu sayfa, mevcut tasarım diline uyumlu örnek içerik göstermek için hazırlanmıştır.',
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
