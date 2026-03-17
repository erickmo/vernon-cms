import 'package:equatable/equatable.dart';

/// Entity pengaturan situs global.
class SiteSettings extends Equatable {
  /// ID unik pengaturan.
  final String id;

  /// Nama situs.
  final String siteName;

  /// Deskripsi situs (opsional).
  final String? siteDescription;

  /// URL situs (opsional).
  final String? siteUrl;

  /// URL logo (opsional).
  final String? logoUrl;

  /// URL favicon (opsional).
  final String? faviconUrl;

  /// Judul meta default (opsional).
  final String? defaultMetaTitle;

  /// Deskripsi meta default (opsional).
  final String? defaultMetaDescription;

  /// URL gambar OG default (opsional).
  final String? defaultOgImage;

  /// Warna primer hex (opsional).
  final String? primaryColor;

  /// Warna sekunder hex (opsional).
  final String? secondaryColor;

  /// Teks footer (opsional).
  final String? footerText;

  /// ID Google Analytics (opsional).
  final String? googleAnalyticsId;

  /// Kode kustom untuk `<head>` (opsional).
  final String? customHeadCode;

  /// Kode kustom sebelum `</body>` (opsional).
  final String? customBodyCode;

  /// Mode maintenance aktif.
  final bool maintenanceMode;

  /// Pesan maintenance (opsional).
  final String? maintenanceMessage;

  /// Tanggal terakhir diperbarui.
  final DateTime updatedAt;

  const SiteSettings({
    required this.id,
    required this.siteName,
    this.siteDescription,
    this.siteUrl,
    this.logoUrl,
    this.faviconUrl,
    this.defaultMetaTitle,
    this.defaultMetaDescription,
    this.defaultOgImage,
    this.primaryColor,
    this.secondaryColor,
    this.footerText,
    this.googleAnalyticsId,
    this.customHeadCode,
    this.customBodyCode,
    this.maintenanceMode = false,
    this.maintenanceMessage,
    required this.updatedAt,
  });

  /// Membuat salinan dengan field yang diubah.
  SiteSettings copyWith({
    String? id,
    String? siteName,
    String? siteDescription,
    String? siteUrl,
    String? logoUrl,
    String? faviconUrl,
    String? defaultMetaTitle,
    String? defaultMetaDescription,
    String? defaultOgImage,
    String? primaryColor,
    String? secondaryColor,
    String? footerText,
    String? googleAnalyticsId,
    String? customHeadCode,
    String? customBodyCode,
    bool? maintenanceMode,
    String? maintenanceMessage,
    DateTime? updatedAt,
  }) {
    return SiteSettings(
      id: id ?? this.id,
      siteName: siteName ?? this.siteName,
      siteDescription: siteDescription ?? this.siteDescription,
      siteUrl: siteUrl ?? this.siteUrl,
      logoUrl: logoUrl ?? this.logoUrl,
      faviconUrl: faviconUrl ?? this.faviconUrl,
      defaultMetaTitle: defaultMetaTitle ?? this.defaultMetaTitle,
      defaultMetaDescription:
          defaultMetaDescription ?? this.defaultMetaDescription,
      defaultOgImage: defaultOgImage ?? this.defaultOgImage,
      primaryColor: primaryColor ?? this.primaryColor,
      secondaryColor: secondaryColor ?? this.secondaryColor,
      footerText: footerText ?? this.footerText,
      googleAnalyticsId: googleAnalyticsId ?? this.googleAnalyticsId,
      customHeadCode: customHeadCode ?? this.customHeadCode,
      customBodyCode: customBodyCode ?? this.customBodyCode,
      maintenanceMode: maintenanceMode ?? this.maintenanceMode,
      maintenanceMessage: maintenanceMessage ?? this.maintenanceMessage,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  List<Object?> get props => [
        id,
        siteName,
        siteDescription,
        siteUrl,
        logoUrl,
        faviconUrl,
        defaultMetaTitle,
        defaultMetaDescription,
        defaultOgImage,
        primaryColor,
        secondaryColor,
        footerText,
        googleAnalyticsId,
        customHeadCode,
        customBodyCode,
        maintenanceMode,
        maintenanceMessage,
        updatedAt,
      ];
}
