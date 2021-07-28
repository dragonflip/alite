import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:package_info_plus/package_info_plus.dart';

import '../widgets/MyAppBar.dart';
import '../widgets/MyBottomNavigationBar.dart';

class More extends StatelessWidget {
  var version;

  Future _getAppInfo() async {
    PackageInfo packageInfo = await PackageInfo.fromPlatform();
    version = packageInfo.version;

    return version;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: MyAppBar(),
      body: SingleChildScrollView(
        physics: BouncingScrollPhysics(),
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
                        title: Text('Вийти з особистого кабінету?'),
                        content: Text('Після виходу потрібно знову вказувати дані для входу.'),
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
                    Clipboard.setData(ClipboardData(text: "ABillS lite, версія $version"));
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Інформацію про версію скопійовано")));
                  },
                  title: FutureBuilder(
                    future: _getAppInfo(),
                    builder: (context, snapshot) {
                      if (snapshot.hasData) {
                        return Text("Версія ${snapshot.data.toString()}");
                      } else {
                        return Text("Версія");
                      }
                    }
                  ),
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