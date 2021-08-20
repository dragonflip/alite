import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:intl/intl.dart';

import '../widgets/MyAppBar.dart';
import '../widgets/MyBottomNavigationBar.dart';

class Profile extends StatefulWidget {
  @override
  createState() => _Profile();
}

var futureData;
var _uid, _sid, _login;

class _Profile extends State<Profile> {
  var _editPhone = false;
  var _editEmail = false;
  final _focusNode = FocusNode();

  Future getData() async {
    final prefs = await SharedPreferences.getInstance();
    _uid = prefs.getString("uid");
    _sid = prefs.getString("sid");
    _login = prefs.getString("login");

    var profile = await http.get(Uri.parse('https://demo.abills.net.ua:9443/api.cgi/user/$_uid/pi'), headers: {"USERSID": _sid});

    return jsonDecode(utf8.decode(profile.bodyBytes));
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
        constraints: BoxConstraints.expand(),
        child: SingleChildScrollView(
          physics: BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
          child: FutureBuilder(
            future: futureData,
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                final data = snapshot.data as Map<String, dynamic>;

                return Card(
                  margin: EdgeInsets.all(8),
                  child: Padding(
                    padding: EdgeInsets.symmetric(vertical: 16, horizontal: 8),
                    child: Column(
                      children: [
                        OutlinedButton.icon(
                          onPressed: () {
                            showDialog(
                              context: context,
                              builder: (_) => AlertDialog(
                                title: Text('Заморозити аккаунт?'),
                                content: Text('Замороження аккаунта призупиняє послуги та їх щомісячну оплату.'),
                                actions: [
                                  TextButton(
                                    onPressed: () => Navigator.pop(context),
                                    child: Text("СКАСУВАТИ", style: TextStyle(color: Colors.black54)),
                                  ),
                                  TextButton(
                                    onPressed: () => Navigator.pop(context),
                                    child: Text("ЗАМОРОЗИТИ"),
                                  ),
                                ],
                              ),
                            );
                          },
                          icon: Icon(Icons.block),
                          label: Text("Заморозити аккаунт"),
                        ),
                        ListTile(
                          title: Text("${data['fio']}"),
                          subtitle: Text("ПІБ"),
                          leading: Icon(Icons.person),
                        ),
                        ListTile(
                          title: Text("$_login"),
                          subtitle: Text("Логін"),
                          leading: Icon(Icons.assignment_ind),
                        ),
                        ListTile(
                          title: _editPhone ? TextFormField(
                            initialValue: "${data['phone'][0]}",
                            cursorHeight: 22,
                            focusNode: _focusNode,

                            decoration: InputDecoration(
                              isDense: true,
                              contentPadding: EdgeInsets.symmetric(vertical: 1),
                            ),

                            validator: (value) {
                              if (value!.isEmpty) {
                                return "Введіть телефон";
                              }

                              data['phone'][0] = value;
                            },
                            autovalidateMode: AutovalidateMode.onUserInteraction,
                          ) : Text("${data['phone'][0]}"),
                          subtitle: Text("Телефон"),
                          leading: Icon(Icons.phone),
                          trailing: IconButton(
                            onPressed: () async {
                              if (_editPhone) {
                                try {
                                  var res = await http.put(Uri.parse('https://demo.abills.net.ua:9443/api.cgi/users/$_uid/pi'), body: jsonEncode({"phone": data['phone'][0]}), headers: {"KEY": "testAPI_KEY12"});
                                  print(res.body);
                                } catch (e) {
                                  print(e);
                                }
                              }

                              setState(() {
                                _editPhone = !_editPhone;
                                _focusNode.requestFocus();
                              });
                            },
                            icon: !_editPhone ? Icon(Icons.edit) : Icon(Icons.check, color: Colors.red),
                            tooltip: !_editPhone ? "Редагувати телефон" : "Зберегти зміни",
                          ),
                        ),
                        ListTile(
                          title: Text("${data['addressFull'].trim()}"),
                          subtitle: Text("Адреса"),
                          leading: Icon(Icons.home),
                        ),
                        ListTile(
                          title: _editEmail ? TextFormField(
                            initialValue: "${data['email'][0]}",
                            cursorHeight: 22,
                            focusNode: _focusNode,

                            decoration: InputDecoration(
                              isDense: true,
                              contentPadding: EdgeInsets.symmetric(vertical: 1),
                            ),
                          ) : Text("${data['email'][0]}"),
                          subtitle: Text("Електронна пошта"),
                          leading: Icon(Icons.email),
                          trailing: IconButton(
                            onPressed: () {
                              setState(() {
                                _editEmail = !_editEmail;
                                _focusNode.requestFocus();
                              });
                            },
                            icon: !_editEmail ? Icon(Icons.edit) : Icon(Icons.check, color: Colors.red),
                            tooltip: !_editEmail ? "Редагувати електронну пошту" : "Зберегти зміни",
                          ),
                        ),
                        ListTile(
                          title: Text("${data['contractId']}"),
                          subtitle: Text("Контракт №"),
                          leading: Icon(Icons.assignment),
                        ),
                        ListTile(
                          title: Text("${DateFormat("dd.MM.yyyy").format(DateTime.parse(data['contractDate']))}"),
                          subtitle: Text("Дата підписання контракту"),
                          leading: Icon(Icons.date_range),
                        ),
                      ],
                    ),
                  ),
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