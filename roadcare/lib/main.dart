import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:sqflite_common/sqflite.dart';
import 'package:sqflite_common_ffi_web/sqflite_ffi_web.dart';

import 'services/app_settings.dart';
import 'screens/auth/login_screen.dart';
import 'screens/report/report_damage_screen.dart';

// =========================================================
// MAIN
// =========================================================

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // =======================================================
  // DATABASE INITIALIZATION
  // =======================================================
  //
  // Android / iOS:
  // Existing SQLite behavior is preserved.
  //
  // Chrome / Web:
  // Use sqflite_common_ffi_web database factory.
  //
  // This fixes:
  // "Bad state: databaseFactory not initialized"
  // =======================================================

  if (kIsWeb) {
    databaseFactory = databaseFactoryFfiWeb;
  }

  // =======================================================
  // LOAD APPLICATION SETTINGS
  // =======================================================

  await AppSettings.loadSettings();

  // =======================================================
  // START APPLICATION
  // =======================================================

  runApp(const RoadCareApp());
}

// =========================================================
// ROADCARE APP
// =========================================================

class RoadCareApp extends StatelessWidget {
  const RoadCareApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<bool>(
      valueListenable: AppSettings.darkModeNotifier,

      builder: (context, darkMode, child) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,

          title: 'RoadCare',

          // =================================================
          // THEME MODE
          // =================================================
          themeMode: darkMode ? ThemeMode.dark : ThemeMode.light,

          // =================================================
          // LIGHT THEME
          // =================================================
          theme: ThemeData(
            brightness: Brightness.light,

            useMaterial3: true,

            colorScheme: ColorScheme.fromSeed(
              seedColor: const Color(0xFF176B87),
              brightness: Brightness.light,
            ),

            scaffoldBackgroundColor: const Color(0xFFF5F8FC),

            // -------------------------------------------------
            // APP BAR
            // -------------------------------------------------
            appBarTheme: const AppBarTheme(
              backgroundColor: Colors.white,
              surfaceTintColor: Colors.white,
              foregroundColor: Color(0xFF102A43),
              elevation: 0,
            ),

            // -------------------------------------------------
            // CARDS
            // -------------------------------------------------
            cardTheme: CardThemeData(
              color: Colors.white,
              elevation: 3,
              surfaceTintColor: Colors.transparent,

              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(18)),
              ),
            ),

            // -------------------------------------------------
            // INPUT FIELDS
            // -------------------------------------------------
            inputDecorationTheme: InputDecorationTheme(
              filled: true,

              fillColor: Colors.white,

              border: OutlineInputBorder(
                borderRadius: BorderRadius.all(Radius.circular(14)),

                borderSide: BorderSide.none,
              ),
            ),

            // -------------------------------------------------
            // NAVIGATION BAR
            // -------------------------------------------------
            navigationBarTheme: const NavigationBarThemeData(
              backgroundColor: Colors.white,
            ),
          ),

          // =================================================
          // DARK THEME
          // =================================================
          darkTheme: ThemeData(
            brightness: Brightness.dark,

            useMaterial3: true,

            colorScheme: ColorScheme.fromSeed(
              seedColor: const Color(0xFF2A9D8F),
              brightness: Brightness.dark,
            ),

            scaffoldBackgroundColor: const Color(0xFF0F1720),

            // -------------------------------------------------
            // APP BAR
            // -------------------------------------------------
            appBarTheme: const AppBarTheme(
              backgroundColor: Color(0xFF111827),

              surfaceTintColor: Colors.transparent,

              foregroundColor: Colors.white,

              elevation: 0,
            ),

            // -------------------------------------------------
            // CARDS
            // -------------------------------------------------
            cardTheme: CardThemeData(
              color: const Color(0xFF1E293B),

              elevation: 3,

              surfaceTintColor: Colors.transparent,

              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(18)),
              ),
            ),

            // -------------------------------------------------
            // INPUT FIELDS
            // -------------------------------------------------
            inputDecorationTheme: InputDecorationTheme(
              filled: true,

              fillColor: const Color(0xFF1E293B),

              border: OutlineInputBorder(
                borderRadius: BorderRadius.all(Radius.circular(14)),

                borderSide: BorderSide.none,
              ),
            ),

            // -------------------------------------------------
            // NAVIGATION BAR
            // -------------------------------------------------
            navigationBarTheme: const NavigationBarThemeData(
              backgroundColor: Color(0xFF111827),
            ),
          ),

          // =================================================
          // FIRST SCREEN
          // =================================================
          home: const SplashScreen(),
        );
      },
    );
  }
}

// =========================================================
// SPLASH SCREEN
// =========================================================

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  late Animation<double> _scaleAnimation;

  late Animation<double> _fadeAnimation;

  // =======================================================
  // INIT STATE
  // =======================================================

  @override
  void initState() {
    super.initState();

    // =====================================================
    // ANIMATION CONTROLLER
    // =====================================================

    _controller = AnimationController(
      vsync: this,

      duration: const Duration(milliseconds: 1200),
    );

    // =====================================================
    // SCALE ANIMATION
    // =====================================================

    _scaleAnimation = Tween<double>(
      begin: 0.65,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutBack));

    // =====================================================
    // FADE ANIMATION
    // =====================================================

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeIn));

    // =====================================================
    // START ANIMATION
    // =====================================================

    _controller.forward();

    // =====================================================
    // CHECK PENDING CAMERA SESSION
    // =====================================================

    _checkPendingCameraSession();
  }

  // =======================================================
  // CHECK PENDING CAMERA SESSION
  // =======================================================

  Future<void> _checkPendingCameraSession() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();

    final bool pendingCamera =
        prefs.getBool('roadcare_pending_camera') ?? false;

    final int? userId = prefs.getInt('roadcare_pending_user_id');

    if (!mounted) return;

    // =====================================================
    // CAMERA WAS OPEN
    // =====================================================

    if (pendingCamera && userId != null && userId > 0) {
      await Future.delayed(const Duration(milliseconds: 400));

      if (!mounted) return;

      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => ReportDamageScreen(userId: userId)),
      );

      return;
    }

    // =====================================================
    // NORMAL APP START
    // =====================================================

    await Future.delayed(const Duration(seconds: 3));

    if (!mounted) return;

    Navigator.of(
      context,
    ).pushReplacement(MaterialPageRoute(builder: (_) => const WelcomeScreen()));
  }

  // =======================================================
  // DISPOSE
  // =======================================================

  @override
  void dispose() {
    _controller.dispose();

    super.dispose();
  }

  // =======================================================
  // BUILD SPLASH SCREEN
  // =======================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,

        height: double.infinity,

        decoration: BoxDecoration(
          image: DecorationImage(
            image: const AssetImage('assets/images/roadcare-road.jpg'),
            fit: BoxFit.cover,
            colorFilter: ColorFilter.mode(
              const Color(0xFF0B3954).withValues(alpha: 0.18),
              BlendMode.darken,
            ),
          ),
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0x440B3954), Color(0x33176B87), Color(0x552A9D8F)],
          ),
        ),

        child: Center(
          child: AnimatedBuilder(
            animation: _controller,

            builder: (context, child) {
              return FadeTransition(
                opacity: _fadeAnimation,

                child: ScaleTransition(
                  scale: _scaleAnimation,

                  child: Column(
                    mainAxisSize: MainAxisSize.min,

                    children: [
                      // ===================================
                      // LOGO
                      // ===================================

                      Container(
                        width: 110,

                        height: 110,

                        decoration: BoxDecoration(
                          color: Colors.white,

                          borderRadius: BorderRadius.circular(32),

                          boxShadow: const [
                            BoxShadow(
                              color: Colors.black26,

                              blurRadius: 25,

                              offset: Offset(0, 12),
                            ),
                          ],
                        ),

                        child: const Icon(
                          Icons.add_road,

                          size: 60,

                          color: Color(0xFF176B87),
                        ),
                      ),

                      const SizedBox(height: 28),

                      // ===================================
                      // APP NAME
                      // ===================================
                      const Text(
                        'RoadCare',

                        style: TextStyle(
                          color: Colors.white,

                          fontSize: 38,

                          fontWeight: FontWeight.bold,

                          letterSpacing: 1,
                        ),
                      ),

                      const SizedBox(height: 8),

                      // ===================================
                      // TAGLINE
                      // ===================================
                      const Text(
                        'Report. Track. Improve.',

                        style: TextStyle(
                          color: Colors.white70,

                          fontSize: 16,

                          letterSpacing: 1.2,
                        ),
                      ),

                      const SizedBox(height: 40),

                      // ===================================
                      // LOADING
                      // ===================================
                      const SizedBox(
                        width: 28,

                        height: 28,

                        child: CircularProgressIndicator(
                          strokeWidth: 2.5,

                          valueColor: AlwaysStoppedAnimation<Color>(
                            Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

// =========================================================
// WELCOME SCREEN
// =========================================================

class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({super.key});

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> {
  static const List<
    ({String image, String eyebrow, String title, String description})
  >
  _slides = [
    (
      image: 'assets/images/roadcare-road.jpg',
      eyebrow: 'See it. Report it.',
      title: 'A safer street starts with you.',
      description: 'Photograph potholes, cracks and hazards, then send a clear report to your community.',
    ),
    (
      image: 'assets/images/gps-route.png',
      eyebrow: 'Precise GPS location',
      title: 'Put the problem on the map.',
      description: 'Attach your current location so the right road team can find the issue quickly.',
    ),
    (
      image: 'assets/images/city-operations.jpg',
      eyebrow: 'Stay in the loop',
      title: 'Follow every update.',
      description: 'See when your report is received, being reviewed and resolved, all in one place.',
    ),
  ];

  final PageController _pageController = PageController();
  int _currentPage = 0;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _continue() {
    if (_currentPage < _slides.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 550),
        curve: Curves.easeInOutCubic,
      );
      return;
    }

    Navigator.of(context).push(
      PageRouteBuilder<void>(
        transitionDuration: const Duration(milliseconds: 500),
        pageBuilder: (_, animation, secondaryAnimation) => const LoginScreen(),
        transitionsBuilder: (_, animation, secondaryAnimation, child) {
          final curved = CurvedAnimation(
            parent: animation,
            curve: Curves.easeOutCubic,
          );
          return FadeTransition(
            opacity: curved,
            child: SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(0, 0.035),
                end: Offset.zero,
              ).animate(curved),
              child: child,
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0B2434),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final bool wide = constraints.maxWidth >= 760;
          return Stack(
            fit: StackFit.expand,
            children: [
              PageView.builder(
                controller: _pageController,
                itemCount: _slides.length,
                onPageChanged: (index) => setState(() => _currentPage = index),
                itemBuilder: (context, index) => Image.asset(
                  _slides[index].image,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) =>
                      const ColoredBox(
                        color: Color(0xFF176B87),
                        child: Icon(
                          Icons.add_road_rounded,
                          size: 90,
                          color: Colors.white,
                        ),
                      ),
                ),
              ),
              const DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    stops: [0, 0.32, 1],
                    colors: [
                      Color(0x66101D24),
                      Color(0x140B2434),
                      Color(0xF20B2434),
                    ],
                  ),
                ),
              ),
              SafeArea(
                child: Padding(
                  padding: EdgeInsets.fromLTRB(
                    wide ? 64 : 26,
                    22,
                    wide ? 64 : 26,
                    28,
                  ),
                  child: Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 1280),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Icon(
                                Icons.add_road_rounded,
                                color: Color(0xFFF4C95D),
                                size: 30,
                              ),
                              const SizedBox(width: 10),
                              const Text(
                                'RoadCare',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 20,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                              const Spacer(),
                              if (_currentPage < _slides.length - 1)
                                TextButton(
                                  onPressed: () =>
                                      _pageController.animateToPage(
                                        _slides.length - 1,
                                        duration: const Duration(
                                          milliseconds: 550,
                                        ),
                                        curve: Curves.easeInOutCubic,
                                      ),
                                  child: const Text(
                                    'Skip',
                                    style: TextStyle(color: Colors.white),
                                  ),
                                ),
                            ],
                          ),
                          const Spacer(),
                          AnimatedSwitcher(
                            duration: const Duration(milliseconds: 400),
                            transitionBuilder: (child, animation) =>
                                FadeTransition(
                                  opacity: animation,
                                  child: SlideTransition(
                                    position: Tween<Offset>(
                                      begin: const Offset(0, 0.08),
                                      end: Offset.zero,
                                    ).animate(animation),
                                    child: child,
                                  ),
                                ),
                            child: Column(
                              key: ValueKey(_currentPage),
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  '${(_currentPage + 1).toString().padLeft(2, '0')}  /  03     ${_slides[_currentPage].eyebrow.toUpperCase()}',
                                  style: const TextStyle(
                                    color: Color(0xFFF4C95D),
                                    fontSize: 12,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                                const SizedBox(height: 15),
                                ConstrainedBox(
                                  constraints: const BoxConstraints(
                                    maxWidth: 720,
                                  ),
                                  child: Text(
                                    _slides[_currentPage].title,
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: wide ? 54 : 38,
                                      height: 1.06,
                                      fontWeight: FontWeight.w800,
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 14),
                                ConstrainedBox(
                                  constraints: const BoxConstraints(
                                    maxWidth: 560,
                                  ),
                                  child: Text(
                                    _slides[_currentPage].description,
                                    style: const TextStyle(
                                      color: Colors.white70,
                                      fontSize: 16,
                                      height: 1.5,
                                    ),
                                  ),
                                ),
                                if (_currentPage == 1) ...[
                                  const SizedBox(height: 8),
                                  const Text(
                                    'Map tiles © OpenStreetMap contributors',
                                    style: TextStyle(
                                      color: Colors.white60,
                                      fontSize: 11,
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ),
                          const SizedBox(height: 30),
                          Row(
                            children: [
                              ElevatedButton.icon(
                                onPressed: _continue,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFFF4C95D),
                                  foregroundColor: const Color(0xFF102A43),
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 22,
                                    vertical: 17,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                                icon: Icon(
                                  _currentPage == _slides.length - 1
                                      ? Icons.arrow_forward_rounded
                                      : Icons.chevron_right_rounded,
                                ),
                                label: Text(
                                  _currentPage == _slides.length - 1
                                      ? 'Get Started'
                                      : 'Continue',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 18),
                              Row(
                                children: List.generate(
                                  _slides.length,
                                  (index) => AnimatedContainer(
                                    duration: const Duration(milliseconds: 250),
                                    margin: const EdgeInsets.only(right: 7),
                                    width: index == _currentPage ? 26 : 8,
                                    height: 8,
                                    decoration: BoxDecoration(
                                      color: index == _currentPage
                                          ? const Color(0xFFF4C95D)
                                          : Colors.white54,
                                      borderRadius: BorderRadius.circular(8),
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
              ),
            ],
          );
        },
      ),
    );
  }
}
