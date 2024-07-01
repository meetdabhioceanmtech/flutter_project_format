part of 'app_language_cubit.dart';

sealed class AppLanguageState extends Equatable {
  const AppLanguageState();

  @override
  List<Object?> get props => [];
}

final class AppLanguageInitialState extends AppLanguageState {
  const AppLanguageInitialState();

  @override
  List<Object> get props => [];
}

final class AppLanguageLoadingState extends AppLanguageState {
  const AppLanguageLoadingState();

  @override
  List<Object> get props => [];
}

final class AppLanguageLoadedState extends AppLanguageState {
  final int selectIndex;
  final List<AppLanguageEntity> languageEntity;
  final List<AppLanguageEntity> origionalLanguageList;
  final String selectedLanguage;
  final double? random;

  const AppLanguageLoadedState({
    required this.selectIndex,
    required this.languageEntity,
    required this.origionalLanguageList,
    required this.selectedLanguage,
    this.random,
  });

  AppLanguageLoadedState copyWith({
    List<AppLanguageEntity>? languageEntity,
    int? selectIndex,
    double? random,
    List<AppLanguageEntity>? origionalLanguageList,
    String? selectedLanguage,
  }) {
    return AppLanguageLoadedState(
      selectIndex: selectIndex ?? this.selectIndex,
      languageEntity: languageEntity ?? this.languageEntity,
      random: random ?? this.random,
      origionalLanguageList: origionalLanguageList ?? this.origionalLanguageList,
      selectedLanguage: selectedLanguage ?? this.selectedLanguage,
    );
  }

  @override
  List<Object?> get props => [
        selectIndex,
        languageEntity,
        origionalLanguageList,
        selectedLanguage,
        random,
      ];
}

final class AppLanguageErrorState extends AppLanguageState {
  final AppErrorType appErrorType;
  final String errorMessage;

  const AppLanguageErrorState({required this.appErrorType, required this.errorMessage});

  @override
  List<Object?> get props => [appErrorType, errorMessage];
}
