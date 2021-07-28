import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../widgets/MyAppBar.dart';

class About extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: MyAppBar("Про нас"),
      body: SingleChildScrollView(
        child: Container(
          child: Card(
            margin: EdgeInsets.all(8),
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Column(
                children: [
                  Image.asset("assets/logo.png", width: 250, fit: BoxFit.fill),
                  SizedBox(height: 16),
                  Text("ABillS (Advanced Billing Solutions) — надежная конвергентная биллинговая система, предназначенная для учета и тарификации всего спектра услуг предоставляемых операторами связи (Dialup, VPN, Hotspot, VoIP, IPTV). \nСистема является многофункциональной, модульной ACP (Автоматической Системой Расчётов) с открытым программным кодом, в последующем будет называться Биллингом.", style: TextStyle(fontSize: 18)),
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