import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class MyBottomNavigationBar extends StatelessWidget {
  final Map<String, int> routes = {"/": 0, "/tariffs": 1, "/profile": 2, "/more": 3};
  final List<String> screens = ['/', '/tariffs', '/profile', '/more'];

  @override
  Widget build(BuildContext context) {
    int _currentIndex = 0;

    if (routes.containsKey(ModalRoute.of(context)?.settings.name)) {
      _currentIndex = routes[ModalRoute.of(context)?.settings.name] as int;
    }

    return BottomNavigationBar(
      currentIndex: _currentIndex,

      items: [
        BottomNavigationBarItem(
          icon: Icon(Icons.home_filled),
          label: 'Головна',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.assessment),
          label: 'Тарифи',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.person),
          label: 'Профіль',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.menu),
          label: 'Ще',
        ),
      ],

      type: BottomNavigationBarType.fixed,
      selectedFontSize: 12,
      backgroundColor: Colors.white,

      onTap: (value) {
        if (routes.containsKey(ModalRoute.of(context)?.settings.name) && routes[ModalRoute.of(context)?.settings.name] as int != value) {
          if (value == 0) {
            Navigator.popUntil(context, ModalRoute.withName("/"));
          } else {
            Navigator.pushNamed(context, screens[value]);
          }

          HapticFeedback.vibrate();
        }
      },
    );
  }
}