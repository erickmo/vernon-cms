import 'package:equatable/equatable.dart';

/// Entity file media.
class MediaFile extends Equatable {
  /// ID unik file.
  final String id;

  /// Nama file asli.
  final String fileName;

  /// URL lengkap untuk mengakses file.
  final String fileUrl;

  /// URL thumbnail (untuk gambar).
  final String? thumbnailUrl;

  /// Tipe MIME (contoh: image/png, application/pdf).
  final String mimeType;

  /// Ukuran file dalam bytes.
  final int fileSize;

  /// Lebar gambar dalam piksel (opsional, untuk gambar).
  final int? width;

  /// Tinggi gambar dalam piksel (opsional, untuk gambar).
  final int? height;

  /// Teks alternatif untuk gambar.
  final String? alt;

  /// Caption file.
  final String? caption;

  /// Folder virtual / kategori.
  final String? folder;

  /// ID user yang mengunggah.
  final String? uploadedBy;

  /// Nama user yang mengunggah (untuk display).
  final String? uploadedByName;

  /// Tanggal dibuat.
  final DateTime createdAt;

  /// Tanggal terakhir diperbarui.
  final DateTime updatedAt;

  const MediaFile({
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

  @override
  List<Object?> get props => [
        id,
        fileName,
        fileUrl,
        thumbnailUrl,
        mimeType,
        fileSize,
        width,
        height,
        alt,
        caption,
        folder,
        uploadedBy,
        uploadedByName,
        createdAt,
        updatedAt,
      ];
}
