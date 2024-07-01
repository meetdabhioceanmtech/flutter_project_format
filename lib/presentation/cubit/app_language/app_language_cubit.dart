// ignore_for_file: empty_catches

import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:oceanmtech_dmt/common/constants/api_end_point_constants.dart';
import 'package:oceanmtech_dmt/common/constants/common_router.dart';
import 'package:oceanmtech_dmt/common/constants/hive_constants.dart';
import 'package:oceanmtech_dmt/common/constants/languages.dart';
import 'package:oceanmtech_dmt/data/core/api_constants.dart';
import 'package:oceanmtech_dmt/data/datasources/common_api_call.dart';
import 'package:oceanmtech_dmt/data/models/common_respnse_model.dart';
import 'package:oceanmtech_dmt/data/models/language_model.dart';
import 'package:oceanmtech_dmt/data/models/model_response_extend.dart';
import 'package:oceanmtech_dmt/domain/entities/app_error.dart';
import 'package:oceanmtech_dmt/domain/entities/language/app_language/app_language_entity.dart';
import 'package:oceanmtech_dmt/domain/usecases/api_usecase.dart';
import 'package:oceanmtech_dmt/presentation/cubit/language/language_cubit.dart';
import 'package:oceanmtech_dmt/presentation/cubit/loading/loading_cubit.dart';
import 'package:oceanmtech_dmt/presentation/globals.dart';
import 'package:oceanmtech_dmt/presentation/utils/app_functions.dart';
part 'app_language_state.dart';

class AppLanguageCubit extends Cubit<AppLanguageState> {
  final LoadingCubit loadingCubit;
  final ApiUsecase apiUsecase;
  bool isMounted = true;

  AppLanguageCubit({
    required this.apiUsecase,
    required this.loadingCubit,
  }) : super(const AppLanguageLoadingState());

  Future<void> loadInitialData<T extends ModelResponseExtend>() async {
    if (!isMounted) return;

    emit(const AppLanguageLoadingState());
    final endpoint = dotenv.env[ApiEndPointConstants.API_ENDPOINT_2];
    if (endpoint == null) return;
    Either<AppError, T> response = await apiUsecase.call(
      endpoint: endpoint + ApiConstatnts.salt,
      fromJson: (json) => LanguageModel.fromJson(json) as T,
      apiCallType: APICallType.GET,
      screenName: 'AppLanguage',
    );
    response.fold(
      (AppError error) async {
        if (error.errorType == AppErrorType.unauthorised) {
          loadingCubit.hide();
          await AppFunctions().forceLogout();
          return error.errorMessage;
        }
        loadingCubit.hide();

        emit(AppLanguageErrorState(appErrorType: error.errorType, errorMessage: error.errorMessage));
      },
      (appLangList) async {
        if (appLangList is LanguageModel) {
          loadingCubit.hide();
          String languageCode = "en";

          int defaultLanguageIndex = languages.indexWhere((element) => element.isDefault == 1);

          if (languages.isNotEmpty && defaultLanguageIndex != -1) {
            languageCode = languages[defaultLanguageIndex].shortCode;
          }

          List<AppLanguageEntity> tempLanguages = [];
          tempLanguages.addAll(appLangList.data ?? []);

          var enIndex = appLangList.data?.indexWhere((element) => element.shortCode == languageCode);
          if (enIndex != null && enIndex != -1) {
            defaultLanguageIndex = enIndex;
          }

          if (tempLanguages.isNotEmpty) {
            tempLanguages = tempLanguages.map((e) => e.copyWith(isDefault: 0)).toList();
            tempLanguages[defaultLanguageIndex] = tempLanguages[defaultLanguageIndex].copyWith(isDefault: 1);
          }

          languages = tempLanguages;
          currentLangCode = languageCode;

          await currentLanBox.put(HiveConstants.PREFERRED_LANGUAGE, currentLangCode);
          await currentLanBox.put(HiveConstants.APP_LANGUAGE_LIST, languages);

          if (!isMounted) return;
          emit(
            AppLanguageLoadedState(
              languageEntity: tempLanguages,
              origionalLanguageList: tempLanguages,
              selectIndex: defaultLanguageIndex,
              selectedLanguage: currentLangCode,
              random: Random().nextDouble(),
            ),
          );

          if (state is AppLanguageLoadedState) {
            loadLanguageLabels(
              context: null,
              isLanguageSet: true,
              loadedState: state as AppLanguageLoadedState,
              selectedIndex: defaultLanguageIndex,
              appLanguageEntity: tempLanguages[defaultLanguageIndex],
            );
          }
        }
      },
    );
  }

  Future<void> loadLanguageLabels<T extends ModelResponseExtend>({
    required AppLanguageLoadedState loadedState,
    required int selectedIndex,
    required BuildContext? context,
    required bool isLanguageSet,
    required AppLanguageEntity appLanguageEntity,
  }) async {
    if (!isMounted) return;
    emit(loadedState.copyWith(selectIndex: selectedIndex));

    emit(const AppLanguageLoadingState());

    final endpoint = dotenv.env[ApiEndPointConstants.API_ENDPOINT_3];

    if (endpoint == null) return;

    Either<AppError, T> response = await apiUsecase.call(
      endpoint: '$endpoint${appLanguageEntity.id}?/salt=${ApiConstatnts.salt}',
      fromJson: (json) => CommonResponseModel.fromJson(json) as T,
      apiCallType: APICallType.GET,
      screenName: 'AppLanguage',
    );

    await response.fold(
      (error) async {
        if (error.errorType == AppErrorType.unauthorised) {
          await AppFunctions().forceLogout();
          return;
        }
        loadingCubit.hide();
        if (!isMounted) return;
        emit(AppLanguageErrorState(appErrorType: error.errorType, errorMessage: error.errorMessage));
      },
      (status) async {
        if (status is CommonResponseModel) {
          loadingCubit.hide();

          if (!status.status) return;

          if (status.data.isNotEmpty) {
            String langCode = appLanguageEntity.shortCode;
            File file = await File('$languageLocalPath/$langCode.json').create(recursive: true);
            file.writeAsStringSync(jsonEncode(status.data), flush: true, mode: FileMode.write);
          }

          List<AppLanguageEntity> oldList = loadedState.languageEntity;
          oldList = oldList.map((e) => e.copyWith(isDefault: 0)).toList();
          oldList[selectedIndex] = oldList[selectedIndex].copyWith(isDefault: 1);

          if (!isMounted) return;

          emit(
            loadedState.copyWith(
              languageEntity: oldList,
              origionalLanguageList: oldList,
              selectIndex: selectedIndex,
              selectedLanguage: oldList[selectedIndex].shortCode,
              random: Random().nextDouble(),
            ),
          );

          if (context != null) {
            if (!context.mounted) return; 
            BlocProvider.of<LanguageCubit>(context).toggleLanguage(shortCode: appLanguageEntity.shortCode);
          }
        }
        loadingCubit.hide();
      },
    );
  }

  // void setSelectedIndexValue({required AppLanguageLoadedState state, required int index}) {
  //   if (!isMounted) return;
  //   emit(state.copyWith(selectIndex: index, random: Random().nextDouble()));
  // }
  // Future<void> setLanguage({
  //   required AppLanguageLoadedState loadedState,
  //   required int selectedIndex,
  //   required bool isFromSettingScreen,
  // }) async {
  //   loadingCubit.show();
  //   Either<AppError, PostApiResponse> response = await setDefaultLanguage(
  //     loadedState.languageEntity[selectedIndex].id,
  //   );
  //   response.fold(
  //     (AppError error) {
  //       loadingCubit.hide();
  //       CustomSnackbar.show(snackbarType: SnackbarType.ERROR, message: error.errorMessage);
  //     },
  //     (PostApiResponse data) {
  //       languages = languages.map((e) => e.copyWith(isDefault: 0)).toList();
  //       languages[selectedIndex] = languages[selectedIndex].copyWith(isDefault: 1);
  //       currentLanBox.put(HiveConstants.PREFERRED_LANGUAGE, languages[selectedIndex].shortCode);
  //       appLanBox.put(HiveConstants.APP_LANGUAGE_LIST, languages);
  //       CustomSnackbar.show(snackbarType: SnackbarType.SUCCESS, message: data.message);
  //       loadingCubit.hide();
  //       isFromSettingScreen ? CommonRouter.pop() : CommonRouter.pushReplacementNamed(RouteList.login_screen);
  //     },
  //   );
  // }

  Future<void> setLocallyLanguage({
    required int selectedIndex,
    required AppLanguageLoadedState state,
    required BuildContext context,
  }) async {
    languages = languages.map((e) => e.copyWith(isDefault: 0)).toList();
    languages[selectedIndex] = languages[selectedIndex].copyWith(isDefault: 1);
    currentLanBox.put(HiveConstants.PREFERRED_LANGUAGE, languages[selectedIndex].shortCode);
    appLanBox.put(HiveConstants.APP_LANGUAGE_LIST, languages);
    BlocProvider.of<LanguageCubit>(context).toggleLanguage(shortCode: languages[selectedIndex].shortCode);

    CommonRouter.pop();
  }
}
