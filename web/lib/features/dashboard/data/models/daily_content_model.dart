import 'package:json_annotation/json_annotation.dart';

import '../../domain/entities/daily_content.dart';

part 'daily_content_model.g.dart';

/// Model response konten per hari dari API.
@JsonSerializable()
class DailyContentModel {
  /// Tanggal dalam format ISO 8601.
  final String date;

  /// Jumlah konten pada tanggal ini.
  final int count;

  const DailyContentModel({
    required this.date,
    required this.count,
  });

  /// Parse dari JSON.
  factory DailyContentModel.fromJson(Map<String, dynamic> json) =>
      _$DailyContentModelFromJson(json);

  /// Convert ke domain entity.
  DailyContent toEntity() => DailyContent(
        date: DateTime.parse(date),
        count: count,
      );
}
