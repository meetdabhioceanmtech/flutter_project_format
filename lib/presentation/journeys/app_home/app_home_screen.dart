import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:oceanmtech_dmt/presentation/cubit/bottom_navigation/bottom_navigation_cubit.dart';
import 'package:oceanmtech_dmt/common/constants/translation_constants.dart';
import 'package:oceanmtech_dmt/common/extention/string_extension.dart';
import 'package:oceanmtech_dmt/presentation/globals.dart';
import 'package:oceanmtech_dmt/presentation/journeys/app_home/app_home_widget.dart';
import 'package:oceanmtech_dmt/presentation/journeys/screens/bottom_navbar/bottom_nav_constants.dart';
import 'package:oceanmtech_dmt/presentation/widgets/common_widget.dart';

class AppHome extends StatefulWidget {
  final bool? check;
  const AppHome({super.key, this.check});

  @override
  State<AppHome> createState() => _AppHomeState();
}

class _AppHomeState extends AppHomeWidget {
  @override
  Widget build(BuildContext context) {
    buildContext = context;
    return PopScope(
      canPop: false,
      onPopInvoked: (didPop) async {
        if (didPop) return;
        final NavigatorState navigator = Navigator.of(context);
        if (bottomNavigationCubit.state == 0) {
          var result = await CommonWidget.showAlertDialog(
            context: context,
            isTitle: true,
            title: TranslationConstants.company_app.translate(context),
            subTitle: TranslationConstants.exit_msg.translate(context),
          );
          if (result == true) {
            if (Platform.isAndroid) {
              generalSettingBox.clear();
              appActivityAnaltics.clear();

              navigator.popUntil((route) => route.isFirst);
              SystemNavigator.pop();
            } else {
              navigator.popUntil((route) => route.isFirst);
              SystemNavigator.pop();
            }
          }
        } else {
          bottomNavigationCubit.changedBottomNavigation(0);
        }
      },
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        backgroundColor: appConstants.whiteBackgroundColor,
        endDrawerEnableOpenDragGesture: false,
        body: BlocBuilder<BottomNavigationCubit, int>(
          bloc: bottomNavigationCubit,
          builder: (context, state) {
            return IndexedStack(index: state, children: bottomScreenList);
          },
        ),
        bottomNavigationBar: bottomBar(),
      ),
    );
  }
}
