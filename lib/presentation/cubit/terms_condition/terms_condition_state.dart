part of 'terms_condition_cubit.dart';

sealed class TermsConditionState extends Equatable {
  const TermsConditionState();

  @override
  List<Object?> get props => [];
}

final class TermsConditionInitial extends TermsConditionState {

  @override
  List<Object?> get props => [];
}

final class TermsConditionLoadingState extends TermsConditionState {

  @override
  List<Object?> get props => [];
}

final class TermsConditionLoadedState extends TermsConditionState {
  final TermsModelData termsData;

  const TermsConditionLoadedState({required this.termsData});

  TermsConditionLoadedState copyWith({TermsModelData? termsData}) {
    return TermsConditionLoadedState(
      termsData: termsData ?? this.termsData,
    );
  }

  @override
  List<Object?> get props => [termsData];
}

final class TermsConditionErrorState extends TermsConditionState {
  final AppErrorType appErrorType;
  final String errorMessage;

  const TermsConditionErrorState({
    required this.appErrorType,
    required this.errorMessage,
  });
  @override
  List<Object?> get props => [
        appErrorType,
        errorMessage,
      ];
}
