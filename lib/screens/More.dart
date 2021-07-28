import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../widgets/MyAppBar.dart';
import '../widgets/MyBottomNavigationBar.dart';

const VERSION = "Версія 0.0.47";

class More extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: MyAppBar(),
      body: SingleChildScrollView(
        child: Container(
          // color: Colors.white,
          child: Card(
            margin: EdgeInsets.all(8),
            child: Column(
              children: [
                ListTile(
                  onTap: () {
                    Navigator.pushNamed(context, '/chat');
                  },
                  title: Text("Технічна підтримка"),
                  leading: Icon(Icons.chat),
                  trailing: Icon(Icons.keyboard_arrow_right),
                ),
                ListTile(
                  onTap: () {},
                  title: Text("Інформація про компанію"),
                  leading: Icon(Icons.info_outlined),
                  trailing: Icon(Icons.keyboard_arrow_right),
                ),
                ListTile(
                  onTap: () {},
                  title: Text("Налаштування"),
                  leading: Icon(Icons.settings_outlined),
                  trailing: Icon(Icons.keyboard_arrow_right),
                ),
                ListTile(
                  onTap: () {},
                  title: Text("Сповістити про проблему"),
                  leading: Icon(Icons.report_problem_outlined),
                  trailing: Icon(Icons.keyboard_arrow_right),
                ),
                ListTile(
                  onTap: () async {
                    showDialog(
                      context: context,
                      builder: (_) => AlertDialog(
                        title: Text('Вийти?'),
                        content: Text('Ви дійсно хочете вийти з особистого кабінету? \n\nПісля цього потрібно знову вказувати дані для входу.'),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: Text("СКАСУВАТИ", style: TextStyle(color: Colors.black54)),
                          ),
                          TextButton(
                            onPressed: () async {
                              final prefs = await SharedPreferences.getInstance();

                              prefs.remove("login");
                              prefs.remove("password");
                              prefs.remove("url");
                              prefs.remove("port");

                              Navigator.pushNamedAndRemoveUntil(context, "/login", (route) => false);
                            },
                            child: Text("ВИЙТИ"),
                          ),
                        ],
                      ),
                    );
                  },
                  title: Text("Вийти", style: TextStyle(color: Colors.red)),
                  leading: Icon(Icons.logout, color: Colors.red),
                  trailing: Icon(Icons.keyboard_arrow_right, color: Colors.red),
                ),
                Divider(),
                ListTile(
                  onLongPress: () {
                    Clipboard.setData(ClipboardData(text: VERSION));
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Інформацію про версію скопійовано")));
                  },
                  title: Text(VERSION),
                  leading: Icon(Icons.bug_report_outlined),
                ),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: MyBottomNavigationBar(),
    );
  }
}