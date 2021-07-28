import 'package:flutter/material.dart';

import '../widgets/MyAppBar.dart';

class Notifications extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: MyAppBar("Сповіщення"),
      body: Container(
        constraints: BoxConstraints.expand(),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.notifications, size: 100, color: Colors.black38),
            Text("Нових сповіщень немає", style: Theme.of(context).textTheme.headline5),
            SizedBox(height: 64),
          ],
        ),
      ),
    );
  }
}