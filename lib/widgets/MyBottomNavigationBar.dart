import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class MyBottomNavigationBar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    Map<String, int> routes = {"/": 0, "/tariff": 1, "/profile": 2, "/more": 3};
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
        List<String> routes = ['/', '/tariff', '/profile', '/more'];
        Navigator.pushNamedAndRemoveUntil(context, routes[value], (route) => false);

        HapticFeedback.vibrate();
      },
    );
  }
}