import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'screens/Home.dart';
import 'screens/Tariffs.dart';
import 'screens/Profile.dart';
import 'screens/More.dart';
import 'screens/Login.dart';

import 'screens/Notifications.dart';
import 'screens/Support.dart';
import 'screens/SupportDialog.dart';
import 'screens/Pay.dart';
import 'screens/About.dart';
import 'screens/Settings.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'ABillS',
      theme: ThemeData(
        primarySwatch: Colors.red,
        pageTransitionsTheme: PageTransitionsTheme(
          builders: {
            TargetPlatform.android: CupertinoPageTransitionsBuilder(),
            TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
          }
        ),
      ),

      localizationsDelegates: [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: [
        Locale('uk', ''),
      ],

      // TODO checkLogin
      initialRoute: 'login',
      routes: {
        'login': (context) => Login(),

        '/notifications': (context) => Notifications(),
        '/support': (context) => Support(),
        '/support_dialog': (context) => SupportDialog(),
        '/pay': (context) => Pay(),
        '/about': (context) => About(),
        '/settings': (context) => Settings(),
      },
      // Disabling animation for BottomNavigationBar
      onGenerateRoute: (settings) {
        if (settings.name == '/' || settings.name == '/tariffs' || settings.name == '/profile' || settings.name == '/more') {
          final Map routes = {'/': Home(), '/tariffs': Tariffs(), '/profile': Profile(), '/more': More()};

          return PageRouteBuilder(
            settings: settings,
            pageBuilder: (context, animation1, animation2) => routes[settings.name],
            transitionDuration: Duration.zero,
            reverseTransitionDuration: Duration.zero,
          );
        }
      },
    );
  }
}
