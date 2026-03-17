import 'package:equatable/equatable.dart';

import 'field_type.dart';
import 'select_option.dart';

/// Entity definisi field dalam sebuah domain.
class DomainFieldDefinition extends Equatable {
  /// ID unik field.
  final String id;

  /// Nama field (snake_case, e.g. "nama_cabang").
  final String name;

  /// Label tampilan (e.g. "Nama Cabang").
  final String label;

  /// Tipe field.
  final FieldType fieldType;

  /// Apakah field wajib diisi.
  final bool isRequired;

  /// Nilai default (opsional).
  final String? defaultValue;

  /// Placeholder (opsional).
  final String? placeholder;

  /// Teks bantuan (opsional).
  final String? helpText;

  /// Urutan tampil.
  final int sortOrder;

  /// Daftar opsi untuk field tipe select.
  final List<SelectOption> options;

  /// ID domain terkait untuk field tipe relation.
  final String? relatedDomainId;

  /// Slug domain terkait untuk field tipe relation.
  final String? relatedDomainSlug;

  const DomainFieldDefinition({
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

  @override
  List<Object?> get props => [
        id,
        name,
        label,
        fieldType,
        isRequired,
        defaultValue,
        placeholder,
        helpText,
        sortOrder,
        options,
        relatedDomainId,
        relatedDomainSlug,
      ];
}
