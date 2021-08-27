import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'dart:io';
import 'dart:async';

import '../globals.dart';

class Login extends StatefulWidget {
  @override
  _Login createState() => _Login();
}

class _Login extends State<Login> {
  final _formKey = GlobalKey<FormState>();
  var _login, _password, _url, _port;
  var _buttonDisabled = false;
  var _showPassword = false;

  authorization() async {
    setState(() {
      _buttonDisabled = true;
    });

    try {
      // Check internet connection
      await http.get(Uri.parse('https://cloudflare.com')).timeout(Duration(seconds: 5));

      try {
        var url = Uri.parse('https://$_url:$_port/api.cgi/users/login');
        var response = await http.post(
          url,
          body: jsonEncode({'login': _login, 'password': _password}),
          headers: {'Content-Type' : 'application/json'}
        ).timeout(Duration(seconds: 5));

        print(_login);
        print(_password);
        print(response.body);

        if (jsonDecode(response.body)['uid'] != 0) {
          final prefs = await SharedPreferences.getInstance();
          prefs.setString('uid', jsonDecode(response.body)['uid'].toString());
          prefs.setString('sid', jsonDecode(response.body)['sid'].toString());

          prefs.setString('login', _login);
          prefs.setString('password', _password);
          prefs.setString('url', _url);
          prefs.setString('port', _port);

          Navigator.pushNamedAndRemoveUntil(context, '/', (route) => false);
        } else {
          showDialog(
            context: context,
            builder: (_) => AlertDialog(
              title: Text('Помилка'),
              content: Text('Невірний логін або пароль'),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text('ОК'),
                ),
              ],
            ),
          );
        }
      } on SocketException catch (e) {
        print(_url);
        print(e);

        showDialog(
          context: context,
          builder: (_) => AlertDialog(
            title: Text('Помилка'),
            content: Text('Невірний URL'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text('ОК'),
              ),
            ],
          ),
        );
      } catch (e) {
        print(_port);
        print(e);

        showDialog(
          context: context,
          builder: (_) => AlertDialog(
            title: Text('Помилка'),
            content: Text('Невірний порт'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text('ОК'),
              ),
            ],
          ),
        );
      }
    } catch (e) {
      print(e);

      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: Text('Помилка'),
          content: Text('Перевірте підключення до Інтернету'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('ОК'),
            ),
          ],
        ),
      );
    }

    // TODO re-auth
    // Timer.periodic(Duration(seconds: 60), (Timer timer) async {
    //   await getGlobals();
    //
    //   if (sid == null) {
    //     timer.cancel();
    //   }
    //
    //   print("PERIOD");
    //   print(timer.tick);
    // });

    setState(() {
      _buttonDisabled = false;
    });

    HapticFeedback.mediumImpact();
  }

  Future getData() async {
    await getGlobals();

    setState(() {
      _login = login;
      _password = password;
      _url = url;
      _port = port;

      if (_login != null && _password != null && _url != null && _port != null) {
        authorization();
      }
    });
  }

  @override
  void initState() {
    getData();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: SingleChildScrollView(
          physics: BouncingScrollPhysics(),
          child: Container(
            padding: EdgeInsets.all(16),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset('assets/logo.png', width: 270, fit: BoxFit.fill),
                SizedBox(height: 8),

                Text('Вхід в ABillS', style: TextStyle(fontSize: 36)),
                Text('Для продовження введіть Ваші дані', style: TextStyle(color: Colors.grey[700], fontSize: 16)),
                SizedBox(height: 16),

                Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      TextFormField(
                        cursorHeight: 22,
                        initialValue: _login,
                        key: Key('login_$_login'),
                        decoration: InputDecoration(
                          labelText: 'Логін',
                          border: OutlineInputBorder(),
                        ),
                        validator: (value) {
                          if (value!.isEmpty) {
                            return 'Введіть логін';
                          }
                        },
                        onSaved: (value) => _login = value,
                      ),
                      SizedBox(height: 8),

                      TextFormField(
                        cursorHeight: 22,
                        initialValue: _password,
                        key: Key('password_$_password'),
                        obscureText: !_showPassword,
                        decoration: InputDecoration(
                          labelText: 'Пароль',
                          border: OutlineInputBorder(),
                          suffixIcon: IconButton(
                            onPressed: () {
                              setState(() {
                                _showPassword = !_showPassword;
                              });
                            },
                            icon: !_showPassword ? Icon(Icons.visibility_off) : Icon(Icons.visibility),
                            tooltip: !_showPassword ? 'Показати пароль' : 'Приховати пароль',
                          ),
                        ),
                        validator: (value) {
                          if (value!.isEmpty) {
                            return 'Введіть пароль';
                          }
                        },
                        onSaved: (value) => _password = value,
                      ),
                      SizedBox(height: 8),

                      Row(
                        children: [
                          Flexible(
                            flex: 3,
                            child: TextFormField(
                              cursorHeight: 22,
                              initialValue: _url,
                              key: Key('url_$_url'),
                              keyboardType: TextInputType.url,
                              decoration: InputDecoration(
                                labelText: 'URL',
                                border: OutlineInputBorder(),
                                hintText: 'Адреса сервера'
                              ),
                              validator: (value) {
                                if (value!.isEmpty) {
                                  return 'Введіть URL адресу';
                                }
                              },
                              onSaved: (value) => _url = value,
                            ),
                          ),

                          SizedBox(width: 8),

                          Flexible(
                            flex: 1,
                            child: TextFormField(
                              cursorHeight: 22,
                              initialValue: _port,
                              key: Key('port_$_port'),
                              keyboardType: TextInputType.number,
                              inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[0-9]'))],
                              maxLength: 5,

                              decoration: InputDecoration(
                                labelText: 'Порт',
                                border: OutlineInputBorder(),
                                counterText: '',
                              ),
                              validator: (value) {
                                if (value!.isEmpty) {
                                  return 'Введіть порт';
                                }
                              },
                              onSaved: (value) => _port = value,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 8),

                      SizedBox(
                        width: double.infinity,
                        height: 59,
                        child: ElevatedButton(
                          onPressed: _buttonDisabled ? null : () {
                            if (_formKey.currentState!.validate()) {
                              _formKey.currentState!.save();
                              authorization();
                            }
                          },
                          child: !_buttonDisabled ? Text('УВІЙТИ', style: TextStyle(fontSize: 16)) : CircularProgressIndicator(),
                          style: ElevatedButton.styleFrom(
                            elevation: 0,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}