import 'package:flutter/material.dart';

import 'screens/Home.dart';
import 'screens/Tariff.dart';
import 'screens/Profile.dart';
import 'screens/More.dart';

import 'screens/Notifications.dart';
import 'screens/Chat.dart';
import 'screens/Pay.dart';
import 'screens/About.dart';
import 'screens/Settings.dart';

import 'screens/Login.dart';

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



      initialRoute: '/login',
      routes: {
        '/': (context) => Home(),
        '/tariff': (context) => Tariff(),
        '/profile': (context) => Profile(),
        '/more': (context) => More(),

        '/notifications': (context) => Notifications(),
        '/chat': (context) => Chat(),
        '/pay': (context) => Pay(),
        '/about': (context) => About(),
        '/settings': (context) => Settings(),

        '/login': (context) => Login(),
      }
    );
  }
}
