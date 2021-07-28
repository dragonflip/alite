import 'package:flutter/material.dart';

import '../widgets/MyAppBar.dart';

class Settings extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: MyAppBar("Налаштування"),
      body: SingleChildScrollView(
        child: Container(
          child: Card(
            margin: EdgeInsets.all(8),
            child: Column(
              children: [
                ListTile(
                  onTap: () {},
                  title: Text("Сповіщення"),
                  leading: Icon(Icons.notifications),
                  trailing: Switch(
                    onChanged: (value) {},
                    value: true,
                  ),
                ),
                ListTile(
                  onTap: () {},
                  title: Text("Темна тема"),
                  leading: Icon(Icons.dark_mode),
                  trailing: Switch(
                    onChanged: (value) {},
                    value: false,
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