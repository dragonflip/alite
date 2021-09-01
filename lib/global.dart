import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

var uid, sid, url, port, login, password, tpId;
var apiUrl;

Future getGlobals() async {
  final prefs = await SharedPreferences.getInstance();

  login = prefs.getString('login');
  password = prefs.getString('password');
  url = prefs.getString('url');
  port = prefs.getString('port');

  uid = prefs.getString('uid');
  sid = prefs.getString('sid');
  tpId = prefs.getString('tpId');

  apiUrl = 'https://$url:$port/api.cgi';
}

Future checkSession() async {
  var userResponse = await http.get(Uri.parse('$apiUrl/user/$uid'), headers: {'USERSID': sid});
  var user = jsonDecode(utf8.decode(userResponse.bodyBytes));

  if (user['error'] == 'Access denied') {
    print('\n\nSESSION EXPIRED');

    var sessionResponse = await http.post(Uri.parse('$apiUrl/users/login'), body: jsonEncode({'login': login, 'password': password}), headers: {'Content-Type' : 'application/json'});
    var session = jsonDecode(utf8.decode(sessionResponse.bodyBytes));

    if (session['uid'] != 0) {
      print('Old sid: $sid, new sid: ${session['sid']}\n\n\n');

      sid = session['sid'];

      final prefs = await SharedPreferences.getInstance();
      prefs.setString('sid', sid);
    }
  }
}