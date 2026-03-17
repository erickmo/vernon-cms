import 'package:json_annotation/json_annotation.dart';

import '../../domain/entities/domain_definition.dart';
import 'domain_field_definition_model.dart';

part 'domain_definition_model.g.dart';

/// Model response definisi domain dari API.
@JsonSerializable()
class DomainDefinitionModel {
  /// ID unik domain.
  final String id;

  /// Nama domain.
  final String name;

  /// Slug URL-friendly.
  final String slug;

  /// Deskripsi domain.
  final String? description;

  /// Nama icon Material.
  final String? icon;

  /// Nama jamak.
  @JsonKey(name: 'plural_name')
  final String pluralName;

  /// Bagian sidebar.
  @JsonKey(name: 'sidebar_section')
  final String sidebarSection;

  /// Urutan di sidebar.
  @JsonKey(name: 'sidebar_order')
  final int sidebarOrder;

  /// Daftar definisi field.
  final List<DomainFieldDefinitionModel> fields;

  /// Tanggal dibuat.
  @JsonKey(name: 'created_at')
  final DateTime createdAt;

  /// Tanggal terakhir diperbarui.
  @JsonKey(name: 'updated_at')
  final DateTime updatedAt;

  const DomainDefinitionModel({
    required this.id,
    required this.name,
    required this.slug,
    this.description,
    this.icon,
    required this.pluralName,
    this.sidebarSection = 'content',
    this.sidebarOrder = 0,
    this.fields = const [],
    required this.createdAt,
    required this.updatedAt,
  });

  /// Parse dari JSON.
  factory DomainDefinitionModel.fromJson(Map<String, dynamic> json) =>
      _$DomainDefinitionModelFromJson(json);

  /// Convert ke JSON.
  Map<String, dynamic> toJson() => _$DomainDefinitionModelToJson(this);

  /// Convert ke domain entity.
  DomainDefinition toEntity() => DomainDefinition(
        id: id,
        name: name,
        slug: slug,
        description: description,
        icon: icon,
        pluralName: pluralName,
        sidebarSection: sidebarSection,
        sidebarOrder: sidebarOrder,
        fields: fields.map((e) => e.toEntity()).toList(),
        createdAt: createdAt,
        updatedAt: updatedAt,
      );

  /// Buat model dari domain entity.
  factory DomainDefinitionModel.fromEntity(DomainDefinition entity) {
    return DomainDefinitionModel(
      id: entity.id,
      name: entity.name,
      slug: entity.slug,
      description: entity.description,
      icon: entity.icon,
      pluralName: entity.pluralName,
      sidebarSection: entity.sidebarSection,
      sidebarOrder: entity.sidebarOrder,
      fields: entity.fields
          .map((e) => DomainFieldDefinitionModel.fromEntity(e))
          .toList(),
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
    );
  }
}
