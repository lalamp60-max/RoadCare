import 'package:flutter/material.dart';

import '../../models/notification.dart';
import '../../models/road_report.dart';
import '../report/report_details_screen.dart';

class NotificationScreen extends StatefulWidget {
  final int userId;

  final List<RoadReport> reports;

  const NotificationScreen({
    super.key,
    required this.userId,
    required this.reports,
  });

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  // =========================================================
  // READ NOTIFICATIONS
  // =========================================================

  final Set<String> _readNotifications = <String>{};

  // =========================================================
  // CREATE NOTIFICATIONS FROM REPORTS
  // =========================================================

  List<RoadNotification> _buildNotifications() {
    final List<RoadNotification> notifications = [];

    for (final RoadReport report in widget.reports) {
      final String reportId =
          '${report.userId}_${report.title}_${report.createdAt}';

      final String status = report.status.toLowerCase();

      String title;

      String message;

      String type;

      switch (status) {
        case 'resolved':
          title = 'Report Resolved';
          message =
              'Your road damage report "${report.title}" has been resolved.';
          type = 'resolved';
          break;

        case 'in progress':
          title = 'Report In Progress';
          message =
              'Your road damage report "${report.title}" is currently being processed.';
          type = 'in progress';
          break;

        case 'rejected':
          title = 'Report Rejected';
          message =
              'Your road damage report "${report.title}" has been rejected.';
          type = 'rejected';
          break;

        case 'pending':
        default:
          title = 'Report Submitted';
          message =
              'Your road damage report "${report.title}" is waiting for review.';
          type = 'pending';
          break;
      }

      notifications.add(
        RoadNotification(
          id: report.id,
          userId: widget.userId,
          title: title,
          message: message,
          type: type,
          createdAt: report.updatedAt.isNotEmpty
              ? report.updatedAt
              : report.createdAt,
          isRead: _readNotifications.contains(reportId),
        ),
      );
    }

    notifications.sort((a, b) => b.createdAt.compareTo(a.createdAt));

    return notifications;
  }

  // =========================================================
  // NOTIFICATION KEY
  // =========================================================

  String _notificationKey(RoadNotification notification) {
    return '${notification.userId}_'
        '${notification.title}_'
        '${notification.createdAt}';
  }

  // =========================================================
  // MARK AS READ
  // =========================================================

  void _markAsRead(RoadNotification notification) {
    final String key = _notificationKey(notification);

    setState(() {
      _readNotifications.add(key);
    });
  }

  // =========================================================
  // MARK ALL AS READ
  // =========================================================

  void _markAllAsRead() {
    final List<RoadNotification> notifications = _buildNotifications();

    setState(() {
      for (final notification in notifications) {
        _readNotifications.add(_notificationKey(notification));
      }
    });
  }

  // =========================================================
  // DELETE / CLEAR NOTIFICATIONS
  // =========================================================

  void _clearNotifications() {
    if (_buildNotifications().isEmpty) {
      return;
    }

    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text(
            'Clear Notifications',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          content: const Text(
            'Are you sure you want to clear the notification view?',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext);
              },
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(dialogContext);

                setState(() {
                  _readNotifications.clear();
                });

                _showMessage('Notifications marked as unread again.');
              },
              child: const Text('Clear'),
            ),
          ],
        );
      },
    );
  }

  // =========================================================
  // OPEN REPORT
  // =========================================================

  void _openReport(RoadNotification notification) {
    RoadReport? selectedReport;

    for (final RoadReport report in widget.reports) {
      if (report.title == notification.message.split('"')[1]) {
        selectedReport = report;
        break;
      }
    }

    if (selectedReport == null) {
      return;
    }

    _markAsRead(notification);

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ReportDetailsScreen(report: selectedReport!),
      ),
    );
  }

  // =========================================================
  // BUILD
  // =========================================================

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final List<RoadNotification> notifications = _buildNotifications();

    final int unreadCount = notifications.where((notification) {
      return !_readNotifications.contains(_notificationKey(notification));
    }).length;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,

      // =====================================================
      // APP BAR
      // =====================================================
      appBar: AppBar(
        backgroundColor: theme.appBarTheme.backgroundColor,
        surfaceTintColor: theme.appBarTheme.surfaceTintColor,
        elevation: 0,

        iconTheme: IconThemeData(color: colorScheme.onSurface),

        title: Text(
          'Notifications',
          style: TextStyle(
            color: colorScheme.onSurface,
            fontWeight: FontWeight.bold,
          ),
        ),

        actions: [
          if (unreadCount > 0)
            IconButton(
              tooltip: 'Mark all as read',
              onPressed: _markAllAsRead,
              icon: Icon(Icons.done_all, color: colorScheme.primary),
            ),

          if (notifications.isNotEmpty)
            IconButton(
              tooltip: 'Clear',
              onPressed: _clearNotifications,
              icon: Icon(Icons.clear_all, color: colorScheme.onSurface),
            ),

          const SizedBox(width: 8),
        ],
      ),

      // =====================================================
      // BODY
      // =====================================================
      body: notifications.isEmpty
          ? _buildEmptyState()
          : RefreshIndicator(
              onRefresh: _refreshNotifications,
              child: ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(20),
                children: [
                  // =================================================
                  // HEADER
                  // =================================================

                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF1565C0), Color(0xFF1976D2)],
                      ),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.18),
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: const Icon(
                            Icons.notifications_active_outlined,
                            color: Colors.white,
                            size: 30,
                          ),
                        ),

                        const SizedBox(width: 15),

                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Your Notifications',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),

                              const SizedBox(height: 5),

                              Text(
                                unreadCount == 0
                                    ? 'You are all caught up!'
                                    : '$unreadCount unread notification'
                                          '${unreadCount == 1 ? '' : 's'}',
                                style: const TextStyle(
                                  color: Colors.white70,
                                  fontSize: 13,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  // =================================================
                  // NOTIFICATIONS
                  // =================================================
                  ...notifications.map(
                    (notification) => _buildNotificationCard(notification),
                  ),
                ],
              ),
            ),
    );
  }

  // =========================================================
  // NOTIFICATION CARD
  // =========================================================

  Widget _buildNotificationCard(RoadNotification notification) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final bool isRead = _readNotifications.contains(
      _notificationKey(notification),
    );

    Color iconColor;

    Color iconBackground;

    IconData icon;

    switch (notification.type.toLowerCase()) {
      case 'resolved':
        iconColor = Colors.green;
        iconBackground = Colors.green.withValues(
          alpha: theme.brightness == Brightness.dark ? 0.2 : 0.1,
        );
        icon = Icons.check_circle_outline;
        break;

      case 'in progress':
        iconColor = Colors.orange;
        iconBackground = Colors.orange.withValues(
          alpha: theme.brightness == Brightness.dark ? 0.2 : 0.1,
        );
        icon = Icons.autorenew;
        break;

      case 'rejected':
        iconColor = Colors.red;
        iconBackground = Colors.red.withValues(
          alpha: theme.brightness == Brightness.dark ? 0.2 : 0.1,
        );
        icon = Icons.cancel_outlined;
        break;

      case 'pending':
      default:
        iconColor = colorScheme.primary;
        iconBackground = colorScheme.primaryContainer;
        icon = Icons.pending_actions;
        break;
    }

    return InkWell(
      borderRadius: BorderRadius.circular(18),
      onTap: () {
        _openReport(notification);
      },
      child: Container(
        width: double.infinity,
        margin: const EdgeInsets.only(bottom: 14),
        padding: const EdgeInsets.all(17),
        decoration: BoxDecoration(
          color: isRead
              ? theme.cardColor
              : colorScheme.primaryContainer.withValues(
                  alpha: theme.brightness == Brightness.dark ? 0.48 : 0.55,
                ),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: isRead
                ? colorScheme.outlineVariant
                : colorScheme.primary.withValues(alpha: 0.35),
          ),
          boxShadow: theme.brightness == Brightness.dark
              ? null
              : const [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 8,
                    offset: Offset(0, 3),
                  ),
                ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // =================================================
            // ICON
            // =================================================

            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: iconBackground,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(icon, color: iconColor, size: 27),
            ),

            const SizedBox(width: 14),

            // =================================================
            // CONTENT
            // =================================================
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          notification.title,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: isRead
                                ? FontWeight.w600
                                : FontWeight.bold,
                            color: colorScheme.onSurface,
                          ),
                        ),
                      ),

                      if (!isRead)
                        Container(
                          width: 9,
                          height: 9,
                          decoration: BoxDecoration(
                            color: colorScheme.primary,
                            shape: BoxShape.circle,
                          ),
                        ),
                    ],
                  ),

                  const SizedBox(height: 7),

                  Text(
                    notification.message,
                    style: TextStyle(
                      color: colorScheme.onSurfaceVariant,
                      fontSize: 13,
                      height: 1.4,
                    ),
                  ),

                  const SizedBox(height: 10),

                  Row(
                    children: [
                      Icon(
                        Icons.access_time,
                        size: 15,
                        color: colorScheme.onSurfaceVariant,
                      ),

                      const SizedBox(width: 5),

                      Text(
                        _formatDate(notification.createdAt),
                        style: TextStyle(
                          fontSize: 12,
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),

                      const Spacer(),

                      Icon(
                        Icons.chevron_right,
                        size: 20,
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // =========================================================
  // EMPTY STATE
  // =========================================================

  Widget _buildEmptyState() {
    final colorScheme = Theme.of(context).colorScheme;

    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(30),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(25),
              decoration: BoxDecoration(
                color: colorScheme.primaryContainer,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.notifications_none,
                size: 65,
                color: colorScheme.primary,
              ),
            ),

            const SizedBox(height: 25),

            Text(
              'No Notifications',
              style: TextStyle(
                fontSize: 23,
                fontWeight: FontWeight.bold,
                color: colorScheme.onSurface,
              ),
            ),

            const SizedBox(height: 10),

            Text(
              'You do not have any notifications yet.\n'
              'Updates about your road reports will appear here.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: colorScheme.onSurfaceVariant,
                fontSize: 14,
                height: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // =========================================================
  // REFRESH
  // =========================================================

  Future<void> _refreshNotifications() async {
    setState(() {});

    await Future.delayed(const Duration(milliseconds: 400));
  }

  // =========================================================
  // DATE
  // =========================================================

  String _formatDate(String date) {
    try {
      final DateTime parsedDate = DateTime.parse(date);

      return '${parsedDate.day.toString().padLeft(2, '0')}/'
          '${parsedDate.month.toString().padLeft(2, '0')}/'
          '${parsedDate.year}';
    } catch (_) {
      return date;
    }
  }

  // =========================================================
  // MESSAGE
  // =========================================================

  void _showMessage(String message) {
    if (!mounted) return;

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.check_circle_outline, color: Colors.white),
              const SizedBox(width: 10),
              Expanded(child: Text(message)),
            ],
          ),
          backgroundColor: Colors.green.shade700,
          behavior: SnackBarBehavior.floating,
          margin: const EdgeInsets.all(20),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
      );
  }
}
