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

class _Profile extends State<Profile> {
  var _edit_phone = false;
  var _edit_email = false;
  final _focusNode = FocusNode();

  var _uid;

  getData() async {
    final prefs = await SharedPreferences.getInstance();
    _uid = prefs.getString("uid");

    var profile = await http.get(Uri.parse('https://demo.abills.net.ua:9443/api.cgi/users/$_uid/pi'), headers: {"KEY": "testAPI_KEY12"});

    return jsonDecode(utf8.decode(profile.bodyBytes));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: MyAppBar(),
      body: SingleChildScrollView(
        physics: BouncingScrollPhysics(),
        child: Container(
          child: FutureBuilder(
            future: getData(),
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                final data = snapshot.data as Map<String, dynamic>;
                print(data);

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
                          title: Text("testuser"),
                          subtitle: Text("Логін"),
                          leading: Icon(Icons.assignment_ind),
                        ),
                        ListTile(
                          title: _edit_phone ? TextFormField(
                            initialValue: "${data['phone'][0]}",
                            cursorHeight: 22,
                            focusNode: _focusNode,

                            decoration: InputDecoration(
                              isDense: true,
                              contentPadding: EdgeInsets.symmetric(vertical: 1),
                            ),
                          ) : Text("${data['phone'][0]}"),
                          subtitle: Text("Телефон"),
                          leading: Icon(Icons.phone),
                          trailing: IconButton(
                            onPressed: () {
                              setState(() {
                                _edit_phone = !_edit_phone;
                                _focusNode.requestFocus();
                              });
                            },
                            icon: !_edit_phone ? Icon(Icons.edit) : Icon(Icons.check, color: Colors.red),
                            tooltip: !_edit_phone ? "Редагувати телефон" : "Зберегти зміни",
                          ),
                        ),
                        ListTile(
                          title: Text("${data['addressFull'].toString().trim()}"),
                          subtitle: Text("Адреса"),
                          leading: Icon(Icons.home),
                        ),
                        ListTile(
                          title: _edit_email ? TextFormField(
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
                                _edit_email = !_edit_email;
                                _focusNode.requestFocus();
                              });
                            },
                            icon: !_edit_email ? Icon(Icons.edit) : Icon(Icons.check, color: Colors.red),
                            tooltip: !_edit_email ? "Редагувати електронну пошту" : "Зберегти зміни",
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