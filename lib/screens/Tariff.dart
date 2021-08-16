import 'package:flutter/material.dart';
import 'dart:async';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import '../widgets/MyAppBar.dart';
import '../widgets/MyBottomNavigationBar.dart';

class Tariff extends StatefulWidget {
  @override
  _Tariff createState() => _Tariff();
}

class _Tariff extends State<Tariff> {
  var _uid, _sid, _tpId;

  getData() async {
    final prefs = await SharedPreferences.getInstance();
    _uid = prefs.getString("uid");
    _sid = prefs.getString("sid");
    _tpId = prefs.getString("tpId");

    var internetInfo = await http.get(Uri.parse("https://demo.abills.net.ua:9443/api.cgi/user/$_uid/internet"), headers: {"USERSID": _sid});
    var internet = jsonDecode(utf8.decode(internetInfo.bodyBytes))[0];
    internet['name'] = internet['tpName'];

    var tariffsInfo = await http.get(Uri.parse('https://demo.abills.net.ua:9443/api.cgi/user/$_uid/internet/$_tpId/tariffs'), headers: {"USERSID": _sid});
    var tariffs = jsonDecode(utf8.decode(tariffsInfo.bodyBytes));
    tariffs.insert(0, internet);

    return tariffs;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: MyAppBar(),
      body: Container(
        child: FutureBuilder(
          future: getData(),
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              final data = snapshot.data as List<dynamic>;

              final scrollController = ScrollController();
              if (ModalRoute.of(context)?.settings.arguments.toString() != "change_tariff") {
                Timer(Duration(milliseconds: 1000), () => scrollController.animateTo(255, duration: Duration(milliseconds: 1000), curve: Curves.ease));
              }

              return ListView.builder(
                itemCount: data.length,
                controller: scrollController,
                physics: BouncingScrollPhysics(),

                itemBuilder: (_, index) => Card(
                  margin: EdgeInsets.all(8),
                  child: Padding(
                    padding: EdgeInsets.fromLTRB(16, 24, 16, 16),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            data[index]['id'] == _tpId ? Row(
                              children: [
                                Icon(Icons.check_circle, color: Colors.green),
                                SizedBox(width: 8),
                              ],
                            ) : Wrap(),
                            Text("Інтернет «${data[index]['name']}»", style: TextStyle(fontSize: 24)),
                          ],
                        ),
                        SizedBox(height: 8),

                        ListTile(
                          title: Text("${data[index]['speed']} Мб/c"),
                          subtitle: Text("Швидкість"),
                          leading: Icon(Icons.network_check),
                        ),
                        Divider(),

                        ListTile(
                          title: Text("${data[index]['monthFee']} грн", style: TextStyle(fontSize: 18)),
                          subtitle: Text("Ціна"),
                          leading: Icon(Icons.attach_money),
                          trailing: data[index]['id'] != _tpId ? ElevatedButton(
                            onPressed: () {},
                            child: Text("ПІДКЛЮЧИТИ"),
                            style: ElevatedButton.styleFrom(
                              elevation: 0,
                            ),
                          ) : TextButton(
                            onPressed: () {},
                            child: Text("ПРИЗУПИНИТИ"),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            } else {
              return LinearProgressIndicator();
            }
          },
        ),
      ),
      bottomNavigationBar: MyBottomNavigationBar(),
    );
  }
}