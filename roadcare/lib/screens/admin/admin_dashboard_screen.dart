import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../../database/database_helper.dart';
import '../auth/login_screen.dart';
import '../../widgets/roadcare_photo_layout.dart';

class AdminDashboardScreen extends StatefulWidget {
  final int adminId;
  final String adminName;

  const AdminDashboardScreen({
    super.key,
    required this.adminId,
    required this.adminName,
  });

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  // =========================================================
  // DATA
  // =========================================================

  List<Map<String, dynamic>> _reports = [];

  List<Map<String, dynamic>> _archivedReports = [];

  List<Map<String, dynamic>> _feedback = [];

  bool _isLoading = true;

  // =========================================================
  // SEARCH / FILTER / SORT
  // =========================================================

  final TextEditingController _searchController = TextEditingController();

  String _selectedStatusFilter = 'All';

  String _selectedSeverityFilter = 'All';

  String _selectedSort = 'Newest First';

  // =========================================================
  // INIT
  // =========================================================

  @override
  void initState() {
    super.initState();

    _loadDashboardData();
  }

  // =========================================================
  // LOAD DASHBOARD DATA
  // =========================================================

  Future<void> _loadDashboardData() async {
    if (mounted) {
      setState(() {
        _isLoading = true;
      });
    }

    try {
      final results = await Future.wait<List<Map<String, dynamic>>>([
        DatabaseHelper.instance.getAllReports(),
        DatabaseHelper.instance.getArchivedReports(),
        DatabaseHelper.instance.getAllFeedback(),
      ]);

      if (!mounted) return;

      setState(() {
        _reports = results[0];
        _archivedReports = results[1];
        _feedback = results[2];
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _isLoading = false;
      });

      _showMessage('Unable to load dashboard data.', isError: true);

      debugPrint('Admin dashboard load error: $e');
    }
  }

  // =========================================================
  // STATUS COLOR
  // =========================================================

  Color _statusColor(String status) {
    switch (status.toLowerCase().trim()) {
      case 'resolved':
        return Colors.green;

      case 'in progress':
        return Colors.orange;

      case 'rejected':
        return Colors.red;

      case 'pending':
      default:
        return Colors.blue;
    }
  }

  // =========================================================
  // SEVERITY COLOR
  // =========================================================

  Color _severityColor(dynamic value) {
    switch (value?.toString().toLowerCase().trim()) {
      case 'critical':
        return Colors.red.shade700;

      case 'high':
        return Colors.orange.shade700;

      case 'medium':
        return Colors.amber.shade700;

      case 'low':
        return Colors.green;

      default:
        return Colors.grey;
    }
  }

  // =========================================================
  // SEVERITY ICON
  // =========================================================

  IconData _severityIcon(dynamic value) {
    switch (value?.toString().toLowerCase().trim()) {
      case 'critical':
        return Icons.dangerous_outlined;

      case 'high':
        return Icons.error_outline;

      case 'medium':
        return Icons.warning_amber_outlined;

      case 'low':
        return Icons.check_circle_outline;

      default:
        return Icons.warning_amber_outlined;
    }
  }

  // =========================================================
  // SEVERITY VALUE
  // =========================================================

  int _severityValue(dynamic value) {
    final String severity = value?.toString().toLowerCase().trim() ?? '';

    switch (severity) {
      case 'critical':
        return 4;

      case 'high':
        return 3;

      case 'medium':
        return 2;

      case 'low':
        return 1;

      default:
        return 0;
    }
  }

  // =========================================================
  // STATUS COUNT
  // =========================================================

  int _countStatus(String status) {
    return _reports.where((report) {
      return (report['status'] ?? '').toString().toLowerCase().trim() ==
          status.toLowerCase().trim();
    }).length;
  }

  // =========================================================
  // SEVERITY COUNT
  // =========================================================

  int _countSeverity(String severity) {
    return _reports.where((report) {
      return (report['severity'] ?? '').toString().toLowerCase().trim() ==
          severity.toLowerCase().trim();
    }).length;
  }

  // =========================================================
  // RESOLUTION RATE
  // =========================================================

  double get _resolutionRate {
    if (_reports.isEmpty) {
      return 0;
    }

    return (_countStatus('Resolved') / _reports.length) * 100;
  }

  // =========================================================
  // AVERAGE FEEDBACK
  // =========================================================

  double get _averageRating {
    if (_feedback.isEmpty) {
      return 0;
    }

    final int total = _feedback.fold<int>(
      0,
      (sum, feedback) => sum + _feedbackRating(feedback),
    );

    return total / _feedback.length;
  }

  // =========================================================
  // FILTERED REPORTS
  // =========================================================

  List<Map<String, dynamic>> get _filteredReports {
    List<Map<String, dynamic>> filtered = List<Map<String, dynamic>>.from(
      _reports,
    );

    final String search = _searchController.text.trim().toLowerCase();

    // -------------------------------------------------------
    // SEARCH
    // -------------------------------------------------------

    if (search.isNotEmpty) {
      filtered = filtered.where((report) {
        final String searchableText =
            [
                  report['id'],
                  report['title'],
                  report['description'],
                  report['damage_type'],
                  report['severity'],
                  report['status'],
                  report['user_name'],
                  report['user_email'],
                  report['address'],
                  report['latitude'],
                  report['longitude'],
                  report['user_id'],
                  report['reporter_id'],
                ]
                .map((value) {
                  return value?.toString() ?? '';
                })
                .join(' ')
                .toLowerCase();

        return searchableText.contains(search);
      }).toList();
    }

    // -------------------------------------------------------
    // STATUS FILTER
    // -------------------------------------------------------

    if (_selectedStatusFilter != 'All') {
      filtered = filtered.where((report) {
        final String status = (report['status'] ?? '')
            .toString()
            .toLowerCase()
            .trim();

        return status == _selectedStatusFilter.toLowerCase().trim();
      }).toList();
    }

    // -------------------------------------------------------
    // SEVERITY FILTER
    // -------------------------------------------------------

    if (_selectedSeverityFilter != 'All') {
      filtered = filtered.where((report) {
        final String severity = (report['severity'] ?? '')
            .toString()
            .toLowerCase()
            .trim();

        return severity == _selectedSeverityFilter.toLowerCase().trim();
      }).toList();
    }

    // -------------------------------------------------------
    // SORT
    // -------------------------------------------------------

    if (_selectedSort == 'Newest First') {
      filtered.sort((a, b) {
        final DateTime? dateA = DateTime.tryParse(
          a['created_at']?.toString() ?? '',
        );

        final DateTime? dateB = DateTime.tryParse(
          b['created_at']?.toString() ?? '',
        );

        if (dateA == null && dateB == null) {
          return 0;
        }

        if (dateA == null) {
          return 1;
        }

        if (dateB == null) {
          return -1;
        }

        return dateB.compareTo(dateA);
      });
    } else if (_selectedSort == 'Oldest First') {
      filtered.sort((a, b) {
        final DateTime? dateA = DateTime.tryParse(
          a['created_at']?.toString() ?? '',
        );

        final DateTime? dateB = DateTime.tryParse(
          b['created_at']?.toString() ?? '',
        );

        if (dateA == null && dateB == null) {
          return 0;
        }

        if (dateA == null) {
          return 1;
        }

        if (dateB == null) {
          return -1;
        }

        return dateA.compareTo(dateB);
      });
    } else if (_selectedSort == 'Severity: Critical → Low') {
      filtered.sort((a, b) {
        return _severityValue(b['severity'])
            .compareTo(_severityValue(a['severity']));
      });
    } else if (_selectedSort == 'Severity: Low → Critical') {
      filtered.sort((a, b) {
        return _severityValue(a['severity'])
            .compareTo(_severityValue(b['severity']));
      });
    }

    return filtered;
  }

  // =========================================================
  // HAS FILTERS
  // =========================================================

  bool get _hasActiveFilters {
    return _searchController.text.trim().isNotEmpty ||
        _selectedStatusFilter != 'All' ||
        _selectedSeverityFilter != 'All' ||
        _selectedSort != 'Newest First';
  }

  // =========================================================
  // CLEAR FILTERS
  // =========================================================

  void _clearFilters() {
    setState(() {
      _searchController.clear();

      _selectedStatusFilter = 'All';

      _selectedSeverityFilter = 'All';

      _selectedSort = 'Newest First';
    });
  }

  // =========================================================
  // DATE FORMAT
  // =========================================================

  String _formatDate(dynamic value) {
    if (value == null) {
      return 'Date not available';
    }

    final String raw = value.toString();

    final DateTime? date = DateTime.tryParse(raw);

    if (date == null) {
      return raw;
    }

    final String day = date.day.toString().padLeft(2, '0');

    final String month = date.month.toString().padLeft(2, '0');

    final String year = date.year.toString();

    int hour = date.hour;

    final String minute = date.minute.toString().padLeft(2, '0');

    final String period = hour >= 12 ? 'PM' : 'AM';

    hour = hour % 12;

    if (hour == 0) {
      hour = 12;
    }

    return '$day/$month/$year $hour:$minute $period';
  }

  // =========================================================
  // SAFE VALUE
  // =========================================================

  String _value(
    Map<String, dynamic> data,
    String key, [
    String defaultValue = 'Not available',
  ]) {
    final dynamic value = data[key];

    if (value == null || value.toString().trim().isEmpty) {
      return defaultValue;
    }

    return value.toString();
  }

  // =========================================================
  // REPORT ID
  // =========================================================

  int? _getReportId(Map<String, dynamic> report) {
    final dynamic rawId = report['id'];

    if (rawId == null) {
      return null;
    }

    if (rawId is int) {
      return rawId;
    }

    return int.tryParse(rawId.toString());
  }

  // =========================================================
  // UPDATE STATUS DIALOG
  // =========================================================

  Future<void> _showStatusDialog(Map<String, dynamic> report) async {
    String selectedStatus = (report['status'] ?? 'Pending').toString();

    final TextEditingController remarksController = TextEditingController();

    await showDialog(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: const Text(
                'Update Report Status',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Report #${_value(report, 'id')}',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 15),
                    DropdownButtonFormField<String>(
                      initialValue: selectedStatus,
                      decoration: const InputDecoration(
                        labelText: 'Status',
                        border: OutlineInputBorder(),
                      ),
                      items: const [
                        DropdownMenuItem(
                          value: 'Pending',
                          child: Text('Pending'),
                        ),
                        DropdownMenuItem(
                          value: 'In Progress',
                          child: Text('In Progress'),
                        ),
                        DropdownMenuItem(
                          value: 'Resolved',
                          child: Text('Resolved'),
                        ),
                        DropdownMenuItem(
                          value: 'Rejected',
                          child: Text('Rejected'),
                        ),
                      ],
                      onChanged: (value) {
                        if (value == null) {
                          return;
                        }

                        setDialogState(() {
                          selectedStatus = value;
                        });
                      },
                    ),
                    const SizedBox(height: 15),
                    TextField(
                      controller: remarksController,
                      maxLines: 3,
                      decoration: const InputDecoration(
                        labelText: 'Remarks (Optional)',
                        hintText: 'Enter remarks for the user...',
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(dialogContext);
                  },
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: () async {
                    Navigator.pop(dialogContext);

                    await _updateStatus(
                      report,
                      selectedStatus,
                      remarksController.text,
                    );
                  },
                  child: const Text('Update Status'),
                ),
              ],
            );
          },
        );
      },
    );

    remarksController.dispose();
  }

  // =========================================================
  // UPDATE STATUS
  // =========================================================

  Future<void> _updateStatus(
    Map<String, dynamic> report,
    String newStatus,
    String remarks,
  ) async {
    final int? reportId = _getReportId(report);

    if (reportId == null) {
      _showMessage('Invalid report ID.', isError: true);

      return;
    }

    final String oldStatus = (report['status'] ?? 'Pending').toString();

    if (oldStatus.toLowerCase() == newStatus.toLowerCase()) {
      _showMessage('Report is already $newStatus.', isError: true);

      return;
    }

    try {
      final int result = await DatabaseHelper.instance.updateReportStatus(
        reportId: reportId,
        newStatus: newStatus,
        remarks: remarks.trim().isEmpty ? null : remarks.trim(),
      );

      if (!mounted) return;

      if (result > 0) {
        await _loadDashboardData();

        if (!mounted) return;

        _showMessage('Report #$reportId updated to $newStatus.');
      } else {
        _showMessage('Unable to update report status.', isError: true);
      }
    } catch (e) {
      if (!mounted) return;

      _showMessage('Unable to update report status.', isError: true);

      debugPrint('Update report status error: $e');
    }
  }

  // =========================================================
  // CONFIRM ARCHIVE
  // =========================================================

  Future<void> _confirmArchiveReport(Map<String, dynamic> report) async {
    final int? reportId = _getReportId(report);

    if (reportId == null) {
      _showMessage('Invalid report ID.', isError: true);

      return;
    }

    final bool? confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text(
            'Archive Report?',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          content: Text(
            'Are you sure you want to archive '
            'Report #$reportId?\n\n'
            'The report will move from Active Reports '
            'to Archived Reports.',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext, false);
              },
              child: const Text('Cancel'),
            ),
            ElevatedButton.icon(
              onPressed: () {
                Navigator.pop(dialogContext, true);
              },
              icon: const Icon(Icons.archive_outlined),
              label: const Text('Archive'),
            ),
          ],
        );
      },
    );

    if (confirmed != true) {
      return;
    }

    try {
      final int result = await DatabaseHelper.instance.archiveReport(reportId);

      if (!mounted) return;

      if (result > 0) {
        await _loadDashboardData();

        if (!mounted) return;

        _showMessage('Report #$reportId archived successfully.');
      } else {
        _showMessage('Unable to archive report.', isError: true);
      }
    } catch (e) {
      if (!mounted) return;

      _showMessage('Unable to archive report.', isError: true);

      debugPrint('Archive report error: $e');
    }
  }

  // =========================================================
  // UNARCHIVE
  // =========================================================

  Future<void> _unarchiveReport(Map<String, dynamic> report) async {
    final int? reportId = _getReportId(report);

    if (reportId == null) {
      _showMessage('Invalid report ID.', isError: true);

      return;
    }

    try {
      final int result = await DatabaseHelper.instance.unarchiveReport(
        reportId,
      );

      if (!mounted) return;

      if (result > 0) {
        await _loadDashboardData();

        if (!mounted) return;

        _showMessage('Report #$reportId restored successfully.');
      } else {
        _showMessage('Unable to restore report.', isError: true);
      }
    } catch (e) {
      if (!mounted) return;

      _showMessage('Unable to restore report.', isError: true);

      debugPrint('Unarchive report error: $e');
    }
  }

  // =========================================================
  // REPORT DETAILS
  // =========================================================

  Future<void> _showReportDetails(Map<String, dynamic> report) async {
    final String status = _value(report, 'status', 'Pending');

    final Color statusColor = _statusColor(status);

    final String severity = _value(report, 'severity', 'Low');

    final Color severityColor = _severityColor(severity);

    final String imagePath = _value(report, 'image_path', '');

    final String latitude = _value(report, 'latitude', '');

    final String longitude = _value(report, 'longitude', '');

    final String address = _value(report, 'address', 'Location not available');

    final bool hasImage = imagePath.isNotEmpty && imagePath != 'Not available';

    final bool hasCoordinates =
        latitude.isNotEmpty &&
        longitude.isNotEmpty &&
        latitude != 'Not available' &&
        longitude != 'Not available';

    await showDialog(
      context: context,
      builder: (dialogContext) {
        return Dialog(
          insetPadding: const EdgeInsets.symmetric(
            horizontal: 18,
            vertical: 24,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(22),
          ),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 650, maxHeight: 720),
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // -------------------------------------------------
                  // TITLE
                  // -------------------------------------------------

                  Row(
                    children: [
                      const Expanded(
                        child: Text(
                          'Report Details',
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      IconButton(
                        onPressed: () {
                          Navigator.pop(dialogContext);
                        },
                        icon: const Icon(Icons.close),
                      ),
                    ],
                  ),

                  const SizedBox(height: 8),

                  // -------------------------------------------------
                  // ID + STATUS + SEVERITY
                  // -------------------------------------------------
                  Wrap(
                    spacing: 10,
                    runSpacing: 8,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      Text(
                        'Report #${_value(report, 'id')}',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      // STATUS
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 7,
                        ),
                        decoration: BoxDecoration(
                          color: statusColor.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          status,
                          style: TextStyle(
                            color: statusColor,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),

                      // SEVERITY
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 7,
                        ),
                        decoration: BoxDecoration(
                          color: severityColor.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: severityColor.withValues(alpha: 0.25),
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              _severityIcon(severity),
                              size: 17,
                              color: severityColor,
                            ),
                            const SizedBox(width: 5),
                            Text(
                              'Severity: $severity',
                              style: TextStyle(
                                color: severityColor,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 18),

                  // -------------------------------------------------
                  // IMAGE
                  // -------------------------------------------------
                  if (hasImage) _buildReportImage(imagePath),

                  if (hasImage) const SizedBox(height: 18),

                  // -------------------------------------------------
                  // REPORT INFORMATION
                  // -------------------------------------------------
                  _detailsSection(
                    title: 'Report Information',
                    icon: Icons.description_outlined,
                    children: [
                      _detailRow('Title', _value(report, 'title')),
                      _detailRow('Description', _value(report, 'description')),
                      _detailRow('Damage Type', _value(report, 'damage_type')),
                      _detailRow('Severity', severity),
                      _detailRow(
                        'Submitted',
                        _formatDate(report['created_at']),
                      ),
                      _detailRow(
                        'Last Updated',
                        _formatDate(report['updated_at']),
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  // -------------------------------------------------
                  // USER INFORMATION
                  // -------------------------------------------------
                  _detailsSection(
                    title: 'Reported By',
                    icon: Icons.person_outline,
                    children: [
                      _detailRow(
                        'User ID',
                        _value(
                          report,
                          'reporter_id',
                          _value(report, 'user_id', 'N/A'),
                        ),
                      ),
                      _detailRow(
                        'Name',
                        _value(report, 'user_name', 'User name not available'),
                      ),
                      _detailRow(
                        'Email',
                        _value(report, 'user_email', 'Email not available'),
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  // -------------------------------------------------
                  // LOCATION
                  // -------------------------------------------------
                  _detailsSection(
                    title: 'Location',
                    icon: Icons.location_on_outlined,
                    children: [
                      _detailRow('Address', address),
                      if (hasCoordinates) _detailRow('Latitude', latitude),
                      if (hasCoordinates) _detailRow('Longitude', longitude),
                    ],
                  ),

                  const SizedBox(height: 20),

                  // -------------------------------------------------
                  // CLOSE
                  // -------------------------------------------------
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton.icon(
                      onPressed: () {
                        Navigator.pop(dialogContext);
                      },
                      icon: const Icon(Icons.check),
                      label: const Text(
                        'Close',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Theme.of(context).colorScheme.primary,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  // =========================================================
  // REPORT IMAGE
  // =========================================================

  Widget _buildReportImage(String imagePath) {
    return GestureDetector(
      onTap: () {
        _showFullScreenImage(imagePath);
      },
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Stack(
          alignment: Alignment.bottomRight,
          children: [
            if (kIsWeb)
              Image.network(
                imagePath,
                width: double.infinity,
                height: 240,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return _photoError();
                },
                loadingBuilder: (context, child, loadingProgress) {
                  if (loadingProgress == null) {
                    return child;
                  }

                  return Container(
                    width: double.infinity,
                    height: 240,
                    alignment: Alignment.center,
                    color: Colors.grey.shade100,
                    child: const CircularProgressIndicator(),
                  );
                },
              )
            else
              _buildLocalImage(imagePath),

            Container(
              margin: const EdgeInsets.all(10),
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.65),
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.zoom_in, color: Colors.white, size: 17),
                  SizedBox(width: 5),
                  Text(
                    'Tap to zoom',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                    ),
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
  // LOCAL IMAGE
  // =========================================================

  Widget _buildLocalImage(String imagePath) {
    try {
      final File imageFile = File(imagePath);

      if (!imageFile.existsSync()) {
        return _photoError();
      }

      return Image.file(
        imageFile,
        width: double.infinity,
        height: 240,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return _photoError();
        },
      );
    } catch (e) {
      debugPrint('Local report image error: $e');

      return _photoError();
    }
  }

  // =========================================================
  // FULL SCREEN IMAGE
  // =========================================================

  void _showFullScreenImage(String imagePath) {
    showDialog(
      context: context,
      builder: (dialogContext) {
        return Dialog(
          backgroundColor: Colors.black,
          insetPadding: EdgeInsets.zero,
          child: Stack(
            children: [
              Center(
                child: InteractiveViewer(
                  minScale: 0.5,
                  maxScale: 5,
                  child: kIsWeb
                      ? Image.network(
                          imagePath,
                          errorBuilder: (context, error, stackTrace) {
                            return _photoError(dark: true);
                          },
                        )
                      : _buildFullScreenLocalImage(imagePath),
                ),
              ),

              Positioned(
                top: 15,
                right: 15,
                child: IconButton(
                  onPressed: () {
                    Navigator.pop(dialogContext);
                  },
                  style: IconButton.styleFrom(
                    backgroundColor: Colors.black.withValues(alpha: 0.65),
                  ),
                  icon: const Icon(Icons.close, color: Colors.white),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // =========================================================
  // FULL SCREEN LOCAL IMAGE
  // =========================================================

  Widget _buildFullScreenLocalImage(String imagePath) {
    try {
      final File imageFile = File(imagePath);

      if (!imageFile.existsSync()) {
        return _photoError(dark: true);
      }

      return Image.file(imageFile, fit: BoxFit.contain);
    } catch (e) {
      return _photoError(dark: true);
    }
  }

  // =========================================================
  // PHOTO ERROR
  // =========================================================

  Widget _photoError({bool dark = false}) {
    return Container(
      width: double.infinity,
      height: 240,
      decoration: BoxDecoration(
        color: dark ? Colors.grey.shade900 : Colors.grey.shade100,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.image_not_supported_outlined,
            size: 45,
            color: dark ? Colors.white70 : Colors.grey,
          ),
          const SizedBox(height: 8),
          Text(
            'Report image not available',
            style: TextStyle(color: dark ? Colors.white70 : Colors.grey),
          ),
        ],
      ),
    );
  }

  // =========================================================
  // DETAILS SECTION
  // =========================================================

  Widget _detailsSection({
    required String title,
    required IconData icon,
    required List<Widget> children,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest
            .withValues(alpha: 0.35),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                icon,
                size: 21,
                color: Theme.of(context).colorScheme.primary,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ...children,
        ],
      ),
    );
  }

  // =========================================================
  // DETAIL ROW
  // =========================================================

  Widget _detailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 105,
            child: Text(
              label,
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
                fontWeight: FontWeight.w600,
                fontSize: 13,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
    );
  }

  // =========================================================
  // FEEDBACK RATING
  // =========================================================

  int _feedbackRating(Map<String, dynamic> feedback) {
    final dynamic value = feedback['rating'];

    if (value is int) {
      return value;
    }

    return int.tryParse(value?.toString() ?? '') ?? 0;
  }

  // =========================================================
  // FEEDBACK DATE
  // =========================================================

  String _feedbackDate(Map<String, dynamic> feedback) {
    return _formatDate(
      feedback['feedback_created_at'] ?? feedback['created_at'],
    );
  }

  // =========================================================
  // FILTER DROPDOWN
  // =========================================================

  Widget _filterDropdown({
    required String label,
    required String value,
    required List<String> items,
    required IconData icon,
    required ValueChanged<String?> onChanged,
  }) {
    return DropdownButtonFormField<String>(
      initialValue: value,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, size: 20),
        filled: true,
        fillColor: Theme.of(context).cardColor,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: Theme.of(context).dividerColor),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 12,
          vertical: 10,
        ),
      ),
      items: items.map((item) {
        return DropdownMenuItem<String>(
          value: item,
          child: Text(item, overflow: TextOverflow.ellipsis),
        );
      }).toList(),
      onChanged: onChanged,
    );
  }

  // =========================================================
  // SEARCH SECTION
  // =========================================================

  Widget _buildSearchReportsSection() {
    final Color primary = Theme.of(context).colorScheme.primary;

    final Color textColor = Theme.of(context).colorScheme.onSurface;

    final Color secondaryText = Theme.of(context).colorScheme.onSurfaceVariant;

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 30),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Search Reports',
                      style: TextStyle(
                        fontSize: 23,
                        fontWeight: FontWeight.bold,
                        color: textColor,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      'Search and filter active road reports.',
                      style: TextStyle(color: secondaryText, fontSize: 13),
                    ),
                  ],
                ),
              ),
              IconButton(
                tooltip: 'Refresh',
                onPressed: _loadDashboardData,
                icon: const Icon(Icons.refresh),
              ),
            ],
          ),

          const SizedBox(height: 18),

          // SEARCH BAR
          TextField(
            controller: _searchController,
            onChanged: (value) {
              setState(() {});
            },
            decoration: InputDecoration(
              hintText: 'Search by title, ID, user, email, address...',
              prefixIcon: const Icon(Icons.search),
              suffixIcon: _searchController.text.isNotEmpty
                  ? IconButton(
                      tooltip: 'Clear search',
                      onPressed: () {
                        _searchController.clear();

                        setState(() {});
                      },
                      icon: const Icon(Icons.clear),
                    )
                  : null,
              filled: true,
              fillColor: Theme.of(context).cardColor,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(15),
                borderSide: BorderSide.none,
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(15),
                borderSide: BorderSide(color: Theme.of(context).dividerColor),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(15),
                borderSide: BorderSide(color: primary, width: 1.5),
              ),
            ),
          ),

          const SizedBox(height: 14),

          // FILTERS
          LayoutBuilder(
            builder: (context, constraints) {
              final bool isWide = constraints.maxWidth >= 650;

              final Widget statusFilter = _filterDropdown(
                label: 'Status',
                value: _selectedStatusFilter,
                items: const [
                  'All',
                  'Pending',
                  'In Progress',
                  'Resolved',
                  'Rejected',
                ],
                icon: Icons.filter_alt_outlined,
                onChanged: (value) {
                  setState(() {
                    _selectedStatusFilter = value ?? 'All';
                  });
                },
              );

              final Widget severityFilter = _filterDropdown(
                label: 'Severity',
                value: _selectedSeverityFilter,
                items: const ['All', 'Critical', 'High', 'Medium', 'Low'],
                icon: Icons.warning_amber_outlined,
                onChanged: (value) {
                  setState(() {
                    _selectedSeverityFilter = value ?? 'All';
                  });
                },
              );

              final Widget sortDropdown = _filterDropdown(
                label: 'Sort',
                value: _selectedSort,
                items: const [
                  'Newest First',
                  'Oldest First',
                  'Severity: Critical → Low',
                  'Severity: Low → Critical',
                ],
                icon: Icons.swap_vert,
                onChanged: (value) {
                  setState(() {
                    _selectedSort = value ?? 'Newest First';
                  });
                },
              );

              if (isWide) {
                return Row(
                  children: [
                    Expanded(child: statusFilter),
                    const SizedBox(width: 10),
                    Expanded(child: severityFilter),
                    const SizedBox(width: 10),
                    Expanded(child: sortDropdown),
                  ],
                );
              }

              return Column(
                children: [
                  statusFilter,
                  const SizedBox(height: 10),
                  severityFilter,
                  const SizedBox(height: 10),
                  sortDropdown,
                ],
              );
            },
          ),

          const SizedBox(height: 14),

          // RESULT COUNT
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${_filteredReports.length} '
                '${_filteredReports.length == 1 ? 'report' : 'reports'} found',
                style: TextStyle(
                  color: secondaryText,
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
              ),
              if (_hasActiveFilters)
                TextButton.icon(
                  onPressed: _clearFilters,
                  icon: const Icon(Icons.clear_all, size: 18),
                  label: const Text('Clear Filters'),
                ),
            ],
          ),

          const SizedBox(height: 10),

          if (_reports.isEmpty)
            _emptyReports()
          else if (_filteredReports.isEmpty)
            _emptyFilteredReports()
          else
            ..._filteredReports.map(
              (report) =>
                  _reportCard(report, textColor, secondaryText, primary),
            ),
        ],
      ),
    );
  }

  // =========================================================
  // FEEDBACK SECTION
  // =========================================================

  Widget _buildFeedbackSection() {
    final Color primary = Theme.of(context).colorScheme.primary;

    final Color secondaryText = Theme.of(context).colorScheme.onSurfaceVariant;

    final Color textColor = Theme.of(context).colorScheme.onSurface;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(
                'User Feedback',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: textColor,
                ),
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
              decoration: BoxDecoration(
                color: Colors.amber.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.star, color: Colors.amber, size: 18),
                  const SizedBox(width: 5),
                  Text(
                    _feedback.isEmpty
                        ? '0.0'
                        : _averageRating.toStringAsFixed(1),
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.amber,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),

        const SizedBox(height: 6),

        Text(
          '${_feedback.length} '
          '${_feedback.length == 1 ? 'feedback' : 'feedbacks'} received',
          style: TextStyle(color: secondaryText, fontSize: 13),
        ),

        const SizedBox(height: 14),

        if (_feedback.isEmpty)
          _emptyFeedback()
        else
          ..._feedback.map(
            (feedback) =>
                _feedbackCard(feedback, primary, textColor, secondaryText),
          ),
      ],
    );
  }

  // =========================================================
  // FEEDBACK CARD
  // =========================================================

  Widget _feedbackCard(
    Map<String, dynamic> feedback,
    Color primary,
    Color textColor,
    Color secondaryText,
  ) {
    final int rating = _feedbackRating(feedback);

    final String userName = _value(
      feedback,
      'user_name',
      'User name not available',
    );

    final String userEmail = _value(
      feedback,
      'user_email',
      'Email not available',
    );

    final String reportTitle = _value(
      feedback,
      'report_title',
      'Report not available',
    );

    final String reportId = _value(feedback, 'report_id', 'N/A');

    final String comment = _value(feedback, 'comment', 'No comment provided.');

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 15),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.07),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 45,
                height: 45,
                decoration: BoxDecoration(
                  color: primary.withValues(alpha: 0.10),
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.person_outline, color: primary),
              ),

              const SizedBox(width: 12),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      userName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: textColor,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      userEmail,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(fontSize: 12, color: secondaryText),
                    ),
                  ],
                ),
              ),

              const SizedBox(width: 8),

              Container(
                padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.amber.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.star, color: Colors.amber, size: 17),
                    const SizedBox(width: 3),
                    Text(
                      '$rating/5',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.amber,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 15),

          Row(
            children: List.generate(5, (index) {
              return Icon(
                index < rating ? Icons.star : Icons.star_border,
                color: Colors.amber,
                size: 21,
              );
            }),
          ),

          const SizedBox(height: 13),

          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(13),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surfaceContainerHighest
                  .withValues(alpha: 0.35),
              borderRadius: BorderRadius.circular(13),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.format_quote_outlined, size: 21, color: primary),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    comment,
                    style: TextStyle(
                      color: textColor,
                      fontSize: 14,
                      height: 1.4,
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 13),

          Wrap(
            spacing: 15,
            runSpacing: 8,
            children: [
              _feedbackInfo(
                Icons.description_outlined,
                'Report #$reportId',
                primary,
              ),
              _feedbackInfo(Icons.route_outlined, reportTitle, secondaryText),
              _feedbackInfo(
                Icons.calendar_today_outlined,
                _feedbackDate(feedback),
                secondaryText,
              ),
            ],
          ),
        ],
      ),
    );
  }

  // =========================================================
  // FEEDBACK INFO
  // =========================================================

  Widget _feedbackInfo(IconData icon, String text, Color color) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 17, color: color),
        const SizedBox(width: 5),
        ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 300),
          child: Text(
            text,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
              fontSize: 12,
            ),
          ),
        ),
      ],
    );
  }

  // =========================================================
  // EMPTY FEEDBACK
  // =========================================================

  Widget _emptyFeedback() {
    final Color primary = Theme.of(context).colorScheme.primary;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(30),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          Icon(Icons.rate_review_outlined, size: 60, color: primary),
          const SizedBox(height: 15),
          const Text(
            'No Feedback Yet',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          const Text(
            'User feedback for resolved '
            'reports will appear here.',
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  // =========================================================
  // STATUS ANALYTICS
  // =========================================================

  Widget _buildStatusAnalyticsCard() {
    final Color textColor = Theme.of(context).colorScheme.onSurface;

    final List<Map<String, dynamic>> statusData = [
      {
        'name': 'Pending',
        'count': _countStatus('Pending'),
        'color': Colors.blue,
      },
      {
        'name': 'In Progress',
        'count': _countStatus('In Progress'),
        'color': Colors.orange,
      },
      {
        'name': 'Resolved',
        'count': _countStatus('Resolved'),
        'color': Colors.green,
      },
      {
        'name': 'Rejected',
        'count': _countStatus('Rejected'),
        'color': Colors.red,
      },
    ];

    return _analyticsContainer(
      title: 'Report Status',
      icon: Icons.donut_large_outlined,
      child: Column(
        children: statusData.map((item) {
          final int count = item['count'] as int;

          final Color color = item['color'] as Color;

          final String name = item['name'] as String;

          final double percentage = _reports.isEmpty
              ? 0
              : count / _reports.length;

          return Padding(
            padding: const EdgeInsets.only(bottom: 15),
            child: Column(
              children: [
                Row(
                  children: [
                    Container(
                      width: 10,
                      height: 10,
                      decoration: BoxDecoration(
                        color: color,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        name,
                        style: TextStyle(
                          color: textColor,
                          fontWeight: FontWeight.w600,
                          fontSize: 13,
                        ),
                      ),
                    ),
                    Text(
                      '$count',
                      style: TextStyle(
                        color: textColor,
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 7),
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: LinearProgressIndicator(
                    value: percentage,
                    minHeight: 8,
                    backgroundColor: color.withValues(alpha: 0.10),
                    valueColor: AlwaysStoppedAnimation<Color>(color),
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  // =========================================================
  // SEVERITY ANALYTICS
  // =========================================================

  Widget _buildSeverityAnalyticsCard() {
    final Color textColor = Theme.of(context).colorScheme.onSurface;

    final List<Map<String, dynamic>> severityData = [
      {
        'name': 'Critical',
        'count': _countSeverity('Critical'),
        'color': Colors.red.shade700,
        'icon': Icons.dangerous_outlined,
      },
      {
        'name': 'High',
        'count': _countSeverity('High'),
        'color': Colors.orange.shade700,
        'icon': Icons.error_outline,
      },
      {
        'name': 'Medium',
        'count': _countSeverity('Medium'),
        'color': Colors.amber.shade700,
        'icon': Icons.warning_amber_outlined,
      },
      {
        'name': 'Low',
        'count': _countSeverity('Low'),
        'color': Colors.green,
        'icon': Icons.check_circle_outline,
      },
    ];

    return _analyticsContainer(
      title: 'Report Severity',
      icon: Icons.warning_amber_outlined,
      child: Column(
        children: severityData.map((item) {
          final int count = item['count'] as int;

          final Color color = item['color'] as Color;

          final String name = item['name'] as String;

          final IconData icon = item['icon'] as IconData;

          final double percentage = _reports.isEmpty
              ? 0
              : count / _reports.length;

          return Padding(
            padding: const EdgeInsets.only(bottom: 15),
            child: Column(
              children: [
                Row(
                  children: [
                    Icon(icon, size: 18, color: color),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        name,
                        style: TextStyle(
                          color: textColor,
                          fontWeight: FontWeight.w600,
                          fontSize: 13,
                        ),
                      ),
                    ),
                    Text(
                      '$count',
                      style: TextStyle(
                        color: textColor,
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 7),
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: LinearProgressIndicator(
                    value: percentage,
                    minHeight: 8,
                    backgroundColor: color.withValues(alpha: 0.10),
                    valueColor: AlwaysStoppedAnimation<Color>(color),
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  // =========================================================
  // ANALYTICS SECTION
  // =========================================================

  Widget _buildAnalyticsSection() {
    final Color textColor = Theme.of(context).colorScheme.onSurface;

    final Color secondaryText = Theme.of(context).colorScheme.onSurfaceVariant;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Analytics & Insights',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: textColor,
          ),
        ),

        const SizedBox(height: 6),

        Text(
          'Overview of road damage reports, status and severity.',
          style: TextStyle(color: secondaryText, fontSize: 13),
        ),

        const SizedBox(height: 16),

        // QUICK METRICS
        LayoutBuilder(
          builder: (context, constraints) {
            final int crossAxisCount = constraints.maxWidth >= 550 ? 3 : 1;

            return GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: 3,
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: crossAxisCount,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                mainAxisExtent: 105,
              ),
              itemBuilder: (context, index) {
                switch (index) {
                  case 0:
                    return _analyticsMetricCard(
                      title: 'Resolution Rate',
                      value: '${_resolutionRate.toStringAsFixed(1)}%',
                      icon: Icons.check_circle_outline,
                      iconColor: Colors.green,
                      subtitle: '${_countStatus('Resolved')} resolved reports',
                    );

                  case 1:
                    return _analyticsMetricCard(
                      title: 'Critical Reports',
                      value: '${_countSeverity('Critical')}',
                      icon: Icons.dangerous_outlined,
                      iconColor: Colors.red.shade700,
                      subtitle: 'Requires immediate attention',
                    );

                  default:
                    return _analyticsMetricCard(
                      title: 'Total Reports',
                      value: '${_reports.length}',
                      icon: Icons.analytics_outlined,
                      iconColor: Colors.blue,
                      subtitle: 'Active submitted reports',
                    );
                }
              },
            );
          },
        ),

        const SizedBox(height: 20),

        // STATUS + SEVERITY
        LayoutBuilder(
          builder: (context, constraints) {
            final bool isWide = constraints.maxWidth >= 750;

            final Widget statusCard = _buildStatusAnalyticsCard();

            final Widget severityCard = _buildSeverityAnalyticsCard();

            if (isWide) {
              return Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(child: statusCard),
                  const SizedBox(width: 14),
                  Expanded(child: severityCard),
                ],
              );
            }

            return Column(
              children: [statusCard, const SizedBox(height: 14), severityCard],
            );
          },
        ),
      ],
    );
  }

  // =========================================================
  // ANALYTICS METRIC CARD
  // =========================================================

  Widget _analyticsMetricCard({
    required String title,
    required String value,
    required IconData icon,
    required Color iconColor,
    required String subtitle,
  }) {
    final Color textColor = Theme.of(context).colorScheme.onSurface;

    final Color secondaryText = Theme.of(context).colorScheme.onSurfaceVariant;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 9,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              color: iconColor.withValues(alpha: 0.10),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: iconColor, size: 24),
          ),

          const SizedBox(width: 12),

          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  value,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: textColor,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: textColor,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  subtitle,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(fontSize: 10, color: secondaryText),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // =========================================================
  // ANALYTICS CONTAINER
  // =========================================================

  Widget _analyticsContainer({
    required String title,
    required IconData icon,
    required Widget child,
  }) {
    final Color primary = Theme.of(context).colorScheme.primary;

    final Color textColor = Theme.of(context).colorScheme.onSurface;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: primary.withValues(alpha: 0.10),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: primary, size: 20),
              ),
              const SizedBox(width: 10),
              Text(
                title,
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.bold,
                  color: textColor,
                ),
              ),
            ],
          ),

          const SizedBox(height: 18),

          child,
        ],
      ),
    );
  }

  // =========================================================
  // REPORT CARD
  // =========================================================

  Widget _reportCard(
    Map<String, dynamic> report,
    Color textColor,
    Color secondaryText,
    Color primary, {
    bool isArchived = false,
  }) {
    final String status = _value(report, 'status', 'Pending');

    final Color statusColor = _statusColor(status);

    final String severity = _value(report, 'severity', 'Low');

    final Color severityColor = _severityColor(severity);

    final String userName = _value(
      report,
      'user_name',
      'User name not available',
    );

    final String userEmail = _value(
      report,
      'user_email',
      'Email not available',
    );

    final String userId = _value(
      report,
      'reporter_id',
      _value(report, 'user_id', 'N/A'),
    );

    return GestureDetector(
      onTap: () {
        _showReportDetails(report);
      },
      child: Container(
        width: double.infinity,
        margin: const EdgeInsets.only(bottom: 15),
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(20),
          border: isArchived
              ? Border.all(color: Colors.grey.withValues(alpha: 0.25))
              : null,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.07),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // -------------------------------------------------
            // HEADER
            // -------------------------------------------------

            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '#${_value(report, 'id')}  '
                        '${_value(report, 'title')}',
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: textColor,
                        ),
                      ),

                      const SizedBox(height: 7),

                      Row(
                        children: [
                          Icon(
                            Icons.person_outline,
                            size: 17,
                            color: secondaryText,
                          ),
                          const SizedBox(width: 5),
                          Expanded(
                            child: Text(
                              'ID: $userId • '
                              '$userName',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                color: secondaryText,
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 3),

                      Row(
                        children: [
                          Icon(
                            Icons.email_outlined,
                            size: 16,
                            color: secondaryText,
                          ),
                          const SizedBox(width: 5),
                          Expanded(
                            child: Text(
                              userEmail,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                color: secondaryText,
                                fontSize: 12,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                const SizedBox(width: 8),

                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: statusColor.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    status,
                    style: TextStyle(
                      color: statusColor,
                      fontWeight: FontWeight.bold,
                      fontSize: 11,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),

            // -------------------------------------------------
            // SEVERITY BADGE
            // -------------------------------------------------
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 7),
              decoration: BoxDecoration(
                color: severityColor.withValues(alpha: 0.10),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: severityColor.withValues(alpha: 0.25),
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(_severityIcon(severity), size: 17, color: severityColor),
                  const SizedBox(width: 6),
                  Text(
                    'Severity: $severity',
                    style: TextStyle(
                      color: severityColor,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 14),

            // -------------------------------------------------
            // DESCRIPTION
            // -------------------------------------------------
            Text(
              _value(report, 'description'),
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(color: secondaryText, fontSize: 14, height: 1.4),
            ),

            const SizedBox(height: 13),

            // -------------------------------------------------
            // DETAILS
            // -------------------------------------------------
            Wrap(
              spacing: 16,
              runSpacing: 8,
              children: [
                _smallInfo(
                  Icons.category_outlined,
                  _value(report, 'damage_type'),
                  primary,
                ),

                _smallInfo(_severityIcon(severity), severity, severityColor),

                _smallInfo(
                  Icons.calendar_today_outlined,
                  _formatDate(report['created_at']),
                  secondaryText,
                ),
              ],
            ),

            const SizedBox(height: 14),

            Divider(color: Theme.of(context).dividerColor),

            const SizedBox(height: 8),

            // -------------------------------------------------
            // BUTTONS
            // -------------------------------------------------
            if (isArchived)
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () {
                    _unarchiveReport(report);
                  },
                  icon: const Icon(Icons.unarchive_outlined, size: 18),
                  label: const Text(
                    'Unarchive Report',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  style: OutlinedButton.styleFrom(
                    minimumSize: const Size(0, 45),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(11),
                    ),
                  ),
                ),
              )
            else
              LayoutBuilder(
                builder: (context, constraints) {
                  if (constraints.maxWidth < 500) {
                    return Column(
                      children: [
                        SizedBox(
                          width: double.infinity,
                          child: OutlinedButton.icon(
                            onPressed: () {
                              _showReportDetails(report);
                            },
                            icon: const Icon(
                              Icons.visibility_outlined,
                              size: 18,
                            ),
                            label: const Text(
                              'View Details',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ),
                        ),

                        const SizedBox(height: 8),

                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton.icon(
                            onPressed: () {
                              _showStatusDialog(report);
                            },
                            icon: const Icon(Icons.edit_outlined, size: 18),
                            label: const Text(
                              'Update Status',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: primary,
                              foregroundColor: Colors.white,
                            ),
                          ),
                        ),

                        const SizedBox(height: 8),

                        SizedBox(
                          width: double.infinity,
                          child: OutlinedButton.icon(
                            onPressed: () {
                              _confirmArchiveReport(report);
                            },
                            icon: const Icon(Icons.archive_outlined, size: 18),
                            label: const Text(
                              'Archive',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ),
                        ),
                      ],
                    );
                  }

                  return Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () {
                            _showReportDetails(report);
                          },
                          icon: const Icon(Icons.visibility_outlined, size: 18),
                          label: const Text(
                            'View Details',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),

                      const SizedBox(width: 8),

                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () {
                            _showStatusDialog(report);
                          },
                          icon: const Icon(Icons.edit_outlined, size: 18),
                          label: const Text(
                            'Update',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: primary,
                            foregroundColor: Colors.white,
                          ),
                        ),
                      ),

                      const SizedBox(width: 8),

                      IconButton(
                        tooltip: 'Archive Report',
                        onPressed: () {
                          _confirmArchiveReport(report);
                        },
                        icon: const Icon(Icons.archive_outlined),
                      ),
                    ],
                  );
                },
              ),

            const SizedBox(height: 4),

            Center(
              child: Text(
                isArchived
                    ? 'Archived report • Tap to view complete details'
                    : 'Tap report to view complete details',
                style: const TextStyle(fontSize: 10, color: Colors.grey),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // =========================================================
  // SMALL INFO
  // =========================================================

  Widget _smallInfo(IconData icon, String text, Color color) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 18, color: color),
        const SizedBox(width: 5),
        Text(
          text,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            color: Theme.of(context).colorScheme.onSurfaceVariant,
            fontSize: 12,
          ),
        ),
      ],
    );
  }

  // =========================================================
  // REPORT VIEW SECTION
  // =========================================================

  Widget _buildReportViewSection() {
    final Color textColor = Theme.of(context).colorScheme.onSurface;

    final Color secondaryText = Theme.of(context).colorScheme.onSurfaceVariant;

    final Color primary = Theme.of(context).colorScheme.primary;

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 30),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Report View',
            style: TextStyle(
              fontSize: 23,
              fontWeight: FontWeight.bold,
              color: textColor,
            ),
          ),

          const SizedBox(height: 5),

          Text(
            'View active and archived road reports.',
            style: TextStyle(color: secondaryText, fontSize: 13),
          ),

          const SizedBox(height: 22),

          // ACTIVE REPORTS
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Active Reports',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: textColor,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: primary.withValues(alpha: 0.10),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '${_reports.length}',
                  style: TextStyle(color: primary, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          if (_reports.isEmpty)
            _emptyReports()
          else
            ..._reports.map(
              (report) =>
                  _reportCard(report, textColor, secondaryText, primary),
            ),

          const SizedBox(height: 20),

          // ARCHIVED
          _buildArchivedReportsSection(),
        ],
      ),
    );
  }

  // =========================================================
  // ARCHIVED REPORTS
  // =========================================================

  Widget _buildArchivedReportsSection() {
    final Color textColor = Theme.of(context).colorScheme.onSurface;

    final Color secondaryText = Theme.of(context).colorScheme.onSurfaceVariant;

    final Color primary = Theme.of(context).colorScheme.primary;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Archived Reports',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: textColor,
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.grey.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                '${_archivedReports.length}',
                style: const TextStyle(
                  color: Colors.grey,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),

        const SizedBox(height: 12),

        if (_archivedReports.isEmpty)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(25),
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              borderRadius: BorderRadius.circular(18),
            ),
            child: Column(
              children: [
                Icon(
                  Icons.inventory_2_outlined,
                  size: 50,
                  color: Colors.grey.shade500,
                ),
                const SizedBox(height: 10),
                const Text(
                  'No Archived Reports',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 5),
                Text(
                  'Archived reports will appear here.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: secondaryText),
                ),
              ],
            ),
          )
        else
          ..._archivedReports.map(
            (report) => _reportCard(
              report,
              textColor,
              secondaryText,
              primary,
              isArchived: true,
            ),
          ),
      ],
    );
  }

  // =========================================================
  // STATUS PAGE
  // =========================================================

  Widget _buildStatusPage() {
    final Color textColor = Theme.of(context).colorScheme.onSurface;

    final Color secondaryText = Theme.of(context).colorScheme.onSurfaceVariant;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Report Status',
            style: TextStyle(
              fontSize: 23,
              fontWeight: FontWeight.bold,
              color: textColor,
            ),
          ),

          const SizedBox(height: 5),

          Text(
            'Status-wise analysis of active reports.',
            style: TextStyle(color: secondaryText, fontSize: 13),
          ),

          const SizedBox(height: 20),

          _buildStatusAnalyticsCard(),

          const SizedBox(height: 20),

          _statusSummaryCard(
            'Pending',
            _countStatus('Pending'),
            Colors.blue,
            Icons.pending_actions,
          ),

          _statusSummaryCard(
            'In Progress',
            _countStatus('In Progress'),
            Colors.orange,
            Icons.hourglass_top,
          ),

          _statusSummaryCard(
            'Resolved',
            _countStatus('Resolved'),
            Colors.green,
            Icons.check_circle_outline,
          ),

          _statusSummaryCard(
            'Rejected',
            _countStatus('Rejected'),
            Colors.red,
            Icons.cancel_outlined,
          ),
        ],
      ),
    );
  }

  // =========================================================
  // STATUS SUMMARY
  // =========================================================

  Widget _statusSummaryCard(
    String title,
    int count,
    Color color,
    IconData icon,
  ) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 45,
            height: 45,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.10),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color),
          ),

          const SizedBox(width: 12),

          Expanded(
            child: Text(
              title,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
          ),

          Text(
            '$count',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  // =========================================================
  // SEVERITY PAGE
  // =========================================================

  Widget _buildSeverityPage() {
    final Color textColor = Theme.of(context).colorScheme.onSurface;

    final Color secondaryText = Theme.of(context).colorScheme.onSurfaceVariant;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Report Severity',
            style: TextStyle(
              fontSize: 23,
              fontWeight: FontWeight.bold,
              color: textColor,
            ),
          ),

          const SizedBox(height: 5),

          Text(
            'Severity-wise analysis of active reports.',
            style: TextStyle(color: secondaryText, fontSize: 13),
          ),

          const SizedBox(height: 20),

          _buildSeverityAnalyticsCard(),

          const SizedBox(height: 20),

          _severitySummaryCard(
            'Critical',
            _countSeverity('Critical'),
            Colors.red.shade700,
            Icons.dangerous_outlined,
          ),

          _severitySummaryCard(
            'High',
            _countSeverity('High'),
            Colors.orange.shade700,
            Icons.error_outline,
          ),

          _severitySummaryCard(
            'Medium',
            _countSeverity('Medium'),
            Colors.amber.shade700,
            Icons.warning_amber_outlined,
          ),

          _severitySummaryCard(
            'Low',
            _countSeverity('Low'),
            Colors.green,
            Icons.check_circle_outline,
          ),
        ],
      ),
    );
  }

  // =========================================================
  // SEVERITY SUMMARY
  // =========================================================

  Widget _severitySummaryCard(
    String title,
    int count,
    Color color,
    IconData icon,
  ) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 45,
            height: 45,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.10),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color),
          ),

          const SizedBox(width: 12),

          Expanded(
            child: Text(
              title,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
          ),

          Text(
            '$count',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  // =========================================================
  // DASHBOARD SECTION CARD
  // =========================================================

  Widget _dashboardSectionCard({
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    final Color textColor = Theme.of(context).colorScheme.onSurface;

    final Color secondaryText = Theme.of(context).colorScheme.onSurfaceVariant;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: onTap,
        child: Container(
          width: double.infinity,
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(18),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 9,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.10),
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Icon(icon, color: color, size: 25),
              ),

              const SizedBox(width: 14),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: textColor,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(fontSize: 12, color: secondaryText),
                    ),
                  ],
                ),
              ),

              Icon(
                Icons.arrow_forward_ios_rounded,
                size: 17,
                color: secondaryText,
              ),
            ],
          ),
        ),
      ),
    );
  }

  // =========================================================
  // OPEN SECTION PAGE
  // =========================================================

  void _openSectionPage({required String title, required Widget child}) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => Scaffold(
          appBar: AppBar(
            title: Text(
              title,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          body: SafeArea(child: child),
        ),
      ),
    ).then((_) {
      if (mounted) {
        setState(() {});
      }
    });
  }

  // =========================================================
  // OPEN SEARCH
  // =========================================================

  void _openSearchReports() {
    _openSectionPage(
      title: 'Search Reports',
      child: _buildSearchReportsSection(),
    );
  }

  // =========================================================
  // OPEN FEEDBACK
  // =========================================================

  void _openFeedbackSection() {
    _openSectionPage(
      title: 'Feedback',
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: _buildFeedbackSection(),
      ),
    );
  }

  // =========================================================
  // OPEN STATUS
  // =========================================================

  void _openStatusSection() {
    _openSectionPage(title: 'Report Status', child: _buildStatusPage());
  }

  // =========================================================
  // OPEN SEVERITY
  // =========================================================

  void _openSeveritySection() {
    _openSectionPage(title: 'Report Severity', child: _buildSeverityPage());
  }

  // =========================================================
  // OPEN REPORT VIEW
  // =========================================================

  void _openReportView() {
    _openSectionPage(title: 'Report View', child: _buildReportViewSection());
  }

  // =========================================================
  // EMPTY REPORTS
  // =========================================================

  Widget _emptyReports() {
    final Color primary = Theme.of(context).colorScheme.primary;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(30),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          Icon(Icons.assignment_outlined, size: 60, color: primary),

          const SizedBox(height: 15),

          const Text(
            'No Reports Found',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),

          const SizedBox(height: 8),

          const Text(
            'User submitted reports '
            'will appear here.',
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  // =========================================================
  // EMPTY FILTERED REPORTS
  // =========================================================

  Widget _emptyFilteredReports() {
    final Color primary = Theme.of(context).colorScheme.primary;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(30),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          Icon(Icons.search_off_outlined, size: 60, color: primary),

          const SizedBox(height: 15),

          const Text(
            'No Matching Reports',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),

          const SizedBox(height: 8),

          const Text(
            'No reports match your '
            'search or selected filters.',
            textAlign: TextAlign.center,
          ),

          const SizedBox(height: 15),

          OutlinedButton.icon(
            onPressed: _clearFilters,
            icon: const Icon(Icons.clear_all),
            label: const Text('Clear Filters'),
          ),
        ],
      ),
    );
  }

  // =========================================================
  // PROFILE DIALOG
  // =========================================================

  void _showAdminProfile() {
    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text(
            'Admin Profile',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircleAvatar(
                radius: 38,
                backgroundColor: Theme.of(context).colorScheme.primary
                    .withValues(alpha: 0.12),
                child: Icon(
                  Icons.admin_panel_settings_outlined,
                  size: 42,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),

              const SizedBox(height: 15),

              Text(
                widget.adminName,
                style: const TextStyle(
                  fontSize: 19,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 5),

              Text(
                'Admin ID: ${widget.adminId}',
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),

              const SizedBox(height: 10),

              const Text('RoadCare Administrator'),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext);
              },
              child: const Text('Close'),
            ),
          ],
        );
      },
    );
  }

  // =========================================================
  // LOGOUT
  // =========================================================

  void _logout() {
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const LoginScreen()),
      (route) => false,
    );
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
          content: Text(message),
          backgroundColor: isError
              ? Colors.red.shade700
              : Colors.green.shade700,
          behavior: SnackBarBehavior.floating,
        ),
      );
  }

  // =========================================================
  // MAIN DASHBOARD
  // =========================================================

  @override
  Widget build(BuildContext context) {
    final Color primary = Theme.of(context).colorScheme.primary;

    final Color textColor = Theme.of(context).colorScheme.onSurface;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Admin Dashboard',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          // PROFILE

          IconButton(
            tooltip: 'Admin Profile',
            onPressed: _showAdminProfile,
            icon: const Icon(Icons.account_circle_outlined),
          ),

          // REFRESH
          IconButton(
            tooltip: 'Refresh',
            onPressed: _loadDashboardData,
            icon: const Icon(Icons.refresh),
          ),

          // LOGOUT
          IconButton(
            tooltip: 'Logout',
            onPressed: _logout,
            icon: const Icon(Icons.logout),
          ),

          const SizedBox(width: 8),
        ],
      ),

      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                RoadCarePhotoHeader(
                  imageAsset: 'assets/images/city-operations.jpg',
                  eyebrow: 'RoadCare operations',
                  title: 'Good day, ${widget.adminName}.',
                  description: 'Review reports, monitor repairs and coordinate safer streets.',
                  height: 250,
                ),
                Expanded(
                  child: RefreshIndicator(
                    onRefresh: _loadDashboardData,
                    child: SingleChildScrollView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      padding: const EdgeInsets.fromLTRB(20, 12, 20, 30),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // =================================================
                          // REPORT OVERVIEW
                          // =================================================

                          Text(
                            'Report Overview',
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: textColor,
                            ),
                          ),

                          const SizedBox(height: 14),

                          LayoutBuilder(
                            builder: (context, constraints) {
                              int crossAxisCount;

                              if (constraints.maxWidth >= 1000) {
                                crossAxisCount = 5;
                              } else if (constraints.maxWidth >= 650) {
                                crossAxisCount = 3;
                              } else {
                                crossAxisCount = 2;
                              }

                              return GridView.builder(
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                itemCount: 5,
                                gridDelegate:
                                    SliverGridDelegateWithFixedCrossAxisCount(
                                      crossAxisCount: crossAxisCount,
                                      crossAxisSpacing: 12,
                                      mainAxisSpacing: 12,
                                      mainAxisExtent: 92,
                                    ),
                                itemBuilder: (context, index) {
                                  switch (index) {
                                    case 0:
                                      return _statCard(
                                        'Total Reports',
                                        _reports.length,
                                        Icons.description_outlined,
                                        Colors.blue,
                                      );

                                    case 1:
                                      return _statCard(
                                        'Pending',
                                        _countStatus('Pending'),
                                        Icons.pending_actions,
                                        Colors.blue,
                                      );

                                    case 2:
                                      return _statCard(
                                        'In Progress',
                                        _countStatus('In Progress'),
                                        Icons.hourglass_top,
                                        Colors.orange,
                                      );

                                    case 3:
                                      return _statCard(
                                        'Resolved',
                                        _countStatus('Resolved'),
                                        Icons.check_circle_outline,
                                        Colors.green,
                                      );

                                    default:
                                      return _statCard(
                                        'Rejected',
                                        _countStatus('Rejected'),
                                        Icons.cancel_outlined,
                                        Colors.red,
                                      );
                                  }
                                },
                              );
                            },
                          ),

                          const SizedBox(height: 28),

                          // =================================================
                          // ANALYTICS
                          // =================================================
                          _buildAnalyticsSection(),

                          const SizedBox(height: 32),

                          // =================================================
                          // DASHBOARD SECTIONS
                          // =================================================
                          Text(
                            'Dashboard Sections',
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: textColor,
                            ),
                          ),

                          const SizedBox(height: 6),

                          Text(
                            'Open each section separately to manage and analyse reports.',
                            style: TextStyle(
                              color: Theme.of(context)
                                  .colorScheme
                                  .onSurfaceVariant,
                              fontSize: 13,
                            ),
                          ),

                          const SizedBox(height: 16),

                          // SEARCH
                          _dashboardSectionCard(
                            title: 'Search Reports',
                            subtitle: 'Search, filter and sort active reports.',
                            icon: Icons.search,
                            color: Colors.blue,
                            onTap: _openSearchReports,
                          ),

                          // FEEDBACK
                          _dashboardSectionCard(
                            title: 'Feedback',
                            subtitle:
                                'View ratings and feedback submitted by users.',
                            icon: Icons.rate_review_outlined,
                            color: Colors.amber.shade700,
                            onTap: _openFeedbackSection,
                          ),

                          // STATUS
                          _dashboardSectionCard(
                            title: 'Report Status',
                            subtitle: 'Analyse Pending, In Progress, Resolved and Rejected reports.',
                            icon: Icons.donut_large_outlined,
                            color: Colors.orange,
                            onTap: _openStatusSection,
                          ),

                          // SEVERITY
                          _dashboardSectionCard(
                            title: 'Report Severity',
                            subtitle: 'Analyse Critical, High, Medium and Low reports.',
                            icon: Icons.warning_amber_outlined,
                            color: Colors.red,
                            onTap: _openSeveritySection,
                          ),

                          // REPORT VIEW
                          _dashboardSectionCard(
                            title: 'Report View',
                            subtitle: 'View active reports and manage archived reports.',
                            icon: Icons.view_list_outlined,
                            color: primary,
                            onTap: _openReportView,
                          ),

                          const SizedBox(height: 10),

                          // =================================================
                          // FOOTER
                          // =================================================
                          Center(
                            child: Text(
                              'RoadCare • Admin Management System',
                              style: TextStyle(
                                color: Theme.of(context)
                                    .colorScheme
                                    .onSurfaceVariant,
                                fontSize: 11,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
    );
  }

  // =========================================================
  // STAT CARD
  // =========================================================

  Widget _statCard(String title, int value, IconData icon, Color iconColor) {
    final Color textColor = Theme.of(context).colorScheme.onSurface;

    final Color cardColor = Theme.of(context).cardColor;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 10),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: iconColor.withValues(alpha: 0.10),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: iconColor, size: 22),
          ),

          const SizedBox(width: 9),

          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '$value',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: textColor,
                  ),
                ),

                const SizedBox(height: 2),

                Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 11,
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
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
  // DISPOSE
  // =========================================================

  @override
  void dispose() {
    _searchController.dispose();

    super.dispose();
  }
}
