import 'package:shared_preferences/shared_preferences.dart';

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