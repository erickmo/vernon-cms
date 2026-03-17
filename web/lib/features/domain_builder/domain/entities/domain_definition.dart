import 'package:equatable/equatable.dart';

import 'domain_field_definition.dart';

/// Entity definisi domain (custom data type).
class DomainDefinition extends Equatable {
  /// ID unik domain.
  final String id;

  /// Nama domain (e.g. "Cabang Bisnis").
  final String name;

  /// Slug URL-friendly (e.g. "cabang-bisnis").
  final String slug;

  /// Deskripsi domain (opsional).
  final String? description;

  /// Nama icon Material (e.g. "store").
  final String? icon;

  /// Nama jamak (e.g. "Cabang Bisnis").
  final String pluralName;

  /// Bagian sidebar tempat domain ditampilkan.
  final String sidebarSection;

  /// Urutan di sidebar.
  final int sidebarOrder;

  /// Daftar definisi field.
  final List<DomainFieldDefinition> fields;

  /// Tanggal dibuat.
  final DateTime createdAt;

  /// Tanggal terakhir diperbarui.
  final DateTime updatedAt;

  const DomainDefinition({
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

  @override
  List<Object?> get props => [
        id,
        name,
        slug,
        description,
        icon,
        pluralName,
        sidebarSection,
        sidebarOrder,
        fields,
        createdAt,
        updatedAt,
      ];
}
