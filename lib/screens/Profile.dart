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
  Future getData() async {
    await getGlobals();

    lastUid = lastUid ?? uid;

    var profileResponse = await http.get(Uri.parse('$apiUrl/user/$uid/pi'), headers: {'USERSID': sid});
    var profile = jsonDecode(utf8.decode(profileResponse.bodyBytes));

    print(profileResponse.body);

    profile['phone'] = profile['phone'].isNotEmpty ? profile['phone'][0].trim() : 'Не вказано';
    profile['email'] = profile['email'].isNotEmpty ? profile['email'][0].trim() : 'Не вказано';
    profile['addressFull'] = profile.containsKey('addressFull') ? profile['addressFull'].trim() : 'Не вказано';

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
                    title: Text(futureData['phone']),
                    subtitle: Text('Телефон'),
                    leading: Icon(Icons.phone),
                  ),
                  ListTile(
                    title: Text(futureData['email']),
                    subtitle: Text('Електронна пошта'),
                    leading: Icon(Icons.email),
                  ),
                  ListTile(
                    title: Text(futureData['addressFull']),
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