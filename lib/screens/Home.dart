import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import '../globals.dart';

import '../widgets/MyAppBar.dart';
import '../widgets/MyBottomNavigationBar.dart';

class Home extends StatefulWidget {
  @override
  _Home createState() => _Home();
}

var futureData;

class _Home extends State<Home> {
  Future getData() async {
    await getGlobals();

    var overallInfo = await http.get(Uri.parse('$apiUrl/user/$uid'), headers: {'USERSID': sid});
    var personalInfo = await http.get(Uri.parse('$apiUrl/user/$uid/pi'), headers: {'USERSID': sid});

    var profile = jsonDecode(utf8.decode(personalInfo.bodyBytes));
    profile.addAll(jsonDecode(utf8.decode(overallInfo.bodyBytes)));

    var servicesResponse = await http.get(Uri.parse('$apiUrl/users/$uid/abon'), headers: {'KEY': 'testAPI_KEY12'}); // TODO change to user API
    var servicesInfo = jsonDecode(utf8.decode(servicesResponse.bodyBytes));

    var services = [];

    for (int i = 0; i < servicesInfo.length; i++) {
      if (servicesInfo[i]['activeService'] == '1') {
        services.add(servicesInfo[i]);
      }
    }

    var internetResponse = await http.get(Uri.parse('$apiUrl/user/$uid/internet'), headers: {'USERSID': sid});
    var internet = jsonDecode(utf8.decode(internetResponse.bodyBytes))[0]; // TODO multiple tariffs

    var nextFeeResponse = await http.get(Uri.parse('$apiUrl/user/$uid/internet/${internet['id']}/warnings'), headers: {'USERSID': sid});
    var nextFee = jsonDecode(utf8.decode(nextFeeResponse.bodyBytes));

    print(nextFee);
    print(internetResponse.body);

    var prefs = await SharedPreferences.getInstance();
    prefs.setString('tpId', internet['id']);

    return {'profile': profile, 'services': services, 'internet': internet, 'nextFee': nextFee};
  }

  Future checkData() async {
    return getData().then((value) {
      if (!mounted) return;

      setState(() {
        futureData = value;
      });
    });
  }

  @override
  void initState() {
    checkData();
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
        tooltip: 'Чат з тех. підтримкою',
      ),
      body: Container(
        child: futureData != null ? RefreshIndicator(
          onRefresh: () {
            return checkData();
          },
          child: Scrollbar(
            child: ListView(
              physics: BouncingScrollPhysics(),
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
                                Text(futureData['profile']['fio'], style: TextStyle(fontSize: 20, fontWeight: FontWeight.w400)),
                                Text('Договір №${futureData['profile']['contractId']}'),
                              ],
                            ),
                            TextButton(
                              onPressed: () {
                                Navigator.pushNamed(context, '/profile');
                              },
                              child: Text('Мій профіль'),
                            ),
                          ],
                        ),
                        SizedBox(height: 16),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Column(
                              children: [
                                Text('БАЛАНС', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w300)),
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    Text(double.parse(futureData['profile']['deposit']).toStringAsFixed(2), style: TextStyle(fontSize: 32, color: Colors.green)),
                                    Text(' грн', style: TextStyle(fontSize: 18, color: Colors.green)),
                                  ],
                                ),
                                SizedBox(height: 8),
                                // Text('15.08.2021 буде знято 290 грн'), // TODO output like this
                                Text(futureData['nextFee']['warning']),
                                SizedBox(height: 16),

                                ElevatedButton(
                                  onPressed: () {
                                    Navigator.pushNamed(context, '/pay');
                                  },
                                  child: Text('ПОПОВНИТИ', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w400, letterSpacing: 1.5)),
                                  style: ElevatedButton.styleFrom(
                                    fixedSize: Size(MediaQuery.of(context).size.width - 16 * 3, 55),
                                    elevation: 0,
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
                            Text('Інтернет «${futureData['internet']['tpName']}»', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                          ],
                        ),
                        SizedBox(height: 8),
                        // Slider(
                        //   value: 0.25,
                        //   onChanged: (value) {
                        //     Navigator.pushNamed(context, '/tariffs');
                        //   },
                        //   divisions: 4,
                        // ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            OutlinedButton.icon(
                              onPressed: () {
                                Navigator.pushNamed(context, '/tariffs', arguments: 'change_tariff');
                              },
                              icon: Icon(Icons.swap_horiz),
                              label: Text('ЗМІНИТИ'),
                            ),
                          ],
                        ),
                        ListTile(
                          title: Text('${futureData['internet']['speed']} Мб/с'),
                          subtitle: Text('Швидкість'),
                          leading: Icon(Icons.network_check),
                        ),
                        Divider(),
                        ListTile(
                          title: Text('${futureData['internet']['monthFee']} грн', style: TextStyle(fontSize: 18)),
                          subtitle: Text('Ціна'),
                          leading: Icon(Icons.attach_money),
                        ),
                      ],
                    ),
                  ),
                ),
                for (var item in futureData['services']) Card(
                  margin: EdgeInsets.fromLTRB(8, 4, 8, 4),
                  child: Padding(
                    padding: EdgeInsets.fromLTRB(16, 24, 16, 8),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Послуга\n«${item['name']}»', style: TextStyle(fontSize: 20)),
                            Column(
                              children: [
                                Text('АКТИВНО', style: TextStyle(color: Colors.green)),
                                Switch(value: true, onChanged: (value) {}),
                              ],
                            ),
                          ],
                        ),
                        // Divider(),
                        ListTile(
                          title: Text('${item['price']} грн', style: TextStyle(fontSize: 18)),
                          subtitle: Text('Ціна'),
                          leading: Icon(Icons.attach_money),
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(height: 4),
              ],
            ),
          ),
        ) : LinearProgressIndicator(),
      ),
      bottomNavigationBar: MyBottomNavigationBar(),
    );
  }
}