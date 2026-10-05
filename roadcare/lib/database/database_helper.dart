import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

import 'database_constants.dart';

class DatabaseHelper {
  DatabaseHelper._privateConstructor();

  static final DatabaseHelper instance = DatabaseHelper._privateConstructor();

  static Database? _database;

  // =========================================================
  // DATABASE GETTER
  // =========================================================

  Future<Database> get database async {
    if (_database != null && _database!.isOpen) {
      return _database!;
    }

    _database = await _initDatabase();

    return _database!;
  }

  // =========================================================
  // INITIALIZE DATABASE
  // =========================================================

  Future<Database> _initDatabase() async {
    final String databasesPath = await getDatabasesPath();

    final String path = join(databasesPath, DatabaseConstants.databaseName);

    return await openDatabase(
      path,
      version: DatabaseConstants.databaseVersion,

      onConfigure: (Database db) async {
        await db.execute('PRAGMA foreign_keys = ON');
      },

      onCreate: _onCreate,

      onUpgrade: _onUpgrade,
    );
  }

  // =========================================================
  // CREATE DATABASE
  // =========================================================

  Future<void> _onCreate(Database db, int version) async {
    // =======================================================
    // USERS
    // =======================================================

    await db.execute('''
      CREATE TABLE ${DatabaseConstants.usersTable} (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        username TEXT NOT NULL,
        email TEXT NOT NULL UNIQUE,
        password TEXT NOT NULL,
        created_at TEXT NOT NULL
      )
    ''');

    // =======================================================
    // REPORTS
    // =======================================================

    await db.execute('''
      CREATE TABLE ${DatabaseConstants.reportsTable} (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        user_id INTEGER NOT NULL,
        title TEXT NOT NULL,
        description TEXT NOT NULL,
        damage_type TEXT NOT NULL,
        severity TEXT NOT NULL,
        latitude REAL,
        longitude REAL,
        address TEXT,
        image_path TEXT,
        status TEXT NOT NULL DEFAULT 'Pending',
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL,

        -- 0 = Active
        -- 1 = Archived
        is_archived INTEGER NOT NULL DEFAULT 0,

        FOREIGN KEY (user_id)
          REFERENCES ${DatabaseConstants.usersTable}(id)
          ON DELETE CASCADE
      )
    ''');

    // =======================================================
    // REPORT IMAGES
    // =======================================================

    await db.execute('''
      CREATE TABLE ${DatabaseConstants.reportImagesTable} (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        report_id INTEGER NOT NULL,
        image_path TEXT NOT NULL,
        image_type TEXT NOT NULL,
        created_at TEXT NOT NULL,

        FOREIGN KEY (report_id)
          REFERENCES ${DatabaseConstants.reportsTable}(id)
          ON DELETE CASCADE
      )
    ''');

    // =======================================================
    // STATUS HISTORY
    // =======================================================

    await db.execute('''
      CREATE TABLE ${DatabaseConstants.statusHistoryTable} (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        report_id INTEGER NOT NULL,
        old_status TEXT,
        new_status TEXT NOT NULL,
        remarks TEXT,
        changed_at TEXT NOT NULL,

        FOREIGN KEY (report_id)
          REFERENCES ${DatabaseConstants.reportsTable}(id)
          ON DELETE CASCADE
      )
    ''');

    // =======================================================
    // NOTIFICATIONS
    // =======================================================

    await db.execute('''
      CREATE TABLE ${DatabaseConstants.notificationsTable} (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        user_id INTEGER NOT NULL,
        title TEXT NOT NULL,
        message TEXT NOT NULL,
        type TEXT NOT NULL,
        created_at TEXT NOT NULL,
        is_read INTEGER NOT NULL DEFAULT 0,

        FOREIGN KEY (user_id)
          REFERENCES ${DatabaseConstants.usersTable}(id)
          ON DELETE CASCADE
      )
    ''');

    // =======================================================
    // FEEDBACK
    // =======================================================

    await db.execute('''
      CREATE TABLE ${DatabaseConstants.feedbackTable} (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        user_id INTEGER NOT NULL,
        report_id INTEGER,
        rating INTEGER,
        comment TEXT,
        created_at TEXT NOT NULL,

        FOREIGN KEY (user_id)
          REFERENCES ${DatabaseConstants.usersTable}(id)
          ON DELETE CASCADE,

        FOREIGN KEY (report_id)
          REFERENCES ${DatabaseConstants.reportsTable}(id)
          ON DELETE SET NULL
      )
    ''');

    // =======================================================
    // INDEXES
    // =======================================================

    await db.execute('''
      CREATE INDEX idx_reports_user_id
      ON ${DatabaseConstants.reportsTable}(user_id)
    ''');

    await db.execute('''
      CREATE INDEX idx_reports_is_archived
      ON ${DatabaseConstants.reportsTable}(is_archived)
    ''');

    await db.execute('''
      CREATE INDEX idx_status_history_report_id
      ON ${DatabaseConstants.statusHistoryTable}(report_id)
    ''');

    await db.execute('''
      CREATE INDEX idx_notifications_user_id
      ON ${DatabaseConstants.notificationsTable}(user_id)
    ''');

    await db.execute('''
      CREATE INDEX idx_notifications_is_read
      ON ${DatabaseConstants.notificationsTable}(is_read)
    ''');

    await db.execute('''
      CREATE INDEX idx_feedback_report_id
      ON ${DatabaseConstants.feedbackTable}(report_id)
    ''');

    await db.execute('''
      CREATE INDEX idx_feedback_user_id
      ON ${DatabaseConstants.feedbackTable}(user_id)
    ''');
  }

  // =========================================================
  // DATABASE UPGRADE
  // =========================================================

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    // =======================================================
    // VERSION 1 -> VERSION 2
    // =======================================================

    if (oldVersion < 2) {
      // -----------------------------------------------------
      // STATUS HISTORY
      // -----------------------------------------------------

      await db.execute('''
        CREATE TABLE IF NOT EXISTS ${DatabaseConstants.statusHistoryTable} (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          report_id INTEGER NOT NULL,
          old_status TEXT,
          new_status TEXT NOT NULL,
          remarks TEXT,
          changed_at TEXT NOT NULL,

          FOREIGN KEY (report_id)
            REFERENCES ${DatabaseConstants.reportsTable}(id)
            ON DELETE CASCADE
        )
      ''');

      // -----------------------------------------------------
      // NOTIFICATIONS
      // -----------------------------------------------------

      await db.execute('''
        CREATE TABLE IF NOT EXISTS ${DatabaseConstants.notificationsTable} (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          user_id INTEGER NOT NULL,
          title TEXT NOT NULL,
          message TEXT NOT NULL,
          type TEXT NOT NULL,
          created_at TEXT NOT NULL,
          is_read INTEGER NOT NULL DEFAULT 0,

          FOREIGN KEY (user_id)
            REFERENCES ${DatabaseConstants.usersTable}(id)
            ON DELETE CASCADE
        )
      ''');

      // -----------------------------------------------------
      // FEEDBACK
      // -----------------------------------------------------

      await db.execute('''
        CREATE TABLE IF NOT EXISTS ${DatabaseConstants.feedbackTable} (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          user_id INTEGER NOT NULL,
          report_id INTEGER,
          rating INTEGER,
          comment TEXT,
          created_at TEXT NOT NULL,

          FOREIGN KEY (user_id)
            REFERENCES ${DatabaseConstants.usersTable}(id)
            ON DELETE CASCADE,

          FOREIGN KEY (report_id)
            REFERENCES ${DatabaseConstants.reportsTable}(id)
            ON DELETE SET NULL
        )
      ''');

      // -----------------------------------------------------
      // INDEXES
      // -----------------------------------------------------

      await db.execute('''
        CREATE INDEX IF NOT EXISTS idx_status_history_report_id
        ON ${DatabaseConstants.statusHistoryTable}(report_id)
      ''');

      await db.execute('''
        CREATE INDEX IF NOT EXISTS idx_notifications_user_id
        ON ${DatabaseConstants.notificationsTable}(user_id)
      ''');

      await db.execute('''
        CREATE INDEX IF NOT EXISTS idx_notifications_is_read
        ON ${DatabaseConstants.notificationsTable}(is_read)
      ''');

      await db.execute('''
        CREATE INDEX IF NOT EXISTS idx_feedback_report_id
        ON ${DatabaseConstants.feedbackTable}(report_id)
      ''');

      await db.execute('''
        CREATE INDEX IF NOT EXISTS idx_feedback_user_id
        ON ${DatabaseConstants.feedbackTable}(user_id)
      ''');
    }

    // =======================================================
    // VERSION 2 -> VERSION 3
    // ARCHIVE REPORTS
    // =======================================================

    if (oldVersion < 3) {
      // -----------------------------------------------------
      // ADD ARCHIVE COLUMN
      // -----------------------------------------------------

      await db.execute('''
        ALTER TABLE ${DatabaseConstants.reportsTable}
        ADD COLUMN is_archived INTEGER NOT NULL DEFAULT 0
      ''');

      // -----------------------------------------------------
      // ARCHIVE INDEX
      // -----------------------------------------------------

      await db.execute('''
        CREATE INDEX IF NOT EXISTS idx_reports_is_archived
        ON ${DatabaseConstants.reportsTable}(is_archived)
      ''');
    }
  }

  // =========================================================
  // REGISTER USER
  // =========================================================

  Future<int> registerUser({
    required String username,
    required String email,
    required String password,
  }) async {
    final Database db = await database;

    final String cleanUsername = username.trim();
    final String cleanEmail = email.trim().toLowerCase();

    final List<Map<String, dynamic>> existingUsers = await db.query(
      DatabaseConstants.usersTable,
      columns: ['id'],
      where: 'email = ?',
      whereArgs: [cleanEmail],
      limit: 1,
    );

    if (existingUsers.isNotEmpty) {
      return -1;
    }

    return await db.insert(DatabaseConstants.usersTable, {
      'username': cleanUsername,
      'email': cleanEmail,
      'password': password,
      'created_at': DateTime.now().toIso8601String(),
    }, conflictAlgorithm: ConflictAlgorithm.abort);
  }

  // =========================================================
  // LOGIN USER
  // =========================================================

  Future<Map<String, dynamic>?> loginUser({
    required String email,
    required String password,
  }) async {
    final Database db = await database;

    final String cleanEmail = email.trim().toLowerCase();

    final List<Map<String, dynamic>> results = await db.query(
      DatabaseConstants.usersTable,
      where: 'email = ? AND password = ?',
      whereArgs: [cleanEmail, password],
      limit: 1,
    );

    if (results.isEmpty) {
      return null;
    }

    final Map<String, dynamic> user = Map<String, dynamic>.from(results.first);

    user['name'] = user['username'];

    return user;
  }

  // =========================================================
  // ADMIN LOGIN
  // =========================================================

  Future<Map<String, dynamic>?> loginAdmin({
    required String email,
    required String password,
  }) async {
    final String cleanEmail = email.trim().toLowerCase();

    const String adminEmail = 'admin@roadcare.com';
    const String adminPassword = 'Admin@123';

    if (cleanEmail != adminEmail || password != adminPassword) {
      return null;
    }

    return {
      'id': 0,
      'username': 'RoadCare Admin',
      'name': 'RoadCare Admin',
      'email': adminEmail,
      'is_admin': 1,
    };
  }

  // =========================================================
  // GET USER BY ID
  // =========================================================

  Future<Map<String, dynamic>?> getUserById(int userId) async {
    final Database db = await database;

    final List<Map<String, dynamic>> results = await db.query(
      DatabaseConstants.usersTable,
      where: 'id = ?',
      whereArgs: [userId],
      limit: 1,
    );

    if (results.isEmpty) {
      return null;
    }

    final Map<String, dynamic> user = Map<String, dynamic>.from(results.first);

    user['name'] = user['username'];

    return user;
  }

  // =========================================================
  // GET USER BY EMAIL
  // =========================================================

  Future<Map<String, dynamic>?> getUserByEmail(String email) async {
    final Database db = await database;

    final List<Map<String, dynamic>> results = await db.query(
      DatabaseConstants.usersTable,
      where: 'email = ?',
      whereArgs: [email.trim().toLowerCase()],
      limit: 1,
    );

    if (results.isEmpty) {
      return null;
    }

    final Map<String, dynamic> user = Map<String, dynamic>.from(results.first);

    user['name'] = user['username'];

    return user;
  }

  // =========================================================
  // GET ALL USERS
  // =========================================================

  Future<List<Map<String, dynamic>>> getAllUsers() async {
    final Database db = await database;

    return await db.query(
      DatabaseConstants.usersTable,
      orderBy: 'created_at DESC',
    );
  }

  // =========================================================
  // INSERT REPORT
  // =========================================================

  Future<int> insertReport(Map<String, dynamic> report) async {
    final Database db = await database;

    final Map<String, dynamic> reportData = Map<String, dynamic>.from(report);

    // New reports are always active.
    reportData.putIfAbsent('is_archived', () => 0);

    return await db.insert(
      DatabaseConstants.reportsTable,
      reportData,
      conflictAlgorithm: ConflictAlgorithm.abort,
    );
  }

  // =========================================================
  // GET USER ACTIVE REPORTS
  // =========================================================

  Future<List<Map<String, dynamic>>> getReportsByUser(int userId) async {
    final Database db = await database;

    return await db.query(
      DatabaseConstants.reportsTable,
      where: 'user_id = ? AND is_archived = 0',
      whereArgs: [userId],
      orderBy: 'created_at DESC',
    );
  }

  // =========================================================
  // GET USER ARCHIVED REPORTS
  // =========================================================

  Future<List<Map<String, dynamic>>> getArchivedReportsByUser(
    int userId,
  ) async {
    final Database db = await database;

    return await db.query(
      DatabaseConstants.reportsTable,
      where: 'user_id = ? AND is_archived = 1',
      whereArgs: [userId],
      orderBy: 'created_at DESC',
    );
  }

  // =========================================================
  // GET ALL ACTIVE REPORTS WITH USER DETAILS
  // =========================================================

  Future<List<Map<String, dynamic>>> getAllReports() async {
    final Database db = await database;

    final List<Map<String, dynamic>> results = await db.rawQuery('''
      SELECT
        r.*,
        u.id AS reporter_id,
        u.username AS user_name,
        u.email AS user_email

      FROM ${DatabaseConstants.reportsTable} r

      LEFT JOIN ${DatabaseConstants.usersTable} u
        ON r.user_id = u.id

      WHERE r.is_archived = 0

      ORDER BY r.created_at DESC
    ''');

    return results;
  }

  // =========================================================
  // GET ALL ARCHIVED REPORTS
  // =========================================================

  Future<List<Map<String, dynamic>>> getArchivedReports() async {
    final Database db = await database;

    final List<Map<String, dynamic>> results = await db.rawQuery('''
      SELECT
        r.*,
        u.id AS reporter_id,
        u.username AS user_name,
        u.email AS user_email

      FROM ${DatabaseConstants.reportsTable} r

      LEFT JOIN ${DatabaseConstants.usersTable} u
        ON r.user_id = u.id

      WHERE r.is_archived = 1

      ORDER BY r.created_at DESC
    ''');

    return results;
  }

  // =========================================================
  // GET SINGLE REPORT
  // =========================================================

  Future<Map<String, dynamic>?> getReportById(int reportId) async {
    final Database db = await database;

    final List<Map<String, dynamic>> results = await db.query(
      DatabaseConstants.reportsTable,
      where: 'id = ?',
      whereArgs: [reportId],
      limit: 1,
    );

    if (results.isEmpty) {
      return null;
    }

    return results.first;
  }

  // =========================================================
  // CHECK IF REPORT IS ARCHIVED
  // =========================================================

  Future<bool> isReportArchived(int reportId) async {
    final Database db = await database;

    final List<Map<String, dynamic>> result = await db.query(
      DatabaseConstants.reportsTable,
      columns: ['is_archived'],
      where: 'id = ?',
      whereArgs: [reportId],
      limit: 1,
    );

    if (result.isEmpty) {
      return false;
    }

    return (result.first['is_archived'] ?? 0) == 1;
  }

  // =========================================================
  // ARCHIVE REPORT
  // =========================================================

  Future<int> archiveReport(int reportId) async {
    final Database db = await database;

    return await db.update(
      DatabaseConstants.reportsTable,
      {'is_archived': 1, 'updated_at': DateTime.now().toIso8601String()},
      where: 'id = ?',
      whereArgs: [reportId],
    );
  }

  // =========================================================
  // UNARCHIVE REPORT
  // =========================================================

  Future<int> unarchiveReport(int reportId) async {
    final Database db = await database;

    return await db.update(
      DatabaseConstants.reportsTable,
      {'is_archived': 0, 'updated_at': DateTime.now().toIso8601String()},
      where: 'id = ?',
      whereArgs: [reportId],
    );
  }

  // =========================================================
  // DELETE REPORT
  // =========================================================

  Future<int> deleteReport(int reportId) async {
    final Database db = await database;

    return await db.delete(
      DatabaseConstants.reportsTable,
      where: 'id = ?',
      whereArgs: [reportId],
    );
  }

  // =========================================================
  // UPDATE REPORT STATUS
  // =========================================================

  Future<int> updateReportStatus({
    required int reportId,
    required String newStatus,
    String? remarks,
  }) async {
    final Database db = await database;

    // -------------------------------------------------------
    // GET CURRENT REPORT
    // -------------------------------------------------------

    final List<Map<String, dynamic>> reports = await db.query(
      DatabaseConstants.reportsTable,
      where: 'id = ?',
      whereArgs: [reportId],
      limit: 1,
    );

    if (reports.isEmpty) {
      return 0;
    }

    final Map<String, dynamic> report = reports.first;

    final String oldStatus = (report['status'] ?? 'Pending').toString();

    final int userId = report['user_id'] as int;

    final String now = DateTime.now().toIso8601String();

    // -------------------------------------------------------
    // TRANSACTION
    // -------------------------------------------------------

    return await db.transaction((txn) async {
      // -----------------------------------------------------
      // UPDATE REPORT
      // -----------------------------------------------------

      final int updatedRows = await txn.update(
        DatabaseConstants.reportsTable,
        {'status': newStatus, 'updated_at': now},
        where: 'id = ?',
        whereArgs: [reportId],
      );

      // -----------------------------------------------------
      // INSERT STATUS HISTORY
      // -----------------------------------------------------

      await txn.insert(DatabaseConstants.statusHistoryTable, {
        'report_id': reportId,
        'old_status': oldStatus,
        'new_status': newStatus,
        'remarks': remarks,
        'changed_at': now,
      });

      // -----------------------------------------------------
      // USER NOTIFICATION
      // -----------------------------------------------------

      await txn.insert(DatabaseConstants.notificationsTable, {
        'user_id': userId,
        'title': 'Report Status Updated',
        'message':
            'Your report "${report['title']}" status changed '
            'from $oldStatus to $newStatus.',
        'type': newStatus.toLowerCase(),
        'created_at': now,
        'is_read': 0,
      });

      return updatedRows;
    });
  }

  // =========================================================
  // GET ALL STATUS HISTORY
  // =========================================================

  Future<List<Map<String, dynamic>>> getAllStatusHistory() async {
    final Database db = await database;

    return await db.query(
      DatabaseConstants.statusHistoryTable,
      orderBy: 'changed_at DESC',
    );
  }

  // =========================================================
  // GET STATUS HISTORY FOR REPORT
  // =========================================================

  Future<List<Map<String, dynamic>>> getStatusHistoryByReport(
    int reportId,
  ) async {
    final Database db = await database;

    return await db.query(
      DatabaseConstants.statusHistoryTable,
      where: 'report_id = ?',
      whereArgs: [reportId],
      orderBy: 'changed_at DESC',
    );
  }

  // =========================================================
  // GET ALL NOTIFICATIONS
  // =========================================================

  Future<List<Map<String, dynamic>>> getAllNotifications() async {
    final Database db = await database;

    return await db.query(
      DatabaseConstants.notificationsTable,
      orderBy: 'created_at DESC',
    );
  }

  // =========================================================
  // GET USER NOTIFICATIONS
  // =========================================================

  Future<List<Map<String, dynamic>>> getNotificationsByUser(int userId) async {
    final Database db = await database;

    return await db.query(
      DatabaseConstants.notificationsTable,
      where: 'user_id = ?',
      whereArgs: [userId],
      orderBy: 'created_at DESC',
    );
  }

  // =========================================================
  // GET UNREAD NOTIFICATION COUNT
  // =========================================================

  Future<int> getUnreadNotificationCount(int userId) async {
    final Database db = await database;

    final List<Map<String, dynamic>> result = await db.rawQuery(
      '''
      SELECT COUNT(*) AS count
      FROM ${DatabaseConstants.notificationsTable}
      WHERE user_id = ?
        AND is_read = 0
      ''',
      [userId],
    );

    return Sqflite.firstIntValue(result) ?? 0;
  }

  // =========================================================
  // MARK NOTIFICATION AS READ
  // =========================================================

  Future<int> markNotificationAsRead(int notificationId) async {
    final Database db = await database;

    return await db.update(
      DatabaseConstants.notificationsTable,
      {'is_read': 1},
      where: 'id = ?',
      whereArgs: [notificationId],
    );
  }

  // =========================================================
  // MARK ALL NOTIFICATIONS AS READ
  // =========================================================

  Future<int> markAllNotificationsAsRead(int userId) async {
    final Database db = await database;

    return await db.update(
      DatabaseConstants.notificationsTable,
      {'is_read': 1},
      where: 'user_id = ? AND is_read = 0',
      whereArgs: [userId],
    );
  }

  // =========================================================
  // FEEDBACK SYSTEM
  // =========================================================

  // ---------------------------------------------------------
  // GET FEEDBACK BY REPORT FOR SPECIFIC USER
  // ---------------------------------------------------------

  Future<Map<String, dynamic>?> getFeedbackByReport({
    required int userId,
    required int reportId,
  }) async {
    final Database db = await database;

    final List<Map<String, dynamic>> result = await db.query(
      DatabaseConstants.feedbackTable,
      where: 'user_id = ? AND report_id = ?',
      whereArgs: [userId, reportId],
      limit: 1,
    );

    if (result.isEmpty) {
      return null;
    }

    return Map<String, dynamic>.from(result.first);
  }

  // ---------------------------------------------------------
  // INSERT FEEDBACK
  // ---------------------------------------------------------

  Future<int> insertFeedback({
    required int userId,
    required int reportId,
    required int rating,
    String? comment,
  }) async {
    final Database db = await database;

    return await db.insert(DatabaseConstants.feedbackTable, {
      'user_id': userId,
      'report_id': reportId,
      'rating': rating,
      'comment': comment?.trim(),
      'created_at': DateTime.now().toIso8601String(),
    }, conflictAlgorithm: ConflictAlgorithm.abort);
  }

  // ---------------------------------------------------------
  // UPDATE FEEDBACK
  // ---------------------------------------------------------

  Future<int> updateFeedback({
    required int feedbackId,
    required int rating,
    String? comment,
  }) async {
    final Database db = await database;

    return await db.update(
      DatabaseConstants.feedbackTable,
      {
        'rating': rating,
        'comment': comment?.trim(),
        'created_at': DateTime.now().toIso8601String(),
      },
      where: 'id = ?',
      whereArgs: [feedbackId],
    );
  }

  // =========================================================
  // GET ALL FEEDBACK FOR ADMIN
  // =========================================================

  Future<List<Map<String, dynamic>>> getAllFeedback() async {
    final Database db = await database;

    final List<Map<String, dynamic>> result = await db.rawQuery('''
      SELECT
        f.id AS feedback_id,
        f.user_id,
        f.report_id,
        f.rating,
        f.comment,
        f.created_at AS feedback_created_at,

        u.username AS user_name,
        u.email AS user_email,

        r.title AS report_title,
        r.status AS report_status

      FROM ${DatabaseConstants.feedbackTable} f

      LEFT JOIN ${DatabaseConstants.usersTable} u
        ON f.user_id = u.id

      LEFT JOIN ${DatabaseConstants.reportsTable} r
        ON f.report_id = r.id

      ORDER BY f.created_at DESC
    ''');

    return result;
  }

  // ---------------------------------------------------------
  // GET ALL FEEDBACK FOR A REPORT
  // ---------------------------------------------------------

  Future<List<Map<String, dynamic>>> getFeedbackByReportId(int reportId) async {
    final Database db = await database;

    return await db.query(
      DatabaseConstants.feedbackTable,
      where: 'report_id = ?',
      whereArgs: [reportId],
      orderBy: 'created_at DESC',
    );
  }

  // =========================================================
  // CLOSE DATABASE
  // =========================================================

  Future<void> closeDatabase() async {
    if (_database != null && _database!.isOpen) {
      await _database!.close();
    }

    _database = null;
  }

  // =========================================================
  // DELETE DATABASE
  // =========================================================

  Future<void> deleteDatabaseFile() async {
    final String databasesPath = await getDatabasesPath();

    final String path = join(databasesPath, DatabaseConstants.databaseName);

    await closeDatabase();

    await deleteDatabase(path);
  }
}
