import 'package:json_annotation/json_annotation.dart';

import '../../domain/entities/domain_record.dart';

part 'domain_record_model.g.dart';

/// Model response record domain dari API.
@JsonSerializable()
class DomainRecordModel {
  /// ID unik record.
  final String id;

  /// Slug domain.
  @JsonKey(name: 'domain_slug')
  final String domainSlug;

  /// Data record.
  final Map<String, dynamic> data;

  /// Tanggal dibuat.
  @JsonKey(name: 'created_at')
  final DateTime createdAt;

  /// Tanggal terakhir diperbarui.
  @JsonKey(name: 'updated_at')
  final DateTime updatedAt;

  const DomainRecordModel({
    required this.id,
    required this.domainSlug,
    required this.data,
    required this.createdAt,
    required this.updatedAt,
  });

  /// Parse dari JSON.
  factory DomainRecordModel.fromJson(Map<String, dynamic> json) =>
      _$DomainRecordModelFromJson(json);

  /// Convert ke JSON.
  Map<String, dynamic> toJson() => _$DomainRecordModelToJson(this);

  /// Convert ke domain entity.
  DomainRecord toEntity() => DomainRecord(
        id: id,
        domainSlug: domainSlug,
        data: data,
        createdAt: createdAt,
        updatedAt: updatedAt,
      );
}
