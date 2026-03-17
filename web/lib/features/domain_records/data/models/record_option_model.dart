import 'package:json_annotation/json_annotation.dart';

import '../../domain/entities/record_option.dart';

part 'record_option_model.g.dart';

/// Model response opsi record dari API.
@JsonSerializable()
class RecordOptionModel {
  /// ID record.
  final String id;

  /// Label yang ditampilkan.
  final String label;

  const RecordOptionModel({
    required this.id,
    required this.label,
  });

  /// Parse dari JSON.
  factory RecordOptionModel.fromJson(Map<String, dynamic> json) =>
      _$RecordOptionModelFromJson(json);

  /// Convert ke JSON.
  Map<String, dynamic> toJson() => _$RecordOptionModelToJson(this);

  /// Convert ke domain entity.
  RecordOption toEntity() => RecordOption(
        id: id,
        label: label,
      );
}
