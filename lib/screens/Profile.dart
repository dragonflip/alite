import 'package:flutter/material.dart';

import '../widgets/MyAppBar.dart';
import '../widgets/MyBottomNavigationBar.dart';

class Profile extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: MyAppBar(),
      body: SingleChildScrollView(
        child: Container(
          child: Card(
            margin: EdgeInsets.all(8),
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: 16, horizontal: 8),
              child: Column(
                children: [
                  Row(
                    children: [
                      // OutlinedButton.icon(
                      //   onPressed: () {},
                      //   icon: Icon(Icons.edit),
                      //   label: Text("Редагувати профіль"),
                      // ),
                      OutlinedButton.icon(
                        onPressed: () {},
                        icon: Icon(Icons.block),
                        label: Text("Заморозити аккаунт"),
                      ),
                    ],
                  ),
                  ListTile(
                    title: Text("Василенко Василь"),
                    subtitle: Text("ПІБ"),
                    leading: Icon(Icons.person),
                  ),
                  ListTile(
                    title: Text("testuser"),
                    subtitle: Text("Логін"),
                    leading: Icon(Icons.assignment_ind),
                  ),
                  ListTile(
                    title: Text("+38088008080"),
                    subtitle: Text("Телефон"),
                    leading: Icon(Icons.phone),
                  ),
                  ListTile(
                    title: Text("Петренка 2А"),
                    subtitle: Text("Адреса"),
                    leading: Icon(Icons.home),
                  ),
                  ListTile(
                    title: Text("vasylenko@gmail.com"),
                    subtitle: Text("Електронна пошта"),
                    leading: Icon(Icons.email),
                  ),
                  ListTile(
                    title: Text("35114"),
                    subtitle: Text("Контракт №"),
                    leading: Icon(Icons.assignment),
                  ),
                  ListTile(
                    title: Text("26.02.2015"),
                    subtitle: Text("Дата підписання контракту"),
                    leading: Icon(Icons.date_range),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
      bottomNavigationBar: MyBottomNavigationBar(),
    );
  }
}