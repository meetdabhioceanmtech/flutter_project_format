// ignore_for_file: constant_identifier_names, depend_on_referenced_packages

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:flutter_project/common/constants/translation_constants.dart';
import 'package:flutter_project/common/extention/string_extension.dart';
import 'package:flutter_project/di/get_it.dart';
import 'package:flutter_project/presentation/cubit/terms_condition/terms_condition_cubit.dart';
import 'package:flutter_project/presentation/globals.dart';
import 'package:flutter_project/presentation/widgets/common_widget.dart';
import 'package:flutter_project/presentation/widgets/custom_app_bar.dart';
import 'package:html/dom.dart' as dom;
import 'package:html/parser.dart' as htmlparser;

enum TypeScreen { PRIVACY_CONDITION, TERMS_CONDITION }

class PrivacyAndTermsScreen extends StatefulWidget {
  final TypeScreen typeScreen;

  const PrivacyAndTermsScreen({super.key, required this.typeScreen});

  @override
  State<PrivacyAndTermsScreen> createState() => _PrivacyAndTermsScreenState();
}

class _PrivacyAndTermsScreenState extends State<PrivacyAndTermsScreen> {
  late TermsConditionCubit termsConditionCubit;
  @override
  void initState() {
    termsConditionCubit = getItInstance<TermsConditionCubit>();
    termsConditionCubit.termsCondition(typeScreen: widget.typeScreen);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: appConstants.grayBackgroundColor,
      appBar: customAppBar(
        context: context,
        title: widget.typeScreen == TypeScreen.PRIVACY_CONDITION
            ? TranslationConstants.privacy_policy.translate(context)
            : TranslationConstants.terms_condition.translate(context),
      ),
      body: BlocBuilder(
        bloc: termsConditionCubit,
        builder: (context, state) {
          if (state is TermsConditionLoadedState) {
            dom.Document document = htmlparser.parse(state.termsData.description);

            return Html.fromDom(document: document);
          } else if (state is TermsConditionLoadingState) {
            return CommonWidget.loadingIos();
          } else if (state is TermsConditionErrorState) {
            return CommonWidget.dataNotFound(
              context: context,
              heading: TranslationConstants.something_went_wrong.translate(context),
              subHeading: state.errorMessage,
              buttonLabel: TranslationConstants.try_again.translate(context),
            );
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }
}
