import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_localized_locales/flutter_localized_locales.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:vservesafe/src/controllers/settings_controller.dart';
import 'package:vservesafe/src/controllers/user_controller.dart';
import 'package:vservesafe/src/pages/dashboard_view.dart';
import 'package:vservesafe/src/pages/login_view.dart';

class _MyCustomScrollBehavior extends MaterialScrollBehavior {
  @override
  Set<PointerDeviceKind> get dragDevices => {
        PointerDeviceKind.touch,
        PointerDeviceKind.mouse,
        PointerDeviceKind.stylus,
        PointerDeviceKind.trackpad,
      };
}

/// The Widget that configures your application.
class VserveApp extends StatelessWidget {
  const VserveApp({
    super.key,
    required this.settingsController,
    required this.userController,
  });

  final SettingsController settingsController;
  final UserController userController;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: settingsController,
      builder: (BuildContext context, Widget? child) {
        return MaterialApp(
          scrollBehavior: _MyCustomScrollBehavior(),
          restorationScopeId: 'app',
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
            LocaleNamesLocalizationsDelegate(),
          ],
          supportedLocales: SettingsController.supportedLocales,
          locale: settingsController.locale,
          onGenerateTitle: (BuildContext context) =>
              AppLocalizations.of(context)!.appTitle,
          theme: ThemeData(
            textTheme: GoogleFonts.kanitTextTheme(),
          ),
          darkTheme: ThemeData.dark().copyWith(
            textTheme: GoogleFonts.kanitTextTheme(ThemeData.dark().textTheme),
          ),
          onGenerateRoute: (RouteSettings routeSettings) {
            Map<String, dynamic> args = {};
            if (routeSettings.arguments is Map<String, dynamic>) {
              args = routeSettings.arguments as Map<String, dynamic>;
            }
            return MaterialPageRoute<void>(
              settings: routeSettings,
              builder: (BuildContext context) {
                if (userController.userData != null) {
                  String subRoute = "";
                  if (routeSettings.name!.startsWith(DashboardView.routeName)) {
                    subRoute = routeSettings.name!
                        .substring(DashboardView.routeName.length);
                  }
                  return DashboardView(
                    settingsController: settingsController,
                    userController: userController,
                    subroute: subRoute,
                    arguments: args,
                  );
                }

                switch (routeSettings.name) {
                  case LoginView.routeName:
                  default:
                    return LoginView(
                      settingsController: settingsController,
                      userController: userController,
                      autoLogin:
                          args["autoLogin"] is bool ? args["autoLogin"] : true,
                    );
                }
              },
            );
          },
          initialRoute: LoginView.routeName,
        );
      },
    );
  }
}
