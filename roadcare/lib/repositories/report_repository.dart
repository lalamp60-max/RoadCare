import 'package:sqflite/sqflite.dart';

import '../database/database_constants.dart';
import '../database/database_helper.dart';
import '../models/road_report.dart';
import '../models/report_image.dart';

class ReportRepository {
  final DatabaseHelper _databaseHelper = DatabaseHelper.instance;

  // =========================================================
  // CREATE REPORT
  // =========================================================

  Future<int> createReport(RoadReport report, {String? imagePath}) async {
    final Database db = await _databaseHelper.database;

    return await db.transaction<int>((txn) async {
      // -----------------------------------------------------
      // REPORT DATA
      // -----------------------------------------------------

      final Map<String, dynamic> reportMap = Map<String, dynamic>.from(
        report.toMap(),
      );

      // SQLite generates ID.
      reportMap.remove('id');

      // -----------------------------------------------------
      // IMAGE PATH
      // -----------------------------------------------------

      if (imagePath != null && imagePath.trim().isNotEmpty) {
        reportMap['image_path'] = imagePath.trim();
      } else {
        reportMap['image_path'] = null;
      }

      // -----------------------------------------------------
      // INSERT REPORT
      // -----------------------------------------------------

      final int reportId = await txn.insert(
        DatabaseConstants.reportsTable,
        reportMap,
        conflictAlgorithm: ConflictAlgorithm.abort,
      );

      if (reportId <= 0) {
        throw Exception('Unable to create report');
      }

      // -----------------------------------------------------
      // INSERT IMAGE
      // -----------------------------------------------------

      if (imagePath != null && imagePath.trim().isNotEmpty) {
        final String now = DateTime.now().toIso8601String();

        final ReportImage reportImage = ReportImage(
          reportId: reportId,
          imagePath: imagePath.trim(),
          imageType: 'evidence',
          createdAt: now,
        );

        final Map<String, dynamic> imageMap = Map<String, dynamic>.from(
          reportImage.toMap(),
        );

        imageMap.remove('id');

        await txn.insert(
          DatabaseConstants.reportImagesTable,
          imageMap,
          conflictAlgorithm: ConflictAlgorithm.abort,
        );
      }

      return reportId;
    });
  }

  // =========================================================
  // GET USER REPORTS
  // =========================================================

  Future<List<RoadReport>> getReportsByUser(int userId) async {
    final Database db = await _databaseHelper.database;

    final List<Map<String, dynamic>> result = await db.query(
      DatabaseConstants.reportsTable,
      where: 'user_id = ?',
      whereArgs: [userId],
      orderBy: 'created_at DESC',
    );

    return result.map((map) => RoadReport.fromMap(map)).toList();
  }

  // =========================================================
  // GET REPORT BY ID
  // =========================================================

  Future<RoadReport?> getReportById(int id) async {
    final Database db = await _databaseHelper.database;

    final List<Map<String, dynamic>> result = await db.query(
      DatabaseConstants.reportsTable,
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );

    if (result.isEmpty) {
      return null;
    }

    return RoadReport.fromMap(result.first);
  }

  // =========================================================
  // GET REPORT IMAGE
  // =========================================================

  Future<ReportImage?> getReportImage(int reportId) async {
    final Database db = await _databaseHelper.database;

    final List<Map<String, dynamic>> result = await db.query(
      DatabaseConstants.reportImagesTable,
      where: 'report_id = ?',
      whereArgs: [reportId],
      orderBy: 'created_at DESC',
      limit: 1,
    );

    if (result.isEmpty) {
      return null;
    }

    return ReportImage.fromMap(result.first);
  }

  // =========================================================
  // GET USER REPORTS WITH IMAGES
  // =========================================================

  Future<List<Map<String, dynamic>>> getReportsWithImages(int userId) async {
    final Database db = await _databaseHelper.database;

    final List<Map<String, dynamic>> reports = await db.query(
      DatabaseConstants.reportsTable,
      where: 'user_id = ?',
      whereArgs: [userId],
      orderBy: 'created_at DESC',
    );

    final List<Map<String, dynamic>> result = [];

    for (final Map<String, dynamic> report in reports) {
      final int reportId = (report['id'] as num).toInt();

      final List<Map<String, dynamic>> images = await db.query(
        DatabaseConstants.reportImagesTable,
        where: 'report_id = ?',
        whereArgs: [reportId],
        orderBy: 'created_at DESC',
        limit: 1,
      );

      result.add({
        'report': RoadReport.fromMap(report),
        'image': images.isEmpty ? null : ReportImage.fromMap(images.first),
      });
    }

    return result;
  }

  // =========================================================
  // UPDATE REPORT
  // =========================================================

  Future<int> updateReport(RoadReport report) async {
    final Database db = await _databaseHelper.database;

    final Map<String, dynamic> map = Map<String, dynamic>.from(report.toMap());

    map.remove('id');

    return await db.update(
      DatabaseConstants.reportsTable,
      map,
      where: 'id = ?',
      whereArgs: [report.id],
    );
  }

  // =========================================================
  // DELETE REPORT
  // =========================================================

  Future<int> deleteReport(int id) async {
    final Database db = await _databaseHelper.database;

    return await db.delete(
      DatabaseConstants.reportsTable,
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // =========================================================
  // GET ALL REPORTS - ADMIN
  // =========================================================

  Future<List<RoadReport>> getAllReports() async {
    final Database db = await _databaseHelper.database;

    final List<Map<String, dynamic>> result = await db.query(
      DatabaseConstants.reportsTable,
      orderBy: 'created_at DESC',
    );

    return result.map((map) => RoadReport.fromMap(map)).toList();
  }

  // =========================================================
  // UPDATE REPORT STATUS
  // =========================================================

  Future<int> updateStatus(int reportId, String status) async {
    final Database db = await _databaseHelper.database;

    return await db.update(
      DatabaseConstants.reportsTable,
      {'status': status, 'updated_at': DateTime.now().toIso8601String()},
      where: 'id = ?',
      whereArgs: [reportId],
    );
  }
}
