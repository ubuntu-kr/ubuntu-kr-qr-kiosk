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
}

Future<bool> checkIsKioskConfigured() async {
  final SharedPreferences prefs = await SharedPreferences.getInstance();
  var apiToken = prefs.getString('apiToken') != null;
  var host = prefs.getString('host') != null;
  return apiToken && host;
}

class KioskClient {
  static final KioskClient _instance = KioskClient._internal();
  late sqlite3lib.Database db;
  late String host;
  late String apiToken;

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
  }

  (bool, dynamic) checkInLocally(dynamic payload) {
    try {
      markAsCheckedIn(
          db,
          payload['id'],
          payload['nametagName'],
          payload['nametagAffiliation'],
          payload['nametagRole'],
          payload['nametagUrl'],
          payload['sub']);
      return (true, payload);
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
    var jsonBody = jsonDecode(utf8.decode(response.bodyBytes));
    // String resultMsg = jsonBody["result"];
    return (status == 200, jsonBody);
  }

  Future<(bool, List)> searchByEmailKeyword(String keyword) async {
    var url = Uri.parse("$host/participants/?format=json&keyword=$keyword");
    var response =
        await http.get(url, headers: {'Authorization': 'Token $apiToken'});
    var status = response.statusCode;
    var searchResults = jsonDecode(utf8.decode(response.bodyBytes)) as List;
    return (status == 200, searchResults);
  }

  Future<(bool, dynamic)> getParticipantById(int id) async {
    var url = Uri.parse("$host/participant/?format=json&id=$id");
    var response =
        await http.get(url, headers: {'Authorization': 'Token $apiToken'});
    var status = response.statusCode;
    var result = jsonDecode(utf8.decode(response.bodyBytes)) as List;
    return (status == 200, result);
  }

  Future<(bool, String)> checkInBySearch(
      int participantId, String passcode) async {
    var url = Uri.parse(
        "$host/checkin_passcode/?format=json&participantId=$participantId");
    var response = await http.post(
      url,
      headers: {'Authorization': 'Token $apiToken'},
      body: {"passcode": passcode},
    );
    var status = response.statusCode;
    try {
      var jsonBody = jsonDecode(utf8.decode(response.bodyBytes));
      String resultMsg = jsonBody["result"];
      return (status == 200, resultMsg);
    } on Exception {
      return (false, "체크인 중 서버 오류 발생. Error on serer while checking in.");
    }
  }

  Future<(bool, String)> callStaff() async {
    var url = Uri.parse("$host/call_staff");
    var response =
        await http.get(url, headers: {'Authorization': 'Token $apiToken'});
    var status = response.statusCode;
    try {
      var jsonBody = jsonDecode(utf8.decode(response.bodyBytes));
      String resultMsg = jsonBody["result"];
      return (status == 200, resultMsg);
    } on Exception {
      return (false, "관계자를 호출 했습니다. Called event staff.");
    }
  }

  void closeDb() {
    db.dispose();
  }
}
