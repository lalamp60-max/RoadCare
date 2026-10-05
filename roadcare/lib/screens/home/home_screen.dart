import 'package:flutter/material.dart';

import '../../models/road_report.dart';
import '../../models/user.dart';

import '../../repositories/report_repository.dart';
import '../../repositories/user_repository.dart';

import '../../services/auth_service.dart';
import '../../services/session_manager.dart';

import '../auth/login_screen.dart';
import '../notification/notification_screen.dart';
import '../profile/profile_screen.dart';
import '../report/report_damage_screen.dart';
import '../report/report_details_screen.dart';
import '../settings/settings_screen.dart';
import '../map/report_map_screen.dart';
import '../../widgets/roadcare_photo_layout.dart';

class HomeScreen extends StatefulWidget {
  final int userId;
  final String userName;

  const HomeScreen({super.key, required this.userId, required this.userName});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // =========================================================
  // SERVICES / REPOSITORIES
  // =========================================================

  final AuthService _authService = AuthService();
  final ReportRepository _reportRepository = ReportRepository();
  final UserRepository _userRepository = UserRepository();

  // =========================================================
  // STATE
  // =========================================================

  int _selectedIndex = 0;

  List<RoadReport> _reports = [];

  bool _isLoadingReports = false;

  late String _currentUserName;

  // =========================================================
  // SEARCH / FILTER
  // =========================================================

  final TextEditingController _reportSearchController = TextEditingController();

  String _selectedReportStatus = 'All';

  // =========================================================
  // THEME COLORS
  // =========================================================

  Color get _backgroundColor => Theme.of(context).scaffoldBackgroundColor;

  Color get _cardColor => Theme.of(context).cardColor;

  Color get _textColor => Theme.of(context).colorScheme.onSurface;

  Color get _secondaryTextColor =>
      Theme.of(context).colorScheme.onSurfaceVariant;

  Color get _primaryColor => Theme.of(context).colorScheme.primary;

  Color get _iconBackgroundColor =>
      Theme.of(context).colorScheme.primaryContainer;

  bool get _isDarkMode => Theme.of(context).brightness == Brightness.dark;

  // =========================================================
  // FILTERED REPORTS
  // =========================================================

  List<RoadReport> get _filteredReports {
    final String query = _reportSearchController.text.trim().toLowerCase();

    final String selectedStatus = _selectedReportStatus.trim().toLowerCase();

    return _reports.where((report) {
      final String reportStatus = report.status.trim().toLowerCase();

      // -------------------------------
      // STATUS FILTER
      // -------------------------------

      final bool statusMatches =
          selectedStatus == 'all' || reportStatus == selectedStatus;

      if (!statusMatches) {
        return false;
      }

      // -------------------------------
      // SEARCH FILTER
      // -------------------------------

      if (query.isEmpty) {
        return true;
      }

      final String searchableText = [
        report.title,
        report.description,
        report.damageType,
        report.severity,
        report.status,
        report.address ?? '',
      ].join(' ').toLowerCase();

      return searchableText.contains(query);
    }).toList();
  }

  // =========================================================
  // CLEAR SEARCH / FILTER
  // =========================================================

  void _clearReportFilters() {
    _reportSearchController.clear();

    setState(() {
      _selectedReportStatus = 'All';
    });
  }

  // =========================================================
  // INIT
  // =========================================================

  @override
  void initState() {
    super.initState();

    _currentUserName = widget.userName;

    _reportSearchController.addListener(_onReportSearchChanged);

    _loadCurrentUser();
    _loadReports();
  }

  // =========================================================
  // SEARCH LISTENER
  // =========================================================

  void _onReportSearchChanged() {
    if (!mounted) return;

    setState(() {});
  }

  // =========================================================
  // DISPOSE
  // =========================================================

  @override
  void dispose() {
    _reportSearchController.removeListener(_onReportSearchChanged);

    _reportSearchController.dispose();

    super.dispose();
  }

  // =========================================================
  // LOAD CURRENT USER
  // =========================================================

  Future<void> _loadCurrentUser() async {
    try {
      final RoadUser? user = await _userRepository.getUserById(widget.userId);

      if (!mounted) return;

      if (user != null) {
        setState(() {
          _currentUserName = user.name;
        });

        await SessionManager.updateUserName(user.name);
      }
    } catch (e) {
      debugPrint('Load current user error: $e');
    }
  }

  // =========================================================
  // LOAD REPORTS
  // =========================================================

  Future<void> _loadReports() async {
    if (!mounted) return;

    setState(() {
      _isLoadingReports = true;
    });

    try {
      final List<RoadReport> reports = await _reportRepository.getReportsByUser(
        widget.userId,
      );

      if (!mounted) return;

      setState(() {
        _reports = reports;
        _isLoadingReports = false;
      });
    } catch (e) {
      debugPrint('Load reports error: $e');

      if (!mounted) return;

      setState(() {
        _isLoadingReports = false;
      });

      _showMessage('Unable to load reports.', isError: true);
    }
  }

  // =========================================================
  // OPEN NOTIFICATIONS
  // =========================================================

  void _openNotifications() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) =>
            NotificationScreen(userId: widget.userId, reports: _reports),
      ),
    );
  }

  // =========================================================
  // OPEN PROFILE
  // =========================================================

  Future<void> _openProfile() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) =>
            ProfileScreen(userId: widget.userId, userName: _currentUserName),
      ),
    );

    if (!mounted) return;

    await _loadCurrentUser();

    if (!mounted) return;

    if (result == true) {
      setState(() {
        _selectedIndex = 0;
      });
    }
  }

  // =========================================================
  // OPEN SETTINGS
  // =========================================================

  void _openSettings() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const SettingsScreen()),
    );
  }

  // =========================================================
  // OPEN REPORT DAMAGE
  // =========================================================

  Future<void> _openReportDamage() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ReportDamageScreen(userId: widget.userId),
      ),
    );

    if (!mounted) return;

    if (result == true) {
      await _loadReports();

      if (!mounted) return;

      setState(() {
        _selectedIndex = 0;
      });

      _showMessage('Report submitted successfully!');
    }
  }

  // =========================================================
  // OPEN REPORT MAP
  // =========================================================

  void _openReportMap() {
    final reportsWithLocation = _reports
        .where((report) => report.latitude != null && report.longitude != null)
        .toList();

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ReportMapScreen(reports: reportsWithLocation),
      ),
    );
  }

  // =========================================================
  // BUILD
  // =========================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _backgroundColor,

      // =======================================================
      // APP BAR
      // =======================================================
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
        surfaceTintColor: Colors.transparent,
        automaticallyImplyLeading: false,

        // ---------------------------------------------------
        // HOME BUTTON
        // ---------------------------------------------------
        leading: IconButton(
          tooltip: 'Home',
          icon: Icon(Icons.arrow_back, color: _textColor, size: 30),
          onPressed: () {
            setState(() {
              _selectedIndex = 0;
            });
          },
        ),

        // ---------------------------------------------------
        // ROADCARE TITLE
        // ---------------------------------------------------
        title: Row(
          children: [
            Icon(Icons.add_road, color: _primaryColor, size: 30),

            const SizedBox(width: 10),

            Text(
              'RoadCare',
              style: TextStyle(
                color: _primaryColor,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),

        // ===================================================
        // RIGHT SIDE ACTIONS
        // ===================================================
        actions: [
          // -------------------------------------------------
          // NOTIFICATIONS
          // -------------------------------------------------

          IconButton(
            tooltip: 'Notifications',
            onPressed: _openNotifications,
            icon: Stack(
              clipBehavior: Clip.none,
              children: [
                Icon(Icons.notifications_none, color: _textColor, size: 28),

                if (_reports.isNotEmpty)
                  Positioned(
                    right: -2,
                    top: -2,
                    child: Container(
                      width: 9,
                      height: 9,
                      decoration: const BoxDecoration(
                        color: Colors.red,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
              ],
            ),
          ),

          const SizedBox(width: 8),

          // -------------------------------------------------
          // PROFILE ICON
          // -------------------------------------------------
          Padding(
            padding: const EdgeInsets.only(right: 15),
            child: InkWell(
              borderRadius: BorderRadius.circular(30),
              onTap: _openProfile,
              child: CircleAvatar(
                radius: 22,
                backgroundColor: _iconBackgroundColor,
                child: Icon(Icons.person, color: _primaryColor, size: 25),
              ),
            ),
          ),
        ],
      ),

      // =======================================================
      // BODY
      // =======================================================
      body: _buildBody(),

      // =======================================================
      // BOTTOM NAVIGATION
      // =======================================================
      bottomNavigationBar: NavigationBar(
        backgroundColor: Theme.of(context).navigationBarTheme.backgroundColor,

        indicatorColor: _iconBackgroundColor,

        selectedIndex: _selectedIndex,

        onDestinationSelected: (index) async {
          setState(() {
            _selectedIndex = index;
          });

          // My Reports
          if (index == 1) {
            await _loadReports();
          }

          // Profile
          if (index == 2) {
            await _loadCurrentUser();
          }
        },

        destinations: [
          NavigationDestination(
            icon: Icon(Icons.home_outlined, color: _secondaryTextColor),
            selectedIcon: Icon(Icons.home, color: _primaryColor),
            label: 'Home',
          ),

          NavigationDestination(
            icon: Icon(Icons.report_outlined, color: _secondaryTextColor),
            selectedIcon: Icon(Icons.report, color: _primaryColor),
            label: 'My Reports',
          ),

          NavigationDestination(
            icon: Icon(Icons.person_outline, color: _secondaryTextColor),
            selectedIcon: Icon(Icons.person, color: _primaryColor),
            label: 'Profile',
          ),
        ],
      ),
    );
  }

  // =========================================================
  // BODY
  // =========================================================

  Widget _buildBody() {
    final Widget page = switch (_selectedIndex) {
      0 => _buildDashboard(),
      1 => _buildReports(),
      2 => _buildProfile(),
      _ => _buildDashboard(),
    };

    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 300),
      switchInCurve: Curves.easeOutCubic,
      switchOutCurve: Curves.easeInCubic,
      transitionBuilder: (child, animation) => FadeTransition(
        opacity: animation,
        child: SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(0, 0.025),
            end: Offset.zero,
          ).animate(animation),
          child: child,
        ),
      ),
      child: KeyedSubtree(key: ValueKey(_selectedIndex), child: page),
    );
  }

  // =========================================================
  // DASHBOARD
  // =========================================================

  Widget _buildDashboard() {
    final int totalReports = _reports.length;

    final int pendingReports = _reports
        .where((report) => report.status.toLowerCase() == 'pending')
        .length;

    final int inProgressReports = _reports
        .where((report) => report.status.toLowerCase() == 'in progress')
        .length;

    final int resolvedReports = _reports
        .where((report) => report.status.toLowerCase() == 'resolved')
        .length;

    final int rejectedReports = _reports
        .where((report) => report.status.toLowerCase() == 'rejected')
        .length;

    return Column(
      children: [
        RoadCarePhotoHeader(
          imageAsset: 'assets/images/city-operations.jpg',
          eyebrow: 'RoadCare community',
          title: 'Welcome, $_currentUserName.',
          description:
              'Report a hazard, share its location and follow the repair.',
          height: 270,
        ),
        Expanded(
          child: RefreshIndicator(
            onRefresh: _loadReports,
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // =================================================
                  // STATISTICS
                  // =================================================
                  Text(
                    'Your Activity',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: _textColor,
                    ),
                  ),

                  const SizedBox(height: 15),

                  LayoutBuilder(
                    builder: (context, constraints) {
                      final bool compact = constraints.maxWidth < 600;

                      final double cardWidth = compact
                          ? (constraints.maxWidth - 24) / 3
                          : (constraints.maxWidth - 48) / 4;

                      return Wrap(
                        spacing: 12,
                        runSpacing: 12,

                        children: [
                          SizedBox(
                            width: cardWidth,
                            child: _statCard(
                              icon: Icons.description_outlined,
                              title: 'Total',
                              value: '$totalReports',
                              iconColor: _primaryColor,
                            ),
                          ),

                          SizedBox(
                            width: cardWidth,
                            child: _statCard(
                              icon: Icons.pending_actions,
                              title: 'Pending',
                              value: '$pendingReports',
                              iconColor: Colors.orange,
                            ),
                          ),

                          SizedBox(
                            width: cardWidth,
                            child: _statCard(
                              icon: Icons.autorenew_rounded,
                              title: 'In Progress',
                              value: '$inProgressReports',
                              iconColor: Colors.deepOrange,
                            ),
                          ),

                          SizedBox(
                            width: cardWidth,
                            child: _statCard(
                              icon: Icons.check_circle_outline,
                              title: 'Resolved',
                              value: '$resolvedReports',
                              iconColor: Colors.green,
                            ),
                          ),

                          SizedBox(
                            width: cardWidth,
                            child: _statCard(
                              icon: Icons.cancel_outlined,
                              title: 'Rejected',
                              value: '$rejectedReports',
                              iconColor: Colors.red,
                            ),
                          ),
                        ],
                      );
                    },
                  ),

                  const SizedBox(height: 28),

                  // =================================================
                  // QUICK ACTIONS
                  // =================================================
                  Text(
                    'Quick Actions',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: _textColor,
                    ),
                  ),

                  const SizedBox(height: 15),

                  // =================================================
                  // RESPONSIVE QUICK ACTIONS
                  // =================================================
                  LayoutBuilder(
                    builder: (context, constraints) {
                      final bool compact = constraints.maxWidth < 700;

                      if (compact) {
                        return Column(
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: _actionCard(
                                    icon: Icons.add_a_photo_outlined,
                                    title: 'Report Damage',
                                    description:
                                        'Report a pothole or damaged road',
                                    onTap: _openReportDamage,
                                  ),
                                ),

                                const SizedBox(width: 15),

                                Expanded(
                                  child: _actionCard(
                                    icon: Icons.track_changes,
                                    title: 'Track Reports',
                                    description: 'Check your complaint status',
                                    onTap: () {
                                      setState(() {
                                        _selectedIndex = 1;
                                      });

                                      _loadReports();
                                    },
                                  ),
                                ),
                              ],
                            ),

                            const SizedBox(height: 15),

                            _actionCard(
                              icon: Icons.map_outlined,
                              title: 'View Map',
                              description: 'View your reported road locations',
                              onTap: _openReportMap,
                            ),
                          ],
                        );
                      }

                      return Row(
                        children: [
                          Expanded(
                            child: _actionCard(
                              icon: Icons.add_a_photo_outlined,
                              title: 'Report Damage',
                              description: 'Report a pothole or damaged road',
                              onTap: _openReportDamage,
                            ),
                          ),

                          const SizedBox(width: 15),

                          Expanded(
                            child: _actionCard(
                              icon: Icons.track_changes,
                              title: 'Track Reports',
                              description: 'Check your complaint status',
                              onTap: () {
                                setState(() {
                                  _selectedIndex = 1;
                                });

                                _loadReports();
                              },
                            ),
                          ),

                          const SizedBox(width: 15),

                          Expanded(
                            child: _actionCard(
                              icon: Icons.map_outlined,
                              title: 'View Map',
                              description: 'View your reported road locations',
                              onTap: _openReportMap,
                            ),
                          ),
                        ],
                      );
                    },
                  ),

                  const SizedBox(height: 28),

                  // =================================================
                  // ROADCARE SERVICES
                  // =================================================
                  Text(
                    'RoadCare Services',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: _textColor,
                    ),
                  ),

                  const SizedBox(height: 15),

                  _informationCard(
                    Icons.location_on_outlined,
                    'Report With Location',
                    'Add the exact location of the damaged road to help authorities identify the problem.',
                  ),

                  const SizedBox(height: 12),

                  _informationCard(
                    Icons.photo_camera_outlined,
                    'Add Photo Evidence',
                    'Upload photographs to provide clear evidence of the road damage.',
                  ),

                  const SizedBox(height: 12),

                  _informationCard(
                    Icons.notifications_active_outlined,
                    'Track Progress',
                    'Stay updated when the status of your report changes.',
                  ),

                  const SizedBox(height: 12),

                  // =================================================
                  // MAP SERVICE CARD
                  // =================================================
                  _informationCard(
                    Icons.map_outlined,
                    'View Reports on Map',
                    'See your reported road damage locations on an interactive map.',
                  ),

                  const SizedBox(height: 12),

                  _informationCard(
                    Icons.security_outlined,
                    'Safe & Simple',
                    'Your reports are stored securely in the RoadCare local database.',
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  // =========================================================
  // STAT CARD
  // =========================================================

  Widget _statCard({
    required IconData icon,
    required String title,
    required String value,
    required Color iconColor,
  }) {
    return Container(
      padding: const EdgeInsets.all(15),

      decoration: BoxDecoration(
        color: _cardColor,
        borderRadius: BorderRadius.circular(18),

        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: _isDarkMode ? 0.30 : 0.08),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),

      child: Column(
        children: [
          Icon(icon, color: iconColor, size: 28),

          const SizedBox(height: 8),

          Text(
            value,
            style: TextStyle(
              fontSize: 23,
              fontWeight: FontWeight.bold,
              color: _textColor,
            ),
          ),

          const SizedBox(height: 3),

          Text(
            title,
            style: TextStyle(fontSize: 12, color: _secondaryTextColor),
          ),
        ],
      ),
    );
  }

  // =========================================================
  // ACTION CARD
  // =========================================================

  Widget _actionCard({
    required IconData icon,
    required String title,
    required String description,
    required VoidCallback onTap,
  }) {
    return InkWell(
      borderRadius: BorderRadius.circular(20),
      onTap: onTap,

      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),

        decoration: BoxDecoration(
          color: _cardColor,
          borderRadius: BorderRadius.circular(20),

          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: _isDarkMode ? 0.30 : 0.08),
              blurRadius: 12,
              offset: const Offset(0, 5),
            ),
          ],
        ),

        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,

          children: [
            Container(
              padding: const EdgeInsets.all(12),

              decoration: BoxDecoration(
                color: _iconBackgroundColor,
                borderRadius: BorderRadius.circular(14),
              ),

              child: Icon(icon, color: _primaryColor, size: 30),
            ),

            const SizedBox(height: 15),

            Text(
              title,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 17,
                color: _textColor,
              ),
            ),

            const SizedBox(height: 6),

            Text(
              description,
              style: TextStyle(
                color: _secondaryTextColor,
                fontSize: 13,
                height: 1.4,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // =========================================================
  // INFORMATION CARD
  // =========================================================

  Widget _informationCard(IconData icon, String title, String description) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),

      decoration: BoxDecoration(
        color: _cardColor,
        borderRadius: BorderRadius.circular(18),

        border: Border.all(
          color: _isDarkMode ? Colors.white10 : Colors.blue.shade50,
        ),
      ),

      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),

            decoration: BoxDecoration(
              color: _iconBackgroundColor,
              borderRadius: BorderRadius.circular(13),
            ),

            child: Icon(icon, color: _primaryColor),
          ),

          const SizedBox(width: 15),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,

              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: _textColor,
                  ),
                ),

                const SizedBox(height: 5),

                Text(
                  description,
                  style: TextStyle(
                    color: _secondaryTextColor,
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
  // MY REPORTS
  // =========================================================

  Widget _buildReports() {
    final List<RoadReport> filteredReports = _filteredReports;

    const List<String> statusFilters = [
      'All',
      'Pending',
      'In Progress',
      'Resolved',
      'Rejected',
    ];

    return Column(
      children: [
        const RoadCarePhotoHeader(
          imageAsset: 'assets/images/road-repair.jpg',
          eyebrow: 'Your neighborhood, safer',
          title: 'My Reports',
          description:
              'Follow every reported road issue from review to repair.',
          height: 245,
        ),
        Expanded(
          child: RefreshIndicator(
            onRefresh: _loadReports,
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // =================================================
                  // TITLE
                  // =================================================

                  const SizedBox(height: 4),

                  // =================================================
                  // SEARCH BAR
                  // =================================================
                  Container(
                    decoration: BoxDecoration(
                      color: _cardColor,
                      borderRadius: BorderRadius.circular(16),

                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(
                            alpha: _isDarkMode ? 0.25 : 0.06,
                          ),
                          blurRadius: 8,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),

                    child: TextField(
                      controller: _reportSearchController,

                      style: TextStyle(color: _textColor),

                      decoration: InputDecoration(
                        hintText: 'Search reports...',

                        hintStyle: TextStyle(color: _secondaryTextColor),

                        prefixIcon: Icon(Icons.search, color: _primaryColor),

                        suffixIcon: _reportSearchController.text.isNotEmpty
                            ? IconButton(
                                tooltip: 'Clear search',
                                icon: Icon(
                                  Icons.clear,
                                  color: _secondaryTextColor,
                                ),
                                onPressed: () {
                                  _reportSearchController.clear();
                                },
                              )
                            : null,

                        filled: true,
                        fillColor: Colors.transparent,

                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: BorderSide.none,
                        ),

                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: BorderSide.none,
                        ),

                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: BorderSide(
                            color: _primaryColor,
                            width: 1.5,
                          ),
                        ),

                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 16,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 18),

                  // =================================================
                  // STATUS FILTER TITLE
                  // =================================================
                  Text(
                    'Filter by Status',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: _textColor,
                    ),
                  ),

                  const SizedBox(height: 10),

                  // =================================================
                  // STATUS FILTER CHIPS
                  // =================================================
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,

                    child: Row(
                      children: statusFilters.map((status) {
                        final bool isSelected = _selectedReportStatus == status;

                        return Padding(
                          padding: const EdgeInsets.only(right: 8),

                          child: ChoiceChip(
                            label: Text(status),

                            selected: isSelected,

                            onSelected: (selected) {
                              if (!selected) return;

                              setState(() {
                                _selectedReportStatus = status;
                              });
                            },

                            selectedColor: _iconBackgroundColor,

                            backgroundColor: _cardColor,

                            side: BorderSide(
                              color: isSelected
                                  ? _primaryColor
                                  : (_isDarkMode
                                        ? Colors.white12
                                        : Colors.black12),
                            ),

                            labelStyle: TextStyle(
                              color: isSelected
                                  ? _primaryColor
                                  : _secondaryTextColor,
                              fontWeight: isSelected
                                  ? FontWeight.bold
                                  : FontWeight.normal,
                            ),

                            checkmarkColor: _primaryColor,
                          ),
                        );
                      }).toList(),
                    ),
                  ),

                  const SizedBox(height: 20),

                  // =================================================
                  // LOADING
                  // =================================================
                  if (_isLoadingReports)
                    Center(
                      child: Padding(
                        padding: const EdgeInsets.all(40),
                        child: CircularProgressIndicator(color: _primaryColor),
                      ),
                    )
                  // =================================================
                  // NO REPORTS AT ALL
                  // =================================================
                  else if (_reports.isEmpty)
                    _buildEmptyReports()
                  // =================================================
                  // REPORTS AVAILABLE
                  // =================================================
                  else
                    Column(
                      children: [
                        // -------------------------------------------
                        // REPORT COUNT
                        // -------------------------------------------

                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(16),

                          decoration: BoxDecoration(
                            color: _iconBackgroundColor,
                            borderRadius: BorderRadius.circular(16),
                          ),

                          child: Row(
                            children: [
                              Icon(
                                Icons.assessment_outlined,
                                color: _primaryColor,
                              ),

                              const SizedBox(width: 10),

                              Expanded(
                                child: Text(
                                  '${filteredReports.length} report'
                                  '${filteredReports.length == 1 ? '' : 's'} found',

                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: _primaryColor,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 18),

                        // -------------------------------------------
                        // NO MATCHING REPORTS
                        // -------------------------------------------
                        if (filteredReports.isEmpty)
                          _buildNoMatchingReports()
                        // -------------------------------------------
                        // FILTERED REPORT CARDS
                        // -------------------------------------------
                        else
                          ...filteredReports.map(
                            (report) => _buildReportCard(report),
                          ),

                        const SizedBox(height: 5),

                        // -------------------------------------------
                        // CREATE NEW REPORT
                        // -------------------------------------------
                        SizedBox(
                          width: double.infinity,
                          height: 52,

                          child: ElevatedButton.icon(
                            onPressed: _openReportDamage,

                            icon: const Icon(Icons.add),

                            label: const Text(
                              'Create New Report',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),

                            style: ElevatedButton.styleFrom(
                              backgroundColor: _primaryColor,
                              foregroundColor: Colors.white,

                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  // =========================================================
  // NO MATCHING REPORTS
  // =========================================================

  Widget _buildNoMatchingReports() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(30),

      decoration: BoxDecoration(
        color: _cardColor,
        borderRadius: BorderRadius.circular(20),

        border: Border.all(
          color: _isDarkMode ? Colors.white10 : Colors.black12,
        ),
      ),

      child: Column(
        children: [
          Icon(Icons.search_off_rounded, size: 55, color: _secondaryTextColor),

          const SizedBox(height: 15),

          Text(
            'No Matching Reports',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: _textColor,
            ),
          ),

          const SizedBox(height: 8),

          Text(
            'Try another search or select a different status.',
            textAlign: TextAlign.center,
            style: TextStyle(color: _secondaryTextColor),
          ),

          const SizedBox(height: 18),

          OutlinedButton.icon(
            onPressed: _clearReportFilters,

            icon: const Icon(Icons.clear_all),

            label: const Text('Clear Filters'),

            style: OutlinedButton.styleFrom(
              foregroundColor: _primaryColor,

              side: BorderSide(color: _primaryColor),

              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // =========================================================
  // EMPTY REPORTS
  // =========================================================

  Widget _buildEmptyReports() {
    return Column(
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(30),

          decoration: BoxDecoration(
            color: _cardColor,
            borderRadius: BorderRadius.circular(20),
          ),

          child: Column(
            children: [
              Icon(
                Icons.description_outlined,
                size: 60,
                color: _isDarkMode
                    ? Colors.blue.shade300
                    : const Color(0xFF90CAF9),
              ),

              const SizedBox(height: 15),

              Text(
                'No Reports Yet',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: _textColor,
                ),
              ),

              const SizedBox(height: 8),

              Text(
                'Your submitted road damage reports will appear here.',
                textAlign: TextAlign.center,
                style: TextStyle(color: _secondaryTextColor),
              ),
            ],
          ),
        ),

        const SizedBox(height: 25),

        SizedBox(
          width: double.infinity,
          height: 52,

          child: ElevatedButton.icon(
            onPressed: _openReportDamage,

            icon: const Icon(Icons.add),

            label: const Text(
              'Create New Report',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),

            style: ElevatedButton.styleFrom(
              backgroundColor: _primaryColor,
              foregroundColor: Colors.white,

              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
          ),
        ),
      ],
    );
  }

  // =========================================================
  // REPORT CARD
  // =========================================================

  Widget _buildReportCard(RoadReport report) {
    Color statusColor;

    switch (report.status.toLowerCase()) {
      case 'resolved':
        statusColor = Colors.green;
        break;

      case 'in progress':
        statusColor = Colors.orange;
        break;

      case 'rejected':
        statusColor = Colors.red;
        break;

      case 'pending':
      default:
        statusColor = Colors.blue;
    }

    return InkWell(
      borderRadius: BorderRadius.circular(20),

      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => ReportDetailsScreen(report: report),
          ),
        );
      },

      child: Container(
        width: double.infinity,

        margin: const EdgeInsets.only(bottom: 15),

        padding: const EdgeInsets.all(18),

        decoration: BoxDecoration(
          color: _cardColor,
          borderRadius: BorderRadius.circular(20),

          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: _isDarkMode ? 0.30 : 0.08),
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
                  padding: const EdgeInsets.all(12),

                  decoration: BoxDecoration(
                    color: _iconBackgroundColor,
                    borderRadius: BorderRadius.circular(14),
                  ),

                  child: Icon(
                    Icons.report_problem_outlined,
                    color: _primaryColor,
                    size: 28,
                  ),
                ),

                const SizedBox(width: 14),

                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,

                    children: [
                      Text(
                        report.title,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: _textColor,
                        ),
                      ),

                      const SizedBox(height: 5),

                      Text(
                        report.damageType,
                        style: TextStyle(
                          color: _secondaryTextColor,
                          fontSize: 14,
                        ),
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
                    report.status,
                    style: TextStyle(
                      color: statusColor,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            Text(
              report.description,
              style: TextStyle(
                color: _secondaryTextColor,
                fontSize: 14,
                height: 1.4,
              ),
            ),

            const SizedBox(height: 15),

            Divider(color: _isDarkMode ? Colors.white12 : Colors.black12),

            const SizedBox(height: 8),

            Row(
              children: [
                Icon(
                  Icons.warning_amber_rounded,
                  size: 18,
                  color: _secondaryTextColor,
                ),

                const SizedBox(width: 6),

                Expanded(
                  child: Text(
                    'Severity: ${report.severity}',
                    style: TextStyle(color: _secondaryTextColor, fontSize: 13),
                  ),
                ),

                Icon(Icons.access_time, size: 17, color: _secondaryTextColor),

                const SizedBox(width: 5),

                Text(
                  _formatDate(report.createdAt),
                  style: TextStyle(color: _secondaryTextColor, fontSize: 13),
                ),
              ],
            ),

            if (report.address != null &&
                report.address!.trim().isNotEmpty) ...[
              const SizedBox(height: 12),

              Row(
                crossAxisAlignment: CrossAxisAlignment.start,

                children: [
                  Icon(
                    Icons.location_on_outlined,
                    size: 18,
                    color: _primaryColor,
                  ),

                  const SizedBox(width: 6),

                  Expanded(
                    child: Text(
                      report.address!,
                      style: TextStyle(
                        color: _secondaryTextColor,
                        fontSize: 13,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  // =========================================================
  // DATE FORMAT
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
  // PROFILE TAB
  // =========================================================

  Widget _buildProfile() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),

      child: Column(
        children: [
          const SizedBox(height: 20),

          CircleAvatar(
            radius: 45,
            backgroundColor: _iconBackgroundColor,

            child: Icon(Icons.person, size: 50, color: _primaryColor),
          ),

          const SizedBox(height: 15),

          Text(
            _currentUserName,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: _textColor,
            ),
          ),

          const SizedBox(height: 5),

          Text(
            'User ID: ${widget.userId}',
            style: TextStyle(color: _secondaryTextColor),
          ),

          const SizedBox(height: 30),

          // =================================================
          // PROFILE INFORMATION
          // =================================================
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),

            decoration: BoxDecoration(
              color: _cardColor,
              borderRadius: BorderRadius.circular(20),

              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(
                    alpha: _isDarkMode ? 0.30 : 0.08,
                  ),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),

            child: Column(
              children: [
                _profileInfoRow(Icons.person_outline, 'Name', _currentUserName),

                Divider(
                  height: 25,
                  color: _isDarkMode ? Colors.white12 : Colors.black12,
                ),

                _profileInfoRow(
                  Icons.badge_outlined,
                  'User ID',
                  '${widget.userId}',
                ),

                Divider(
                  height: 25,
                  color: _isDarkMode ? Colors.white12 : Colors.black12,
                ),

                _profileInfoRow(
                  Icons.description_outlined,
                  'My Reports',
                  '${_reports.length}',
                ),
              ],
            ),
          ),

          const SizedBox(height: 25),

          // =================================================
          // MY PROFILE
          // =================================================
          _profileOption(
            Icons.person_outline,
            'My Profile',
            'View and update your profile',
            onTap: _openProfile,
          ),

          // =================================================
          // NOTIFICATIONS
          // =================================================
          _profileOption(
            Icons.notifications_none,
            'Notifications',
            'View your report notifications',
            onTap: _openNotifications,
          ),

          // =================================================
          // REPORT MAP
          // =================================================
          _profileOption(
            Icons.map_outlined,
            'Report Map',
            'View your reported road locations',
            onTap: _openReportMap,
          ),

          // =================================================
          // SETTINGS
          // =================================================
          _profileOption(
            Icons.settings_outlined,
            'Settings',
            'Application settings',
            onTap: _openSettings,
          ),

          const SizedBox(height: 15),

          // =================================================
          // LOGOUT
          // =================================================
          SizedBox(
            width: double.infinity,
            height: 52,

            child: OutlinedButton.icon(
              onPressed: _logout,

              icon: const Icon(Icons.logout),

              label: const Text(
                'Logout',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),

              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.red.shade700,

                side: BorderSide(color: Colors.red.shade300),

                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
            ),
          ),

          const SizedBox(height: 20),

          Text(
            'RoadCare • Road Damage Reporting System',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 12,
              color: _isDarkMode ? Colors.white38 : const Color(0xFF9FB3C8),
            ),
          ),
        ],
      ),
    );
  }

  // =========================================================
  // PROFILE INFO ROW
  // =========================================================

  Widget _profileInfoRow(IconData icon, String title, String value) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(10),

          decoration: BoxDecoration(
            color: _iconBackgroundColor,
            borderRadius: BorderRadius.circular(12),
          ),

          child: Icon(icon, color: _primaryColor),
        ),

        const SizedBox(width: 14),

        Expanded(
          child: Text(title, style: TextStyle(color: _secondaryTextColor)),
        ),

        Flexible(
          child: Text(
            value,
            textAlign: TextAlign.right,
            style: TextStyle(fontWeight: FontWeight.bold, color: _textColor),
          ),
        ),
      ],
    );
  }

  // =========================================================
  // PROFILE OPTION
  // =========================================================

  Widget _profileOption(
    IconData icon,
    String title,
    String subtitle, {
    VoidCallback? onTap,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: Material(
        color: _cardColor,
        elevation: _isDarkMode ? 0 : 2,
        borderRadius: BorderRadius.circular(14),
        clipBehavior: Clip.antiAlias,
        child: ListTile(
          leading: Container(
            padding: const EdgeInsets.all(10),

            decoration: BoxDecoration(
              color: _iconBackgroundColor,
              borderRadius: BorderRadius.circular(12),
            ),

            child: Icon(icon, color: _primaryColor),
          ),

          title: Text(
            title,
            style: TextStyle(fontWeight: FontWeight.bold, color: _textColor),
          ),

          subtitle: Text(
            subtitle,
            style: TextStyle(color: _secondaryTextColor),
          ),

          trailing: Icon(Icons.chevron_right, color: _secondaryTextColor),

          onTap:
              onTap ??
              () {
                _showMessage('$title will be available soon.');
              },
        ),
      ),
    );
  }

  // =========================================================
  // LOGOUT
  // =========================================================

  Future<void> _logout() async {
    try {
      await _authService.logout();
    } catch (e) {
      debugPrint('Logout error: $e');
    }

    if (!mounted) return;

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
