import 'package:bloc_test/bloc_test.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:vernon_cms_ui/core/errors/failures.dart';
import 'package:vernon_cms_ui/features/auth/domain/entities/auth_token.dart';
import 'package:vernon_cms_ui/features/auth/domain/entities/login_params.dart';
import 'package:vernon_cms_ui/features/auth/domain/usecases/get_remembered_username_usecase.dart';
import 'package:vernon_cms_ui/features/auth/domain/usecases/login_usecase.dart';
import 'package:vernon_cms_ui/features/auth/presentation/cubit/login_cubit.dart';

class MockLoginUseCase extends Mock implements LoginUseCase {}

class MockGetRememberedUsernameUseCase extends Mock
    implements GetRememberedUsernameUseCase {}

class FakeLoginParams extends Fake implements LoginParams {}

void main() {
  late LoginCubit cubit;
  late MockLoginUseCase mockLoginUseCase;
  late MockGetRememberedUsernameUseCase mockGetRememberedEmail;

  setUpAll(() {
    registerFallbackValue(FakeLoginParams());
  });

  setUp(() {
    mockLoginUseCase = MockLoginUseCase();
    mockGetRememberedEmail = MockGetRememberedUsernameUseCase();
    cubit = LoginCubit(
      loginUseCase: mockLoginUseCase,
      getRememberedUsernameUseCase: mockGetRememberedEmail,
    );
  });

  tearDown(() => cubit.close());

  const tToken = AuthToken(
    accessToken: 'access_123',
    refreshToken: 'refresh_123',
    expiresAt: 1710600000,
  );

  group('LoginCubit', () {
    test('initial state should be LoginState.initial()', () {
      expect(cubit.state, const LoginState.initial());
    });

    group('login', () {
      blocTest<LoginCubit, LoginState>(
        'emits [loading, success] when login berhasil',
        build: () {
          when(() => mockLoginUseCase(any()))
              .thenAnswer((_) async => const Right(tToken));
          return cubit;
        },
        act: (cubit) => cubit.login(
          email: 'admin@example.com',
          password: 'password',
          rememberMe: false,
        ),
        expect: () => [
          const LoginState.loading(),
          const LoginState.success(),
        ],
      );

      blocTest<LoginCubit, LoginState>(
        'emits [loading, error] when login gagal',
        build: () {
          when(() => mockLoginUseCase(any())).thenAnswer(
            (_) async => const Left(
              ServerFailure('Email atau password salah', statusCode: 401),
            ),
          );
          return cubit;
        },
        act: (cubit) => cubit.login(
          email: 'admin@example.com',
          password: 'wrong',
          rememberMe: false,
        ),
        expect: () => [
          const LoginState.loading(),
          const LoginState.error('Email atau password salah'),
        ],
      );
    });

    group('loadRememberedEmail', () {
      blocTest<LoginCubit, LoginState>(
        'emits initial with email when remembered email ada',
        build: () {
          when(() => mockGetRememberedEmail())
              .thenAnswer((_) async => const Right('admin@example.com'));
          return cubit;
        },
        act: (cubit) => cubit.loadRememberedEmail(),
        expect: () => [
          const LoginState.initial(
            rememberedEmail: 'admin@example.com',
            rememberMe: true,
          ),
        ],
      );

      blocTest<LoginCubit, LoginState>(
        'tidak emit state baru when remembered email kosong',
        build: () {
          when(() => mockGetRememberedEmail())
              .thenAnswer((_) async => const Right(null));
          return cubit;
        },
        act: (cubit) => cubit.loadRememberedEmail(),
        expect: () => <LoginState>[],
      );
    });
  });
}
