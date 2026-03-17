import 'package:equatable/equatable.dart';

/// Entity konten (artikel/post).
class Content extends Equatable {
  /// ID unik konten (uuid).
  final String id;

  /// Judul konten.
  final String title;

  /// Slug URL-friendly (unik).
  final String slug;

  /// Isi konten (rich text).
  final String? body;

  /// Ringkasan singkat konten.
  final String? excerpt;

  /// Status konten: draft, published, archived.
  final String status;

  /// ID halaman terkait.
  final String? pageId;

  /// ID kategori.
  final String? categoryId;

  /// ID penulis.
  final String? authorId;

  /// Metadata fleksibel (seo_title, seo_description, tags, dll).
  final Map<String, dynamic> metadata;

  /// Tanggal dipublikasikan.
  final DateTime? publishedAt;

  /// Tanggal dibuat.
  final DateTime? createdAt;

  /// Tanggal terakhir diperbarui.
  final DateTime? updatedAt;

  const Content({
    required this.id,
    required this.title,
    required this.slug,
    this.body,
    this.excerpt,
    this.status = 'draft',
    this.pageId,
    this.categoryId,
    this.authorId,
    this.metadata = const {},
    this.publishedAt,
    this.createdAt,
    this.updatedAt,
  });

  @override
  List<Object?> get props => [
        id,
        title,
        slug,
        body,
        excerpt,
        status,
        pageId,
        categoryId,
        authorId,
        metadata,
        publishedAt,
        createdAt,
        updatedAt,
      ];
}
