import 'package:flutter/material.dart';

import '../widgets/MyAppBar.dart';

class Settings extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: MyAppBar("Налаштування"),
      body: Container(
        constraints: BoxConstraints.expand(),
        child: SingleChildScrollView(
          physics: BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
          child: Card(
            margin: EdgeInsets.all(8),
            child: Column(
              children: [
                ListTile(
                  title: Text("Мова"),
                  leading: Icon(Icons.language),
                  trailing: DropdownButton(
                      onChanged: (value) {},
                      value: 0,
                      items: [
                        DropdownMenuItem(
                          value: 0,
                          child: Text("Українська"),
                        ),
                        DropdownMenuItem(
                          value: 1,
                          child: Text("Русский"),
                        ),
                        DropdownMenuItem(
                          value: 2,
                          child: Text("English"),
                        ),
                      ]
                  ),
                ),
                ListTile(
                  title: Text("Сповіщення"),
                  leading: Icon(Icons.notifications),
                  trailing: Switch(
                    onChanged: (value) {},
                    value: true,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}