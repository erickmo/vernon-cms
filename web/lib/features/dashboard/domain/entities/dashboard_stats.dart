import 'package:equatable/equatable.dart';

/// Entity statistik dashboard.
class DashboardStats extends Equatable {
  /// Total jumlah post/konten.
  final int totalPosts;

  /// Total kunjungan keseluruhan.
  final int totalVisits;

  /// Kunjungan hari ini.
  final int todayVisits;

  /// Persentase pertumbuhan kunjungan dibanding kemarin.
  final double visitGrowthPercent;

  const DashboardStats({
    required this.totalPosts,
    required this.totalVisits,
    required this.todayVisits,
    required this.visitGrowthPercent,
  });

  @override
  List<Object> get props => [
        totalPosts,
        totalVisits,
        todayVisits,
        visitGrowthPercent,
      ];
}
