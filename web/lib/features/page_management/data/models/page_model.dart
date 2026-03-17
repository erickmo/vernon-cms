import 'package:json_annotation/json_annotation.dart';

import '../../domain/entities/page_entity.dart';

part 'page_model.g.dart';

/// Model response halaman dari API.
@JsonSerializable()
class PageModel {
  /// ID unik halaman.
  final String id;

  /// Nama halaman.
  final String name;

  /// Slug URL-friendly.
  final String slug;

  /// Variables JSON fleksibel untuk template fields.
  final Map<String, dynamic> variables;

  /// Apakah halaman aktif.
  @JsonKey(name: 'is_active')
  final bool isActive;

  /// Tanggal dibuat.
  @JsonKey(name: 'created_at')
  final DateTime createdAt;

  /// Tanggal terakhir diperbarui.
  @JsonKey(name: 'updated_at')
  final DateTime updatedAt;

  const PageModel({
    required this.id,
    required this.name,
    required this.slug,
    this.variables = const {},
    this.isActive = true,
    required this.createdAt,
    required this.updatedAt,
  });

  /// Parse dari JSON.
  factory PageModel.fromJson(Map<String, dynamic> json) =>
      _$PageModelFromJson(json);

  /// Convert ke JSON.
  Map<String, dynamic> toJson() => _$PageModelToJson(this);

  /// Convert ke domain entity.
  PageEntity toEntity() => PageEntity(
        id: id,
        name: name,
        slug: slug,
        variables: variables,
        isActive: isActive,
        createdAt: createdAt,
        updatedAt: updatedAt,
      );

  /// Buat model dari domain entity.
  factory PageModel.fromEntity(PageEntity entity) {
    return PageModel(
      id: entity.id,
      name: entity.name,
      slug: entity.slug,
      variables: entity.variables,
      isActive: entity.isActive,
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
    );
  }
}
