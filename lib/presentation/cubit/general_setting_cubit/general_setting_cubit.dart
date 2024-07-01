import 'dart:math';

import 'package:bloc/bloc.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:oceanmtech_dmt/common/constants/api_end_point_constants.dart';
import 'package:oceanmtech_dmt/common/constants/hive_constants.dart';
import 'package:oceanmtech_dmt/data/datasources/common_api_call.dart';
import 'package:oceanmtech_dmt/data/models/general_setting_model.dart';
import 'package:oceanmtech_dmt/data/models/model_response_extend.dart';
import 'package:oceanmtech_dmt/domain/entities/app_error.dart';
import 'package:oceanmtech_dmt/domain/usecases/api_usecase.dart';
import 'package:oceanmtech_dmt/presentation/custom_snackbar.dart';
import 'package:oceanmtech_dmt/presentation/globals.dart';
import 'package:oceanmtech_dmt/presentation/utils/app_functions.dart';

class GeneralSettingCubit extends Cubit<double> {
  final ApiUsecase apiUsecase;
  GeneralSettingCubit({required this.apiUsecase}) : super(0);

  Future<void> getGeneralSetting<T extends ModelResponseExtend>() async {
    final endpoint = dotenv.env[ApiEndPointConstants.API_ENDPOINT_1];
    if (endpoint == null) return;

    Either<AppError, T> response = await apiUsecase.call(
      endpoint: endpoint,
      fromJson: (json) => GeneralSettingModel.fromJson(json) as T,
      apiCallType: APICallType.GET,
      screenName: 'getGeneralSetting',
      header: {"Accept": "application/json"},
    );

    response.fold(
      (error) async {
        if (error.errorType == AppErrorType.unauthorised) {
          await AppFunctions().forceLogout();
          return error.errorMessage;
        }

        CustomSnackbar.show(snackbarType: SnackbarType.ERROR, message: error.errorMessage);
      },
      (data) async {
        if (data is GeneralSettingModel) {
          await generalSettingBox.put(HiveConstants.GENERAL_SETTING_DATA, data.data);
          generalSettingEntity = await generalSettingBox.get(HiveConstants.GENERAL_SETTING_DATA);

          debugPrint('getGeneralSetting API success ==> ${data.data}');

          emit(Random().nextDouble());
        }
      },
    );
  }
}
