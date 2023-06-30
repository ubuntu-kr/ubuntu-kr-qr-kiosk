import 'package:sqlite3/sqlite3.dart';

void createTable(Database db) {
  db.execute(
      '''
    CREATE TABLE IF NOT EXISTS checkin (
      tid TEXT NOT NULL PRIMARY KEY,
      name TEXT NOT NULL,
      affiliation TEXT NOT NULL,
      role TEXT NOT NULL,
      qrurl TEXT NOT NULL,
      userid TEXT
    );
  ''');
}

bool isCheckedIn(Database db, String tid) {
  final ResultSet resultSet =
      db.select("SELECT * FROM checkin WHERE tid = ?", [tid]);
  return resultSet.isNotEmpty;
}

void markAsCheckedIn(Database db, String tid, String name, String affiliation,
    String role, String qrUrl, String userid) {
  db.execute(
      '''
    INSERT INTO checkin  (
      tid,
      name,
      affiliation,
      role,
      qrurl,
      userid
    ) VALUES (?, ?, ?, ?, ?, ?);
  ''',
      [tid, name, affiliation, role, qrUrl, userid]);
}
