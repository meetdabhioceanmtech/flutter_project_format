import 'package:get_it/get_it.dart';
import 'package:http/http.dart';
import 'package:oceanmtech_dmt/data/datasources/language_local_data_source.dart';
import 'package:oceanmtech_dmt/data/repositories/app_repository.dart';
import 'package:oceanmtech_dmt/data/repositories/app_repository_impl.dart';
import 'package:oceanmtech_dmt/domain/usecases/get_preferred_language.dart';
import 'package:oceanmtech_dmt/domain/usecases/update_language.dart';
import 'package:oceanmtech_dmt/presentation/cubit/app_language/app_language_cubit.dart';
import 'package:oceanmtech_dmt/presentation/cubit/bottom_navigation/bottom_navigation_cubit.dart';
import 'package:oceanmtech_dmt/presentation/cubit/counter/counter_cubit.dart';
import 'package:oceanmtech_dmt/presentation/cubit/general_setting_cubit/general_setting_cubit.dart';
import 'package:oceanmtech_dmt/presentation/cubit/language/language_cubit.dart';
import 'package:oceanmtech_dmt/presentation/cubit/loading/loading_cubit.dart';
import 'package:oceanmtech_dmt/presentation/cubit/notification/notification_handle/notification_cubit.dart';
import 'package:oceanmtech_dmt/presentation/cubit/notification/selected_notification/selected_notification_cubit.dart';
import 'package:oceanmtech_dmt/presentation/cubit/terms_condition/terms_condition_cubit.dart';
import 'package:oceanmtech_dmt/presentation/cubit/theme/theme_cubit.dart';
import 'package:oceanmtech_dmt/presentation/cubit/toggle_cubit/toggle_cubit.dart';
import 'package:oceanmtech_dmt/data/core/api_client.dart';
import 'package:oceanmtech_dmt/data/datasources/api_data_source.dart';
import 'package:oceanmtech_dmt/data/repositories/api_data_repositorie_impl.dart';
import 'package:oceanmtech_dmt/domain/repositories/api_repositorie.dart';
import 'package:oceanmtech_dmt/domain/usecases/api_usecase.dart';

final getItInstance = GetIt.I;

Future init() async {
  getItInstance.registerLazySingleton<Client>(() => Client());
  getItInstance.registerLazySingleton<ApiClient>(() => ApiClient(getItInstance()));

  // Analytics Property
  // getItInstance.registerLazySingleton<AnalyticsService>(() => AnalyticsService());

  //Data source Dependency
  getItInstance.registerLazySingleton<ApiDataSource>(() => ApiDataSourceImpl(client: getItInstance()));

  //Data Repository Dependency
  getItInstance.registerLazySingleton<ApiDataRepositories>(() => ApiDataRepositoriesImpl(dataSource: getItInstance()));

  //Usecase Dependency
  getItInstance.registerLazySingleton<ApiUsecase>(() => ApiUsecase(dataRepositories: getItInstance()));

  //Bloc Dependency

  //Cubit Dependency
  getItInstance.registerFactory<SelectedNotificationCubit>(() => SelectedNotificationCubit());
  getItInstance.registerFactory<ToggleCubit>(() => ToggleCubit());
  getItInstance.registerFactory<CounterCubit>(() => CounterCubit());
  getItInstance.registerFactory<GeneralSettingCubit>(() => GeneralSettingCubit(apiUsecase: getItInstance()));
  // register cubit register

  getItInstance.registerFactory<TermsConditionCubit>(
      () => TermsConditionCubit(apiUsecase: getItInstance(), loadingCubit: getItInstance()));
  getItInstance.registerFactory<AppLanguageCubit>(
      () => AppLanguageCubit(apiUsecase: getItInstance(), loadingCubit: getItInstance()));

  // Theme Dependency
  getItInstance.registerFactory(() => BottomNavigationCubit());
  getItInstance.registerSingleton<LoadingCubit>(LoadingCubit());
  getItInstance.registerSingleton<ThemeCubit>(ThemeCubit());

  // Language
  getItInstance.registerFactory<LanguageCubit>(
      () => LanguageCubit(getPreferredLanguage: getItInstance(), updateLanguage: getItInstance()));
  getItInstance.registerLazySingleton<LanguageLocalDataSource>(() => LanguageLocalDataSourceImpl());
  getItInstance.registerLazySingleton<AppRepository>(() => AppRepositoryImpl(languageLocalDataSource: getItInstance()));
  getItInstance.registerLazySingleton<GetPreferredLanguage>(() => GetPreferredLanguage(appRepository: getItInstance()));
  getItInstance.registerLazySingleton<UpdateLanguage>(() => UpdateLanguage(appRepository: getItInstance()));
  getItInstance.registerFactory<NotificationCubit>(
    () => NotificationCubit(
      loadingCubit: getItInstance(),
      apiUsecase: getItInstance(),
    ),
  );
}
