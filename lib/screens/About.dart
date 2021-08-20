import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../widgets/MyAppBar.dart';

class About extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: MyAppBar("Про нас"),
      body: Container(
        constraints: BoxConstraints.expand(),
        child: SingleChildScrollView(
          physics: BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
          child: Card(
            margin: EdgeInsets.all(8),
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Column(
                children: [
                  Image.asset("assets/logo.png", width: 250, fit: BoxFit.fill),
                  SizedBox(height: 16),
                  Text("ABillS (Advanced Billing Solutions) — надійна конвергентна білінгова система, призначена для обліку і тарифікації всього спектра послуг, що надаються операторами зв'язку (Dialup, VPN, Hotspot, VoIP, IPTV). \nСистема є багатофункціональною, модульною ACP (Автоматична Система Розрахунків) з відкритим програмним кодом.", style: TextStyle(fontSize: 18)),
                  SizedBox(height: 16),
                  InkWell(
                    onTap: () => launch("http://abills.net.ua"),
                    child: Text("abills.net.ua", style: TextStyle(color: Colors.red, decoration: TextDecoration.underline)),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}