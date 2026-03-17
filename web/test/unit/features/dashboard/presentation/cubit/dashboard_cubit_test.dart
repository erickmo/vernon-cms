import 'package:bloc_test/bloc_test.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:vernon_cms_ui/core/errors/failures.dart';
import 'package:vernon_cms_ui/features/dashboard/domain/entities/daily_content.dart';
import 'package:vernon_cms_ui/features/dashboard/domain/entities/dashboard_stats.dart';
import 'package:vernon_cms_ui/features/dashboard/domain/usecases/get_daily_content_usecase.dart';
import 'package:vernon_cms_ui/features/dashboard/domain/usecases/get_dashboard_stats_usecase.dart';
import 'package:vernon_cms_ui/features/dashboard/presentation/cubit/dashboard_cubit.dart';

class MockGetDashboardStatsUseCase extends Mock
    implements GetDashboardStatsUseCase {}

class MockGetDailyContentUseCase extends Mock
    implements GetDailyContentUseCase {}

void main() {
  late DashboardCubit cubit;
  late MockGetDashboardStatsUseCase mockGetStats;
  late MockGetDailyContentUseCase mockGetDailyContent;

  setUp(() {
    mockGetStats = MockGetDashboardStatsUseCase();
    mockGetDailyContent = MockGetDailyContentUseCase();
    cubit = DashboardCubit(
      getStatsUseCase: mockGetStats,
      getDailyContentUseCase: mockGetDailyContent,
    );
  });

  tearDown(() => cubit.close());

  const tStats = DashboardStats(
    totalPosts: 150,
    totalVisits: 12500,
    todayVisits: 320,
    visitGrowthPercent: 12.5,
  );

  final tDailyContent = [
    DailyContent(date: DateTime(2026, 3, 10), count: 5),
    DailyContent(date: DateTime(2026, 3, 11), count: 8),
    DailyContent(date: DateTime(2026, 3, 12), count: 3),
  ];

  group('DashboardCubit', () {
    test('initial state should be DashboardState.initial()', () {
      expect(cubit.state, const DashboardState.initial());
    });

    blocTest<DashboardCubit, DashboardState>(
      'emits [loading, loaded] when data berhasil dimuat',
      build: () {
        when(() => mockGetStats())
            .thenAnswer((_) async => const Right(tStats));
        when(() => mockGetDailyContent(days: 7))
            .thenAnswer((_) async => Right(tDailyContent));
        return cubit;
      },
      act: (cubit) => cubit.loadDashboard(),
      expect: () => [
        const DashboardState.loading(),
        DashboardState.loaded(
          stats: tStats,
          dailyContent: tDailyContent,
        ),
      ],
    );

    blocTest<DashboardCubit, DashboardState>(
      'emits [loading, error] when stats gagal',
      build: () {
        when(() => mockGetStats()).thenAnswer(
          (_) async => const Left(ServerFailure('Server error')),
        );
        when(() => mockGetDailyContent(days: 7))
            .thenAnswer((_) async => Right(tDailyContent));
        return cubit;
      },
      act: (cubit) => cubit.loadDashboard(),
      expect: () => [
        const DashboardState.loading(),
        const DashboardState.error('Server error'),
      ],
    );

    blocTest<DashboardCubit, DashboardState>(
      'emits [loading, error] when daily content gagal',
      build: () {
        when(() => mockGetStats())
            .thenAnswer((_) async => const Right(tStats));
        when(() => mockGetDailyContent(days: 7)).thenAnswer(
          (_) async => const Left(ServerFailure('Gagal memuat chart')),
        );
        return cubit;
      },
      act: (cubit) => cubit.loadDashboard(),
      expect: () => [
        const DashboardState.loading(),
        const DashboardState.error('Gagal memuat chart'),
      ],
    );
  });
}
