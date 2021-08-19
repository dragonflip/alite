import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import '../widgets/MyAppBar.dart';
import '../widgets/MyBottomNavigationBar.dart';

class More extends StatefulWidget {
  @override
  _More createState() => _More();
}

class _More extends State<More> {
  var futureData;

  var _loading = false;

  Future getData() async {
    PackageInfo packageInfo = await PackageInfo.fromPlatform();

    print(packageInfo.appName);
    print(packageInfo.packageName);
    print(packageInfo.version);
    print(packageInfo.buildSignature);

    return {"appVersion": packageInfo.version};
  }

  @override
  void initState() {
    futureData = getData();
    super.initState();
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

                              Navigator.pushNamedAndRemoveUntil(context, "login", (route) => false);
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

                FutureBuilder(
                  future: futureData,
                  builder: (context, snapshot) {
                    if (snapshot.hasData) {
                      final data = snapshot.data as Map<String, dynamic>;

                      return ListTile(
                        onLongPress: () async {
                          setState(() {
                            _loading = true;
                          });

                          var versionResponse = await http.get(Uri.parse("https://demo.abills.net.ua:9443/api.cgi/version"), headers: {"KEY": "testAPI_KEY12"});
                          var version = jsonDecode(utf8.decode(versionResponse.bodyBytes));

                          Clipboard.setData(ClipboardData(text: "ABillS lite\n"
                                                                "Версія додатку: ${data['appVersion']}\n"
                                                                "Версія білінгу: ${version['version']}\n"
                                                                "Версія API: ${version['apiVersion']}"));
                          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Докладнішу інформацію скопійовано")));

                          setState(() {
                            _loading = false;
                          });
                        },
                        title: Text("Версія ${data['appVersion']}"),
                        leading: Icon(Icons.code),
                        trailing: _loading ? CircularProgressIndicator() : Wrap(),
                      );
                    } else {
                      return LinearProgressIndicator();
                    }
                  },
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