import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import '../widgets/MyAppBar.dart';
import '../widgets/MyBottomNavigationBar.dart';

class Home extends StatefulWidget {
  @override
  _Home createState() => _Home();
}

class _Home extends State<Home> {
  var _uid, _pib;
  var result;

  getData() async {
    final prefs = await SharedPreferences.getInstance();
    _uid = prefs.getString("uid");

    var overallInfo = await http.get(Uri.parse('https://demo.abills.net.ua:9443/api.cgi/users/$_uid'), headers: {"KEY": "testAPI_KEY12"});
    var personalInfo = await http.get(Uri.parse('https://demo.abills.net.ua:9443/api.cgi/users/$_uid/pi'), headers: {"KEY": "testAPI_KEY12"});

    var profile = jsonDecode(utf8.decode(personalInfo.bodyBytes));
    profile.addAll(jsonDecode(utf8.decode(overallInfo.bodyBytes)));

    var servicesResponse = await http.get(Uri.parse("https://demo.abills.net.ua:9443/api.cgi/users/$_uid/abon"), headers: {"KEY": "testAPI_KEY12"});
    var servicesInfo = jsonDecode(utf8.decode(servicesResponse.bodyBytes));

    var services = [];

    for (int i = 0; i < servicesInfo.length; i++) {
      if (servicesInfo[i]['activeService'] == "1") {
        // print(servicesInfo[i]);
        services.add(servicesInfo[i]);
      }
    }

    var internetResponse = await http.get(Uri.parse("https://demo.abills.net.ua:9443/api.cgi/users/$_uid/internet"), headers: {"KEY": "testAPI_KEY12"});
    var internetID = jsonDecode(utf8.decode(internetResponse.bodyBytes))[0]['id'];

    var internetInfo = await http.get(Uri.parse("https://demo.abills.net.ua:9443/api.cgi/users/$_uid/internet/$internetID"), headers: {"KEY": "testAPI_KEY12"});
    var internet = jsonDecode(utf8.decode(internetInfo.bodyBytes));

    // var api = await http.get(Uri.parse("https://demo.abills.net.ua:9443/api.cgi/abon/tariffs"), headers: {"KEY": "testAPI_KEY12"});
    //
    // var data = jsonDecode(utf8.decode(api.bodyBytes));
    // for (int i = 0; i < data.length; i++) {
    //   print(data[i]);
    // }

    return {"profile": profile, "services": services, "internet": internet};
  }

  @override
  void initState() {
    result = getData();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: MyAppBar(),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.pushNamed(context, '/support');
        },
        child: Icon(Icons.chat),
        tooltip: "Чат з тех. підтримкою",
      ),
      body: SingleChildScrollView(
        physics: BouncingScrollPhysics(),
        child: Container(
          child: FutureBuilder(
            future: getData(), // TODO without reload
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                final data = snapshot.data as Map<String, dynamic>;
                // print(snapshot.data.runtimeType);

                return Column(
                  children: [
                    Card(
                      margin: EdgeInsets.fromLTRB(8, 8, 8, 4),
                      child: Padding(
                        padding: EdgeInsets.all(16),
                        child: Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text("${data['profile']['fio']}", style: TextStyle(fontSize: 20, fontWeight: FontWeight.w400)),
                                    Text("Договір №${data['profile']['contractId']}"),
                                  ],
                                ),
                                TextButton(
                                  onPressed: () {
                                    Navigator.pushNamed(context, "/profile");
                                  },
                                  child: Text("Мій профіль"),
                                ),
                              ],
                            ),
                            SizedBox(height: 16),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Column(
                                  children: [
                                    Text("БАЛАНС", style: TextStyle(fontSize: 22, fontWeight: FontWeight.w300)),
                                    Row(
                                      crossAxisAlignment: CrossAxisAlignment.end,
                                      children: [
                                        Text("${double.parse(data['profile']['deposit']).toStringAsFixed(2)}", style: TextStyle(fontSize: 32, color: Colors.green)),
                                        Text(" грн", style: TextStyle(fontSize: 18, color: Colors.green)),
                                      ],
                                    ),
                                    SizedBox(height: 8),
                                    Text("15.08.2021 буде знято 290 грн"),
                                    SizedBox(height: 16),

                                    ElevatedButton(
                                      onPressed: () {
                                        Navigator.pushNamed(context, "/pay");
                                      },
                                      child: Text("ПОПОВНИТИ", style: TextStyle(fontSize: 18, fontWeight: FontWeight.w400, letterSpacing: 1.5)),
                                      style: ElevatedButton.styleFrom(
                                          fixedSize: Size(MediaQuery.of(context).size.width - 16 * 3, 55),
                                          elevation: 0
                                        // backgroundColor: Colors.green,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            SizedBox(height: 4),
                          ],
                        ),
                      ),
                    ),
                    Card(
                      margin: EdgeInsets.fromLTRB(8, 4, 8, 4),
                      child: Padding(
                        padding: EdgeInsets.fromLTRB(16, 24, 16, 8),
                        child: Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text("Інтернет «${data['internet']['tpName']}»", style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                              ],
                            ),
                            SizedBox(height: 8),
                            // Slider(
                            //   value: 0.25,
                            //   onChanged: (value) {
                            //     Navigator.pushNamed(context, "/tariff");
                            //   },
                            //   divisions: 4,
                            // ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                OutlinedButton.icon(
                                  onPressed: () {
                                    Navigator.pushNamed(context, "/tariff", arguments: "change_tariff");
                                  },
                                  icon: Icon(Icons.swap_horiz),
                                  label: Text("ЗМІНИТИ"),
                                ),
                              ],
                            ),

                            ListTile(
                              title: Text("${data['internet']['speed']} Мб/с"),
                              subtitle: Text("Швидкість"),
                              leading: Icon(Icons.network_check),
                            ),
                            Divider(),
                            ListTile(
                              title: Text("${data['internet']['monthAbon']} грн", style: TextStyle(fontSize: 18)),
                              subtitle: Text("Ціна"),
                              leading: Icon(Icons.attach_money),
                            ),
                          ],
                        ),
                      ),
                    ),
                    for (var item in data['services']) Card(
                      margin: EdgeInsets.fromLTRB(8, 4, 8, 4),
                      child: Padding(
                        padding: EdgeInsets.fromLTRB(16, 24, 16, 8),
                        child: Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text("Послуга \n«${item['name']}»", style: TextStyle(fontSize: 20)),
                                Column(
                                  children: [
                                    Text("АКТИВНО", style: TextStyle(color: Colors.green)),
                                    Switch(value: true, onChanged: (value) {}),
                                  ],
                                ),
                              ],
                            ),
                            // ListTile(
                            //   title: Text("192.168.0.1"),
                            //   subtitle: Text("Статичний IP"),
                            //   leading: Icon(Icons.cable),
                            // ),
                            // Divider(),
                            ListTile(
                              title: Text("${item['price']} грн", style: TextStyle(fontSize: 18)),
                              subtitle: Text("Ціна"),
                              leading: Icon(Icons.attach_money),
                            ),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(height: 4),
                  ],
                );
              } else {
                return LinearProgressIndicator();
              }
            },
          ),
        ),
      ),
      bottomNavigationBar: MyBottomNavigationBar(),
    );
  }
}