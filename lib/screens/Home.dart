import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:intl/intl.dart';
import 'dart:developer';

import '../global.dart';

import '../widgets/MyAppBar.dart';
import '../widgets/MyBottomNavigationBar.dart';

class Home extends StatefulWidget {
  @override
  _Home createState() => _Home();
}

var futureData, lastUid;

class _Home extends State<Home> {
  var debugInfo = '';

  Future getData() async {
    try {
      await getGlobals();
      await checkSession();

      lastUid = lastUid ?? uid;

      var overallInfoResponse = await http.get(Uri.parse('$apiUrl/user/$uid'), headers: {'USERSID': sid});
      var overallInfo = jsonDecode(utf8.decode(overallInfoResponse.bodyBytes));
      debugInfo += '\noverallInfo:\n$overallInfo\n';

      var personalInfoResponse = await http.get(Uri.parse('$apiUrl/user/$uid/pi'), headers: {'USERSID': sid});
      var personalInfo = jsonDecode(utf8.decode(personalInfoResponse.bodyBytes));
      debugInfo += '\npersonalInfo:\n$personalInfo\n';

      overallInfo.addAll(personalInfo);

      var servicesResponse = await http.get(Uri.parse('$apiUrl/user/$uid/abon'), headers: {'USERSID': sid});
      var services = jsonDecode(utf8.decode(servicesResponse.bodyBytes));
      debugInfo += '\nservices:\n$services\n';

      var activeServices = [];

      for (int i = 0; i < services.length; i++) {
        if (services[i] != null && services[i].containsKey('activeService') && services[i]['activeService'] == '1') {
          activeServices.add(services[i]);
        }
      }

      var internetResponse = await http.get(Uri.parse('$apiUrl/user/$uid/internet'), headers: {'USERSID': sid});
      var internet = jsonDecode(utf8.decode(internetResponse.bodyBytes))[0]; // TODO multiple tariffs
      debugInfo += '\ninternet:\n$internet\n';

      var nextFeeResponse = await http.get(Uri.parse('$apiUrl/user/$uid/internet/${internet['id']}/warnings'), headers: {'USERSID': sid});
      var nextFee = jsonDecode(utf8.decode(nextFeeResponse.bodyBytes));
      debugInfo += '\nnextFee:\n$nextFee\n';

      var prefs = await SharedPreferences.getInstance();
      prefs.setString('tpId', internet['id'].toString());

      log(debugInfo);

      return {'profile': overallInfo, 'services': activeServices, 'internet': internet, 'nextFee': nextFee};
    } catch (e, stacktrace) {
      log(debugInfo);
      log(e.toString());
      log(stacktrace.toString());

      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: Text('Помилка'),
          insetPadding: EdgeInsets.all(0),
          contentPadding: EdgeInsets.fromLTRB(24, 16, 24, 0),
          content: SizedBox.expand(
            child: Scrollbar(
              isAlwaysShown: true,
              child: SingleChildScrollView(
                physics: BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
                child: Text(e.toString() + stacktrace.toString() + '\n\n' + debugInfo),
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('ОК'),
            ),
          ],
        ),
      );
    }
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
    if (lastUid != uid) {
      futureData = null;
      lastUid = uid;
    }
    checkData();

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: MyAppBar(),
      // floatingActionButton: FloatingActionButton(
      //   onPressed: () {
      //     Navigator.pushNamed(context, '/support');
      //   },
      //   child: Icon(Icons.chat),
      //   tooltip: 'Чат з тех. підтримкою',
      // ),
      body: Container(
        child: futureData != null ? RefreshIndicator(
          onRefresh: () {
            return checkData();
          },
          child: Scrollbar(
            child: ListView(
              physics: BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
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
                                    Text(futureData['profile']['deposit'].toStringAsFixed(2), style: TextStyle(fontSize: 32, color: futureData['profile']['deposit'] > 0 ? Colors.green : Colors.red)),
                                    Text(' грн', style: TextStyle(fontSize: 18, color: futureData['profile']['deposit'] > 0 ? Colors.green : Colors.red)),
                                  ],
                                ),
                                SizedBox(height: 8),
                                futureData['nextFee'].containsKey('abonDate')
                                  ? Text('${DateFormat('dd.MM.yyyy').format(DateTime.parse(futureData['nextFee']['abonDate']))} буде знято ${futureData['nextFee']['sum']} грн')
                                  : Text(futureData['nextFee']['warning']),
                                SizedBox(height: 16),

                                ElevatedButton(
                                  onPressed: () {
                                    Navigator.pushNamed(context, '/pay');
                                  },
                                  child: Text('ПОПОВНИТИ', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w400, letterSpacing: 1.5)),
                                  style: ElevatedButton.styleFrom(
                                    fixedSize: Size(MediaQuery.of(context).size.width - 16 * 3, 55),
                                    elevation: 0,
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
                            Expanded(
                              child: Text('«${futureData['internet']['tpName']}»', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold), textAlign: TextAlign.center,),
                            ),
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
                          title: Text('${futureData['internet']['speed'] ?? 'needAPI'} Мб/с'),
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
                if (futureData['services'].isNotEmpty) for (var item in futureData['services']) Card(
                  margin: EdgeInsets.fromLTRB(8, 4, 8, 4),
                  child: Padding(
                    padding: EdgeInsets.fromLTRB(16, 24, 16, 8),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: Text('«${item['name']}»', style: TextStyle(fontSize: 20)),
                            ),
                            Column(
                              children: [
                                Text('АКТИВНО', style: TextStyle(color: Colors.green)),
                                // Switch(value: true, onChanged: (value) {}),
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