import 'package:bloc/bloc.dart';
import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:oceanmtech_dmt/common/constants/api_end_point_constants.dart';
import 'package:oceanmtech_dmt/data/datasources/common_api_call.dart';
import 'package:oceanmtech_dmt/data/models/model_response_extend.dart';
import 'package:oceanmtech_dmt/data/models/my_notification_model.dart';
import 'package:oceanmtech_dmt/domain/entities/app_error.dart';
import 'package:oceanmtech_dmt/domain/usecases/api_usecase.dart';
import 'package:oceanmtech_dmt/presentation/cubit/loading/loading_cubit.dart';
import 'package:oceanmtech_dmt/presentation/custom_snackbar.dart';
part 'notification_state.dart';

class NotificationCubit extends Cubit<NotificationState> {
  final LoadingCubit loadingCubit;
  final ApiUsecase apiUsecase;
  NotificationCubit({required this.loadingCubit, required this.apiUsecase}) : super(NotificationInitialState());

  // Future<void> loadData() async {
  //   emit(NotificationLoadingState());
  //   List<NotificationModel> notificationList = [];
  //   List<String> tempNotificationList = [];
  //   tempNotificationList.addAll(await getNotificationData());

  //   for (var e in tempNotificationList) {
  //     try {
  //       Map<dynamic, dynamic> json = jsonDecode(e);
  //       notificationList.add(
  //         NotificationModel(
  //           image: json['image']?.toString() ?? '',
  //           companyId: json['company_id']?.toString() ?? '',
  //           companyName: json['company_name']?.toString() ?? '',
  //           type: json['type']?.toString() ?? '',
  //           title: json['title']?.toString() ?? '',
  //           detail: json['body']?.toString() ?? '',
  //           dateTime: DateTime.tryParse(json['date'].toString()) ?? DateTime.now(),
  //           hasNavigationLink: true,
  //         ),
  //       );
  //     } catch (e) {
  //       CustomSnackbar.show(snackbarType: SnackbarType.ERROR, message: e.toString());
  //     }
  //   }
  //   // notificationList.removeWhere((element) => element.companyId != userEntity?.id.toString());
  //   notificationList.sort((a, b) => b.dateTime.compareTo(a.dateTime));
  //   notificationList.toList().toSet().toList();
  //   emit(NotificationLoadedState(notificationList: notificationList));
  // }

  Future<void> getNotificationHistory<T extends ModelResponseExtend>({bool isRefreshIndicator = false}) async {
    final endpoint = dotenv.env[ApiEndPointConstants.API_ENDPOINT_4];
    if (endpoint == null) return;
    if (!isRefreshIndicator) emit(NotificationLoadingState());

    Either<AppError, T> response = await apiUsecase.call(
      endpoint: endpoint,
      fromJson: (json) => MyNotification.fromJson(json) as T,
      apiCallType: APICallType.GET,
      screenName: "My Notification",
    );

    response.fold(
      (error) async {
        emit(NotificationErrorState(
          errorMessage: error.errorMessage,
          appErrorType: error.errorType,
        ));
        CustomSnackbar.show(
          snackbarType: SnackbarType.ERROR,
          message: error.errorMessage,
        );
      },
      (data) async {
        if (data is MyNotification) {
          emit(NotificationLoadedState(notificationList: data.data.notifications));
        }
      },
    );
  }
}
