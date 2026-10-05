import 'package:flutter/material.dart';

void main() {
  runApp(const RoadCarePortfolioApp());
}

class RoadCarePortfolioApp extends StatelessWidget {
  const RoadCarePortfolioApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'RoadCare - Smart Road Damage Reporting System',
      theme: ThemeData(
        useMaterial3: true,
        fontFamily: 'Arial',
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF5B5FEF),
          brightness: Brightness.light,
        ),
      ),
      home: const PortfolioHomePage(),
    );
  }
}

class PortfolioHomePage extends StatefulWidget {
  const PortfolioHomePage({super.key});

  @override
  State<PortfolioHomePage> createState() => _PortfolioHomePageState();
}

class _PortfolioHomePageState extends State<PortfolioHomePage> {
  final ScrollController _scrollController = ScrollController();

  final GlobalKey homeKey = GlobalKey();
  final GlobalKey aboutKey = GlobalKey();
  final GlobalKey featuresKey = GlobalKey();
  final GlobalKey workflowKey = GlobalKey();
  final GlobalKey modulesKey = GlobalKey();
  final GlobalKey technologyKey = GlobalKey();
  final GlobalKey architectureKey = GlobalKey();
  final GlobalKey contactKey = GlobalKey();

  void _scrollTo(GlobalKey key) {
    final context = key.currentContext;

    if (context != null) {
      Scrollable.ensureVisible(
        context,
        duration: const Duration(milliseconds: 600),
        curve: Curves.easeInOut,
        alignment: 0.05,
      );
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F8FC),
      appBar: _buildAppBar(context),
      drawer: _buildMobileDrawer(),
      body: SingleChildScrollView(
        controller: _scrollController,
        child: Column(
          children: [
            _buildHeroSection(),
            _buildAboutSection(),
            _buildFeaturesSection(),
            _buildWorkflowSection(),
            _buildModulesSection(),
            _buildTechnologySection(),
            _buildArchitectureSection(),
            _buildContactSection(),
            _buildFooter(),
          ],
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    final width = MediaQuery.of(context).size.width;

    return AppBar(
      elevation: 0,
      backgroundColor: Colors.white,
      surfaceTintColor: Colors.white,
      titleSpacing: width < 800 ? 16 : 40,
      title: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF5B5FEF), Color(0xFF7C4DFF)],
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.alt_route_rounded,
              color: Colors.white,
              size: 22,
            ),
          ),
          const SizedBox(width: 10),
          const Text(
            'RoadCare',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 21,
              color: Color(0xFF202238),
            ),
          ),
        ],
      ),
      actions: width >= 800
          ? [
              _navButton('Home', () => _scrollTo(homeKey)),
              _navButton('About', () => _scrollTo(aboutKey)),
              _navButton('Features', () => _scrollTo(featuresKey)),
              _navButton('Modules', () => _scrollTo(modulesKey)),
              _navButton('Technology', () => _scrollTo(technologyKey)),
              _navButton('Contact', () => _scrollTo(contactKey)),
              const SizedBox(width: 30),
            ]
          : null,
    );
  }

  Widget _navButton(String title, VoidCallback onTap) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: TextButton(
        onPressed: onTap,
        child: Text(
          title,
          style: const TextStyle(
            color: Color(0xFF44465A),
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  Drawer _buildMobileDrawer() {
    return Drawer(
      child: SafeArea(
        child: Column(
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFF5B5FEF), Color(0xFF7C4DFF)],
                ),
              ),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.alt_route_rounded, color: Colors.white, size: 42),
                  SizedBox(height: 12),
                  Text(
                    'RoadCare',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 5),
                  Text(
                    'Smart Road Damage Reporting System',
                    style: TextStyle(color: Colors.white70, fontSize: 13),
                  ),
                ],
              ),
            ),
            _drawerItem(
              Icons.home_rounded,
              'Home',
              () => _goFromDrawer(homeKey),
            ),
            _drawerItem(
              Icons.info_outline_rounded,
              'About',
              () => _goFromDrawer(aboutKey),
            ),
            _drawerItem(
              Icons.auto_awesome_rounded,
              'Features',
              () => _goFromDrawer(featuresKey),
            ),
            _drawerItem(
              Icons.account_tree_outlined,
              'Modules',
              () => _goFromDrawer(modulesKey),
            ),
            _drawerItem(
              Icons.code_rounded,
              'Technology',
              () => _goFromDrawer(technologyKey),
            ),
            _drawerItem(
              Icons.contact_mail_outlined,
              'Contact',
              () => _goFromDrawer(contactKey),
            ),
          ],
        ),
      ),
    );
  }

  Widget _drawerItem(IconData icon, String title, VoidCallback onTap) {
    return ListTile(
      leading: Icon(icon, color: const Color(0xFF5B5FEF)),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
      onTap: onTap,
    );
  }

  void _goFromDrawer(GlobalKey key) {
    Navigator.pop(context);

    Future.delayed(const Duration(milliseconds: 200), () => _scrollTo(key));
  }

  Widget _buildHeroSection() {
    return Container(
      key: homeKey,
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 80),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFEEF0FF), Color(0xFFF8F7FF), Color(0xFFEFFAFF)],
        ),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final mobile = constraints.maxWidth < 800;

          if (mobile) {
            return Column(
              children: [
                _heroText(center: true),
                const SizedBox(height: 45),
                _heroVisual(),
              ],
            );
          }

          return Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 1200),
              child: Row(
                children: [
                  Expanded(flex: 6, child: _heroText(center: false)),
                  const SizedBox(width: 50),
                  Expanded(flex: 5, child: _heroVisual()),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _heroText({required bool center}) {
    return Column(
      crossAxisAlignment: center
          ? CrossAxisAlignment.center
          : CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          decoration: BoxDecoration(
            color: const Color(0xFFE3E5FF),
            borderRadius: BorderRadius.circular(30),
          ),
          child: const Text(
            'SMART CIVIC TECHNOLOGY',
            style: TextStyle(
              color: Color(0xFF5155D9),
              fontSize: 12,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.2,
            ),
          ),
        ),
        const SizedBox(height: 20),
        Text(
          'Smart Roads.\nBetter Reporting.\nBetter Communities.',
          textAlign: center ? TextAlign.center : TextAlign.left,
          style: const TextStyle(
            fontSize: 46,
            height: 1.08,
            fontWeight: FontWeight.w800,
            color: Color(0xFF1E2035),
          ),
        ),
        const SizedBox(height: 20),
        Text(
          'RoadCare is a Flutter-based smart road damage reporting '
          'system that helps citizens report road issues and enables '
          'administrators to monitor, manage and resolve them efficiently.',
          textAlign: center ? TextAlign.center : TextAlign.left,
          style: const TextStyle(
            fontSize: 17,
            height: 1.7,
            color: Color(0xFF66697C),
          ),
        ),
        const SizedBox(height: 30),
        Wrap(
          alignment: center ? WrapAlignment.center : WrapAlignment.start,
          spacing: 12,
          runSpacing: 12,
          children: [
            ElevatedButton.icon(
              onPressed: () => _scrollTo(featuresKey),
              icon: const Icon(Icons.auto_awesome_rounded),
              label: const Text('Explore Features'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF5B5FEF),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 22,
                  vertical: 16,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
            ),
            OutlinedButton.icon(
              onPressed: () => _scrollTo(technologyKey),
              icon: const Icon(Icons.code_rounded),
              label: const Text('View Technology'),
              style: OutlinedButton.styleFrom(
                foregroundColor: const Color(0xFF5B5FEF),
                padding: const EdgeInsets.symmetric(
                  horizontal: 22,
                  vertical: 16,
                ),
                side: const BorderSide(color: Color(0xFF5B5FEF)),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _heroVisual() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.85),
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 35,
            offset: const Offset(0, 18),
          ),
        ],
      ),
      child: Container(
        height: 370,
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF5B5FEF), Color(0xFF7C4DFF), Color(0xFF00A8A8)],
          ),
          borderRadius: BorderRadius.circular(22),
        ),
        child: Stack(
          children: [
            Positioned(
              top: 25,
              right: 25,
              child: _floatingIcon(Icons.location_on_rounded),
            ),
            Positioned(
              left: 28,
              bottom: 35,
              child: _floatingIcon(Icons.camera_alt_rounded),
            ),
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.15),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.route_rounded,
                      color: Colors.white,
                      size: 70,
                    ),
                  ),
                  const SizedBox(height: 22),
                  const Text(
                    'ROADCARE',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 30,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 2,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Report • Track • Resolve',
                    style: TextStyle(color: Colors.white70, fontSize: 15),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _floatingIcon(IconData icon) {
    return Container(
      padding: const EdgeInsets.all(13),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.15),
        shape: BoxShape.circle,
      ),
      child: Icon(icon, color: Colors.white, size: 28),
    );
  }

  Widget _buildAboutSection() {
    return _sectionWrapper(
      key: aboutKey,
      child: Column(
        children: [
          _sectionHeading(
            'About RoadCare',
            'A digital solution for smarter road issue reporting',
          ),
          const SizedBox(height: 35),
          LayoutBuilder(
            builder: (context, constraints) {
              final mobile = constraints.maxWidth < 800;

              final content = [
                _infoCard(
                  Icons.report_problem_outlined,
                  'Identify Problems',
                  'Citizens can report potholes, damaged roads and '
                      'other road-related issues with useful details.',
                ),
                _infoCard(
                  Icons.location_on_outlined,
                  'Capture Location',
                  'GPS-based location support helps administrators '
                      'understand where the problem exists.',
                ),
                _infoCard(
                  Icons.track_changes_rounded,
                  'Track Progress',
                  'Users can monitor their reports and view status '
                      'history as administrators process them.',
                ),
              ];

              if (mobile) {
                return Column(
                  children: content
                      .map(
                        (item) => Padding(
                          padding: const EdgeInsets.only(bottom: 16),
                          child: item,
                        ),
                      )
                      .toList(),
                );
              }

              return Row(
                children: content
                    .map(
                      (item) => Expanded(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8),
                          child: item,
                        ),
                      ),
                    )
                    .toList(),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _infoCard(IconData icon, String title, String description) {
    return Container(
      padding: const EdgeInsets.all(25),
      decoration: _cardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _iconBox(icon),
          const SizedBox(height: 18),
          Text(
            title,
            style: const TextStyle(
              fontSize: 19,
              fontWeight: FontWeight.bold,
              color: Color(0xFF25273A),
            ),
          ),
          const SizedBox(height: 10),
          Text(
            description,
            style: const TextStyle(
              color: Color(0xFF6A6D7F),
              height: 1.6,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeaturesSection() {
    return Container(
      key: featuresKey,
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 75),
      color: Colors.white,
      child: Column(
        children: [
          _sectionHeading(
            'Key Features',
            'Everything RoadCare provides for citizens and administrators',
          ),
          const SizedBox(height: 40),
          LayoutBuilder(
            builder: (context, constraints) {
              final width = constraints.maxWidth;
              int columns = 1;

              if (width >= 1050) {
                columns = 3;
              } else if (width >= 650) {
                columns = 2;
              }

              final features = [
                _featureData(
                  Icons.camera_alt_rounded,
                  'Road Damage Reporting',
                  'Submit road damage reports with description, '
                      'severity and supporting images.',
                ),
                _featureData(
                  Icons.my_location_rounded,
                  'GPS Location',
                  'Capture and store the location associated with '
                      'a road damage report.',
                ),
                _featureData(
                  Icons.photo_library_rounded,
                  'Image Support',
                  'Use camera or gallery images and view them '
                      'with zoom support.',
                ),
                _featureData(
                  Icons.timeline_rounded,
                  'Status Tracking',
                  'Track Pending, In Progress, Resolved and '
                      'Rejected report states.',
                ),
                _featureData(
                  Icons.notifications_active_rounded,
                  'Notifications',
                  'Keep users informed when important report '
                      'activities and status changes occur.',
                ),
                _featureData(
                  Icons.feedback_outlined,
                  'Feedback',
                  'Users can provide feedback while administrators '
                      'can review submitted feedback.',
                ),
                _featureData(
                  Icons.dashboard_rounded,
                  'Admin Dashboard',
                  'Administrators get overview, search, analytics '
                      'and report management tools.',
                ),
                _featureData(
                  Icons.analytics_outlined,
                  'Analytics',
                  'View report statistics based on status and '
                      'severity.',
                ),
                _featureData(
                  Icons.archive_outlined,
                  'Archive Management',
                  'Administrators can archive reports and restore '
                      'them when necessary.',
                ),
              ];

              return GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: features.length,
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: columns,
                  crossAxisSpacing: 18,
                  mainAxisSpacing: 18,
                  childAspectRatio: width < 500 ? 1.45 : 1.35,
                ),
                itemBuilder: (context, index) {
                  final item = features[index];

                  return _featureCard(
                    item['icon'] as IconData,
                    item['title'] as String,
                    item['description'] as String,
                  );
                },
              );
            },
          ),
        ],
      ),
    );
  }

  Map<String, dynamic> _featureData(
    IconData icon,
    String title,
    String description,
  ) {
    return {'icon': icon, 'title': title, 'description': description};
  }

  Widget _featureCard(IconData icon, String title, String description) {
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: _cardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _iconBox(icon),
          const SizedBox(height: 15),
          Text(
            title,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 17,
              color: Color(0xFF25273A),
            ),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: Text(
              description,
              style: const TextStyle(
                fontSize: 13.5,
                height: 1.5,
                color: Color(0xFF6A6D7F),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWorkflowSection() {
    return _sectionWrapper(
      key: workflowKey,
      background: const Color(0xFFF7F8FC),
      child: Column(
        children: [
          _sectionHeading(
            'How RoadCare Works',
            'A simple flow from reporting to resolution',
          ),
          const SizedBox(height: 45),
          LayoutBuilder(
            builder: (context, constraints) {
              final mobile = constraints.maxWidth < 750;

              final steps = [
                _workflowStep(
                  '01',
                  Icons.person_add_alt_1_rounded,
                  'Login / Register',
                  'Create an account or log in to access RoadCare.',
                ),
                _workflowStep(
                  '02',
                  Icons.add_a_photo_rounded,
                  'Report Damage',
                  'Submit damage details, severity, images and location.',
                ),
                _workflowStep(
                  '03',
                  Icons.admin_panel_settings_rounded,
                  'Admin Review',
                  'Administrators review and process the submitted report.',
                ),
                _workflowStep(
                  '04',
                  Icons.update_rounded,
                  'Status Update',
                  'Report status is updated as the issue progresses.',
                ),
                _workflowStep(
                  '05',
                  Icons.check_circle_rounded,
                  'Resolution',
                  'Users can see the final status and report history.',
                ),
              ];

              if (mobile) {
                return Column(
                  children: steps
                      .map(
                        (step) => Padding(
                          padding: const EdgeInsets.only(bottom: 18),
                          child: step,
                        ),
                      )
                      .toList(),
                );
              }

              return Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: steps
                    .map(
                      (step) => Expanded(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 5),
                          child: step,
                        ),
                      ),
                    )
                    .toList(),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _workflowStep(
    String number,
    IconData icon,
    String title,
    String description,
  ) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE5E6F0)),
      ),
      child: Column(
        children: [
          Stack(
            alignment: Alignment.center,
            children: [
              Container(
                width: 68,
                height: 68,
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFF5B5FEF), Color(0xFF7C4DFF)],
                  ),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: Colors.white, size: 28),
              ),
              Positioned(
                right: -2,
                top: -4,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 7,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFF202238),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    number,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 9,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            title,
            textAlign: TextAlign.center,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          const SizedBox(height: 8),
          Text(
            description,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Color(0xFF6A6D7F),
              fontSize: 12.5,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildModulesSection() {
    return Container(
      key: modulesKey,
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 75),
      color: Colors.white,
      child: Column(
        children: [
          _sectionHeading(
            'User & Admin Modules',
            'Two connected experiences built around the same road-reporting workflow',
          ),
          const SizedBox(height: 40),
          LayoutBuilder(
            builder: (context, constraints) {
              final mobile = constraints.maxWidth < 800;

              final user = _moduleCard(Icons.person_rounded, 'User Module', [
                'Register and Login',
                'Home Dashboard',
                'Report Road Damage',
                'GPS Location',
                'Camera / Gallery Images',
                'Severity Selection',
                'My Reports',
                'Status Tracking',
                'Notifications',
                'Feedback',
                'Profile Management',
                'Settings',
              ]);

              final admin = _moduleCard(
                Icons.admin_panel_settings_rounded,
                'Admin Module',
                [
                  'Admin Login',
                  'Dashboard Overview',
                  'Search Reports',
                  'Filter & Sort',
                  'Status Analytics',
                  'Severity Analytics',
                  'Report Details',
                  'Reporter Details',
                  'Image Viewing',
                  'Map / Location View',
                  'Status History',
                  'Archive / Unarchive',
                  'Feedback Management',
                ],
              );

              if (mobile) {
                return Column(
                  children: [user, const SizedBox(height: 20), admin],
                );
              }

              return Row(
                children: [
                  Expanded(child: user),
                  const SizedBox(width: 22),
                  Expanded(child: admin),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _moduleCard(IconData icon, String title, List<String> items) {
    return Container(
      padding: const EdgeInsets.all(28),
      decoration: _cardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              _iconBox(icon),
              const SizedBox(width: 15),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF25273A),
                ),
              ),
            ],
          ),
          const SizedBox(height: 22),
          ...items.map(
            (item) => Padding(
              padding: const EdgeInsets.only(bottom: 11),
              child: Row(
                children: [
                  const Icon(
                    Icons.check_circle_rounded,
                    size: 18,
                    color: Color(0xFF5B5FEF),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      item,
                      style: const TextStyle(
                        color: Color(0xFF55586A),
                        fontSize: 14,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTechnologySection() {
    return _sectionWrapper(
      key: technologyKey,
      background: const Color(0xFFF7F8FC),
      child: Column(
        children: [
          _sectionHeading(
            'Technology Stack',
            'Technologies used to build the RoadCare application',
          ),
          const SizedBox(height: 40),
          LayoutBuilder(
            builder: (context, constraints) {
              final width = constraints.maxWidth;

              final technologies = [
                _technology(
                  Icons.flutter_dash_rounded,
                  'Flutter',
                  'Cross-platform UI framework',
                ),
                _technology(
                  Icons.code_rounded,
                  'Dart',
                  'Application programming language',
                ),
                _technology(
                  Icons.storage_rounded,
                  'SQLite',
                  'Local database storage',
                ),
                _technology(
                  Icons.phone_android_rounded,
                  'Android',
                  'Mobile application platform',
                ),
                _technology(
                  Icons.language_rounded,
                  'Chrome / Web',
                  'Web platform support',
                ),
                _technology(
                  Icons.location_on_rounded,
                  'GPS / Location',
                  'Location-based reporting',
                ),
              ];

              int columns = 1;

              if (width >= 1000) {
                columns = 3;
              } else if (width >= 600) {
                columns = 2;
              }

              return GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: technologies.length,
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: columns,
                  crossAxisSpacing: 18,
                  mainAxisSpacing: 18,
                  childAspectRatio: 3.1,
                ),
                itemBuilder: (context, index) {
                  final tech = technologies[index];

                  return Container(
                    padding: const EdgeInsets.all(20),
                    decoration: _cardDecoration(),
                    child: Row(
                      children: [
                        _iconBox(tech['icon'] as IconData),
                        const SizedBox(width: 15),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                tech['title'] as String,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                tech['description'] as String,
                                style: const TextStyle(
                                  color: Color(0xFF707384),
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                },
              );
            },
          ),
        ],
      ),
    );
  }

  Map<String, dynamic> _technology(
    IconData icon,
    String title,
    String description,
  ) {
    return {'icon': icon, 'title': title, 'description': description};
  }

  Widget _buildArchitectureSection() {
    return _sectionWrapper(
      key: architectureKey,
      background: Colors.white,
      child: Column(
        children: [
          _sectionHeading(
            'System Architecture',
            'A clean local-first architecture connecting the application layers',
          ),
          const SizedBox(height: 40),
          LayoutBuilder(
            builder: (context, constraints) {
              final mobile = constraints.maxWidth < 800;

              final layers = [
                _architectureLayer(
                  Icons.phone_android_rounded,
                  'Presentation Layer',
                  'Flutter screens • Responsive UI • Navigation',
                ),
                _architectureLayer(
                  Icons.miscellaneous_services_rounded,
                  'Service Layer',
                  'Authentication • Reports • Notifications • Feedback',
                ),
                _architectureLayer(
                  Icons.account_tree_outlined,
                  'Repository Layer',
                  'Application data access and business interaction',
                ),
                _architectureLayer(
                  Icons.storage_rounded,
                  'SQLite Database',
                  'Users • Reports • Images • Status History • Notifications • Feedback',
                ),
              ];

              if (mobile) {
                return Column(
                  children: layers
                      .map(
                        (layer) => Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: layer,
                        ),
                      )
                      .toList(),
                );
              }

              return Column(
                children: [
                  layers[0],
                  _architectureArrow(),
                  layers[1],
                  _architectureArrow(),
                  layers[2],
                  _architectureArrow(),
                  layers[3],
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _architectureLayer(IconData icon, String title, String description) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFF2F3FF), Color(0xFFF9F7FF)],
        ),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE1E3F5)),
      ),
      child: Row(
        children: [
          _iconBox(icon),
          const SizedBox(width: 18),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 17,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  description,
                  style: const TextStyle(
                    color: Color(0xFF686B7D),
                    fontSize: 13,
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _architectureArrow() {
    return const Padding(
      padding: EdgeInsets.symmetric(vertical: 8),
      child: Icon(
        Icons.arrow_downward_rounded,
        color: Color(0xFF5B5FEF),
        size: 28,
      ),
    );
  }

  Widget _buildContactSection() {
    return Container(
      key: contactKey,
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 75),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF202238), Color(0xFF30335A), Color(0xFF40306D)],
        ),
      ),
      child: Column(
        children: [
          const Text(
            'RoadCare',
            style: TextStyle(
              color: Colors.white,
              fontSize: 34,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 12),
          const Text(
            'Smart Road Damage Reporting System',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.white70, fontSize: 16),
          ),
          const SizedBox(height: 25),
          const Text(
            'Built with Flutter • Dart • SQLite\n'
            'Designed for Android and Web',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.white60, height: 1.7, fontSize: 14),
          ),
          const SizedBox(height: 30),
          Wrap(
            alignment: WrapAlignment.center,
            spacing: 12,
            runSpacing: 12,
            children: [
              _contactChip(Icons.code_rounded, 'GitHub'),
              _contactChip(Icons.email_outlined, 'Contact'),
              _contactChip(Icons.phone_android_rounded, 'Android'),
              _contactChip(Icons.language_rounded, 'Web'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _contactChip(IconData icon, String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: Colors.white.withValues(alpha: 0.15)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: Colors.white, size: 18),
          const SizedBox(width: 8),
          Text(
            text,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFooter() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      color: const Color(0xFF181927),
      child: const Text(
        '© 2026 RoadCare • Smart Road Damage Reporting System',
        textAlign: TextAlign.center,
        style: TextStyle(color: Colors.white54, fontSize: 12),
      ),
    );
  }

  Widget _sectionWrapper({
    required Widget child,
    required GlobalKey key,
    Color background = Colors.white,
  }) {
    return Container(
      key: key,
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 75),
      color: background,
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1200),
          child: child,
        ),
      ),
    );
  }

  Widget _sectionHeading(String title, String subtitle) {
    return Column(
      children: [
        Text(
          title,
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 31,
            fontWeight: FontWeight.w800,
            color: Color(0xFF25273A),
          ),
        ),
        const SizedBox(height: 10),
        Text(
          subtitle,
          textAlign: TextAlign.center,
          style: const TextStyle(color: Color(0xFF707384), fontSize: 14.5),
        ),
        const SizedBox(height: 15),
        Container(
          width: 55,
          height: 4,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF5B5FEF), Color(0xFF7C4DFF)],
            ),
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      ],
    );
  }

  Widget _iconBox(IconData icon) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFE9EAFF), Color(0xFFF1EAFF)],
        ),
        borderRadius: BorderRadius.circular(13),
      ),
      child: Icon(icon, color: const Color(0xFF5B5FEF), size: 25),
    );
  }

  BoxDecoration _cardDecoration() {
    return BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(20),
      border: Border.all(color: const Color(0xFFE7E8F0)),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.04),
          blurRadius: 18,
          offset: const Offset(0, 8),
        ),
      ],
    );
  }
}
