class StatusHistory {
  final int? id;
  final int reportId;
  final String? oldStatus;
  final String newStatus;
  final String? remarks;
  final String changedAt;

  const StatusHistory({
    this.id,
    required this.reportId,
    this.oldStatus,
    required this.newStatus,
    this.remarks,
    required this.changedAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'report_id': reportId,
      'old_status': oldStatus,
      'new_status': newStatus,
      'remarks': remarks,
      'changed_at': changedAt,
    };
  }

  factory StatusHistory.fromMap(Map<String, dynamic> map) {
    return StatusHistory(
      id: map['id'] as int?,
      reportId: map['report_id'] as int,
      oldStatus: map['old_status'] as String?,
      newStatus: map['new_status'] as String,
      remarks: map['remarks'] as String?,
      changedAt: map['changed_at'] as String,
    );
  }
}
