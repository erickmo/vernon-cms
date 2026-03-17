import 'package:equatable/equatable.dart';

/// Entity kategori konten.
class ContentCategory extends Equatable {
  /// ID unik kategori (uuid).
  final String id;

  /// Nama kategori.
  final String name;

  /// Slug URL-friendly (unik).
  final String slug;

  /// Tanggal dibuat.
  final DateTime createdAt;

  /// Tanggal terakhir diperbarui.
  final DateTime updatedAt;

  const ContentCategory({
    required this.id,
    required this.name,
    required this.slug,
    required this.createdAt,
    required this.updatedAt,
  });

  @override
  List<Object?> get props => [
        id,
        name,
        slug,
        createdAt,
        updatedAt,
      ];
}
