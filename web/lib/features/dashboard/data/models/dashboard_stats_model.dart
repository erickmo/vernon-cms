import 'package:json_annotation/json_annotation.dart';

import '../../domain/entities/dashboard_stats.dart';

part 'dashboard_stats_model.g.dart';

/// Model response statistik dashboard dari API.
@JsonSerializable()
class DashboardStatsModel {
  /// Total jumlah post.
  @JsonKey(name: 'total_posts')
  final int totalPosts;

  /// Total kunjungan.
  @JsonKey(name: 'total_visits')
  final int totalVisits;

  /// Kunjungan hari ini.
  @JsonKey(name: 'today_visits')
  final int todayVisits;

  /// Persentase pertumbuhan kunjungan.
  @JsonKey(name: 'visit_growth_percent')
  final double visitGrowthPercent;

  const DashboardStatsModel({
    required this.totalPosts,
    required this.totalVisits,
    required this.todayVisits,
    required this.visitGrowthPercent,
  });

  /// Parse dari JSON.
  factory DashboardStatsModel.fromJson(Map<String, dynamic> json) =>
      _$DashboardStatsModelFromJson(json);

  /// Convert ke domain entity.
  DashboardStats toEntity() => DashboardStats(
        totalPosts: totalPosts,
        totalVisits: totalVisits,
        todayVisits: todayVisits,
        visitGrowthPercent: visitGrowthPercent,
      );
}
