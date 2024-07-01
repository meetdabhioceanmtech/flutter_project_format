import 'package:app_links/app_links.dart';
import 'package:oceanmtech_dmt/presentation/globals.dart';
import 'package:oceanmtech_dmt/presentation/utils/app_functions.dart';

class AppLinksService {
  static init() async {
    AppLinks appLinks = AppLinks();
    initialLinkURI = (await appLinks.getInitialLink()) ?? (await appLinks.getLatestLink());
    appLinks.uriLinkStream.listen((uri) async => await AppFunctions.uriHandler(uri: uri));
  }
}
