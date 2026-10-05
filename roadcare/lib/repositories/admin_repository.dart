import '../database/database_helper.dart';

class AdminRepository {
  final DatabaseHelper _databaseHelper = DatabaseHelper.instance;

  // =========================================================
  // USERS
  // =========================================================

  Future<List<Map<String, dynamic>>> getAllUsers() async {
    return await _databaseHelper.getAllUsers();
  }

  // =========================================================
  // REPORTS
  // =========================================================

  Future<List<Map<String, dynamic>>> getAllReports() async {
    return await _databaseHelper.getAllReports();
  }

  // =========================================================
  // UPDATE REPORT STATUS
  // =========================================================

  Future<int> updateReportStatus({
    required int reportId,
    required String newStatus,
    String? remarks,
  }) async {
    return await _databaseHelper.updateReportStatus(
      reportId: reportId,
      newStatus: newStatus,
      remarks: remarks,
    );
  }

  // =========================================================
  // STATUS HISTORY
  // =========================================================

  Future<List<Map<String, dynamic>>> getAllStatusHistory() async {
    return await _databaseHelper.getAllStatusHistory();
  }

  // =========================================================
  // NOTIFICATIONS
  // =========================================================

  Future<List<Map<String, dynamic>>> getAllNotifications() async {
    return await _databaseHelper.getAllNotifications();
  }
}
