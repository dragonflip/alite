import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

import '../widgets/MyAppBar.dart';
import '../widgets/MyBottomNavigationBar.dart';

class Tariff extends StatelessWidget {
  List<String> names = ["Домашній", "Домашній+", "Геймер", "Геймер Про"];
  List<String> speeds = ["20 Мб/с", "50 Мб/с", "150 Мб/с", "500 Мб/с"];
  List<String> channels = ["100", "210", "300", "400"];
  List<String> prices = ["135", "250", "400", "950"];

  final _scrollController = ScrollController();

  @override
  Widget build(BuildContext context) {
    if (ModalRoute.of(context)?.settings.arguments.toString() == "change_tariff") {
      Timer(Duration.zero, () => _scrollController.animateTo(320, duration: Duration(milliseconds: 1000), curve: Curves.ease));
      // Timer(Duration(milliseconds: 1500), () => _scrollController.animateTo(0, duration: Duration(milliseconds: 1000), curve: Curves.easeOutCubic));
    }

    return Scaffold(
      appBar: MyAppBar(),
      body: Container(
        child: ListView.builder(
          itemCount: 4,
          controller: _scrollController,
          physics: BouncingScrollPhysics(),

          itemBuilder: (_, index) => Card(
            margin: EdgeInsets.all(8),
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Column(
                children: [
                  index == 1 ? Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.check_circle, color: Colors.green),
                      SizedBox(width: 8),
                      Text("Тариф «${names[index]}»", style: TextStyle(fontSize: 24)),
                    ],
                  ) : Text("Тариф «${names[index]}»", style: TextStyle(fontSize: 24)),

                  SizedBox(height: 8),

                  ListTile(
                    title: Text("${speeds[index]}"),
                    subtitle: Text("Інтернет"),
                    leading: Icon(Icons.network_check),
                  ),
                  ListTile(
                    title: Text("${channels[index]} каналів"),
                    subtitle: Text("Телебачення"),
                    leading: Icon(Icons.live_tv),
                  ),
                  Divider(),

                  ListTile(
                    title: Text("${prices[index]} грн", style: TextStyle(fontSize: 18)),
                    subtitle: Text("Ціна"),
                    leading: Icon(Icons.attach_money),
                    trailing: index != 1 ? ElevatedButton(
                      onPressed: () {},
                      child: Text("ПІДКЛЮЧИТИ"),
                    ) : TextButton(
                      onPressed: () {},
                      child: Text("ПРИЗУПИНИТИ"),
                    ),
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