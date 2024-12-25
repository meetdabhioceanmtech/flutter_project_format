import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:oceanmtech_dmt/common/constants/languages.dart';
import 'package:oceanmtech_dmt/common/constants/translation_constants.dart';
import 'package:oceanmtech_dmt/common/extention/string_extension.dart';
import 'package:oceanmtech_dmt/presentation/cubit/app_language/app_language_cubit.dart';
import 'package:oceanmtech_dmt/presentation/cubit/language/language_cubit.dart';
import 'package:oceanmtech_dmt/presentation/globals.dart';
import 'package:oceanmtech_dmt/presentation/journeys/screens/select_language/language_widget.dart';
import 'package:oceanmtech_dmt/presentation/widgets/common_widget.dart';
import 'package:oceanmtech_dmt/presentation/widgets/custom_app_bar.dart';

class LanguageScreen extends StatefulWidget {
  const LanguageScreen({super.key});

  @override
  State<LanguageScreen> createState() => _LanguageScreenState();
}

class _LanguageScreenState extends LanguageWidget {
  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        final NavigatorState navigator = Navigator.of(context);
        var where = languages.where((element) => element.isDefault == 1).toList();
        if (where.isNotEmpty) {
          BlocProvider.of<LanguageCubit>(context).toggleLanguage(shortCode: where.first.shortCode);
        }

        navigator.pop();
      },
      child: Scaffold(
        backgroundColor: appConstants.whiteBackgroundColor,
        appBar: customAppBar(
          context: context,
          title: TranslationConstants.language.translate(context),
          onTap: () {
            final NavigatorState navigator = Navigator.of(context);
            var where = languages.where((element) => element.isDefault == 1).toList();
            if (where.isNotEmpty) {
              BlocProvider.of<LanguageCubit>(context).toggleLanguage(shortCode: where.first.shortCode);
            }

            navigator.pop();
          },
        ),
        body: BlocBuilder<AppLanguageCubit, AppLanguageState>(
          bloc: appLanguageCubit,
          builder: (context, state) {
            if (state is AppLanguageLoadedState) {
              return languageLoadedView(state: state, context: context);
            } else if (state is AppLanguageLoadingState) {
              return Center(child: CommonWidget.loadingIos());
            } else if (state is AppLanguageErrorState) {
              return CommonWidget.dataNotFound(
                context: context,
                onTap: () async => await appLanguageCubit.loadInitialData(),
                actionButton: const SizedBox.shrink(),
              );
            }
            return const SizedBox.shrink();
          },
        ),
      ),
    );
  }
}
