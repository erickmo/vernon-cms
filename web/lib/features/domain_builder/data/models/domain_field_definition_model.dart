import 'package:json_annotation/json_annotation.dart';

import '../../domain/entities/domain_field_definition.dart';
import '../../domain/entities/field_type.dart';
import 'select_option_model.dart';

part 'domain_field_definition_model.g.dart';

/// Model response definisi field dari API.
@JsonSerializable()
class DomainFieldDefinitionModel {
  /// ID unik field.
  final String id;

  /// Nama field (snake_case).
  final String name;

  /// Label tampilan.
  final String label;

  /// Tipe field.
  @JsonKey(name: 'field_type')
  final String fieldType;

  /// Apakah field wajib diisi.
  @JsonKey(name: 'is_required')
  final bool isRequired;

  /// Nilai default.
  @JsonKey(name: 'default_value')
  final String? defaultValue;

  /// Placeholder.
  final String? placeholder;

  /// Teks bantuan.
  @JsonKey(name: 'help_text')
  final String? helpText;

  /// Urutan tampil.
  @JsonKey(name: 'sort_order')
  final int sortOrder;

  /// Daftar opsi untuk field tipe select.
  final List<SelectOptionModel> options;

  /// ID domain terkait untuk field tipe relation.
  @JsonKey(name: 'related_domain_id')
  final String? relatedDomainId;

  /// Slug domain terkait untuk field tipe relation.
  @JsonKey(name: 'related_domain_slug')
  final String? relatedDomainSlug;

  const DomainFieldDefinitionModel({
    required this.id,
    required this.name,
    required this.label,
    required this.fieldType,
    this.isRequired = false,
    this.defaultValue,
    this.placeholder,
    this.helpText,
    this.sortOrder = 0,
    this.options = const [],
    this.relatedDomainId,
    this.relatedDomainSlug,
  });

  /// Parse dari JSON.
  factory DomainFieldDefinitionModel.fromJson(Map<String, dynamic> json) =>
      _$DomainFieldDefinitionModelFromJson(json);

  /// Convert ke JSON.
  Map<String, dynamic> toJson() => _$DomainFieldDefinitionModelToJson(this);

  /// Convert ke domain entity.
  DomainFieldDefinition toEntity() => DomainFieldDefinition(
        id: id,
        name: name,
        label: label,
        fieldType: _parseFieldType(fieldType),
        isRequired: isRequired,
        defaultValue: defaultValue,
        placeholder: placeholder,
        helpText: helpText,
        sortOrder: sortOrder,
        options: options.map((e) => e.toEntity()).toList(),
        relatedDomainId: relatedDomainId,
        relatedDomainSlug: relatedDomainSlug,
      );

  /// Buat model dari domain entity.
  factory DomainFieldDefinitionModel.fromEntity(
    DomainFieldDefinition entity,
  ) {
    return DomainFieldDefinitionModel(
      id: entity.id,
      name: entity.name,
      label: entity.label,
      fieldType: entity.fieldType.name,
      isRequired: entity.isRequired,
      defaultValue: entity.defaultValue,
      placeholder: entity.placeholder,
      helpText: entity.helpText,
      sortOrder: entity.sortOrder,
      options: entity.options
          .map((e) => SelectOptionModel.fromEntity(e))
          .toList(),
      relatedDomainId: entity.relatedDomainId,
      relatedDomainSlug: entity.relatedDomainSlug,
    );
  }

  static FieldType _parseFieldType(String value) {
    return FieldType.values.firstWhere(
      (e) => e.name == value,
      orElse: () => FieldType.text,
    );
  }
}
