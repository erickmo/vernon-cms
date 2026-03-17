import 'package:json_annotation/json_annotation.dart';

import '../../domain/entities/content.dart';

part 'content_model.g.dart';

/// Model response konten dari API.
@JsonSerializable()
class ContentModel {
  /// ID unik konten.
  final String id;

  /// Judul konten.
  final String title;

  /// Slug URL-friendly.
  final String slug;

  /// Isi konten (rich text).
  final String? body;

  /// Ringkasan singkat konten.
  final String? excerpt;

  /// Status konten: draft, published, archived.
  final String status;

  /// ID halaman terkait.
  @JsonKey(name: 'page_id')
  final String? pageId;

  /// ID kategori.
  @JsonKey(name: 'category_id')
  final String? categoryId;

  /// ID penulis.
  @JsonKey(name: 'author_id')
  final String? authorId;

  /// Metadata fleksibel.
  @JsonKey(defaultValue: {})
  final Map<String, dynamic> metadata;

  /// Tanggal dipublikasikan.
  @JsonKey(name: 'published_at')
  final DateTime? publishedAt;

  /// Tanggal dibuat.
  @JsonKey(name: 'created_at')
  final DateTime? createdAt;

  /// Tanggal terakhir diperbarui.
  @JsonKey(name: 'updated_at')
  final DateTime? updatedAt;

  const ContentModel({
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

  /// Parse dari JSON.
  factory ContentModel.fromJson(Map<String, dynamic> json) =>
      _$ContentModelFromJson(json);

  /// Convert ke JSON.
  Map<String, dynamic> toJson() => _$ContentModelToJson(this);

  /// Convert ke domain entity.
  Content toEntity() => Content(
        id: id,
        title: title,
        slug: slug,
        body: body,
        excerpt: excerpt,
        status: status,
        pageId: pageId,
        categoryId: categoryId,
        authorId: authorId,
        metadata: metadata,
        publishedAt: publishedAt,
        createdAt: createdAt,
        updatedAt: updatedAt,
      );

  /// Buat model dari domain entity.
  factory ContentModel.fromEntity(Content entity) {
    return ContentModel(
      id: entity.id,
      title: entity.title,
      slug: entity.slug,
      body: entity.body,
      excerpt: entity.excerpt,
      status: entity.status,
      pageId: entity.pageId,
      categoryId: entity.categoryId,
      authorId: entity.authorId,
      metadata: entity.metadata,
      publishedAt: entity.publishedAt,
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
    );
  }
}
