import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

import '../../models/road_report.dart';
import '../report/report_details_screen.dart';

class ReportMapScreen extends StatefulWidget {
  final List<RoadReport> reports;

  const ReportMapScreen({super.key, required this.reports});

  @override
  State<ReportMapScreen> createState() => _ReportMapScreenState();
}

class _ReportMapScreenState extends State<ReportMapScreen> {
  final MapController _mapController = MapController();

  String _selectedStatus = 'All';

  List<RoadReport> get _filteredReports {
    if (_selectedStatus == 'All') {
      return widget.reports
          .where(
            (report) => report.latitude != null && report.longitude != null,
          )
          .toList();
    }

    return widget.reports
        .where(
          (report) =>
              report.latitude != null &&
              report.longitude != null &&
              report.status.toLowerCase() == _selectedStatus.toLowerCase(),
        )
        .toList();
  }

  LatLng get _initialCenter {
    final reports = _filteredReports;

    if (reports.isNotEmpty) {
      return LatLng(reports.first.latitude!, reports.first.longitude!);
    }

    return const LatLng(17.3850, 78.4867);
  }

  double get _initialZoom {
    return _filteredReports.isEmpty ? 12 : 13;
  }

  Color _statusColor(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return Colors.orange;

      case 'in progress':
        return Colors.blue;

      case 'resolved':
        return Colors.green;

      case 'rejected':
        return Colors.red;

      default:
        return Colors.grey;
    }
  }

  IconData _statusIcon(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return Icons.pending_actions;

      case 'in progress':
        return Icons.autorenew;

      case 'resolved':
        return Icons.check_circle;

      case 'rejected':
        return Icons.cancel;

      default:
        return Icons.location_on;
    }
  }

  void _focusReport(RoadReport report) {
    if (report.latitude == null || report.longitude == null) {
      return;
    }

    _mapController.move(LatLng(report.latitude!, report.longitude!), 16);
  }

  void _openReportDetails(RoadReport report) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => ReportDetailsScreen(report: report)),
    );
  }

  Widget _buildFilterBar() {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    const statuses = ['All', 'Pending', 'In Progress', 'Resolved', 'Rejected'];

    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: theme.brightness == Brightness.dark
            ? null
            : [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.08),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: statuses.map((status) {
            final bool selected = _selectedStatus == status;

            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: ChoiceChip(
                label: Text(status),
                selected: selected,
                onSelected: (_) {
                  setState(() {
                    _selectedStatus = status;
                  });

                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    if (_filteredReports.isNotEmpty) {
                      _focusReport(_filteredReports.first);
                    }
                  });
                },
                selectedColor: colorScheme.primary,
                labelStyle: TextStyle(
                  color: selected ? Colors.white : colorScheme.onSurface,
                  fontWeight: FontWeight.w600,
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildMapMarker(RoadReport report) {
    final color = _statusColor(report.status);

    return GestureDetector(
      onTap: () {
        _showReportBottomSheet(report);
      },
      child: Icon(
        Icons.location_on,
        size: 46,
        color: color,
        shadows: const [
          Shadow(color: Colors.black26, blurRadius: 4, offset: Offset(0, 2)),
        ],
      ),
    );
  }

  void _showReportBottomSheet(RoadReport report) {
    final color = _statusColor(report.status);
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: theme.cardColor,
      builder: (context) {
        return Container(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
          decoration: BoxDecoration(
            color: theme.cardColor,
            borderRadius: BorderRadius.vertical(top: Radius.circular(26)),
          ),
          child: SafeArea(
            top: false,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 45,
                    height: 5,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),

                const SizedBox(height: 18),

                Row(
                  children: [
                    CircleAvatar(
                      backgroundColor: color.withValues(alpha: 0.12),
                      child: Icon(_statusIcon(report.status), color: color),
                    ),

                    const SizedBox(width: 12),

                    Expanded(
                      child: Text(
                        report.title,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: colorScheme.onSurface,
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: colorScheme.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _infoRow(
                        Icons.flag_outlined,
                        'Status',
                        report.status,
                        color,
                      ),

                      const SizedBox(height: 10),

                      _infoRow(
                        Icons.warning_amber_outlined,
                        'Severity',
                        report.severity,
                        null,
                      ),

                      const SizedBox(height: 10),

                      _infoRow(
                        Icons.location_on_outlined,
                        'Location',
                        report.address ?? 'Location available',
                        null,
                      ),

                      const SizedBox(height: 10),

                      _infoRow(
                        Icons.my_location_outlined,
                        'Coordinates',
                        '${report.latitude!.toStringAsFixed(6)}, '
                            '${report.longitude!.toStringAsFixed(6)}',
                        null,
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 18),

                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Navigator.pop(context);
                      _openReportDetails(report);
                    },
                    icon: const Icon(Icons.visibility_outlined),
                    label: const Text(
                      'View Report Details',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: colorScheme.primary,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(13),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _infoRow(
    IconData icon,
    String label,
    String value,
    Color? valueColor,
  ) {
    final colorScheme = Theme.of(context).colorScheme;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 20, color: colorScheme.primary),

        const SizedBox(width: 10),

        Expanded(
          child: RichText(
            text: TextSpan(
              children: [
                TextSpan(
                  text: '$label: ',
                  style: TextStyle(
                    color: colorScheme.onSurface,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                TextSpan(
                  text: value,
                  style: TextStyle(
                    color: valueColor ?? colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMapLegend() {
    final theme = Theme.of(context);

    return Positioned(
      left: 16,
      bottom: 20,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: theme.cardColor,
          borderRadius: BorderRadius.circular(14),
          boxShadow: theme.brightness == Brightness.dark
              ? null
              : [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.12),
                    blurRadius: 10,
                    offset: const Offset(0, 3),
                  ),
                ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Map Legend',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
            ),

            const SizedBox(height: 8),

            _legendItem(Colors.orange, 'Pending'),

            _legendItem(Colors.blue, 'In Progress'),

            _legendItem(Colors.green, 'Resolved'),

            _legendItem(Colors.red, 'Rejected'),
          ],
        ),
      ),
    );
  }

  Widget _legendItem(Color color, String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.location_on, size: 18, color: color),
          const SizedBox(width: 5),
          Text(text),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final bool isDark = theme.brightness == Brightness.dark;
    final reports = _filteredReports;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,

      appBar: AppBar(
        title: Text(
          'Report Map',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: colorScheme.onSurface,
          ),
        ),
        backgroundColor: theme.appBarTheme.backgroundColor,
        foregroundColor: colorScheme.onSurface,
        elevation: 0,
      ),

      body: Stack(
        children: [
          Column(
            children: [
              _buildFilterBar(),

              Expanded(
                child: reports.isEmpty
                    ? _buildEmptyState()
                    : FlutterMap(
                        mapController: _mapController,
                        options: MapOptions(
                          initialCenter: _initialCenter,
                          initialZoom: _initialZoom,
                          minZoom: 3,
                          maxZoom: 19,
                        ),
                        children: [
                          TileLayer(
                            urlTemplate: isDark
                                ? 'https://basemaps.cartocdn.com/dark_all/{z}/{x}/{y}{r}.png'
                                : 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                            userAgentPackageName: 'com.roadcare.app',
                          ),

                          MarkerLayer(
                            markers: reports.map((report) {
                              return Marker(
                                point: LatLng(
                                  report.latitude!,
                                  report.longitude!,
                                ),
                                width: 50,
                                height: 50,
                                child: _buildMapMarker(report),
                              );
                            }).toList(),
                          ),

                          RichAttributionWidget(
                            attributions: [
                              TextSourceAttribution(
                                'OpenStreetMap contributors',
                              ),
                              if (isDark) TextSourceAttribution('© CARTO'),
                            ],
                          ),
                        ],
                      ),
              ),
            ],
          ),

          _buildMapLegend(),

          Positioned(
            top: 85,
            right: 16,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: theme.cardColor,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.12),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Text(
                '${reports.length} '
                '${reports.length == 1 ? 'Report' : 'Reports'}',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: colorScheme.onSurface,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    final colorScheme = Theme.of(context).colorScheme;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(30),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.location_off_outlined,
              size: 80,
              color: colorScheme.outline,
            ),

            const SizedBox(height: 20),

            Text(
              'No Reports with Location',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: colorScheme.onSurface,
              ),
            ),

            const SizedBox(height: 8),

            Text(
              _selectedStatus == 'All'
                  ? 'Your reports with GPS coordinates will appear here.'
                  : 'No $_selectedStatus reports with GPS coordinates were found.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: colorScheme.onSurfaceVariant,
                fontSize: 14,
              ),
            ),

            const SizedBox(height: 20),

            if (_selectedStatus != 'All')
              OutlinedButton(
                onPressed: () {
                  setState(() {
                    _selectedStatus = 'All';
                  });
                },
                child: const Text('Show All Reports'),
              ),
          ],
        ),
      ),
    );
  }
}
