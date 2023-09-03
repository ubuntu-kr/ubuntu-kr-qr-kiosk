import 'dart:convert';
import 'dart:io';
import 'package:sqlite3/sqlite3.dart' as sqlite3lib;
import 'dbcommands.dart';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:dart_jsonwebtoken/dart_jsonwebtoken.dart';

Future<void> configureKiosk(String host, String apiToken) async {
  final SharedPreferences prefs = await SharedPreferences.getInstance();
  prefs.setString('apiToken', apiToken);
  prefs.setString('host', host);

  var url = Uri.parse("$host/kioskconfig");
  var response = await http.get(url);
  var jsonBody = jsonDecode(response.body);

  prefs.setString('jwtKey', jsonBody['public_key']);
  prefs.setString('jwtKeyAlgo', jsonBody['key_algo']);
}

Future<bool> checkIsKioskConfigured() async {
  final SharedPreferences prefs = await SharedPreferences.getInstance();
  var jwtKeyCheck = prefs.getString('jwtKey') != null;
  var jwtKeyAlgoCheck = prefs.getString('jwtKeyAlgo') != null;
  print("jwtKeyCheck: $jwtKeyCheck, jwtKeyAlgoCheck: $jwtKeyAlgoCheck");
  return jwtKeyCheck && jwtKeyAlgoCheck;
}

class KioskClient {
  static final KioskClient _instance = KioskClient._internal();
  late sqlite3lib.Database db;
  late String host;
  late String apiToken;
  late String jwtKey;
  late String jwtKeyAlgo;

  // using a factory is important
  // because it promises to return _an_ object of this type
  // but it doesn't promise to make a new one.
  factory KioskClient() {
    return _instance;
  }

  // This named constructor is the "real" constructor
  // It'll be called exactly once, by the static property assignment above
  // it's also private, so it can only be called in this class
  KioskClient._internal() {
    // initialization logic
    Map<String, String> envVars = Platform.environment;
    db = sqlite3lib.sqlite3.open('${envVars["HOME"]}/ukckiosk_checkin_db.db');
    createTable(db);
    host = envVars['KIOSK_HOST'] ?? "http://localhost:8000";
    apiToken = envVars['KIOSK_API_TOKEN'] ?? "";
    SharedPreferences.getInstance().then((prefs) {
      jwtKey = prefs.getString('jwtKey') ?? "";
      jwtKeyAlgo = prefs.getString('jwtKeyAlgo') ?? "";
    });
  }

  dynamic verifyQrToken(String token) {
    var pubkey = ECPublicKey(jwtKey);
    final jwt =
        JWT.verify(token, pubkey, checkExpiresIn: false, checkNotBefore: false);
    return jwt.payload;
  }

  (bool, dynamic) checkInLocally(String token) {
    try {
      var payload = verifyQrToken(token);
      var tid = payload["tid"];
      if (isCheckedIn(db, tid)) {
        return (false, "이미 사용된 QR 코드 입니다. Already redeemed QR code.");
      }
      markAsCheckedIn(
          db,
          payload['tid'],
          "payload['nametagName']",
          "payload['nametagAffiliation']",
          "payload['nametagRole']",
          "payload['nametagUrl']",
          payload['sub']);
      return (true, payload);
    } on JWTExpiredException catch (e, s) {
      print(e);
      print(s);
      return (false, "만료된 QR 코드 입니다. You've scanned expired QR code.");
    } on JWTException catch (e, s) {
      print(e);
      print(s);
      return (false, "QR 코드 처리 오류. Error processing QR code.");
    } catch (e, s) {
      print(e);
      print(s);
      return (false, "QR 코드 처리 오류. Error processing QR code.");
    }
  }

  Future<(bool, dynamic)> checkInOnServer(String jwt) async {
    var url = Uri.parse("$host/checkin/");
    var response = await http.post(url,
        headers: {'Authorization': 'Token $apiToken', "ParticipantToken": jwt});
    var status = response.statusCode;
    var jsonBody = jsonDecode(response.body);
    // String resultMsg = jsonBody["result"];
    return (status == 200, jsonBody);
  }

  Future<(bool, List)> searchByEmailKeyword(String keyword) async {
    var url = Uri.parse("$host/participants/?format=json&keyword=$keyword");
    var response =
        await http.get(url, headers: {'Authorization': 'Token $apiToken'});
    var status = response.statusCode;
    var searchResults = jsonDecode(response.body) as List;
    return (status == 200, searchResults);
  }

  Future<(bool, String)> checkInBySearch(
      int participantId, String passcode) async {
    var url = Uri.parse("$host/checkin_passcode/?participantId=$participantId");
    var response = await http.post(
      url,
      body: {"passcode": passcode},
    );
    var status = response.statusCode;
    var jsonBody = jsonDecode(response.body);
    String resultMsg = jsonBody["result"];
    return (status == 200, resultMsg);
  }

  void closeDb() {
    db.dispose();
  }
}
