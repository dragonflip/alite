import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

import '../widgets/MyAppBar.dart';
import '../widgets/MyBottomNavigationBar.dart';

const VERSION = "Версія 0.1.10";

class More extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: MyAppBar(),
      body: SingleChildScrollView(
        child: Container(
          child: Card(
            margin: EdgeInsets.all(8),
            child: Column(
              children: [
                ListTile(
                  onTap: () {
                    Navigator.pushNamed(context, "/about");
                  },
                  title: Text("Про нас"),
                  leading: Icon(Icons.info_outlined),
                  trailing: Icon(Icons.keyboard_arrow_right),
                ),
                ListTile(
                  onTap: () {
                    Navigator.pushNamed(context, "/settings");
                  },
                  title: Text("Налаштування"),
                  leading: Icon(Icons.settings_outlined),
                  trailing: Icon(Icons.keyboard_arrow_right),
                ),
                ListTile(
                  onTap: () => launch("https://play.google.com/store/apps/details?id=com.abillsmobile.abillsclient"),
                  title: Text("Оцінити додаток"),
                  leading: Icon(Icons.star_border),
                  trailing: Icon(Icons.keyboard_arrow_right),
                ),
                ListTile(
                  onTap: () {
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
                  leading: Icon(Icons.code),
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