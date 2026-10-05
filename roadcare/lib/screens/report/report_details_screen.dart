import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../../database/database_helper.dart';
import '../../models/road_report.dart';
import '../../models/status_history.dart';
import '../feedback/feedback_screen.dart';
import '../map/report_map_screen.dart';

class ReportDetailsScreen extends StatefulWidget {
  final RoadReport report;

  const ReportDetailsScreen({super.key, required this.report});

  @override
  State<ReportDetailsScreen> createState() => _ReportDetailsScreenState();
}

class _ReportDetailsScreenState extends State<ReportDetailsScreen> {
  // =========================================================
  // STATE
  // =========================================================

  List<StatusHistory> _statusHistory = [];

  bool _isLoadingHistory = true;

  RoadReport get report => widget.report;
  ThemeData get _theme => Theme.of(context);
  ColorScheme get _colorScheme => _theme.colorScheme;

  // =========================================================
  // INIT
  // =========================================================

  @override
  void initState() {
    super.initState();

    _loadStatusHistory();
  }

  // =========================================================
  // LOAD STATUS HISTORY
  // =========================================================

  Future<void> _loadStatusHistory() async {
    try {
      if (report.id == null) {
        if (mounted) {
          setState(() {
            _isLoadingHistory = false;
          });
        }

        return;
      }

      final List<Map<String, dynamic>> rows = await DatabaseHelper.instance
          .getStatusHistoryByReport(report.id!);

      final List<StatusHistory> history = rows
          .map((map) => StatusHistory.fromMap(Map<String, dynamic>.from(map)))
          .toList();

      // Database returns latest first.
      // Display oldest first for timeline.
      history.sort((a, b) => a.changedAt.compareTo(b.changedAt));

      if (!mounted) return;

      setState(() {
        _statusHistory = history;
        _isLoadingHistory = false;
      });
    } catch (e) {
      debugPrint('Status history loading error: $e');

      if (!mounted) return;

      setState(() {
        _statusHistory = [];
        _isLoadingHistory = false;
      });
    }
  }

  // =========================================================
  // OPEN REPORT LOCATION ON MAP
  // =========================================================

  void _openMap() {
    if (report.latitude == null || report.longitude == null) {
      _showMessage('Location coordinates are not available.', isError: true);

      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => ReportMapScreen(reports: [report])),
    );
  }

  // =========================================================
  // OPEN FEEDBACK
  // =========================================================

  Future<void> _openFeedback() async {
    if (report.id == null) {
      _showMessage('Unable to open feedback for this report.', isError: true);

      return;
    }

    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => FeedbackScreen(report: report, userId: report.userId),
      ),
    );

    if (!mounted) return;

    if (result == true) {
      setState(() {});

      _showMessage('Thank you for your feedback!');
    }
  }

  // =========================================================
  // BUILD
  // =========================================================

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,

      // =======================================================
      // APP BAR
      // =======================================================
      appBar: AppBar(
        elevation: 0,
        backgroundColor: theme.appBarTheme.backgroundColor,
        surfaceTintColor: theme.appBarTheme.surfaceTintColor,

        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: Icon(Icons.arrow_back, color: colorScheme.onSurface),
        ),

        title: Text(
          'Report Details',
          style: TextStyle(
            color: colorScheme.onSurface,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),

      // =======================================================
      // BODY
      // =======================================================
      body: RefreshIndicator(
        onRefresh: _loadStatusHistory,

        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),

          padding: const EdgeInsets.all(20),

          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,

            children: [
              // =================================================
              // PHOTO
              // =================================================

              _buildPhotoCard(),

              const SizedBox(height: 20),

              // =================================================
              // CURRENT STATUS
              // =================================================
              _buildStatusCard(),

              const SizedBox(height: 20),

              // =================================================
              // REPORT INFORMATION
              // =================================================
              _buildSectionTitle(
                'Report Information',
                Icons.description_outlined,
              ),

              const SizedBox(height: 12),

              _buildInformationCard(),

              const SizedBox(height: 20),

              // =================================================
              // LOCATION
              // =================================================
              if (report.address != null &&
                  report.address!.trim().isNotEmpty) ...[
                _buildSectionTitle('Location', Icons.location_on_outlined),

                const SizedBox(height: 12),

                _buildLocationCard(),

                const SizedBox(height: 20),
              ],

              // =================================================
              // STATUS HISTORY
              // =================================================
              _buildSectionTitle('Status History', Icons.timeline_outlined),

              const SizedBox(height: 12),

              _buildStatusHistory(),

              // =================================================
              // FEEDBACK
              // =================================================
              if (report.status.toLowerCase() == 'resolved') ...[
                const SizedBox(height: 20),

                SizedBox(
                  width: double.infinity,
                  height: 54,

                  child: ElevatedButton.icon(
                    onPressed: _openFeedback,

                    icon: const Icon(Icons.star_outline),

                    label: const Text(
                      'Give Feedback',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),

                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFFFB300),

                      foregroundColor: Colors.white,

                      elevation: 2,

                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                  ),
                ),
              ],

              const SizedBox(height: 25),

              // =================================================
              // REPORT ID
              // =================================================
              Center(
                child: Text(
                  'Report ID: ${report.id ?? '-'}',

                  style: TextStyle(
                    color: colorScheme.onSurfaceVariant,
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),

              const SizedBox(height: 10),
            ],
          ),
        ),
      ),
    );
  }

  // =========================================================
  // BUILD REPORT IMAGE
  // =========================================================

  Widget _buildReportImage(String imagePath) {
    // =======================================================
    // FLUTTER WEB
    // =======================================================

    if (kIsWeb) {
      return GestureDetector(
        onTap: () => _showFullScreenImage(imagePath, isNetwork: true),
        child: Image.network(
          imagePath,

          width: double.infinity,
          height: 260,

          fit: BoxFit.cover,

          loadingBuilder:
              (
                BuildContext context,
                Widget child,
                ImageChunkEvent? loadingProgress,
              ) {
                if (loadingProgress == null) {
                  return child;
                }

                return Container(
                  width: double.infinity,
                  height: 260,

                  alignment: Alignment.center,

                  color: _colorScheme.surfaceContainerHighest,

                  child: CircularProgressIndicator(color: _colorScheme.primary),
                );
              },

          errorBuilder:
              (BuildContext context, Object error, StackTrace? stackTrace) {
                return _photoError();
              },
        ),
      );
    }

    // =======================================================
    // ANDROID / IOS / DESKTOP
    // =======================================================

    return GestureDetector(
      onTap: () => _showFullScreenImage(imagePath),
      child: Image.file(
        File(imagePath),

        width: double.infinity,
        height: 260,

        fit: BoxFit.cover,

        errorBuilder:
            (BuildContext context, Object error, StackTrace? stackTrace) {
              return _photoError();
            },
      ),
    );
  }

  // =========================================================
  // PHOTO CARD
  // =========================================================

  Widget _buildPhotoCard() {
    return Container(
      width: double.infinity,

      decoration: BoxDecoration(
        color: _theme.cardColor,

        borderRadius: BorderRadius.circular(20),

        boxShadow: _theme.brightness == Brightness.dark
            ? null
            : const [
                BoxShadow(
                  color: Colors.black12,
                  blurRadius: 10,
                  offset: Offset(0, 4),
                ),
              ],
      ),

      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,

        children: [
          if (report.imagePath != null && report.imagePath!.trim().isNotEmpty)
            ClipRRect(
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(20),
              ),

              child: _buildReportImage(report.imagePath!.trim()),
            )
          else
            _photoError(),

          Padding(
            padding: EdgeInsets.all(18),

            child: Row(
              children: [
                Icon(Icons.photo_camera_outlined, color: _colorScheme.primary),

                SizedBox(width: 10),

                Text(
                  'Photo Evidence',

                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                    color: _colorScheme.onSurface,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // =========================================================
  // FULL SCREEN IMAGE ZOOM
  // =========================================================

  void _showFullScreenImage(String imagePath, {bool isNetwork = false}) {
    showDialog(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.92),
      builder: (dialogContext) {
        return Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: const EdgeInsets.all(12),
          child: Stack(
            children: [
              Center(
                child: InteractiveViewer(
                  minScale: 0.8,
                  maxScale: 4.0,
                  child: isNetwork
                      ? Image.network(
                          imagePath,
                          fit: BoxFit.contain,
                          errorBuilder: (_, _, _) => _photoError(),
                        )
                      : Image.file(
                          File(imagePath),
                          fit: BoxFit.contain,
                          errorBuilder: (_, _, _) => _photoError(),
                        ),
                ),
              ),
              Positioned(
                top: 4,
                right: 4,
                child: CircleAvatar(
                  backgroundColor: Colors.white.withValues(alpha: 0.15),
                  child: IconButton(
                    tooltip: 'Close',
                    onPressed: () => Navigator.pop(dialogContext),
                    icon: const Icon(Icons.close, color: Colors.white),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // =========================================================
  // PHOTO ERROR
  // =========================================================

  Widget _photoError() {
    return Container(
      width: double.infinity,
      height: 240,

      decoration: BoxDecoration(
        color: _colorScheme.surfaceContainerHighest,

        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),

      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,

        children: [
          Icon(
            Icons.image_not_supported_outlined,
            size: 55,
            color: _colorScheme.onSurfaceVariant,
          ),

          SizedBox(height: 10),

          Text(
            'Photo not available',
            style: TextStyle(color: _colorScheme.onSurfaceVariant),
          ),
        ],
      ),
    );
  }

  // =========================================================
  // CURRENT STATUS CARD
  // =========================================================

  Widget _buildStatusCard() {
    final String status = report.status.toLowerCase();

    Color statusColor;
    IconData statusIcon;
    String description;

    switch (status) {
      case 'resolved':
        statusColor = Colors.green;

        statusIcon = Icons.check_circle_outline;

        description = 'This road damage report has been resolved.';

        break;

      case 'in progress':
        statusColor = Colors.orange;

        statusIcon = Icons.autorenew;

        description = 'Authorities are currently working on this report.';

        break;

      case 'rejected':
        statusColor = Colors.red;

        statusIcon = Icons.cancel_outlined;

        description = 'This report has been rejected by the authorities.';

        break;

      default:
        statusColor = _colorScheme.primary;

        statusIcon = Icons.pending_actions;

        description =
            'Your report has been submitted and is waiting for review.';
    }

    return Container(
      width: double.infinity,

      padding: const EdgeInsets.all(22),

      decoration: BoxDecoration(
        color: _theme.cardColor,

        borderRadius: BorderRadius.circular(22),

        boxShadow: _theme.brightness == Brightness.dark
            ? null
            : const [
                BoxShadow(
                  color: Colors.black12,
                  blurRadius: 12,
                  offset: Offset(0, 5),
                ),
              ],
      ),

      child: Row(
        children: [
          Container(
            width: 58,
            height: 58,

            decoration: BoxDecoration(
              color: statusColor.withValues(alpha: 0.12),
              shape: BoxShape.circle,
            ),

            child: Icon(statusIcon, color: statusColor, size: 32),
          ),

          const SizedBox(width: 16),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,

              children: [
                Text(
                  'Current Status',

                  style: TextStyle(
                    color: _colorScheme.onSurfaceVariant,
                    fontSize: 13,
                  ),
                ),

                const SizedBox(height: 5),

                Text(
                  report.status,

                  style: TextStyle(
                    color: statusColor,
                    fontSize: 21,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 5),

                Text(
                  description,

                  style: TextStyle(
                    color: _colorScheme.onSurfaceVariant,
                    fontSize: 13,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // =========================================================
  // SECTION TITLE
  // =========================================================

  Widget _buildSectionTitle(String title, IconData icon) {
    return Row(
      children: [
        Icon(icon, color: _colorScheme.primary, size: 24),

        const SizedBox(width: 9),

        Text(
          title,

          style: TextStyle(
            fontSize: 21,
            fontWeight: FontWeight.bold,
            color: _colorScheme.onSurface,
          ),
        ),
      ],
    );
  }

  // =========================================================
  // REPORT INFORMATION
  // =========================================================

  Widget _buildInformationCard() {
    return Container(
      width: double.infinity,

      padding: const EdgeInsets.all(20),

      decoration: BoxDecoration(
        color: _theme.cardColor,

        borderRadius: BorderRadius.circular(20),

        boxShadow: _theme.brightness == Brightness.dark
            ? null
            : const [
                BoxShadow(
                  color: Colors.black12,
                  blurRadius: 8,
                  offset: Offset(0, 3),
                ),
              ],
      ),

      child: Column(
        children: [
          _detailRow(Icons.title, 'Title', report.title),

          const Divider(height: 25),

          _detailRow(Icons.category_outlined, 'Damage Type', report.damageType),

          const Divider(height: 25),

          _detailRow(Icons.warning_amber_rounded, 'Severity', report.severity),

          const Divider(height: 25),

          _detailRow(
            Icons.calendar_today_outlined,
            'Submitted',
            _formatDateTime(report.createdAt),
          ),

          const Divider(height: 25),

          _detailRow(
            Icons.update,
            'Last Updated',
            _formatDateTime(report.updatedAt),
          ),

          const Divider(height: 25),

          Column(
            crossAxisAlignment: CrossAxisAlignment.start,

            children: [
              Row(
                children: [
                  Icon(
                    Icons.notes_outlined,
                    size: 21,
                    color: _colorScheme.primary,
                  ),

                  const SizedBox(width: 12),

                  Text(
                    'Description',

                    style: TextStyle(
                      color: _colorScheme.onSurfaceVariant,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 10),

              Text(
                report.description,

                style: TextStyle(
                  color: _colorScheme.onSurface,
                  fontSize: 15,
                  height: 1.5,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // =========================================================
  // DETAIL ROW
  // =========================================================

  Widget _detailRow(IconData icon, String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,

      children: [
        Icon(icon, size: 21, color: _colorScheme.primary),

        const SizedBox(width: 12),

        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,

            children: [
              Text(
                label,

                style: TextStyle(
                  color: _colorScheme.onSurfaceVariant,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),

              const SizedBox(height: 4),

              Text(
                value,

                style: TextStyle(
                  color: _colorScheme.onSurface,
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // =========================================================
  // LOCATION
  // =========================================================

  Widget _buildLocationCard() {
    return Container(
      width: double.infinity,

      padding: const EdgeInsets.all(20),

      decoration: BoxDecoration(
        color: _theme.cardColor,

        borderRadius: BorderRadius.circular(20),

        boxShadow: _theme.brightness == Brightness.dark
            ? null
            : const [
                BoxShadow(
                  color: Colors.black12,
                  blurRadius: 8,
                  offset: Offset(0, 3),
                ),
              ],
      ),

      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,

        children: [
          // ===================================================
          // ADDRESS
          // ===================================================

          Row(
            crossAxisAlignment: CrossAxisAlignment.start,

            children: [
              Container(
                padding: const EdgeInsets.all(12),

                decoration: BoxDecoration(
                  color: _colorScheme.primaryContainer,
                  borderRadius: BorderRadius.circular(14),
                ),

                child: Icon(
                  Icons.location_on,
                  color: _colorScheme.primary,
                  size: 28,
                ),
              ),

              const SizedBox(width: 14),

              Expanded(
                child: Text(
                  report.address!,

                  style: TextStyle(
                    color: _colorScheme.onSurface,
                    fontSize: 15,
                    height: 1.5,
                  ),
                ),
              ),
            ],
          ),

          // ===================================================
          // COORDINATES + VIEW MAP
          // ===================================================
          if (report.latitude != null && report.longitude != null) ...[
            const SizedBox(height: 15),

            Container(
              width: double.infinity,

              padding: const EdgeInsets.all(12),

              decoration: BoxDecoration(
                color: _colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(12),
              ),

              child: Row(
                children: [
                  Icon(
                    Icons.gps_fixed,
                    size: 18,
                    color: _colorScheme.onSurfaceVariant,
                  ),

                  const SizedBox(width: 8),

                  Expanded(
                    child: Text(
                      'Latitude: ${report.latitude}\n'
                      'Longitude: ${report.longitude}',

                      style: TextStyle(
                        color: _colorScheme.onSurfaceVariant,
                        fontSize: 13,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // =================================================
            // VIEW ON MAP BUTTON
            // =================================================
            const SizedBox(height: 15),

            SizedBox(
              width: double.infinity,
              height: 50,

              child: OutlinedButton.icon(
                onPressed: _openMap,

                icon: const Icon(Icons.map_outlined),

                label: const Text(
                  'View on Map',

                  style: TextStyle(fontWeight: FontWeight.bold),
                ),

                style: OutlinedButton.styleFrom(
                  foregroundColor: _colorScheme.primary,

                  side: BorderSide(color: _colorScheme.primary),

                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(13),
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  // =========================================================
  // STATUS HISTORY
  // =========================================================

  Widget _buildStatusHistory() {
    if (_isLoadingHistory) {
      return Container(
        width: double.infinity,

        padding: const EdgeInsets.all(35),

        decoration: BoxDecoration(
          color: _theme.cardColor,

          borderRadius: BorderRadius.circular(20),

          boxShadow: _theme.brightness == Brightness.dark
              ? null
              : const [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 8,
                    offset: Offset(0, 3),
                  ),
                ],
        ),

        child: Center(
          child: CircularProgressIndicator(color: _colorScheme.primary),
        ),
      );
    }

    return Container(
      width: double.infinity,

      padding: const EdgeInsets.all(20),

      decoration: BoxDecoration(
        color: _theme.cardColor,

        borderRadius: BorderRadius.circular(20),

        boxShadow: _theme.brightness == Brightness.dark
            ? null
            : const [
                BoxShadow(
                  color: Colors.black12,
                  blurRadius: 8,
                  offset: Offset(0, 3),
                ),
              ],
      ),

      child: Column(
        children: [
          // =================================================
          // ALWAYS SHOW SUBMITTED
          // =================================================

          _timelineItem(
            icon: Icons.send,

            title: 'Report Submitted',

            description: 'Your road damage report was submitted.',

            active: true,

            isLast: _statusHistory.isEmpty,

            dateTime: report.createdAt,
          ),

          // =================================================
          // REAL DATABASE HISTORY
          // =================================================
          for (int i = 0; i < _statusHistory.length; i++)
            _buildHistoryItem(
              history: _statusHistory[i],
              isLast: i == _statusHistory.length - 1,
            ),

          // =================================================
          // IF NO HISTORY YET
          // =================================================
          if (_statusHistory.isEmpty)
            _timelineItem(
              icon: Icons.pending_actions,

              title: 'Pending',

              description: 'Waiting for authorities to review your report.',

              active: report.status.toLowerCase() == 'pending',

              isLast: true,

              dateTime: report.createdAt,
            ),
        ],
      ),
    );
  }

  // =========================================================
  // DATABASE HISTORY ITEM
  // =========================================================

  Widget _buildHistoryItem({
    required StatusHistory history,
    required bool isLast,
  }) {
    final String status = history.newStatus.toLowerCase();

    IconData icon;
    Color color;

    switch (status) {
      case 'resolved':
        icon = Icons.check_circle_outline;
        color = Colors.green;
        break;

      case 'in progress':
        icon = Icons.autorenew;
        color = Colors.orange;
        break;

      case 'rejected':
        icon = Icons.cancel_outlined;
        color = Colors.red;
        break;

      case 'pending':
        icon = Icons.pending_actions;
        color = _colorScheme.primary;
        break;

      default:
        icon = Icons.update;
        color = _colorScheme.primary;
    }

    String description;

    if (history.oldStatus != null && history.oldStatus!.trim().isNotEmpty) {
      description =
          'Status changed from ${history.oldStatus} '
          'to ${history.newStatus}.';
    } else {
      description = 'Report status changed to ${history.newStatus}.';
    }

    if (history.remarks != null && history.remarks!.trim().isNotEmpty) {
      description = '$description\n\nRemarks: ${history.remarks}';
    }

    return _timelineItem(
      icon: icon,

      title: history.newStatus,

      description: description,

      active: true,

      isLast: isLast,

      dateTime: history.changedAt,

      customColor: color,
    );
  }

  // =========================================================
  // TIMELINE ITEM
  // =========================================================

  Widget _timelineItem({
    required IconData icon,
    required String title,
    required String description,
    required bool active,
    required bool isLast,
    String? dateTime,
    Color? customColor,
  }) {
    final Color color =
        customColor ?? (active ? _colorScheme.primary : _colorScheme.outline);

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,

        children: [
          // =================================================
          // ICON + CONNECTING LINE
          // =================================================

          Column(
            children: [
              Container(
                width: 42,
                height: 42,

                decoration: BoxDecoration(
                  color: active
                      ? color.withValues(alpha: 0.12)
                      : _colorScheme.surfaceContainerHighest,

                  shape: BoxShape.circle,
                ),

                child: Icon(icon, color: color, size: 22),
              ),

              if (!isLast)
                Expanded(
                  child: Container(
                    width: 2,

                    margin: const EdgeInsets.symmetric(vertical: 4),

                    color: active
                        ? color.withValues(alpha: 0.35)
                        : _colorScheme.outlineVariant,
                  ),
                ),
            ],
          ),

          const SizedBox(width: 15),

          // =================================================
          // CONTENT
          // =================================================
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 25),

              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,

                children: [
                  Text(
                    title,

                    style: TextStyle(
                      color: active
                          ? _colorScheme.onSurface
                          : _colorScheme.onSurfaceVariant,

                      fontSize: 16,

                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 5),

                  Text(
                    description,

                    style: TextStyle(
                      color: active
                          ? _colorScheme.onSurfaceVariant
                          : _colorScheme.onSurfaceVariant.withValues(
                              alpha: 0.7,
                            ),

                      fontSize: 13,

                      height: 1.4,
                    ),
                  ),

                  if (dateTime != null && dateTime.trim().isNotEmpty) ...[
                    const SizedBox(height: 7),

                    Row(
                      children: [
                        Icon(
                          Icons.access_time,
                          size: 14,
                          color: _colorScheme.onSurfaceVariant,
                        ),

                        const SizedBox(width: 5),

                        Text(
                          _formatDateTime(dateTime),

                          style: TextStyle(
                            color: _colorScheme.onSurfaceVariant,
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // =========================================================
  // DATE + TIME
  // =========================================================

  String _formatDateTime(String date) {
    try {
      final DateTime parsedDate = DateTime.parse(date);

      final String day = parsedDate.day.toString().padLeft(2, '0');

      final String month = parsedDate.month.toString().padLeft(2, '0');

      final String year = parsedDate.year.toString();

      int hour = parsedDate.hour;

      final String minute = parsedDate.minute.toString().padLeft(2, '0');

      final String period = hour >= 12 ? 'PM' : 'AM';

      hour = hour % 12;

      if (hour == 0) {
        hour = 12;
      }

      return '$day/$month/$year • '
          '$hour:$minute $period';
    } catch (_) {
      return date;
    }
  }

  // =========================================================
  // MESSAGE
  // =========================================================

  void _showMessage(String message, {bool isError = false}) {
    if (!mounted) return;

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Icon(
                isError ? Icons.error_outline : Icons.check_circle_outline,
                color: Colors.white,
              ),

              const SizedBox(width: 10),

              Expanded(child: Text(message)),
            ],
          ),

          backgroundColor: isError
              ? Colors.red.shade700
              : Colors.green.shade700,

          behavior: SnackBarBehavior.floating,

          margin: const EdgeInsets.all(20),

          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
      );
  }
}
