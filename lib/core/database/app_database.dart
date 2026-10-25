import 'dart:convert';
import 'package:path/path.dart' as p;
import 'package:sqflite/sqflite.dart';
import '../../features/cycle_tracking/domain/models/cycle_record.dart';
import '../../features/notes/domain/models/care_preference.dart';
import '../../features/notes/domain/models/personal_note.dart';
import '../../features/reminders/domain/models/reminder_item.dart';
import '../../features/symptoms/domain/models/daily_observation.dart';

class AppDatabase {
  static final AppDatabase instance = AppDatabase._internal();
  static Database? _database;

  AppDatabase._internal();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase({String dbName = 'hercare.db'}) async {
    final dbPath = await getDatabasesPath();
    final path = p.join(dbPath, dbName);

    return await openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    // 1. Cycle Records
    await db.execute('''
      CREATE TABLE cycle_records (
        id TEXT PRIMARY KEY,
        start_date TEXT NOT NULL,
        end_date TEXT,
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL
      )
    ''');

    // 2. Daily Observations
    await db.execute('''
      CREATE TABLE daily_observations (
        id TEXT PRIMARY KEY,
        date TEXT NOT NULL,
        symptoms_json TEXT,
        emotions_json TEXT,
        note TEXT,
        source TEXT NOT NULL,
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL
      )
    ''');

    // 3. Personal Notes
    await db.execute('''
      CREATE TABLE personal_notes (
        id TEXT PRIMARY KEY,
        title TEXT NOT NULL,
        content TEXT NOT NULL,
        category TEXT NOT NULL,
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL
      )
    ''');

    // 4. Care Preferences
    await db.execute('''
      CREATE TABLE care_preferences (
        id TEXT PRIMARY KEY,
        title TEXT NOT NULL,
        category TEXT NOT NULL,
        description TEXT,
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL
      )
    ''');

    // 5. Reminders
    await db.execute('''
      CREATE TABLE reminders (
        id TEXT PRIMARY KEY,
        notification_id INTEGER NOT NULL,
        title TEXT NOT NULL,
        discreet_message TEXT NOT NULL,
        type TEXT NOT NULL,
        hour INTEGER NOT NULL,
        minute INTEGER NOT NULL,
        is_enabled INTEGER NOT NULL,
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL
      )
    ''');
  }

  // --- Cycle Records DAO ---
  Future<List<CycleRecord>> getAllCycleRecords() async {
    final db = await database;
    final maps = await db.query('cycle_records', orderBy: 'start_date ASC');
    return maps.map((m) => CycleRecord.fromMap(m)).toList();
  }

  Future<void> saveCycleRecord(CycleRecord record) async {
    final db = await database;
    await db.insert(
      'cycle_records',
      record.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<void> deleteCycleRecord(String id) async {
    final db = await database;
    await db.delete('cycle_records', where: 'id = ?', whereArgs: [id]);
  }

  // --- Daily Observations DAO ---
  Future<List<DailyObservation>> getAllObservations() async {
    final db = await database;
    final maps = await db.query('daily_observations', orderBy: 'date DESC');
    return maps.map((m) => DailyObservation.fromMap(m)).toList();
  }

  Future<DailyObservation?> getObservationForDate(DateTime date) async {
    final db = await database;
    final iso = date.toIso8601String().substring(0, 10);
    final maps = await db.query(
      'daily_observations',
      where: 'date = ?',
      whereArgs: [iso],
      limit: 1,
    );
    if (maps.isEmpty) return null;
    return DailyObservation.fromMap(maps.first);
  }

  Future<void> saveObservation(DailyObservation obs) async {
    final db = await database;
    await db.insert(
      'daily_observations',
      obs.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<void> deleteObservation(String id) async {
    final db = await database;
    await db.delete('daily_observations', where: 'id = ?', whereArgs: [id]);
  }

  // --- Personal Notes DAO ---
  Future<List<PersonalNote>> getAllNotes() async {
    final db = await database;
    final maps = await db.query('personal_notes', orderBy: 'created_at DESC');
    return maps.map((m) => PersonalNote.fromMap(m)).toList();
  }

  Future<void> saveNote(PersonalNote note) async {
    final db = await database;
    await db.insert(
      'personal_notes',
      note.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<void> deleteNote(String id) async {
    final db = await database;
    await db.delete('personal_notes', where: 'id = ?', whereArgs: [id]);
  }

  // --- Care Preferences DAO ---
  Future<List<CarePreference>> getAllPreferences() async {
    final db = await database;
    final maps = await db.query('care_preferences', orderBy: 'created_at DESC');
    return maps.map((m) => CarePreference.fromMap(m)).toList();
  }

  Future<void> savePreference(CarePreference pref) async {
    final db = await database;
    await db.insert(
      'care_preferences',
      pref.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<void> deletePreference(String id) async {
    final db = await database;
    await db.delete('care_preferences', where: 'id = ?', whereArgs: [id]);
  }

  // --- Reminders DAO ---
  Future<List<ReminderItem>> getAllReminders() async {
    final db = await database;
    final maps = await db.query('reminders', orderBy: 'hour ASC, minute ASC');
    return maps.map((m) => ReminderItem.fromMap(m)).toList();
  }

  Future<void> saveReminder(ReminderItem reminder) async {
    final db = await database;
    await db.insert(
      'reminders',
      reminder.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<void> deleteReminder(String id) async {
    final db = await database;
    await db.delete('reminders', where: 'id = ?', whereArgs: [id]);
  }

  // --- Data Management: Clear All & Export ---
  Future<void> clearAllData() async {
    final db = await database;
    await db.transaction((txn) async {
      await txn.delete('cycle_records');
      await txn.delete('daily_observations');
      await txn.delete('personal_notes');
      await txn.delete('care_preferences');
      await txn.delete('reminders');
    });
  }

  Future<String> exportDataJson() async {
    final cycles = await getAllCycleRecords();
    final observations = await getAllObservations();
    final notes = await getAllNotes();
    final preferences = await getAllPreferences();
    final reminders = await getAllReminders();

    final data = {
      'exported_at': DateTime.now().toIso8601String(),
      'version': '1.0.0',
      'cycle_records': cycles.map((c) => c.toMap()).toList(),
      'daily_observations': observations.map((o) => o.toMap()).toList(),
      'personal_notes': notes.map((n) => n.toMap()).toList(),
      'care_preferences': preferences.map((p) => p.toMap()).toList(),
      'reminders': reminders.map((r) => r.toMap()).toList(),
    };

    return const JsonEncoder.withIndent('  ').convert(data);
  }

  Future<bool> importDataJson(String jsonString) async {
    try {
      final decoded = jsonDecode(jsonString) as Map<String, dynamic>;
      final db = await database;

      await db.transaction((txn) async {
        if (decoded.containsKey('cycle_records')) {
          final list = decoded['cycle_records'] as List;
          for (final item in list) {
            await txn.insert(
              'cycle_records',
              item as Map<String, dynamic>,
              conflictAlgorithm: ConflictAlgorithm.replace,
            );
          }
        }

        if (decoded.containsKey('daily_observations')) {
          final list = decoded['daily_observations'] as List;
          for (final item in list) {
            await txn.insert(
              'daily_observations',
              item as Map<String, dynamic>,
              conflictAlgorithm: ConflictAlgorithm.replace,
            );
          }
        }

        if (decoded.containsKey('personal_notes')) {
          final list = decoded['personal_notes'] as List;
          for (final item in list) {
            await txn.insert(
              'personal_notes',
              item as Map<String, dynamic>,
              conflictAlgorithm: ConflictAlgorithm.replace,
            );
          }
        }

        if (decoded.containsKey('care_preferences')) {
          final list = decoded['care_preferences'] as List;
          for (final item in list) {
            await txn.insert(
              'care_preferences',
              item as Map<String, dynamic>,
              conflictAlgorithm: ConflictAlgorithm.replace,
            );
          }
        }

        if (decoded.containsKey('reminders')) {
          final list = decoded['reminders'] as List;
          for (final item in list) {
            await txn.insert(
              'reminders',
              item as Map<String, dynamic>,
              conflictAlgorithm: ConflictAlgorithm.replace,
            );
          }
        }
      });
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<void> close() async {
    if (_database != null) {
      await _database!.close();
      _database = null;
    }
  }
}

