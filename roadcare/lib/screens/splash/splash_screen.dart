import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../auth/login_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late AnimationController _mainController;
  late AnimationController _floatingController;
  late AnimationController _roadController;
  late AnimationController _pulseController;
  late AnimationController _dotsController;

  late Animation<double> _logoScale;
  late Animation<double> _logoFade;
  late Animation<Offset> _logoSlide;

  late Animation<double> _titleFade;
  late Animation<Offset> _titleSlide;

  late Animation<double> _descriptionFade;
  late Animation<Offset> _descriptionSlide;

  late Animation<double> _gpsFade;
  late Animation<double> _safetyFade;

  late Animation<double> _contentFade;

  @override
  void initState() {
    super.initState();

    // Main entrance animation
    _mainController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2200),
    );

    // Floating icons
    _floatingController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2200),
    )..repeat(reverse: true);

    // Moving road animation
    _roadController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    )..repeat();

    // Logo pulse
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    )..repeat(reverse: true);

    // Loading dots
    _dotsController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    )..repeat();

    // Logo
    _logoScale = CurvedAnimation(
      parent: _mainController,
      curve: const Interval(
        0.0,
        0.38,
        curve: Curves.easeOutBack,
      ),
    );

    _logoFade = CurvedAnimation(
      parent: _mainController,
      curve: const Interval(
        0.0,
        0.35,
        curve: Curves.easeIn,
      ),
    );

    _logoSlide = Tween<Offset>(
      begin: const Offset(0, 0.35),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _mainController,
        curve: const Interval(
          0.0,
          0.4,
          curve: Curves.easeOutCubic,
        ),
      ),
    );

    // Title
    _titleFade = CurvedAnimation(
      parent: _mainController,
      curve: const Interval(
        0.28,
        0.58,
        curve: Curves.easeIn,
      ),
    );

    _titleSlide = Tween<Offset>(
      begin: const Offset(0, 0.25),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _mainController,
        curve: const Interval(
          0.28,
          0.6,
          curve: Curves.easeOutCubic,
        ),
      ),
    );

    // Description
    _descriptionFade = CurvedAnimation(
      parent: _mainController,
      curve: const Interval(
        0.48,
        0.76,
        curve: Curves.easeIn,
      ),
    );

    _descriptionSlide = Tween<Offset>(
      begin: const Offset(0, 0.22),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _mainController,
        curve: const Interval(
          0.48,
          0.78,
          curve: Curves.easeOutCubic,
        ),
      ),
    );

    // GPS
    _gpsFade = CurvedAnimation(
      parent: _mainController,
      curve: const Interval(
        0.05,
        0.4,
        curve: Curves.easeOut,
      ),
    );

    // Safety
    _safetyFade = CurvedAnimation(
      parent: _mainController,
      curve: const Interval(
        0.15,
        0.48,
        curve: Curves.easeOut,
      ),
    );

    // Bottom content
    _contentFade = CurvedAnimation(
      parent: _mainController,
      curve: const Interval(
        0.65,
        1.0,
        curve: Curves.easeIn,
      ),
    );

    _mainController.forward();

    // Keep splash for a few seconds.
    Timer(const Duration(milliseconds: 5200), () {
      if (!mounted) return;

      Navigator.pushReplacement(
        context,
        PageRouteBuilder(
          transitionDuration: const Duration(milliseconds: 900),
          pageBuilder: (_, animation, __) => const LoginScreen(),
          transitionsBuilder: (_, animation, __, child) {
            final curved = CurvedAnimation(
              parent: animation,
              curve: Curves.easeInOutCubic,
            );

            return FadeTransition(
              opacity: curved,
              child: SlideTransition(
                position: Tween<Offset>(
                  begin: const Offset(0, 0.08),
                  end: Offset.zero,
                ).animate(curved),
                child: child,
              ),
            );
          },
        ),
      );
    });
  }

  @override
  void dispose() {
    _mainController.dispose();
    _floatingController.dispose();
    _roadController.dispose();
    _pulseController.dispose();
    _dotsController.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AnimatedBuilder(
        animation: Listenable.merge([
          _mainController,
          _floatingController,
          _roadController,
          _pulseController,
          _dotsController,
        ]),
        builder: (context, child) {
          return Stack(
            children: [
              // Animated background
              _buildBackground(),

              // Decorative glow circles
              _buildGlow(
                top: 80,
                left: -80,
                size: 190,
                opacity: 0.12,
              ),

              _buildGlow(
                top: 260,
                right: -100,
                size: 230,
                opacity: 0.10,
              ),

              _buildGlow(
                bottom: 80,
                left: -90,
                size: 220,
                opacity: 0.08,
              ),

              SafeArea(
                child: Center(
                  child: SingleChildScrollView(
                    physics: const NeverScrollableScrollPhysics(),
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(
                        maxWidth: 650,
                      ),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const SizedBox(height: 15),

                            // GPS + SAFETY
                            Row(
                              mainAxisAlignment:
                                  MainAxisAlignment.spaceBetween,
                              children: [
                                FadeTransition(
                                  opacity: _gpsFade,
                                  child: _buildFloatingIcon(
                                    icon: Icons.gps_fixed,
                                    title: 'GPS',
                                    color: const Color(0xFF64B5F6),
                                    alignment: -1,
                                  ),
                                ),
                                FadeTransition(
                                  opacity: _safetyFade,
                                  child: _buildFloatingIcon(
                                    icon: Icons.shield_rounded,
                                    title: 'SAFETY',
                                    color: const Color(0xFF81D4FA),
                                    alignment: 1,
                                  ),
                                ),
                              ],
                            ),

                            const SizedBox(height: 20),

                            // RoadCare Logo
                            SlideTransition(
                              position: _logoSlide,
                              child: FadeTransition(
                                opacity: _logoFade,
                                child: ScaleTransition(
                                  scale: _logoScale,
                                  child: _buildLogo(),
                                ),
                              ),
                            ),

                            const SizedBox(height: 28),

                            // RoadCare title
                            FadeTransition(
                              opacity: _titleFade,
                              child: SlideTransition(
                                position: _titleSlide,
                                child: const Text(
                                  'RoadCare',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 42,
                                    fontWeight: FontWeight.w800,
                                    letterSpacing: 1.2,
                                  ),
                                ),
                              ),
                            ),

                            const SizedBox(height: 10),

                            FadeTransition(
                              opacity: _titleFade,
                              child: const Text(
                                'SMART ROAD SAFETY',
                                style: TextStyle(
                                  color: Color(0xFFBBDEFB),
                                  fontSize: 15,
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: 3,
                                ),
                              ),
                            ),

                            const SizedBox(height: 2),

                            FadeTransition(
                              opacity: _titleFade,
                              child: const Text(
                                'SOLUTION',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 15,
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: 3,
                                ),
                              ),
                            ),

                            const SizedBox(height: 18),

                            // Description
                            FadeTransition(
                              opacity: _descriptionFade,
                              child: SlideTransition(
                                position: _descriptionSlide,
                                child: const Padding(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: 22,
                                  ),
                                  child: Text(
                                    'Report damaged roads, capture locations, '
                                    'track complaints and help make roads safer.',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      color: Color(0xFFD9ECFF),
                                      fontSize: 15,
                                      height: 1.55,
                                      letterSpacing: 0.25,
                                    ),
                                  ),
                                ),
                              ),
                            ),

                            const SizedBox(height: 30),

                            // Animated road
                            FadeTransition(
                              opacity: _contentFade,
                              child: _buildAnimatedRoad(),
                            ),

                            const SizedBox(height: 28),

                            // Loading
                            FadeTransition(
                              opacity: _contentFade,
                              child: _buildLoadingSection(),
                            ),

                            const SizedBox(height: 20),
                          ],
                        ),
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

  Widget _buildBackground() {
    final animationValue = _pulseController.value;

    return Container(
      width: double.infinity,
      height: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          stops: const [
            0.0,
            0.48,
            1.0,
          ],
          colors: [
            Color.lerp(
              const Color(0xFF061A3A),
              const Color(0xFF082653),
              animationValue,
            )!,
            Color.lerp(
              const Color(0xFF0D47A1),
              const Color(0xFF1565C0),
              animationValue,
            )!,
            const Color(0xFF0288D1),
          ],
        ),
      ),
    );
  }

  Widget _buildGlow({
    double? top,
    double? bottom,
    double? left,
    double? right,
    required double size,
    required double opacity,
  }) {
    return Positioned(
      top: top,
      bottom: bottom,
      left: left,
      right: right,
      child: IgnorePointer(
        child: Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.white.withValues(
              alpha: opacity,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.white.withValues(
                  alpha: opacity * 0.8,
                ),
                blurRadius: 70,
                spreadRadius: 25,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFloatingIcon({
    required IconData icon,
    required String title,
    required Color color,
    required double alignment,
  }) {
    final floating = math.sin(
          _floatingController.value * math.pi * 2,
        ) *
        7;

    return Transform.translate(
      offset: Offset(
        0,
        floating,
      ),
      child: Column(
        children: [
          Container(
            width: 58,
            height: 58,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.10),
              shape: BoxShape.circle,
              border: Border.all(
                color: color.withValues(alpha: 0.65),
                width: 1.2,
              ),
              boxShadow: [
                BoxShadow(
                  color: color.withValues(alpha: 0.18),
                  blurRadius: 22,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: Icon(
              icon,
              color: color,
              size: 28,
            ),
          ),
          const SizedBox(height: 7),
          Text(
            title,
            style: TextStyle(
              color: color,
              fontSize: 11,
              fontWeight: FontWeight.w800,
              letterSpacing: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLogo() {
    final pulse = 1 + (_pulseController.value * 0.035);

    return Transform.scale(
      scale: pulse,
      child: Container(
        width: 142,
        height: 142,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(38),
          border: Border.all(
            color: Colors.white.withValues(alpha: 0.9),
            width: 2,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.22),
              blurRadius: 30,
              offset: const Offset(0, 16),
            ),
            BoxShadow(
              color: const Color(0xFF90CAF9).withValues(alpha: 0.45),
              blurRadius: 35,
              spreadRadius: 2,
            ),
          ],
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            // Outer circle
            Container(
              width: 102,
              height: 102,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFFE3F2FD),
                border: Border.all(
                  color: const Color(0xFF90CAF9),
                  width: 2,
                ),
              ),
            ),

            // Road icon
            const Icon(
              Icons.add_road_rounded,
              size: 67,
              color: Color(0xFF1565C0),
            ),

            // Check badge
            Positioned(
              right: 22,
              bottom: 24,
              child: Container(
                width: 30,
                height: 30,
                decoration: BoxDecoration(
                  color: const Color(0xFF2E7D32),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: Colors.white,
                    width: 3,
                  ),
                  boxShadow: const [
                    BoxShadow(
                      color: Colors.black26,
                      blurRadius: 8,
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.check_rounded,
                  color: Colors.white,
                  size: 18,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAnimatedRoad() {
    final roadPosition = _roadController.value;

    return SizedBox(
      width: double.infinity,
      height: 92,
      child: CustomPaint(
        painter: _AnimatedRoadPainter(
          animationValue: roadPosition,
        ),
      ),
    );
  }

  Widget _buildLoadingSection() {
    final progress = _dotsController.value;

    return Column(
      children: [
        // Animated circular loader
        Transform.rotate(
          angle: progress * math.pi * 2,
          child: Container(
            width: 42,
            height: 42,
            padding: const EdgeInsets.all(3),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.20),
                width: 2,
              ),
            ),
            child: const CircularProgressIndicator(
              strokeWidth: 2.2,
              valueColor: AlwaysStoppedAnimation<Color>(
                Colors.white,
              ),
            ),
          ),
        ),

        const SizedBox(height: 15),

        const Text(
          'Preparing your safer-road',
          style: TextStyle(
            color: Colors.white,
            fontSize: 13,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.4,
          ),
        ),

        const SizedBox(height: 3),

        const Text(
          'experience...',
          style: TextStyle(
            color: Color(0xFFBBDEFB),
            fontSize: 13,
            fontWeight: FontWeight.w500,
          ),
        ),

        const SizedBox(height: 10),

        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildLoadingDot(0),
            const SizedBox(width: 7),
            _buildLoadingDot(1),
            const SizedBox(width: 7),
            _buildLoadingDot(2),
          ],
        ),
      ],
    );
  }

  Widget _buildLoadingDot(int index) {
    final value = (_dotsController.value + index * 0.22) % 1.0;

    final scale = 0.65 +
        (math.sin(value * math.pi * 2).abs() * 0.45);

    final opacity = 0.45 +
        (math.sin(value * math.pi * 2).abs() * 0.55);

    return Transform.scale(
      scale: scale,
      child: Opacity(
        opacity: opacity,
        child: Container(
          width: 7,
          height: 7,
          decoration: const BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
          ),
        ),
      ),
    );
  }
}

class _AnimatedRoadPainter extends CustomPainter {
  final double animationValue;

  _AnimatedRoadPainter({
    required this.animationValue,
  });

  @override
  void paint(
    Canvas canvas,
    Size size,
  ) {
    final centerX = size.width / 2;

    // Road
    final roadPath = Path();

    roadPath.moveTo(
      centerX - 75,
      size.height,
    );

    roadPath.lineTo(
      centerX - 42,
      0,
    );

    roadPath.lineTo(
      centerX + 42,
      0,
    );

    roadPath.lineTo(
      centerX + 75,
      size.height,
    );

    roadPath.close();

    final roadPaint = Paint()
      ..color = const Color(0xFF263238)
      ..style = PaintingStyle.fill;

    canvas.drawPath(
      roadPath,
      roadPaint,
    );

    // Road edges
    final edgePaint = Paint()
      ..color = const Color(0xFF90CAF9)
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke;

    final leftEdge = Path();

    leftEdge.moveTo(
      centerX - 75,
      size.height,
    );

    leftEdge.lineTo(
      centerX - 42,
      0,
    );

    canvas.drawPath(
      leftEdge,
      edgePaint,
    );

    final rightEdge = Path();

    rightEdge.moveTo(
      centerX + 75,
      size.height,
    );

    rightEdge.lineTo(
      centerX + 42,
      0,
    );

    canvas.drawPath(
      rightEdge,
      edgePaint,
    );

    // Moving center road markings
    final dashPaint = Paint()
      ..color = Colors.white
      ..strokeWidth = 5
      ..strokeCap = StrokeCap.round;

    const dashCount = 6;

    for (int i = 0; i < dashCount; i++) {
      final baseY =
          ((i / dashCount) + animationValue) % 1.0;

      final y = baseY * size.height;

      final roadHalfWidth =
          42 + ((y / size.height) * 33);

      final dashHeight =
          10 + ((y / size.height) * 5);

      canvas.drawLine(
        Offset(
          centerX,
          y - dashHeight,
        ),
        Offset(
          centerX,
          y,
        ),
        dashPaint,
      );

      // Small road glow
      if (i == 2 || i == 5) {
        final glowPaint = Paint()
          ..color = const Color(0xFF64B5F6)
              .withValues(alpha: 0.18)
          ..maskFilter = const MaskFilter.blur(
            BlurStyle.normal,
            8,
          );

        canvas.drawCircle(
          Offset(
            centerX,
            y,
          ),
          roadHalfWidth * 0.05,
          glowPaint,
        );
      }
    }

    // Location pin at top
    final pinPaint = Paint()
      ..color = const Color(0xFFEF5350)
      ..style = PaintingStyle.fill;

    final pinCenter = Offset(
      centerX,
      12,
    );

    canvas.drawCircle(
      pinCenter,
      9,
      pinPaint,
    );

    final pinInner = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;

    canvas.drawCircle(
      pinCenter,
      3.5,
      pinInner,
    );
  }

  @override
  bool shouldRepaint(
    covariant _AnimatedRoadPainter oldDelegate,
  ) {
    return oldDelegate.animationValue != animationValue;
  }
}