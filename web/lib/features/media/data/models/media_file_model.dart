import 'package:json_annotation/json_annotation.dart';

import '../../domain/entities/media_file.dart';

part 'media_file_model.g.dart';

/// Model response file media dari API.
@JsonSerializable()
class MediaFileModel {
  /// ID unik file.
  final String id;

  /// Nama file asli.
  @JsonKey(name: 'file_name')
  final String fileName;

  /// URL lengkap untuk mengakses file.
  @JsonKey(name: 'file_url')
  final String fileUrl;

  /// URL thumbnail (untuk gambar).
  @JsonKey(name: 'thumbnail_url')
  final String? thumbnailUrl;

  /// Tipe MIME.
  @JsonKey(name: 'mime_type')
  final String mimeType;

  /// Ukuran file dalam bytes.
  @JsonKey(name: 'file_size')
  final int fileSize;

  /// Lebar gambar dalam piksel.
  final int? width;

  /// Tinggi gambar dalam piksel.
  final int? height;

  /// Teks alternatif untuk gambar.
  final String? alt;

  /// Caption file.
  final String? caption;

  /// Folder virtual / kategori.
  final String? folder;

  /// ID user yang mengunggah.
  @JsonKey(name: 'uploaded_by')
  final String? uploadedBy;

  /// Nama user yang mengunggah.
  @JsonKey(name: 'uploaded_by_name')
  final String? uploadedByName;

  /// Tanggal dibuat.
  @JsonKey(name: 'created_at')
  final DateTime createdAt;

  /// Tanggal terakhir diperbarui.
  @JsonKey(name: 'updated_at')
  final DateTime updatedAt;

  const MediaFileModel({
    required this.id,
    required this.fileName,
    required this.fileUrl,
    this.thumbnailUrl,
    required this.mimeType,
    required this.fileSize,
    this.width,
    this.height,
    this.alt,
    this.caption,
    this.folder,
    this.uploadedBy,
    this.uploadedByName,
    required this.createdAt,
    required this.updatedAt,
  });

  /// Parse dari JSON.
  factory MediaFileModel.fromJson(Map<String, dynamic> json) =>
      _$MediaFileModelFromJson(json);

  /// Convert ke JSON.
  Map<String, dynamic> toJson() => _$MediaFileModelToJson(this);

  /// Convert ke domain entity.
  MediaFile toEntity() => MediaFile(
        id: id,
        fileName: fileName,
        fileUrl: fileUrl,
        thumbnailUrl: thumbnailUrl,
        mimeType: mimeType,
        fileSize: fileSize,
        width: width,
        height: height,
        alt: alt,
        caption: caption,
        folder: folder,
        uploadedBy: uploadedBy,
        uploadedByName: uploadedByName,
        createdAt: createdAt,
        updatedAt: updatedAt,
      );
}
