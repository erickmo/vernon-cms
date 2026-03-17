import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../features/auth/data/datasources/auth_local_datasource.dart';
import '../../features/auth/data/datasources/auth_remote_datasource.dart';
import '../../features/auth/data/repositories/auth_repository_impl.dart';
import '../../features/auth/domain/repositories/auth_repository.dart';
import '../../features/auth/domain/usecases/get_remembered_username_usecase.dart';
import '../../features/auth/domain/usecases/login_usecase.dart';
import '../../features/auth/domain/usecases/register_usecase.dart';
import '../../features/auth/presentation/cubit/login_cubit.dart';
import '../../features/auth/presentation/cubit/register_cubit.dart';
import '../../features/dashboard/data/datasources/dashboard_remote_datasource.dart';
import '../../features/dashboard/data/repositories/dashboard_repository_impl.dart';
import '../../features/dashboard/domain/repositories/dashboard_repository.dart';
import '../../features/dashboard/domain/usecases/get_daily_content_usecase.dart';
import '../../features/dashboard/domain/usecases/get_dashboard_stats_usecase.dart';
import '../../features/content/data/datasources/content_category_remote_datasource.dart';
import '../../features/content/data/repositories/content_category_repository_impl.dart';
import '../../features/content/domain/repositories/content_category_repository.dart';
import '../../features/content/domain/usecases/create_content_category_usecase.dart';
import '../../features/content/domain/usecases/delete_content_category_usecase.dart';
import '../../features/content/domain/usecases/get_content_categories_usecase.dart';
import '../../features/content/domain/usecases/update_content_category_usecase.dart';
import '../../features/content/data/datasources/content_remote_datasource.dart';
import '../../features/content/data/repositories/content_repository_impl.dart';
import '../../features/content/domain/repositories/content_repository.dart';
import '../../features/content/domain/usecases/create_content_usecase.dart';
import '../../features/content/domain/usecases/delete_content_usecase.dart';
import '../../features/content/domain/usecases/get_content_detail_usecase.dart';
import '../../features/content/domain/usecases/get_contents_usecase.dart';
import '../../features/content/domain/usecases/publish_content_usecase.dart';
import '../../features/content/domain/usecases/update_content_usecase.dart';
import '../../features/content/presentation/cubit/content_category_cubit.dart';
import '../../features/content/presentation/cubit/content_form_cubit.dart';
import '../../features/content/presentation/cubit/content_list_cubit.dart';
import '../../features/page_management/data/datasources/page_remote_datasource.dart';
import '../../features/page_management/data/repositories/page_repository_impl.dart';
import '../../features/page_management/domain/repositories/page_repository.dart';
import '../../features/page_management/domain/usecases/create_page_usecase.dart';
import '../../features/page_management/domain/usecases/delete_page_usecase.dart';
import '../../features/page_management/domain/usecases/get_page_detail_usecase.dart';
import '../../features/page_management/domain/usecases/get_pages_usecase.dart';
import '../../features/page_management/domain/usecases/update_page_usecase.dart';
import '../../features/page_management/presentation/cubit/page_form_cubit.dart';
import '../../features/page_management/presentation/cubit/page_list_cubit.dart';
import '../../features/dashboard/presentation/cubit/dashboard_cubit.dart';
import '../../features/domain_builder/data/datasources/domain_builder_remote_datasource.dart';
import '../../features/domain_builder/data/repositories/domain_builder_repository_impl.dart';
import '../../features/domain_builder/domain/repositories/domain_builder_repository.dart';
import '../../features/domain_builder/domain/usecases/create_domain_usecase.dart';
import '../../features/domain_builder/domain/usecases/delete_domain_usecase.dart';
import '../../features/domain_builder/domain/usecases/get_domain_detail_usecase.dart';
import '../../features/domain_builder/domain/usecases/get_domains_usecase.dart';
import '../../features/domain_builder/domain/usecases/update_domain_usecase.dart';
import '../../features/domain_builder/presentation/cubit/domain_builder_cubit.dart';
import '../../features/domain_builder/presentation/cubit/domain_form_cubit.dart';
import '../../features/domain_records/data/datasources/domain_records_remote_datasource.dart';
import '../../features/domain_records/data/repositories/domain_records_repository_impl.dart';
import '../../features/domain_records/domain/repositories/domain_records_repository.dart';
import '../../features/domain_records/domain/usecases/create_domain_record_usecase.dart';
import '../../features/domain_records/domain/usecases/delete_domain_record_usecase.dart';
import '../../features/domain_records/domain/usecases/get_domain_record_detail_usecase.dart';
import '../../features/domain_records/domain/usecases/get_domain_records_usecase.dart';
import '../../features/domain_records/domain/usecases/get_record_options_usecase.dart';
import '../../features/domain_records/domain/usecases/update_domain_record_usecase.dart';
import '../../features/domain_records/presentation/cubit/domain_record_form_cubit.dart';
import '../../features/domain_records/presentation/cubit/domain_record_list_cubit.dart';
import '../../features/media/data/datasources/media_remote_datasource.dart';
import '../../features/media/data/repositories/media_repository_impl.dart';
import '../../features/media/domain/repositories/media_repository.dart';
import '../../features/media/domain/usecases/delete_media_usecase.dart';
import '../../features/media/domain/usecases/get_media_detail_usecase.dart';
import '../../features/media/domain/usecases/get_media_folders_usecase.dart';
import '../../features/media/domain/usecases/get_media_list_usecase.dart';
import '../../features/media/domain/usecases/update_media_usecase.dart';
import '../../features/media/domain/usecases/upload_media_usecase.dart';
import '../../features/media/presentation/cubit/media_list_cubit.dart';
import '../../features/user_management/data/datasources/user_remote_datasource.dart';
import '../../features/user_management/data/repositories/user_repository_impl.dart';
import '../../features/user_management/domain/repositories/user_repository.dart';
import '../../features/user_management/domain/usecases/create_user_usecase.dart';
import '../../features/user_management/domain/usecases/delete_user_usecase.dart';
import '../../features/user_management/domain/usecases/get_user_detail_usecase.dart';
import '../../features/user_management/domain/usecases/get_users_usecase.dart';
import '../../features/user_management/domain/usecases/update_user_usecase.dart';
import '../../features/user_management/presentation/cubit/user_form_cubit.dart';
import '../../features/user_management/presentation/cubit/user_list_cubit.dart';
import '../../features/settings/data/datasources/settings_remote_datasource.dart';
import '../../features/settings/data/repositories/settings_repository_impl.dart';
import '../../features/settings/domain/repositories/settings_repository.dart';
import '../../features/settings/domain/usecases/get_settings_usecase.dart';
import '../../features/settings/domain/usecases/update_settings_usecase.dart';
import '../../features/settings/presentation/cubit/settings_cubit.dart';
import '../../features/activity_log/data/datasources/activity_log_remote_datasource.dart';
import '../../features/activity_log/data/repositories/activity_log_repository_impl.dart';
import '../../features/activity_log/domain/repositories/activity_log_repository.dart';
import '../../features/activity_log/domain/usecases/get_activity_logs_usecase.dart';
import '../../features/activity_log/presentation/cubit/activity_log_cubit.dart';
import '../../features/api_token/data/datasources/api_token_remote_datasource.dart';
import '../../features/api_token/data/repositories/api_token_repository_impl.dart';
import '../../features/api_token/domain/repositories/api_token_repository.dart';
import '../../features/api_token/domain/usecases/create_api_token_usecase.dart';
import '../../features/api_token/domain/usecases/delete_api_token_usecase.dart';
import '../../features/api_token/domain/usecases/get_api_tokens_usecase.dart';
import '../../features/api_token/domain/usecases/toggle_api_token_usecase.dart';
import '../../features/api_token/domain/usecases/update_api_token_usecase.dart';
import '../../features/api_token/presentation/cubit/api_token_cubit.dart';
import '../../shared/presentation/cubit/sidebar_cubit.dart';
import '../network/api_client.dart';

final getIt = GetIt.instance;

/// Inisialisasi dependency injection.
/// Dipanggil satu kali di main() sebelum runApp().
Future<void> configureDependencies() async {
  // External
  final prefs = await SharedPreferences.getInstance();
  getIt.registerSingleton<SharedPreferences>(prefs);

  // Core
  getIt.registerSingleton<ApiClient>(ApiClient(prefs));

  // ─── Auth ───
  // Data Sources
  getIt.registerLazySingleton<AuthRemoteDataSource>(
    () => AuthRemoteDataSourceImpl(getIt<ApiClient>()),
  );
  getIt.registerLazySingleton<AuthLocalDataSource>(
    () => AuthLocalDataSourceImpl(getIt<SharedPreferences>()),
  );

  // Repository
  getIt.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(
      remoteDataSource: getIt<AuthRemoteDataSource>(),
      localDataSource: getIt<AuthLocalDataSource>(),
    ),
  );

  // Use Cases
  getIt.registerLazySingleton(
    () => LoginUseCase(getIt<AuthRepository>()),
  );
  getIt.registerLazySingleton(
    () => GetRememberedUsernameUseCase(getIt<AuthRepository>()),
  );
  getIt.registerLazySingleton(
    () => RegisterUseCase(getIt<AuthRepository>()),
  );

  // Cubit
  getIt.registerFactory(
    () => LoginCubit(
      loginUseCase: getIt<LoginUseCase>(),
      getRememberedUsernameUseCase: getIt<GetRememberedUsernameUseCase>(),
    ),
  );
  getIt.registerFactory(
    () => RegisterCubit(
      registerUseCase: getIt<RegisterUseCase>(),
    ),
  );

  // ─── Dashboard ───
  // Data Sources
  getIt.registerLazySingleton<DashboardRemoteDataSource>(
    () => DashboardRemoteDataSourceImpl(getIt<ApiClient>()),
  );

  // Repository
  getIt.registerLazySingleton<DashboardRepository>(
    () => DashboardRepositoryImpl(
      remoteDataSource: getIt<DashboardRemoteDataSource>(),
    ),
  );

  // Use Cases
  getIt.registerLazySingleton(
    () => GetDashboardStatsUseCase(getIt<DashboardRepository>()),
  );
  getIt.registerLazySingleton(
    () => GetDailyContentUseCase(getIt<DashboardRepository>()),
  );

  // Cubit
  getIt.registerFactory(
    () => DashboardCubit(
      getStatsUseCase: getIt<GetDashboardStatsUseCase>(),
      getDailyContentUseCase: getIt<GetDailyContentUseCase>(),
    ),
  );

  // ─── Content Category ───
  // Data Sources
  getIt.registerLazySingleton<ContentCategoryRemoteDataSource>(
    () => ContentCategoryRemoteDataSourceImpl(getIt<ApiClient>()),
  );

  // Repository
  getIt.registerLazySingleton<ContentCategoryRepository>(
    () => ContentCategoryRepositoryImpl(
      remoteDataSource: getIt<ContentCategoryRemoteDataSource>(),
    ),
  );

  // Use Cases
  getIt.registerLazySingleton(
    () => GetContentCategoriesUseCase(getIt<ContentCategoryRepository>()),
  );
  getIt.registerLazySingleton(
    () => CreateContentCategoryUseCase(getIt<ContentCategoryRepository>()),
  );
  getIt.registerLazySingleton(
    () => UpdateContentCategoryUseCase(getIt<ContentCategoryRepository>()),
  );
  getIt.registerLazySingleton(
    () => DeleteContentCategoryUseCase(getIt<ContentCategoryRepository>()),
  );

  // Cubit
  getIt.registerFactory(
    () => ContentCategoryCubit(
      getCategoriesUseCase: getIt<GetContentCategoriesUseCase>(),
      createCategoryUseCase: getIt<CreateContentCategoryUseCase>(),
      updateCategoryUseCase: getIt<UpdateContentCategoryUseCase>(),
      deleteCategoryUseCase: getIt<DeleteContentCategoryUseCase>(),
    ),
  );

  // ─── Content ───
  // Data Sources
  getIt.registerLazySingleton<ContentRemoteDataSource>(
    () => ContentRemoteDataSourceImpl(getIt<ApiClient>()),
  );

  // Repository
  getIt.registerLazySingleton<ContentRepository>(
    () => ContentRepositoryImpl(
      remoteDataSource: getIt<ContentRemoteDataSource>(),
    ),
  );

  // Use Cases
  getIt.registerLazySingleton(
    () => GetContentsUseCase(getIt<ContentRepository>()),
  );
  getIt.registerLazySingleton(
    () => GetContentDetailUseCase(getIt<ContentRepository>()),
  );
  getIt.registerLazySingleton(
    () => CreateContentUseCase(getIt<ContentRepository>()),
  );
  getIt.registerLazySingleton(
    () => UpdateContentUseCase(getIt<ContentRepository>()),
  );
  getIt.registerLazySingleton(
    () => DeleteContentUseCase(getIt<ContentRepository>()),
  );
  getIt.registerLazySingleton(
    () => PublishContentUseCase(getIt<ContentRepository>()),
  );

  // Cubit
  getIt.registerFactory(
    () => ContentListCubit(
      getContentsUseCase: getIt<GetContentsUseCase>(),
      deleteContentUseCase: getIt<DeleteContentUseCase>(),
      publishContentUseCase: getIt<PublishContentUseCase>(),
    ),
  );
  getIt.registerFactory(
    () => ContentFormCubit(
      getContentDetailUseCase: getIt<GetContentDetailUseCase>(),
      createContentUseCase: getIt<CreateContentUseCase>(),
      updateContentUseCase: getIt<UpdateContentUseCase>(),
    ),
  );

  // ─── Page Management ───
  // Data Sources
  getIt.registerLazySingleton<PageRemoteDataSource>(
    () => PageRemoteDataSourceImpl(getIt<ApiClient>()),
  );

  // Repository
  getIt.registerLazySingleton<PageRepository>(
    () => PageRepositoryImpl(
      remoteDataSource: getIt<PageRemoteDataSource>(),
    ),
  );

  // Use Cases
  getIt.registerLazySingleton(
    () => GetPagesUseCase(getIt<PageRepository>()),
  );
  getIt.registerLazySingleton(
    () => GetPageDetailUseCase(getIt<PageRepository>()),
  );
  getIt.registerLazySingleton(
    () => CreatePageUseCase(getIt<PageRepository>()),
  );
  getIt.registerLazySingleton(
    () => UpdatePageUseCase(getIt<PageRepository>()),
  );
  getIt.registerLazySingleton(
    () => DeletePageUseCase(getIt<PageRepository>()),
  );

  // Cubit
  getIt.registerFactory(
    () => PageListCubit(
      getPagesUseCase: getIt<GetPagesUseCase>(),
      deletePageUseCase: getIt<DeletePageUseCase>(),
    ),
  );
  getIt.registerFactory(
    () => PageFormCubit(
      getPageDetailUseCase: getIt<GetPageDetailUseCase>(),
      createPageUseCase: getIt<CreatePageUseCase>(),
      updatePageUseCase: getIt<UpdatePageUseCase>(),
    ),
  );

  // ─── Domain Builder ───
  // Data Sources
  getIt.registerLazySingleton<DomainBuilderRemoteDataSource>(
    () => DomainBuilderRemoteDataSourceImpl(getIt<ApiClient>()),
  );

  // Repository
  getIt.registerLazySingleton<DomainBuilderRepository>(
    () => DomainBuilderRepositoryImpl(
      remoteDataSource: getIt<DomainBuilderRemoteDataSource>(),
    ),
  );

  // Use Cases
  getIt.registerLazySingleton(
    () => GetDomainsUseCase(getIt<DomainBuilderRepository>()),
  );
  getIt.registerLazySingleton(
    () => GetDomainDetailUseCase(getIt<DomainBuilderRepository>()),
  );
  getIt.registerLazySingleton(
    () => CreateDomainUseCase(getIt<DomainBuilderRepository>()),
  );
  getIt.registerLazySingleton(
    () => UpdateDomainUseCase(getIt<DomainBuilderRepository>()),
  );
  getIt.registerLazySingleton(
    () => DeleteDomainUseCase(getIt<DomainBuilderRepository>()),
  );

  // Cubit
  getIt.registerFactory(
    () => DomainBuilderCubit(
      getDomainsUseCase: getIt<GetDomainsUseCase>(),
      deleteDomainUseCase: getIt<DeleteDomainUseCase>(),
    ),
  );
  getIt.registerFactory(
    () => DomainFormCubit(
      getDomainDetailUseCase: getIt<GetDomainDetailUseCase>(),
      createDomainUseCase: getIt<CreateDomainUseCase>(),
      updateDomainUseCase: getIt<UpdateDomainUseCase>(),
    ),
  );

  // ─── Domain Records ───
  // Data Sources
  getIt.registerLazySingleton<DomainRecordsRemoteDataSource>(
    () => DomainRecordsRemoteDataSourceImpl(getIt<ApiClient>()),
  );

  // Repository
  getIt.registerLazySingleton<DomainRecordsRepository>(
    () => DomainRecordsRepositoryImpl(
      remoteDataSource: getIt<DomainRecordsRemoteDataSource>(),
    ),
  );

  // Use Cases
  getIt.registerLazySingleton(
    () => GetDomainRecordsUseCase(getIt<DomainRecordsRepository>()),
  );
  getIt.registerLazySingleton(
    () => GetDomainRecordDetailUseCase(getIt<DomainRecordsRepository>()),
  );
  getIt.registerLazySingleton(
    () => CreateDomainRecordUseCase(getIt<DomainRecordsRepository>()),
  );
  getIt.registerLazySingleton(
    () => UpdateDomainRecordUseCase(getIt<DomainRecordsRepository>()),
  );
  getIt.registerLazySingleton(
    () => DeleteDomainRecordUseCase(getIt<DomainRecordsRepository>()),
  );
  getIt.registerLazySingleton(
    () => GetRecordOptionsUseCase(getIt<DomainRecordsRepository>()),
  );

  // Cubit
  getIt.registerFactory(
    () => DomainRecordListCubit(
      getRecordsUseCase: getIt<GetDomainRecordsUseCase>(),
      deleteRecordUseCase: getIt<DeleteDomainRecordUseCase>(),
    ),
  );
  getIt.registerFactory(
    () => DomainRecordFormCubit(
      getRecordDetailUseCase: getIt<GetDomainRecordDetailUseCase>(),
      createRecordUseCase: getIt<CreateDomainRecordUseCase>(),
      updateRecordUseCase: getIt<UpdateDomainRecordUseCase>(),
    ),
  );

  // ─── Media ───
  // Data Sources
  getIt.registerLazySingleton<MediaRemoteDataSource>(
    () => MediaRemoteDataSourceImpl(getIt<ApiClient>()),
  );

  // Repository
  getIt.registerLazySingleton<MediaRepository>(
    () => MediaRepositoryImpl(
      remoteDataSource: getIt<MediaRemoteDataSource>(),
    ),
  );

  // Use Cases
  getIt.registerLazySingleton(
    () => GetMediaListUseCase(getIt<MediaRepository>()),
  );
  getIt.registerLazySingleton(
    () => GetMediaDetailUseCase(getIt<MediaRepository>()),
  );
  getIt.registerLazySingleton(
    () => UploadMediaUseCase(getIt<MediaRepository>()),
  );
  getIt.registerLazySingleton(
    () => UpdateMediaUseCase(getIt<MediaRepository>()),
  );
  getIt.registerLazySingleton(
    () => DeleteMediaUseCase(getIt<MediaRepository>()),
  );
  getIt.registerLazySingleton(
    () => GetMediaFoldersUseCase(getIt<MediaRepository>()),
  );

  // Cubit
  getIt.registerFactory(
    () => MediaListCubit(
      getMediaListUseCase: getIt<GetMediaListUseCase>(),
      getMediaFoldersUseCase: getIt<GetMediaFoldersUseCase>(),
      uploadMediaUseCase: getIt<UploadMediaUseCase>(),
      updateMediaUseCase: getIt<UpdateMediaUseCase>(),
      deleteMediaUseCase: getIt<DeleteMediaUseCase>(),
    ),
  );

  // ─── User Management ───
  // Data Sources
  getIt.registerLazySingleton<UserRemoteDataSource>(
    () => UserRemoteDataSourceImpl(getIt<ApiClient>()),
  );

  // Repository
  getIt.registerLazySingleton<UserRepository>(
    () => UserRepositoryImpl(
      remoteDataSource: getIt<UserRemoteDataSource>(),
    ),
  );

  // Use Cases
  getIt.registerLazySingleton(
    () => GetUsersUseCase(getIt<UserRepository>()),
  );
  getIt.registerLazySingleton(
    () => GetUserDetailUseCase(getIt<UserRepository>()),
  );
  getIt.registerLazySingleton(
    () => CreateUserUseCase(getIt<UserRepository>()),
  );
  getIt.registerLazySingleton(
    () => UpdateUserUseCase(getIt<UserRepository>()),
  );
  getIt.registerLazySingleton(
    () => DeleteUserUseCase(getIt<UserRepository>()),
  );

  // Cubit
  getIt.registerFactory(
    () => UserListCubit(
      getUsersUseCase: getIt<GetUsersUseCase>(),
      deleteUserUseCase: getIt<DeleteUserUseCase>(),
    ),
  );
  getIt.registerFactory(
    () => UserFormCubit(
      getUserDetailUseCase: getIt<GetUserDetailUseCase>(),
      createUserUseCase: getIt<CreateUserUseCase>(),
      updateUserUseCase: getIt<UpdateUserUseCase>(),
    ),
  );

  // ─── Settings ───
  // Data Sources
  getIt.registerLazySingleton<SettingsRemoteDataSource>(
    () => SettingsRemoteDataSourceImpl(getIt<ApiClient>()),
  );

  // Repository
  getIt.registerLazySingleton<SettingsRepository>(
    () => SettingsRepositoryImpl(
      remoteDataSource: getIt<SettingsRemoteDataSource>(),
    ),
  );

  // Use Cases
  getIt.registerLazySingleton(
    () => GetSettingsUseCase(getIt<SettingsRepository>()),
  );
  getIt.registerLazySingleton(
    () => UpdateSettingsUseCase(getIt<SettingsRepository>()),
  );

  // Cubit
  getIt.registerFactory(
    () => SettingsCubit(
      getSettingsUseCase: getIt<GetSettingsUseCase>(),
      updateSettingsUseCase: getIt<UpdateSettingsUseCase>(),
    ),
  );

  // ─── Activity Log ───
  // Data Sources
  getIt.registerLazySingleton<ActivityLogRemoteDataSource>(
    () => ActivityLogRemoteDataSourceImpl(getIt<ApiClient>()),
  );

  // Repository
  getIt.registerLazySingleton<ActivityLogRepository>(
    () => ActivityLogRepositoryImpl(
      remoteDataSource: getIt<ActivityLogRemoteDataSource>(),
    ),
  );

  // Use Cases
  getIt.registerLazySingleton(
    () => GetActivityLogsUseCase(getIt<ActivityLogRepository>()),
  );

  // Cubit
  getIt.registerFactory(
    () => ActivityLogCubit(
      getActivityLogsUseCase: getIt<GetActivityLogsUseCase>(),
    ),
  );

  // ─── API Token ───
  // Data Sources
  getIt.registerLazySingleton<ApiTokenRemoteDataSource>(
    () => ApiTokenRemoteDataSourceImpl(getIt<ApiClient>()),
  );

  // Repository
  getIt.registerLazySingleton<ApiTokenRepository>(
    () => ApiTokenRepositoryImpl(
      remoteDataSource: getIt<ApiTokenRemoteDataSource>(),
    ),
  );

  // Use Cases
  getIt.registerLazySingleton(
    () => GetApiTokensUseCase(getIt<ApiTokenRepository>()),
  );
  getIt.registerLazySingleton(
    () => CreateApiTokenUseCase(getIt<ApiTokenRepository>()),
  );
  getIt.registerLazySingleton(
    () => UpdateApiTokenUseCase(getIt<ApiTokenRepository>()),
  );
  getIt.registerLazySingleton(
    () => DeleteApiTokenUseCase(getIt<ApiTokenRepository>()),
  );
  getIt.registerLazySingleton(
    () => ToggleApiTokenUseCase(getIt<ApiTokenRepository>()),
  );

  // Cubit
  getIt.registerFactory(
    () => ApiTokenCubit(
      getTokensUseCase: getIt<GetApiTokensUseCase>(),
      createTokenUseCase: getIt<CreateApiTokenUseCase>(),
      updateTokenUseCase: getIt<UpdateApiTokenUseCase>(),
      deleteTokenUseCase: getIt<DeleteApiTokenUseCase>(),
      toggleTokenUseCase: getIt<ToggleApiTokenUseCase>(),
    ),
  );

  // ─── Sidebar ───
  getIt.registerFactory(
    () => SidebarCubit(
      getDomainsUseCase: getIt<GetDomainsUseCase>(),
    ),
  );
}
