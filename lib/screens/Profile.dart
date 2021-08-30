import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:intl/intl.dart';

import '../globals.dart';

import '../widgets/MyAppBar.dart';
import '../widgets/MyBottomNavigationBar.dart';

class Profile extends StatefulWidget {
  @override
  createState() => _Profile();
}

var futureData, lastUid;

class _Profile extends State<Profile> {
  var _editPhone = false;
  var _editEmail = false;
  final _focusNode = FocusNode();

  Future getData() async {
    await getGlobals();

    lastUid = lastUid ?? uid;

    var profileResponse = await http.get(Uri.parse('$apiUrl/user/$uid/pi'), headers: {'USERSID': sid});
    var profile = jsonDecode(utf8.decode(profileResponse.bodyBytes));

    profile['phone'] = profile['phone'].isNotEmpty ? profile['phone'][0] : '';
    profile['email'] = profile['email'].isNotEmpty ? profile['email'][0] : '';

    return profile;
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
        constraints: BoxConstraints.expand(),
        child: SingleChildScrollView(
          physics: BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
          child: futureData != null ? Card(
            margin: EdgeInsets.all(8),
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: 16, horizontal: 8),
              child: Column(
                children: [
                  ListTile(
                    title: Text(futureData['fio']),
                    subtitle: Text('ПІБ'),
                    leading: Icon(Icons.person),
                  ),
                  ListTile(
                    title: Text(login),
                    subtitle: Text('Логін'),
                    leading: Icon(Icons.assignment_ind),
                  ),
                  ListTile(
                    title: _editPhone ? TextFormField(
                      initialValue: futureData['phone'],
                      cursorHeight: 22,
                      focusNode: _focusNode,

                      decoration: InputDecoration(
                        isDense: true,
                        contentPadding: EdgeInsets.symmetric(vertical: 1),
                      ),

                      autovalidateMode: AutovalidateMode.onUserInteraction,
                      validator: (value) {
                        if (value!.isEmpty) return 'Введіть телефон';
                        futureData['phone'] = value;
                      },

                    ) : futureData['phone'].isNotEmpty ? Text(futureData['phone']) : Text('Не вказано'),
                    subtitle: Text('Телефон'),
                    leading: Icon(Icons.phone),
                    trailing: IconButton(
                      onPressed: () async {
                        if (_editPhone && futureData['phone'].isNotEmpty) {
                        //   try {
                        //     var res = await http.put(Uri.parse('$apiUrl/users/$uid/pi'), body: jsonEncode({'phone': futureData['phone'][0]}), headers: {'KEY': 'testAPI_KEY12'});
                        //     print(res.body);
                        //   } catch (e) {
                        //     print(e);
                        //   }

                          _focusNode.unfocus();
                        } else {
                          _focusNode.requestFocus();
                        }

                        setState(() {
                          _editPhone = !_editPhone;
                        });
                      },
                      icon: !_editPhone ? Icon(Icons.edit) : Icon(Icons.check, color: Colors.red),
                      tooltip: !_editPhone ? 'Редагувати телефон' : 'Зберегти зміни',
                    ),
                  ),
                  ListTile(
                    title: _editEmail ? TextFormField(
                      initialValue: futureData['email'],
                      cursorHeight: 22,
                      focusNode: _focusNode,

                      decoration: InputDecoration(
                        isDense: true,
                        contentPadding: EdgeInsets.symmetric(vertical: 1),
                      ),

                      autovalidateMode: AutovalidateMode.onUserInteraction,
                      validator: (value) {
                        if (value!.isEmpty) return 'Введіть телефон';
                        futureData['email'] = value;
                      },
                    ) : futureData['email'].isNotEmpty ? Text(futureData['email']) : Text('Не вказано'),
                    subtitle: Text('Електронна пошта'),
                    leading: Icon(Icons.email),
                    trailing: IconButton(
                      onPressed: () async {
                        if (_editEmail && futureData['email'].isNotEmpty) {
                          // try {
                          //   var res = await http.put(Uri.parse('$apiUrl/users/$uid/pi'), body: jsonEncode({'email': futureData['email']}), headers: {'KEY': 'testAPI_KEY12'});
                          //   print(res.body);
                          // } catch (e) {
                          //   print(e);
                          // }

                          _focusNode.unfocus();
                        } else {
                          _focusNode.requestFocus();
                        }

                        setState(() {
                          _editEmail = !_editEmail;
                        });
                      },
                      icon: !_editEmail ? Icon(Icons.edit) : Icon(Icons.check, color: Colors.red),
                      tooltip: !_editEmail ? 'Редагувати електронну пошту' : 'Зберегти зміни',
                    ),
                  ),
                  ListTile(
                    title: futureData.containsKey('addressFull') ? Text(futureData['addressFull'].trim()) : Text('Не вказано'),
                    subtitle: Text('Адреса'),
                    leading: Icon(Icons.home),
                  ),
                  ListTile(
                    title: Text(futureData['contractId']),
                    subtitle: Text('Контракт №'),
                    leading: Icon(Icons.assignment),
                  ),
                  ListTile(
                    title: Text(DateFormat('dd.MM.yyyy').format(DateTime.parse(futureData['contractDate']))),
                    subtitle: Text('Дата підписання контракту'),
                    leading: Icon(Icons.date_range),
                  ),
                ],
              ),
            ),
          ) : LinearProgressIndicator(),
        ),
      ),
      bottomNavigationBar: MyBottomNavigationBar(),
    );
  }
}