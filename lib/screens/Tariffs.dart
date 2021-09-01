import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'dart:convert';

import '../global.dart';

import '../widgets/MyAppBar.dart';
import '../widgets/MyBottomNavigationBar.dart';

class Tariffs extends StatefulWidget {
  @override
  _Tariffs createState() => _Tariffs();
}

var futureData, lastUid;

class _Tariffs extends State<Tariffs> {
  Future getData() async {
    await getGlobals();
    await checkSession();

    lastUid = lastUid ?? uid;

    var internetInfo = await http.get(Uri.parse('$apiUrl/user/$uid/internet'), headers: {'USERSID': sid});
    var internet = jsonDecode(utf8.decode(internetInfo.bodyBytes))[0];
    internet['name'] = internet['tpName'];

    var tariffsInfo = await http.get(Uri.parse('$apiUrl/user/$uid/internet/$tpId/tariffs'), headers: {'USERSID': sid});
    var tariffs = jsonDecode(utf8.decode(tariffsInfo.bodyBytes));

    print(tariffs);

    // Not allowed to change tariff
    if (tariffs is Map && tariffs.containsKey('error')) {
      internet['error_message'] = 'not_allowed_to_change_tp';
      return [internet];
    } else {
      tariffs.insert(0, internet);
      return tariffs;
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
      body: Container(
        child: futureData != null ? Scrollbar(
          child: ListView.builder(
            physics: BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
            itemCount: futureData.length,
            itemBuilder: (_, index) => Column(
              children: [
                Card(
                  margin: EdgeInsets.all(8),
                  child: Padding(
                    padding: EdgeInsets.fromLTRB(16, 24, 16, 16),
                    child: Column(
                      children: [
                        Column(
                          children: [
                            if (futureData[index]['id'] == tpId) Icon(Icons.check_circle, color: Colors.green),
                            Text('«${futureData[index]['name']}»', style: TextStyle(fontSize: 24), textAlign: TextAlign.center),
                          ],
                        ),
                        SizedBox(height: 8),

                        ListTile(
                          title: Text('${futureData[index]['speed']} Мб/c'),
                          subtitle: Text('Швидкість'),
                          leading: Icon(Icons.network_check),
                        ),
                        Divider(),

                        ListTile(
                          title: Text('${futureData[index]['monthFee']} грн', style: TextStyle(fontSize: 18)),
                          subtitle: Text('Ціна'),
                          leading: Icon(Icons.attach_money),
                          trailing: futureData[index]['id'] != tpId ? ElevatedButton(
                            onPressed: () {},
                            child: Text('ПІДКЛЮЧИТИ'),
                            style: ElevatedButton.styleFrom(
                              elevation: 0,
                            ),
                          ) : TextButton(
                            onPressed: () async {
                              final selectedDateRange = await showDateRangePicker(
                                context: context,
                                initialEntryMode: DatePickerEntryMode.input,

                                firstDate: DateTime.now(),
                                lastDate: DateTime(DateTime.now().year + 1),
                                initialDateRange: DateTimeRange(start: DateTime.now(), end: DateTime.now().add(new Duration(days: 10))),

                                helpText: 'ПРИЗУПИНЕННЯ ТАРИФУ',
                                confirmText: 'ПРИЗУПИНИТИ',
                                saveText: 'ПРИЗУПИНИТИ',
                              );

                              if (selectedDateRange != null) {
                                final fromDate = DateFormat('yyyy-MM-dd').format(selectedDateRange.start);
                                final toDate = DateFormat('yyyy-MM-dd').format(selectedDateRange.end);

                                await checkSession();

                                var unpauseInternetResponse = await http.delete(Uri.parse('$apiUrl/user/$uid/internet/$tpId/holdup'), headers: {'USERSID': sid});
                                print(unpauseInternetResponse.body + '\n\n');

                                var pauseInternetResponse = await http.post(Uri.parse('$apiUrl/user/$uid/internet/$tpId/holdup'), body: jsonEncode({'from_date': fromDate, 'to_date': toDate}), headers: {'USERSID': sid});
                                var pauseInternet = jsonDecode(utf8.decode(pauseInternetResponse.bodyBytes));

                                if (pauseInternet['delIds'] == '') {
                                  showDialog(
                                    context: context,
                                    builder: (_) => AlertDialog(
                                      title: Text('Помилка'),
                                      content: Text('Ви не можете призупинити послугу. Адміністратор заборонив цю дію.'),
                                      actions: [
                                        TextButton(
                                          onPressed: () => Navigator.pop(context),
                                          child: Text('ОК'),
                                        ),
                                      ],
                                    ),
                                  );
                                }

                                print(fromDate + ' -> ' + toDate);
                                print(pauseInternet);
                              }
                            },
                            child: Text('ПРИЗУПИНИТИ'),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                if (futureData[index]['error_message'] == 'not_allowed_to_change_tp') Padding(
                  padding: EdgeInsets.only(top: 16),
                  child: Text('Ви не можете змінити тариф. Адміністратор заборонив цю дію.', style: TextStyle(fontSize: 20, color: Colors.black54), textAlign: TextAlign.center),
                ),
              ],
            ),
          ),
        ) : LinearProgressIndicator(),
      ),
      bottomNavigationBar: MyBottomNavigationBar(),
    );
  }
}