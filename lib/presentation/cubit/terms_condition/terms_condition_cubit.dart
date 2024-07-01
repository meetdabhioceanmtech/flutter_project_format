import 'package:bloc/bloc.dart';
import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:oceanmtech_dmt/common/constants/api_end_point_constants.dart';
import 'package:oceanmtech_dmt/data/datasources/common_api_call.dart';
import 'package:oceanmtech_dmt/data/models/model_response_extend.dart';
import 'package:oceanmtech_dmt/data/models/terms_and_conditions_model.dart';
import 'package:oceanmtech_dmt/domain/entities/app_error.dart';
import 'package:oceanmtech_dmt/domain/usecases/api_usecase.dart';
import 'package:oceanmtech_dmt/presentation/cubit/loading/loading_cubit.dart';
import 'package:oceanmtech_dmt/presentation/custom_snackbar.dart';
import 'package:oceanmtech_dmt/presentation/journeys/screens/privacy_and_terms/privacy_and_terms_screen.dart';
import 'package:oceanmtech_dmt/presentation/utils/app_functions.dart';
part 'terms_condition_state.dart';

class TermsConditionCubit extends Cubit<TermsConditionState> {
  final ApiUsecase apiUsecase;
  late LoadingCubit loadingCubit;
  TermsConditionCubit({required this.apiUsecase, required this.loadingCubit}) : super(TermsConditionLoadingState());

  Future<void> termsCondition<T extends ModelResponseExtend>({required TypeScreen typeScreen}) async {
    final endpoint = dotenv.env[typeScreen == TypeScreen.PRIVACY_CONDITION
        ? ApiEndPointConstants.API_ENDPOINT_5
        : ApiEndPointConstants.API_ENDPOINT_6];
    if (endpoint == null) return;

    emit(TermsConditionLoadingState());

    Either<AppError, T> response = await apiUsecase.call(
      endpoint: endpoint,
      fromJson: (result) => TermsAndConditionsModel.fromJson(result) as T,
      apiCallType: APICallType.GET,
      screenName: typeScreen == TypeScreen.PRIVACY_CONDITION ? 'Privacy Policy' : 'Terms Condition',
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
        if (data is TermsAndConditionsModel) {
          emit(TermsConditionLoadedState(termsData: data.data));
        }
      },
    );
  }
}
