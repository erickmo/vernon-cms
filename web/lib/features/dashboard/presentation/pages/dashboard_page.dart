import 'package:dio/dio.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_dimensions.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/di/injection.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/utils/jwt_decoder.dart';
import '../../../auth/data/datasources/auth_local_datasource.dart';

/// Dashboard utama CMS — terinspirasi dari MatDash Dashboard 2.
class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  bool _loading = true;
  int _contentCount = 0;
  int _categoryCount = 0;
  int _pageCount = 0;
  int _publishedCount = 0;
  String _userName = '';

  @override
  void initState() {
    super.initState();
    _loadUserInfo();
    _loadCounts();
  }

  void _loadUserInfo() {
    final token = getIt<AuthLocalDataSource>().getAccessToken();
    if (token != null) {
      _userName = JwtDecoder.getEmail(token) ?? '';
    }
  }

  Future<void> _loadCounts() async {
    setState(() => _loading = true);
    final dio = getIt<ApiClient>().dio;

    try {
      final results = await Future.wait([
        dio.get('/api/v1/contents?page=1&limit=1').catchError((_) =>
            Response(
                requestOptions: RequestOptions(),
                data: {'data': {'total': 0}})),
        dio.get('/api/v1/content-categories?page=1&limit=1').catchError((_) =>
            Response(
                requestOptions: RequestOptions(),
                data: {'data': {'total': 0}})),
        dio.get('/api/v1/pages?page=1&limit=1').catchError((_) =>
            Response(
                requestOptions: RequestOptions(),
                data: {'data': {'total': 0}})),
        dio
            .get('/api/v1/contents?page=1&limit=1&status=published')
            .catchError((_) => Response(
                requestOptions: RequestOptions(),
                data: {'data': {'total': 0}})),
      ]);

      if (mounted) {
        setState(() {
          _contentCount = _extractTotal(results[0]);
          _categoryCount = _extractTotal(results[1]);
          _pageCount = _extractTotal(results[2]);
          _publishedCount = _extractTotal(results[3]);
          _loading = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _loading = false);
    }
  }

  int _extractTotal(Response response) {
    try {
      final data = response.data;
      if (data is Map<String, dynamic>) {
        final inner = data['data'];
        if (inner is Map<String, dynamic>) {
          return (inner['total'] as num?)?.toInt() ?? 0;
        }
      }
    } catch (_) {}
    return 0;
  }

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final greeting = _getGreeting(now);
    final displayName = _userName.split('@').first;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppDimensions.spacingXL),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildWelcomeBanner(greeting, displayName, now),
          const SizedBox(height: AppDimensions.spacingXL),
          if (_loading)
            const Center(
              child: Padding(
                padding: EdgeInsets.all(AppDimensions.spacingXL),
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: AppColors.primary,
                ),
              ),
            )
          else ...[
            _buildStatCards(context),
            const SizedBox(height: AppDimensions.spacingXL),
            _buildChartSection(context),
            const SizedBox(height: AppDimensions.spacingXL),
            _buildQuickActions(context),
          ],
        ],
      ),
    );
  }

  // ── Welcome Banner ────────────────────────────────────────────────────────

  Widget _buildWelcomeBanner(String greeting, String name, DateTime now) {
    final dateStr = DateFormat('EEEE, d MMMM yyyy').format(now);

    return Container(
      padding: const EdgeInsets.all(AppDimensions.spacingXL),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF1A3A6B), Color(0xFF5D87FF)],
        ),
        borderRadius: BorderRadius.circular(AppDimensions.radiusL),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.3),
            blurRadius: 24,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '$greeting${name.isNotEmpty ? ', $name' : ''}! 👋',
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(height: AppDimensions.spacingXS),
                Text(
                  dateStr,
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.white.withValues(alpha: 0.75),
                    fontWeight: FontWeight.w400,
                  ),
                ),
                const SizedBox(height: AppDimensions.spacingM),
                Text(
                  'Kelola konten dan halaman website Anda hari ini.',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.white.withValues(alpha: 0.85),
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: AppDimensions.spacingM),
          Opacity(
            opacity: 0.25,
            child: Icon(
              Icons.dashboard_customize_rounded,
              size: 90,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  // ── Stat Cards ────────────────────────────────────────────────────────────

  Widget _buildStatCards(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isWide = screenWidth >= 900;

    final cards = [
      _StatCardData(
        label: AppStrings.totalPosts,
        value: _contentCount,
        icon: Icons.article_rounded,
        color: AppColors.cardAccentBlue,
        lightColor: AppColors.primaryLight,
        trend: '+12%',
        trendUp: true,
      ),
      _StatCardData(
        label: 'Published',
        value: _publishedCount,
        icon: Icons.check_circle_rounded,
        color: AppColors.cardAccentGreen,
        lightColor: AppColors.successLight,
        trend: '+5%',
        trendUp: true,
      ),
      _StatCardData(
        label: AppStrings.contentCategoryTitle,
        value: _categoryCount,
        icon: Icons.label_rounded,
        color: AppColors.cardAccentOrange,
        lightColor: AppColors.warningLight,
        trend: '0%',
        trendUp: true,
      ),
      _StatCardData(
        label: AppStrings.pageListTitle,
        value: _pageCount,
        icon: Icons.web_rounded,
        color: AppColors.cardAccentCyan,
        lightColor: AppColors.secondaryLight,
        trend: '+3%',
        trendUp: true,
      ),
    ];

    if (isWide) {
      return Row(
        children: cards.map((card) {
          final isLast = card == cards.last;
          return Expanded(
            child: Padding(
              padding: EdgeInsets.only(
                  right: isLast ? 0 : AppDimensions.spacingM),
              child: _buildStatCard(card),
            ),
          );
        }).toList(),
      );
    }

    return Wrap(
      spacing: AppDimensions.spacingM,
      runSpacing: AppDimensions.spacingM,
      children: cards
          .map((card) => SizedBox(
                width: (screenWidth -
                        AppDimensions.spacingXL * 2 -
                        AppDimensions.spacingM) /
                    2,
                child: _buildStatCard(card),
              ))
          .toList(),
    );
  }

  Widget _buildStatCard(_StatCardData data) {
    return Container(
      padding: const EdgeInsets.all(AppDimensions.spacingL),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppDimensions.radiusL),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: data.lightColor,
                  borderRadius: BorderRadius.circular(AppDimensions.radiusM),
                ),
                child: Icon(data.icon, color: data.color, size: 22),
              ),
              const Spacer(),
              _buildTrendBadge(data.trend, data.trendUp),
            ],
          ),
          const SizedBox(height: AppDimensions.spacingM),
          Text(
            data.value.toString(),
            style: const TextStyle(
              fontSize: 30,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
              letterSpacing: -1,
            ),
          ),
          const SizedBox(height: AppDimensions.spacingXS),
          Text(
            data.label,
            style: const TextStyle(
              fontSize: 13,
              color: AppColors.textSecondary,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTrendBadge(String trend, bool trendUp) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: trendUp ? AppColors.successLight : AppColors.errorLight,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              trendUp ? Icons.trending_up_rounded : Icons.trending_down_rounded,
              size: 12,
              color: trendUp ? AppColors.success : AppColors.error,
            ),
            const SizedBox(width: 2),
            Text(
              trend,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: trendUp ? AppColors.success : AppColors.error,
              ),
            ),
          ],
        ),
      );

  // ── Chart Section ─────────────────────────────────────────────────────────

  Widget _buildChartSection(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isWide = screenWidth >= 960;

    if (isWide) {
      return Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(flex: 3, child: _buildRevenueChart()),
          const SizedBox(width: AppDimensions.spacingM),
          Expanded(flex: 2, child: _buildRecentActivity()),
        ],
      );
    }

    return Column(
      children: [
        _buildRevenueChart(),
        const SizedBox(height: AppDimensions.spacingM),
        _buildRecentActivity(),
      ],
    );
  }

  Widget _buildRevenueChart() {
    // Simulasi data 7 hari terakhir
    final spots = [
      const FlSpot(0, 3),
      const FlSpot(1, 5),
      const FlSpot(2, 4),
      const FlSpot(3, 7),
      const FlSpot(4, 6),
      const FlSpot(5, 9),
      const FlSpot(6, 8),
    ];

    final labels = ['Sen', 'Sel', 'Rab', 'Kam', 'Jum', 'Sab', 'Min'];

    return Container(
      padding: const EdgeInsets.all(AppDimensions.spacingL),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppDimensions.radiusL),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildChartHeader(),
          const SizedBox(height: AppDimensions.spacingL),
          SizedBox(
            height: 200,
            child: LineChart(
              LineChartData(
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  horizontalInterval: 2,
                  getDrawingHorizontalLine: (_) => const FlLine(
                    color: AppColors.chartGrid,
                    strokeWidth: 1,
                  ),
                ),
                titlesData: FlTitlesData(
                  show: true,
                  rightTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  topTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      interval: 1,
                      getTitlesWidget: (value, meta) {
                        final idx = value.toInt();
                        if (idx < 0 || idx >= labels.length) {
                          return const SizedBox.shrink();
                        }
                        return Padding(
                          padding: const EdgeInsets.only(top: 8),
                          child: Text(
                            labels[idx],
                            style: const TextStyle(
                              fontSize: 11,
                              color: AppColors.textHint,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      interval: 2,
                      reservedSize: 28,
                      getTitlesWidget: (value, meta) => Text(
                        value.toInt().toString(),
                        style: const TextStyle(
                          fontSize: 11,
                          color: AppColors.textHint,
                        ),
                      ),
                    ),
                  ),
                ),
                borderData: FlBorderData(show: false),
                minY: 0,
                maxY: 12,
                lineBarsData: [
                  LineChartBarData(
                    spots: spots,
                    isCurved: true,
                    color: AppColors.primary,
                    barWidth: 3,
                    isStrokeCapRound: true,
                    dotData: const FlDotData(show: false),
                    belowBarData: BarAreaData(
                      show: true,
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          AppColors.primary.withValues(alpha: 0.2),
                          AppColors.primary.withValues(alpha: 0.0),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChartHeader() => Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Aktivitas Konten',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '7 hari terakhir',
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.textHint,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: AppColors.primaryLight,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: const [
                Icon(Icons.circle, size: 8, color: AppColors.primary),
                SizedBox(width: 6),
                Text(
                  'Konten',
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      );

  Widget _buildRecentActivity() => Container(
        padding: const EdgeInsets.all(AppDimensions.spacingL),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(AppDimensions.radiusL),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 16,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Ringkasan',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: AppDimensions.spacingL),
            _buildProgressItem('Konten Terbit', _publishedCount, _contentCount,
                AppColors.cardAccentBlue),
            const SizedBox(height: AppDimensions.spacingM),
            _buildProgressItem('Draft', _contentCount - _publishedCount,
                _contentCount, AppColors.cardAccentOrange),
            const SizedBox(height: AppDimensions.spacingL),
            const Divider(color: AppColors.divider),
            const SizedBox(height: AppDimensions.spacingM),
            _buildSummaryRow(Icons.category_rounded, 'Total Kategori',
                _categoryCount.toString(), AppColors.cardAccentGreen),
            const SizedBox(height: AppDimensions.spacingS),
            _buildSummaryRow(Icons.web_rounded, 'Total Halaman',
                _pageCount.toString(), AppColors.cardAccentCyan),
          ],
        ),
      );

  Widget _buildProgressItem(
      String label, int value, int total, Color color) {
    final percent = total > 0 ? (value / total).clamp(0.0, 1.0) : 0.0;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: const TextStyle(
                fontSize: 13,
                color: AppColors.textSecondary,
                fontWeight: FontWeight.w500,
              ),
            ),
            Text(
              '$value / $total',
              style: const TextStyle(
                fontSize: 13,
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: percent,
            backgroundColor: AppColors.background,
            valueColor: AlwaysStoppedAnimation<Color>(color),
            minHeight: 6,
          ),
        ),
      ],
    );
  }

  Widget _buildSummaryRow(
      IconData icon, String label, String value, Color color) =>
      Row(
        children: [
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(AppDimensions.radiusS),
            ),
            child: Icon(icon, size: 16, color: color),
          ),
          const SizedBox(width: AppDimensions.spacingS),
          Expanded(
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 13,
                color: AppColors.textSecondary,
              ),
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
        ],
      );

  // ── Quick Actions ─────────────────────────────────────────────────────────

  Widget _buildQuickActions(BuildContext context) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Aksi Cepat',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: AppDimensions.spacingM),
          Wrap(
            spacing: AppDimensions.spacingM,
            runSpacing: AppDimensions.spacingM,
            children: [
              _buildActionCard(
                icon: Icons.add_circle_outline_rounded,
                label: 'Buat Konten',
                color: AppColors.primary,
                lightColor: AppColors.primaryLight,
                onTap: () => context.go('/content/create'),
              ),
              _buildActionCard(
                icon: Icons.web_outlined,
                label: 'Kelola Halaman',
                color: AppColors.secondary,
                lightColor: AppColors.secondaryLight,
                onTap: () => context.go('/pages'),
              ),
              _buildActionCard(
                icon: Icons.label_outline_rounded,
                label: 'Kategori',
                color: AppColors.cardAccentOrange,
                lightColor: AppColors.warningLight,
                onTap: () => context.go('/content-category'),
              ),
              _buildActionCard(
                icon: Icons.perm_media_outlined,
                label: 'Media',
                color: AppColors.cardAccentGreen,
                lightColor: AppColors.successLight,
                onTap: () => context.go('/media'),
              ),
            ],
          ),
        ],
      );

  Widget _buildActionCard({
    required IconData icon,
    required String label,
    required Color color,
    required Color lightColor,
    required VoidCallback onTap,
  }) =>
      Material(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppDimensions.radiusL),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(AppDimensions.radiusL),
          child: Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppDimensions.spacingL,
              vertical: AppDimensions.spacingM,
            ),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(AppDimensions.radiusL),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.04),
                  blurRadius: 12,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: lightColor,
                    borderRadius: BorderRadius.circular(AppDimensions.radiusM),
                  ),
                  child: Icon(icon, size: 18, color: color),
                ),
                const SizedBox(width: AppDimensions.spacingS),
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ),
          ),
        ),
      );

  String _getGreeting(DateTime now) {
    final hour = now.hour;
    if (hour < 12) return 'Selamat Pagi';
    if (hour < 17) return 'Selamat Siang';
    return 'Selamat Malam';
  }
}

class _StatCardData {
  final String label;
  final int value;
  final IconData icon;
  final Color color;
  final Color lightColor;
  final String trend;
  final bool trendUp;

  const _StatCardData({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
    required this.lightColor,
    required this.trend,
    required this.trendUp,
  });
}
