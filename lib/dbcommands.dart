import 'package:sqlite3/sqlite3.dart';

void createTable(Database db) {
  db.execute('''
    CREATE TABLE IF NOT EXISTS checkin (
      id INT NOT NULL PRIMARY KEY,
      name TEXT NOT NULL,
      affiliation TEXT NOT NULL,
      role TEXT NOT NULL,
      qrurl TEXT NOT NULL,
      userid TEXT
    );
  ''');
}

bool isCheckedIn(Database db, int id) {
  final ResultSet resultSet =
      db.select("SELECT * FROM checkin WHERE id = ?", [id]);
  return resultSet.isNotEmpty;
}

void markAsCheckedIn(Database db, int id, String name, String affiliation,
    String role, String qrUrl, String userid) {
  db.execute('''
    INSERT INTO checkin  (
      id,
      name,
      affiliation,
      role,
      qrurl,
      userid
    ) VALUES (?, ?, ?, ?, ?, ?);
  ''', [id, name, affiliation, role, qrUrl, userid]);
}
