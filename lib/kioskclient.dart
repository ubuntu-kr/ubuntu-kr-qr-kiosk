import 'dart:convert';
import 'package:sqlite3/sqlite3.dart' as sqlite3lib;
import 'dbcommands.dart';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:dart_jsonwebtoken/dart_jsonwebtoken.dart';

Future<void> configureKiosk(String host, String apiToken) async {
  final SharedPreferences prefs = await SharedPreferences.getInstance();
  prefs.setString('apiToken', apiToken);
  prefs.setString('host', host);

  var url = Uri.https(host, "kioskconfig");
  var response = await http.get(url);
  var jsonBody = jsonDecode(response.body);

  prefs.setString('jwtKey', jsonBody['public_key']);
  prefs.setString('jwtKeyAlgo', jsonBody['key_algo']);
}

Future<bool> checkIsKioskConfigured() async {
  final SharedPreferences prefs = await SharedPreferences.getInstance();
  var hostCheck = prefs.getString('host')?.isEmpty ?? false;
  var apiTokenCheck = prefs.getString('apiToken')?.isEmpty ?? false;
  var jwtKeyCheck = prefs.getString('jwtKey')?.isEmpty ?? false;
  var jwtKeyAlgoCheck = prefs.getString('jwtKeyAlgo')?.isEmpty ?? false;
  return hostCheck && apiTokenCheck && jwtKeyCheck && jwtKeyAlgoCheck;
}

class KioskClient {
  late sqlite3lib.Database db;
  late String host;
  late String apiToken;
  late String jwtKey;
  late String jwtKeyAlgo;

  KioskClient(String dbpath, String host, String apiToken, String jwtKey,
      String jwtKeyAlgo) {
    this.db = sqlite3lib.sqlite3.open(dbpath);
    this.host = host;
    this.apiToken = apiToken;
    this.jwtKey = jwtKey;
    this.jwtKeyAlgo = jwtKeyAlgo;
    createTable(db);
  }

  dynamic verifyQrToken(String token) {
    final jwt = JWT.verify(token, ECPublicKey(jwtKey));
    return jwt.payload;
  }

  (bool, dynamic) checkInLocally(String token) {
    try {
      var payload = verifyQrToken(token);
      var tid = payload["tid"];
      if (isCheckedIn(db, tid)) {
        return (
          false,
          {
            "nametagName": "[X]",
            "nametagAffiliation": "",
            "nametagRole": "이미 사용된 QR 코드 입니다.",
            "nametagUrl": ""
          }
        );
      }
      markAsCheckedIn(
          db,
          payload['tid'],
          payload['nametagName'],
          payload['nametagAffiliation'],
          payload['nametagRole'],
          payload['nametagUrl'],
          payload['sub']);
      return (true, payload);
    } on JWTExpiredException catch (e) {
      return (
        false,
        {
          "nametagName": "[X]",
          "nametagAffiliation": "",
          "nametagRole": "만료된 QR 코드 입니다.",
          "nametagUrl": ""
        }
      );
    } on JWTException catch (e) {
      return (
        false,
        {
          "nametagName": "[X]",
          "nametagAffiliation": "",
          "nametagRole": "QR 코드 처리 오류.",
          "nametagUrl": ""
        }
      );
    }
  }

  Future<(bool, String)> checkInOnServer(String jwt) async {
    var url = Uri.https(host, "checkin");
    var response = await http.post(url,
        headers: {'Authorization': 'Token $apiToken', "ParticipantToken": jwt});
    var status = response.statusCode;
    var jsonBody = jsonDecode(response.body);
    String resultMsg = jsonBody["result"];
    return (status == 200, resultMsg);
  }

  void closeDb() {
    this.db.dispose();
  }
}
