import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_project/common/constants/common_router.dart';
import 'package:flutter_project/common/constants/translation_constants.dart';
import 'package:flutter_project/common/extention/string_extension.dart';
import 'package:flutter_project/data/models/my_notification_model.dart';
import 'package:flutter_project/presentation/cubit/notification/notification_handle/notification_cubit.dart';
import 'package:flutter_project/presentation/globals.dart';
import 'package:flutter_project/presentation/journeys/screens/notification_screen/notification_widget.dart';
import 'package:flutter_project/presentation/widgets/common_widget.dart';
import 'package:flutter_project/presentation/widgets/custom_app_bar.dart';

class NotificationScreen extends StatefulWidget {
  const NotificationScreen({super.key});

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends NotificationWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: customAppBar(
        context: context,
        onTap: () => CommonRouter.pop(),
        title: TranslationConstants.my_notifications.translate(context),
      ),
      body: BlocBuilder<NotificationCubit, NotificationState>(
        bloc: notificationViewCubit,
        builder: (context, state) {
          if (state is NotificationLoadedState) {
            return SizedBox(
              height: ScreenUtil.defaultSize.height,
              child: RefreshIndicator(
                onRefresh: () async => await notificationViewCubit.getNotificationHistory(isRefreshIndicator: true),
                color: appConstants.primary1Color,
                backgroundColor: appConstants.grayBackgroundColor,
                child: state.notificationList.isEmpty
                    ? CommonWidget.sizedBox(
                        child: CommonWidget.dataNotFound(
                          imagePath: 'assets/svgs/common/data_not_found.svg',
                          heading: TranslationConstants.no_data_found.translate(context),
                          subHeading: TranslationConstants.hint_no_notification.translate(context),
                          context: context,
                          actionButton: const SizedBox.shrink(),
                        ),
                      )
                    : ListView.separated(
                        physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
                        itemCount: state.notificationList.length,
                        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
                        itemBuilder: (context, index) {
                          NotificationData notification = state.notificationList[index];

                          return jobNotificationWidget(notification: notification);
                        },
                        separatorBuilder: (context, index) {
                          return SizedBox(height: 10.h);
                        },
                      ),
              ),
            );
          } else if (state is NotificationLoadingState) {
            return Center(child: CircularProgressIndicator(color: appConstants.primary1Color));
          } else if (state is NotificationErrorState) {
            return CommonWidget.dataNotFound(
              context: context,
              bgColor: appConstants.whiteBackgroundColor,
              heading: TranslationConstants.something_went_wrong.translate(context),
              subHeading: state.errorMessage,
              buttonLabel: TranslationConstants.try_again.translate(context),
              onTap: () async => await notificationViewCubit.getNotificationHistory(),
            );
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }
}
