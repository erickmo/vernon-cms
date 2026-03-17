import 'package:json_annotation/json_annotation.dart';

import '../../domain/entities/site_settings.dart';

part 'site_settings_model.g.dart';

/// Model response pengaturan situs dari API.
@JsonSerializable()
class SiteSettingsModel {
  /// ID unik pengaturan.
  final String id;

  /// Nama situs.
  @JsonKey(name: 'site_name')
  final String siteName;

  /// Deskripsi situs.
  @JsonKey(name: 'site_description')
  final String? siteDescription;

  /// URL situs.
  @JsonKey(name: 'site_url')
  final String? siteUrl;

  /// URL logo.
  @JsonKey(name: 'logo_url')
  final String? logoUrl;

  /// URL favicon.
  @JsonKey(name: 'favicon_url')
  final String? faviconUrl;

  /// Judul meta default.
  @JsonKey(name: 'default_meta_title')
  final String? defaultMetaTitle;

  /// Deskripsi meta default.
  @JsonKey(name: 'default_meta_description')
  final String? defaultMetaDescription;

  /// URL gambar OG default.
  @JsonKey(name: 'default_og_image')
  final String? defaultOgImage;

  /// Warna primer hex.
  @JsonKey(name: 'primary_color')
  final String? primaryColor;

  /// Warna sekunder hex.
  @JsonKey(name: 'secondary_color')
  final String? secondaryColor;

  /// Teks footer.
  @JsonKey(name: 'footer_text')
  final String? footerText;

  /// ID Google Analytics.
  @JsonKey(name: 'google_analytics_id')
  final String? googleAnalyticsId;

  /// Kode kustom untuk `<head>`.
  @JsonKey(name: 'custom_head_code')
  final String? customHeadCode;

  /// Kode kustom sebelum `</body>`.
  @JsonKey(name: 'custom_body_code')
  final String? customBodyCode;

  /// Mode maintenance aktif.
  @JsonKey(name: 'maintenance_mode')
  final bool maintenanceMode;

  /// Pesan maintenance.
  @JsonKey(name: 'maintenance_message')
  final String? maintenanceMessage;

  /// Tanggal terakhir diperbarui.
  @JsonKey(name: 'updated_at')
  final DateTime updatedAt;

  const SiteSettingsModel({
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

  /// Parse dari JSON.
  factory SiteSettingsModel.fromJson(Map<String, dynamic> json) =>
      _$SiteSettingsModelFromJson(json);

  /// Convert ke JSON.
  Map<String, dynamic> toJson() => _$SiteSettingsModelToJson(this);

  /// Convert ke domain entity.
  SiteSettings toEntity() => SiteSettings(
        id: id,
        siteName: siteName,
        siteDescription: siteDescription,
        siteUrl: siteUrl,
        logoUrl: logoUrl,
        faviconUrl: faviconUrl,
        defaultMetaTitle: defaultMetaTitle,
        defaultMetaDescription: defaultMetaDescription,
        defaultOgImage: defaultOgImage,
        primaryColor: primaryColor,
        secondaryColor: secondaryColor,
        footerText: footerText,
        googleAnalyticsId: googleAnalyticsId,
        customHeadCode: customHeadCode,
        customBodyCode: customBodyCode,
        maintenanceMode: maintenanceMode,
        maintenanceMessage: maintenanceMessage,
        updatedAt: updatedAt,
      );

  /// Buat model dari domain entity.
  factory SiteSettingsModel.fromEntity(SiteSettings entity) {
    return SiteSettingsModel(
      id: entity.id,
      siteName: entity.siteName,
      siteDescription: entity.siteDescription,
      siteUrl: entity.siteUrl,
      logoUrl: entity.logoUrl,
      faviconUrl: entity.faviconUrl,
      defaultMetaTitle: entity.defaultMetaTitle,
      defaultMetaDescription: entity.defaultMetaDescription,
      defaultOgImage: entity.defaultOgImage,
      primaryColor: entity.primaryColor,
      secondaryColor: entity.secondaryColor,
      footerText: entity.footerText,
      googleAnalyticsId: entity.googleAnalyticsId,
      customHeadCode: entity.customHeadCode,
      customBodyCode: entity.customBodyCode,
      maintenanceMode: entity.maintenanceMode,
      maintenanceMessage: entity.maintenanceMessage,
      updatedAt: entity.updatedAt,
    );
  }
}
