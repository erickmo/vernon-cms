import 'package:json_annotation/json_annotation.dart';

import '../../domain/entities/select_option.dart';

part 'select_option_model.g.dart';

/// Model response opsi select dari API.
@JsonSerializable()
class SelectOptionModel {
  /// Label yang ditampilkan.
  final String label;

  /// Nilai yang disimpan.
  final String value;

  const SelectOptionModel({
    required this.label,
    required this.value,
  });

  /// Parse dari JSON.
  factory SelectOptionModel.fromJson(Map<String, dynamic> json) =>
      _$SelectOptionModelFromJson(json);

  /// Convert ke JSON.
  Map<String, dynamic> toJson() => _$SelectOptionModelToJson(this);

  /// Convert ke domain entity.
  SelectOption toEntity() => SelectOption(
        label: label,
        value: value,
      );

  /// Buat model dari domain entity.
  factory SelectOptionModel.fromEntity(SelectOption entity) {
    return SelectOptionModel(
      label: entity.label,
      value: entity.value,
    );
  }
}
