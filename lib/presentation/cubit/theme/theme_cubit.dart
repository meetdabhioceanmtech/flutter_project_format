import 'package:bloc/bloc.dart';
import 'package:oceanmtech_dmt/common/constants/theme.dart';

class ThemeCubit extends Cubit<Themes> {
  bool isMounted = true;

  ThemeCubit() : super(Themes.light);

  Future<void> toggleTheme() async {
    // await updateTheme(state == Themes.dark ? Themes.light : Themes.dark);
    loadPreferredTheme();
  }

  void loadPreferredTheme() async {
    // final response = await getPreferredTheme(NoParams());
    // if (!isMounted) return;
    // emit(response.fold((l) => Themes.light, (r) => r));
  }
}
