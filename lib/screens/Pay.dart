import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import '../global.dart';

import '../widgets/MyAppBar.dart';

class Pay extends StatefulWidget {
  @override
  createState() => _Pay();
}

var futureData;

class _Pay extends State<Pay> {
  final _focusNode = FocusNode();
  final _controller = TextEditingController();
  var _amount;

  Future getData() async {
    try {
      await getGlobals();
      await checkSession();

      var overallResponse = await http.get(Uri.parse('$apiUrl/user/$uid'), headers: {'USERSID': sid});
      var overallInfo = jsonDecode(utf8.decode(overallResponse.bodyBytes));
      overallInfo['deposit'] = double.parse(overallInfo['deposit']);
      overallInfo['credit'] = double.parse(overallInfo['credit']);

      var serviceCostResponse = await http.get(Uri.parse('$apiUrl/user/$uid/internet/$tpId/warnings'), headers: {'USERSID': sid});
      var serviceCost = jsonDecode(utf8.decode(serviceCostResponse.bodyBytes));

      var creditInfoResponse = await http.get(Uri.parse('$apiUrl/user/$uid/credit'), headers: {'USERSID': sid});
      var creditInfo = jsonDecode(utf8.decode(creditInfoResponse.bodyBytes));

      print(creditInfo);

      // TODO remove when API send sum even error
      if (serviceCost.containsKey('sum')) {
        if (overallInfo['deposit'] >= serviceCost['sum']) {
          _amount = serviceCost['sum'].toStringAsFixed(2);
        } else {
          _amount = (serviceCost['sum'] - overallInfo['deposit']).toStringAsFixed(2);
        }
      } else {
        serviceCost['sum'] = 0;
        _amount = '0';
      }

      return {'overallInfo': overallInfo, 'creditInfo': creditInfo, 'serviceCost': serviceCost};
    } catch (e) {
      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: Text('Помилка'),
          content: Text(e.toString()),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('ОК'),
            ),
          ],
        ),
      );
    }
  }

  @override
  void initState() {
    futureData = getData();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: MyAppBar('Поповнити'),
      body: Container(
        child: FutureBuilder(
          future: futureData,
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              var data = snapshot.data as Map<String, dynamic>;

              if (_amount != '0') {
                _controller.text = _amount;
                _controller.selection = TextSelection.fromPosition(TextPosition(offset: _controller.text.length));
              }

              return Scrollbar(
                child: ListView(
                  physics: BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
                  children: [
                    Card(
                      margin: EdgeInsets.all(8),
                      child: Padding(
                        padding: EdgeInsets.symmetric(vertical: 16, horizontal: 8),
                        child: Column(
                          children: [
                            ListTile(
                              title: Text('Мій баланс', style: TextStyle(fontSize: 18)),
                              leading: Icon(Icons.account_balance_wallet, color: Colors.red),
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Text(data['overallInfo']['deposit'].toStringAsFixed(2), style: TextStyle(fontSize: 20, color: data['overallInfo']['deposit'] > 0 ? Colors.green : Colors.red)),
                                  Text(' грн', style: TextStyle(fontSize: 14, color: data['overallInfo']['deposit'] > 0 ? Colors.green : Colors.red)),
                                ],
                              ),
                            ),
                            SizedBox(height: 8),
                            ListTile(
                              title: Text('Вартість послуг', style: TextStyle(fontSize: 18)),
                              leading: Icon(Icons.assessment),
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  // TODO remove condition when API will be completed
                                  Text(data['serviceCost']['sum'] == 0 ? 'needApi' : data['serviceCost']['sum'].toStringAsFixed(2), style: TextStyle(fontSize: 20)),
                                  Text(' грн', style: TextStyle(fontSize: 14)),
                                ],
                              ),
                            ),
                            SizedBox(height: 8),
                            if (data['creditInfo']['error'] != 4303) ListTile(
                              title: Text('Кредит', style: TextStyle(fontSize: 18)),
                              leading: Icon(Icons.account_balance),
                              trailing: data['overallInfo']['credit'] > 0 ? Row(
                                mainAxisSize: MainAxisSize.min,
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Text(data['overallInfo']['credit'].toStringAsFixed(2), style: TextStyle(fontSize: 20)),
                                  Text(' грн', style: TextStyle(fontSize: 14)),
                                ],
                              ) : OutlinedButton(
                                onPressed: () async {
                                  showDialog(
                                    context: context,
                                    builder: (_) => AlertDialog(
                                      title: Text('Деталі кредиту'),
                                      content: Text('Ви можете отримати кредит на суму ${data['creditInfo']['creditSum']} грн на ${data['creditInfo']['creditDays']} днів'),
                                      actions: [
                                        TextButton(
                                          onPressed: () => Navigator.pop(context),
                                          child: Text('СКАСУВАТИ', style: TextStyle(color: Colors.black54)),
                                        ),
                                        TextButton(
                                          onPressed: () async {
                                            Navigator.pop(context);

                                            await checkSession();

                                            var creditResponse = await http.post(Uri.parse('$apiUrl/user/$uid/credit'), headers: {'USERSID': sid});
                                            var credit = jsonDecode(utf8.decode(creditResponse.bodyBytes));

                                            print(credit);

                                            showDialog(
                                              context: context,
                                              builder: (_) => AlertDialog(
                                                title: Text('Кредит оформлено'),
                                                content: Text('Вам надано кредит на суму ${credit['creditSum']} грн на ${credit['creditDays']} днів'),
                                                actions: [
                                                  TextButton(
                                                    onPressed: () => Navigator.pop(context),
                                                    child: Text('ОК'),
                                                  ),
                                                ],
                                              ),
                                            );

                                            setState(() {
                                              futureData = getData();
                                            });
                                          },
                                          child: Text('ОТРИМАТИ'),
                                        ),
                                      ],
                                    ),
                                  );
                                },
                                child: Text('ОТРИМАТИ'),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    Card(
                      margin: EdgeInsets.all(8),
                      child: Padding(
                        padding: EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SizedBox(height: 8),
                            Text('Введіть суму поповнення:', style: TextStyle(fontSize: 22)),
                            SizedBox(height: 8),
                            TextFormField(
                              cursorHeight: 22,
                              focusNode: _focusNode,
                              onChanged: (value) {
                                setState(() {
                                  _amount = value.isNotEmpty ? value : '0';
                                });
                              },

                              controller: _controller,
                              keyboardType: TextInputType.numberWithOptions(signed: false, decimal: true),
                              inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'^[+-]?([0-9]+\.?[0-9]*|\.[0-9]+)$'))],
                              maxLength: 6,

                              decoration: InputDecoration(
                                labelText: 'Сума',
                                border: OutlineInputBorder(),
                                counterText: '',
                                helperText: 'Оплата за 1, 3 або 6 місяців:',
                              ),
                              validator: (value) {
                                if (value!.isEmpty) {
                                  return 'Введіть суму поповнення';
                                }
                              },
                            ),
                            Row(
                              children: [
                                ActionChip(
                                  onPressed: () {
                                    setState(() {
                                      _amount = data['serviceCost']['sum'].toStringAsFixed(2);
                                    });
                                  },
                                  label: Text(data['serviceCost']['sum'].toStringAsFixed(2)),
                                  avatar: Icon(Icons.looks_one, color: Colors.red),
                                  tooltip: 'Сума поповнення на 1 місяць',
                                  backgroundColor: Colors.grey[200],
                                ),
                                SizedBox(width: 8),
                                ActionChip(
                                  onPressed: () {
                                    setState(() {
                                      _amount = (data['serviceCost']['sum'] * 3).toStringAsFixed(2);
                                    });
                                  },
                                  label: Text((data['serviceCost']['sum'] * 3).toStringAsFixed(2)),
                                  avatar: Icon(Icons.looks_3, color: Colors.red),
                                  tooltip: 'Сума поповнення на 3 місяці',
                                  backgroundColor: Colors.grey[200],
                                ),
                                SizedBox(width: 8),
                                ActionChip(
                                  onPressed: () {
                                    setState(() {
                                      _amount = (data['serviceCost']['sum'] * 6).toStringAsFixed(2);
                                    });
                                  },
                                  label: Text((data['serviceCost']['sum'] * 6).toStringAsFixed(2)),
                                  avatar: Icon(Icons.looks_6, color: Colors.red),
                                  tooltip: 'Сума поповнення на 6 місяців',
                                  backgroundColor: Colors.grey[200],
                                ),
                              ],
                            ),
                            Divider(height: 32),

                            Text('Оплатити за допомогою:', style: TextStyle(fontSize: 22)),
                            SizedBox(height: 8),
                            ElevatedButton(
                              onPressed: () {
                                if (_amount != '0') {
                                  launch('https://next.privat24.ua/money-transfer/card');
                                } else {
                                  _focusNode.unfocus();
                                  WidgetsBinding.instance?.addPostFrameCallback((_) => _focusNode.requestFocus());
                                }
                              },
                              child: ListTile(
                                title: Text('Privat24'),
                                subtitle: Text('Сума до сплати'),
                                leading: Center(
                                  widthFactor: 1,
                                  child: Image.network('https://upload.wikimedia.org/wikipedia/commons/thumb/e/e0/Privat24_Logo.png/150px-Privat24_Logo.png.png', width: 50),
                                ),
                                trailing: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    Text(_amount, style: TextStyle(fontSize: 20)),
                                    Text(' грн', style: TextStyle(fontSize: 14)),
                                  ],
                                ),
                                isThreeLine: true,
                              ),
                              style: ElevatedButton.styleFrom(
                                primary: Colors.white,
                                onPrimary: Colors.red[200],
                                padding: EdgeInsets.zero,
                              ),
                            ),
                            SizedBox(height: 8),
                            ElevatedButton(
                              onPressed: () async {
                                if (_amount != '0') {
                                  var url = 'https://www.liqpay.ua/uk/checkout/card/380660068608';
                                  await canLaunch(url) ? await launch(url) : throw 'Could not launch $url';
                                } else {
                                  _focusNode.unfocus();
                                  WidgetsBinding.instance?.addPostFrameCallback((_) => _focusNode.requestFocus());
                                }
                              },
                              child: ListTile(
                                title: Text('LiqPay'),
                                subtitle: Text('Сума до сплати'),
                                leading: Center(
                                  widthFactor: 1,
                                  child: Image.network('https://upload.wikimedia.org/wikipedia/commons/thumb/e/ea/LIQPAY.svg/150px-LIQPAY.svg.png', width: 50),
                                ),
                                trailing: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    Text(_amount, style: TextStyle(fontSize: 20)),
                                    Text(' грн', style: TextStyle(fontSize: 14)),
                                  ],
                                ),
                                isThreeLine: true,
                              ),
                              style: ElevatedButton.styleFrom(
                                primary: Colors.white,
                                onPrimary: Colors.red[200],
                                padding: EdgeInsets.zero,
                              ),
                            ),
                            SizedBox(height: 8),
                            ElevatedButton(
                              onPressed: () {
                                if (_amount != '0') {
                                  launch('https://easypay.ua/ua/moneytransfer');
                                } else {
                                  _focusNode.unfocus();
                                  WidgetsBinding.instance?.addPostFrameCallback((_) => _focusNode.requestFocus());
                                }
                              },
                              child: ListTile(
                                title: Text('EasyPay'),
                                subtitle: Text('Сума до сплати'),
                                leading: Center(
                                  widthFactor: 1,
                                  child: Image.network('https://static.openfintech.io/payment_methods/easypay/icon.png?w=278&c=v0.59.26', width: 50),
                                ),
                                trailing: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    Text(_amount, style: TextStyle(fontSize: 20)),
                                    Text(' грн', style: TextStyle(fontSize: 14)),
                                  ],
                                ),
                                isThreeLine: true,
                              ),
                              style: ElevatedButton.styleFrom(
                                primary: Colors.white,
                                onPrimary: Colors.red[200],
                                padding: EdgeInsets.zero,
                              ),
                            ),
                            SizedBox(height: 8),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              );
            } else {
              return LinearProgressIndicator();
            }
          }
        ),
      ),
    );
  }
}