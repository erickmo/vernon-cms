import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../features/auth/data/datasources/auth_remote_datasource.dart';
import '../../features/auth/data/repositories/auth_repository_impl.dart';
import '../../features/auth/domain/repositories/auth_repository.dart';
import '../../features/auth/domain/usecases/login_usecase.dart';
import '../../features/auth/domain/usecases/logout_usecase.dart';
import '../../features/auth/presentation/cubit/login_cubit.dart';
import '../../features/client/data/datasources/client_remote_datasource.dart';
import '../../features/client/data/repositories/client_repository_impl.dart';
import '../../features/client/domain/repositories/client_repository.dart';
import '../../features/client/domain/usecases/create_client_usecase.dart';
import '../../features/client/domain/usecases/delete_client_usecase.dart';
import '../../features/client/domain/usecases/get_client_usecase.dart';
import '../../features/client/domain/usecases/get_clients_usecase.dart';
import '../../features/client/domain/usecases/toggle_client_active_usecase.dart';
import '../../features/client/domain/usecases/update_client_usecase.dart';
import '../../features/client/presentation/cubit/client_detail_cubit.dart';
import '../../features/client/presentation/cubit/client_form_cubit.dart';
import '../../features/client/presentation/cubit/client_list_cubit.dart';
import '../../features/payment/data/datasources/payment_remote_datasource.dart';
import '../../features/payment/data/repositories/payment_repository_impl.dart';
import '../../features/payment/domain/repositories/payment_repository.dart';
import '../../features/payment/domain/usecases/create_payment_usecase.dart';
import '../../features/payment/domain/usecases/get_payment_usecase.dart';
import '../../features/payment/domain/usecases/get_payments_usecase.dart';
import '../../features/payment/presentation/cubit/payment_detail_cubit.dart';
import '../../features/payment/presentation/cubit/payment_form_cubit.dart';
import '../../features/payment/presentation/cubit/payment_list_cubit.dart';
import '../network/api_client.dart';

final getIt = GetIt.instance;

Future<void> configureDependencies() async {
  final prefs = await SharedPreferences.getInstance();
  getIt.registerSingleton<SharedPreferences>(prefs);
  getIt.registerSingleton<ApiClient>(ApiClient(prefs));

  // ── Auth ─────────────────────────────────────────────────────────
  getIt.registerLazySingleton<AuthRemoteDataSource>(
    () => AuthRemoteDataSourceImpl(getIt<ApiClient>()),
  );
  getIt.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(
      remoteDataSource: getIt<AuthRemoteDataSource>(),
      prefs: getIt<SharedPreferences>(),
    ),
  );
  getIt.registerLazySingleton(() => LoginUseCase(getIt<AuthRepository>()));
  getIt.registerLazySingleton(() => LogoutUseCase(getIt<AuthRepository>()));
  getIt.registerFactory(
    () => LoginCubit(
      loginUseCase: getIt<LoginUseCase>(),
    ),
  );

  // ── Client ───────────────────────────────────────────────────────
  getIt.registerLazySingleton<ClientRemoteDataSource>(
    () => ClientRemoteDataSourceImpl(getIt<ApiClient>()),
  );
  getIt.registerLazySingleton<ClientRepository>(
    () => ClientRepositoryImpl(getIt<ClientRemoteDataSource>()),
  );
  getIt.registerLazySingleton(
      () => GetClientsUseCase(getIt<ClientRepository>()));
  getIt.registerLazySingleton(
      () => GetClientUseCase(getIt<ClientRepository>()));
  getIt.registerLazySingleton(
      () => CreateClientUseCase(getIt<ClientRepository>()));
  getIt.registerLazySingleton(
      () => UpdateClientUseCase(getIt<ClientRepository>()));
  getIt.registerLazySingleton(
      () => DeleteClientUseCase(getIt<ClientRepository>()));
  getIt.registerLazySingleton(
      () => ToggleClientActiveUseCase(getIt<ClientRepository>()));
  getIt.registerFactory(
    () => ClientListCubit(
      getClientsUseCase: getIt<GetClientsUseCase>(),
      deleteClientUseCase: getIt<DeleteClientUseCase>(),
      toggleClientActiveUseCase: getIt<ToggleClientActiveUseCase>(),
    ),
  );
  getIt.registerFactory(
    () => ClientFormCubit(
      createClientUseCase: getIt<CreateClientUseCase>(),
      updateClientUseCase: getIt<UpdateClientUseCase>(),
      getClientUseCase: getIt<GetClientUseCase>(),
    ),
  );
  getIt.registerFactory(
    () => ClientDetailCubit(
      getClientUseCase: getIt<GetClientUseCase>(),
      toggleClientActiveUseCase: getIt<ToggleClientActiveUseCase>(),
      deleteClientUseCase: getIt<DeleteClientUseCase>(),
    ),
  );

  // ── Payment ──────────────────────────────────────────────────────
  getIt.registerLazySingleton<PaymentRemoteDataSource>(
    () => PaymentRemoteDataSourceImpl(getIt<ApiClient>()),
  );
  getIt.registerLazySingleton<PaymentRepository>(
    () => PaymentRepositoryImpl(getIt<PaymentRemoteDataSource>()),
  );
  getIt.registerLazySingleton(
      () => GetPaymentsUseCase(getIt<PaymentRepository>()));
  getIt.registerLazySingleton(
      () => GetPaymentUseCase(getIt<PaymentRepository>()));
  getIt.registerLazySingleton(
      () => CreatePaymentUseCase(getIt<PaymentRepository>()));
  getIt.registerFactory(
    () => PaymentListCubit(
      getPaymentsUseCase: getIt<GetPaymentsUseCase>(),
    ),
  );
  getIt.registerFactory(
    () => PaymentFormCubit(
      createPaymentUseCase: getIt<CreatePaymentUseCase>(),
      getClientsUseCase: getIt<GetClientsUseCase>(),
    ),
  );
  getIt.registerFactory(
    () => PaymentDetailCubit(
      getPaymentUseCase: getIt<GetPaymentUseCase>(),
    ),
  );
}
