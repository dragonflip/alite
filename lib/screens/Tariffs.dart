import 'package:flutter/material.dart';
import 'dart:async';
import 'package:http/http.dart' as http;
import 'dart:convert';

import '../globals.dart';

import '../widgets/MyAppBar.dart';
import '../widgets/MyBottomNavigationBar.dart';

class Tariffs extends StatefulWidget {
  @override
  _Tariffs createState() => _Tariffs();
}

var futureData;

class _Tariffs extends State<Tariffs> {
  Future getData() async {
    await getGlobals();

    var internetInfo = await http.get(Uri.parse('$apiUrl/user/$uid/internet'), headers: {'USERSID': sid});
    var internet = jsonDecode(utf8.decode(internetInfo.bodyBytes))[0];
    internet['name'] = internet['tpName'];

    var tariffsInfo = await http.get(Uri.parse('$apiUrl/user/$uid/internet/$tpId/tariffs'), headers: {'USERSID': sid});
    var tariffs = jsonDecode(utf8.decode(tariffsInfo.bodyBytes));
    tariffs.insert(0, internet);

    return tariffs;
  }

  @override
  void initState() {
    futureData = futureData ?? getData();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: MyAppBar(),
      body: Container(
        child: FutureBuilder(
          future: futureData,
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              final data = snapshot.data as List<dynamic>;

              return Scrollbar(
                child: ListView.builder(
                  itemCount: data.length,
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
                              data[index]['id'] == tpId ? Row(
                                children: [
                                  Icon(Icons.check_circle, color: Colors.green),
                                  SizedBox(width: 8),
                                ],
                              ) : Wrap(),
                              Text('Інтернет «${data[index]['name']}»', style: TextStyle(fontSize: 24)),
                            ],
                          ),
                          SizedBox(height: 8),

                          ListTile(
                            title: Text('${data[index]['speed']} Мб/c'),
                            subtitle: Text('Швидкість'),
                            leading: Icon(Icons.network_check),
                          ),
                          Divider(),

                          ListTile(
                            title: Text('${data[index]['monthFee']} грн', style: TextStyle(fontSize: 18)),
                            subtitle: Text('Ціна'),
                            leading: Icon(Icons.attach_money),
                            trailing: data[index]['id'] != tpId ? ElevatedButton(
                              onPressed: () {},
                              child: Text('ПІДКЛЮЧИТИ'),
                              style: ElevatedButton.styleFrom(
                                elevation: 0,
                              ),
                            ) : TextButton(
                              onPressed: () {
                                showDialog(
                                  context: context,
                                  builder: (_) => AlertDialog(
                                    title: Text('Призупинити тариф'),
                                    content: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        TextField(
                                          decoration: InputDecoration(
                                            border: OutlineInputBorder(),
                                            labelText: 'Зупинити з - по',
                                            hintText: 'Оберіть діапазон дати',
                                            suffixIcon: Icon(Icons.calendar_today),
                                          ),
                                          readOnly: true,
                                          showCursor: true,
                                          onTap: () {
                                            showDateRangePicker(
                                              context: context,
                                              firstDate: DateTime(2021),
                                              lastDate: DateTime(2022),
                                              initialDateRange: DateTimeRange(start: DateTime.now(), end: DateTime.now()),
                                              initialEntryMode: DatePickerEntryMode.input,
                                            );
                                          },
                                        ),
                                      ],
                                    ),
                                    actions: [
                                      TextButton(
                                        onPressed: () => Navigator.pop(context),
                                        child: Text('СКАСУВАТИ', style: TextStyle(color: Colors.black54)),
                                      ),
                                      TextButton(
                                        onPressed: () => Navigator.pop(context),
                                        child: Text('ПРИЗУПИНИТИ'),
                                      ),
                                    ],
                                  ),
                                );
                              },
                              child: Text('ПРИЗУПИНИТИ'),
                            ),
                          ),
                        ],
                      ),
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