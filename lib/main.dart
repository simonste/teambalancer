import 'dart:async';

import 'package:teambalancer/common/localization.dart';
import 'package:flutter/material.dart';
import 'package:teambalancer/screens/main_screen.dart';
import 'package:app_links/app_links.dart';

void main() {
  runApp(const MainApp());
}

class MainApp extends StatefulWidget {
  const MainApp({super.key});

  @override
  State<MainApp> createState() => MainAppState();
}

class MainAppState extends State<MainApp> {
  final _navigatorKey = GlobalKey<NavigatorState>();
  late AppLinks _appLinks;
  StreamSubscription<Uri>? _linkSubscription;

  @override
  void initState() {
    super.initState();

    initDeepLinks();
  }

  @override
  void dispose() {
    _linkSubscription?.cancel();

    super.dispose();
  }

  Future<void> initDeepLinks() async {
    _appLinks = AppLinks();

    // Handle links
    _linkSubscription = _appLinks.uriLinkStream.listen((uri) {
      openAppLink(uri);
    });
  }

  void openAppLink(Uri uri) {
    _navigatorKey.currentState?.pushNamed(uri.fragment);
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      navigatorKey: _navigatorKey,
      onGenerateRoute: (RouteSettings settings) {
        final routeName = settings.name;
        return MaterialPageRoute(
          builder: (context) => MainScreen(routeName ?? ""),
          settings: settings,
        );
      },
    );
  }
}
