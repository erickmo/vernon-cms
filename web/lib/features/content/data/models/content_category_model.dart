import 'package:json_annotation/json_annotation.dart';

import '../../domain/entities/content_category.dart';

part 'content_category_model.g.dart';

/// Model response kategori konten dari API.
@JsonSerializable()
class ContentCategoryModel {
  /// ID unik kategori.
  final String id;

  /// Nama kategori.
  final String name;

  /// Slug URL-friendly.
  final String slug;

  /// Tanggal dibuat.
  @JsonKey(name: 'created_at')
  final DateTime createdAt;

  /// Tanggal terakhir diperbarui.
  @JsonKey(name: 'updated_at')
  final DateTime updatedAt;

  const ContentCategoryModel({
    required this.id,
    required this.name,
    required this.slug,
    required this.createdAt,
    required this.updatedAt,
  });

  /// Parse dari JSON.
  factory ContentCategoryModel.fromJson(Map<String, dynamic> json) =>
      _$ContentCategoryModelFromJson(json);

  /// Convert ke JSON.
  Map<String, dynamic> toJson() => _$ContentCategoryModelToJson(this);

  /// Convert ke domain entity.
  ContentCategory toEntity() => ContentCategory(
        id: id,
        name: name,
        slug: slug,
        createdAt: createdAt,
        updatedAt: updatedAt,
      );

  /// Buat model dari domain entity.
  factory ContentCategoryModel.fromEntity(ContentCategory entity) {
    return ContentCategoryModel(
      id: entity.id,
      name: entity.name,
      slug: entity.slug,
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
    );
  }
}
