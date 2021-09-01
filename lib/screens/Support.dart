import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:intl/intl.dart';

import '../global.dart';

import '../widgets/MyAppBar.dart';

class Support extends StatefulWidget {
  @override
  _Support createState() => _Support();
}

class _Support extends State<Support> {
  var futureData;

  Future getData() async {
    await getGlobals();
    await checkSession();

    var dialogs = await http.post(Uri.parse('$apiUrl/msgs/list'), body: jsonEncode({'uid': uid}), headers: {'KEY': 'testAPI_KEY12'});

    return jsonDecode(utf8.decode(dialogs.bodyBytes));
  }

  @override
  void initState() {
    futureData = getData();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    List<String> messages = ['Перестав працювати інтернет після сильного вітру. Робіть щось з тим вітром, я за що гроші плачу', 'Не можу докачати фільм до кінця!!! Хочу дивитись фільми!!', 'Поясніть будь ласка, чому в тарифі заявлена швидкість 150 Мб/с, а в мене чомусь 65 Мб/c', 'Перезавантажте роутер, і не кіпішуйте. Будьте здорові!!'];
    List<String> statuses = ['Відкрито', 'Не виконано і закрито', 'Виконано і закрито', '?', '?', '?', 'Очікуємо Вашу відповідь'];
    List<Color> statusColors = [Colors.blue, Colors.red, Colors.green, Colors.black, Colors.black, Colors.black, Colors.orange];

    return Scaffold(
      appBar: MyAppBar('Технічна підтримка'),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showDialog(
            context: context,
            builder: (_) => AlertDialog(
              title: Text('Нове повідомлення'),
              insetPadding: EdgeInsets.all(0),
              scrollable: true,
              content: Container(
                width: MediaQuery.of(context).size.width * 0.8,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextFormField(
                      autofocus: true,
                      cursorHeight: 22,
                      textCapitalization: TextCapitalization.sentences,

                      decoration: InputDecoration(
                        labelText: 'Тема',
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value!.isEmpty) {
                          return 'Введіть тему повідомлення';
                        }
                      },
                      // onSaved: (value) => _login = value,
                    ),
                    SizedBox(height: 8),
                    TextFormField(
                      cursorHeight: 22,
                      maxLines: 10,
                      minLines: 5,
                      textCapitalization: TextCapitalization.sentences,

                      decoration: InputDecoration(
                        labelText: 'Текст повідомлення',
                        alignLabelWithHint: true,
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value!.isEmpty) {
                          return 'Введіть текст повідомлення';
                        }
                      },
                      // onSaved: (value) => _login = value,
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text('СКАСУВАТИ', style: TextStyle(color: Colors.black54)),
                ),
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text('ВІДПРАВИТИ'),
                ),
              ],
            ),
          );
        },
        child: Icon(Icons.edit),
        tooltip: 'Нове повідомлення в тех. підтримку',
      ),
      body: Container(
        child: FutureBuilder(
          future: futureData,
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              final data = (snapshot.data as List<dynamic>).reversed.toList();

              return ListView.separated(
                physics: BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
                separatorBuilder: (_, index) => Divider(
                  height: 0,
                ),
                itemCount: data.length,
                itemBuilder: (_, index) => ListTile(
                  onTap: () {
                    Navigator.pushNamed(context, '/support_dialog', arguments: index);
                  },
                  title: Text(data[index]['subject'], maxLines: 1, overflow: TextOverflow.ellipsis),
                  subtitle: RichText(
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,

                    text: TextSpan(
                      style: TextStyle(color: Colors.black54),
                      children: [
                        TextSpan(text: index == 3 ? 'Відповідь: ' : 'Ви: ', style: TextStyle(fontWeight: FontWeight.bold)),
                        TextSpan(text: messages[index]),
                      ],
                    ),
                  ),
                  trailing: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(statuses[int.parse(data[index]['stateId'])], style: TextStyle(color: statusColors[int.parse(data[index]['stateId'])], fontSize: 12)),
                      Text(DateFormat('dd.MM.yyyy').format(DateTime.parse(data[index]['date']))),
                    ],
                  ),
                  isThreeLine: true,
                  tileColor: Colors.white,
                ),
              );
            } else {
              return LinearProgressIndicator();
            }
          },
        ),
      ),
    );
  }
}