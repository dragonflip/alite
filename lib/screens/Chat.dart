import 'package:flutter/material.dart';

import '../widgets/MyAppBar.dart';

class Chat extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    List<String> titles = ['Не працює інтернет', 'Нестабільний інтернет', 'Невідповідність заявленої в тарифі швидкості', 'Тупить роутер'];
    List<String> messages = ['Ви: Перестав працювати інтернет після сильного вітру. Робіть щось з тим вітром, я за що гроші плачу', 'Ви: Не можу докачати фільм до кінця!!! Хочу дивитись фільми!!', 'Ви: Поясніть будь ласка, чому в тарифі заявлена швидкість 150 Мб/с, а в мене чомусь 65 Мб/c', 'Відповідь: Перезавантажте роутер, і не кіпішуйте. Будьте здорові!!'];
    List<String> dates = ['12:17', '10:42', '10.07.2021', '23.03.2019'];
    List<String> statuses = ['Відкрито', 'Відкрито', 'Відкрито', 'Закрито'];

    return Scaffold(
      appBar: MyAppBar("Технічна підтримка"),
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
                        labelText: "Тема",
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value!.isEmpty) {
                          return "Введіть тему повідомлення";
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
                        labelText: "Текст повідомлення",
                        alignLabelWithHint: true,
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value!.isEmpty) {
                          return "Введіть текст повідомлення";
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
                  child: Text("СКАСУВАТИ", style: TextStyle(color: Colors.black54)),
                ),
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text("ВІДПРАВИТИ"),
                ),
              ],
            ),
          );
        },
        child: Icon(Icons.edit),
        tooltip: "Нове повідомлення в тех. підтримку",
      ),
      body: Container(
        child: ListView.separated(
          separatorBuilder: (_, index) => Divider(
            height: 0,
          ),
          physics: BouncingScrollPhysics(),

          itemCount: 4,
          itemBuilder: (_, index) => ListTile(
            onTap: () {},
            title: Text(titles[index], maxLines: 1, overflow: TextOverflow.ellipsis),
            subtitle: Text(messages[index], maxLines: 2, overflow: TextOverflow.ellipsis),
            trailing: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(statuses[index], style: TextStyle(color: (statuses[index] == "Відкрито" ? Colors.green : Colors.red), fontSize: 12)),
                Text(dates[index]),
              ],
            ),
            isThreeLine: true,
            tileColor: Colors.white,
          ),
        ),
      ),
    );
  }
}