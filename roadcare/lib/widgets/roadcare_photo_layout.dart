import 'package:flutter/material.dart';

class RoadCarePhotoHeader extends StatelessWidget {
  final String imageAsset;
  final String eyebrow;
  final String title;
  final String description;
  final double height;

  const RoadCarePhotoHeader({
    super.key,
    required this.imageAsset,
    required this.eyebrow,
    required this.title,
    required this.description,
    this.height = 260,
  });

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: const Duration(milliseconds: 650),
      curve: Curves.easeOutCubic,
      builder: (context, value, child) => Opacity(
        opacity: value,
        child: Transform.translate(
          offset: Offset(0, 18 * (1 - value)),
          child: child,
        ),
      ),
      child: SizedBox(
        width: double.infinity,
        height: height,
        child: Stack(
          fit: StackFit.expand,
          children: [
            Image.asset(
              imageAsset,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) => const ColoredBox(
                color: Color(0xFF176B87),
                child: Icon(
                  Icons.add_road_rounded,
                  size: 64,
                  color: Colors.white,
                ),
              ),
            ),
            const DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Color(0x180B2434), Color(0xE60B2434)],
                ),
              ),
            ),
            Positioned(
              left: 24,
              right: 24,
              bottom: 24,
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 760),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      eyebrow.toUpperCase(),
                      style: const TextStyle(
                        color: Color(0xFFF4C95D),
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      title,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 30,
                        height: 1.12,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 7),
                    Text(
                      description,
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 14,
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class RoadCarePhotoAuthLayout extends StatelessWidget {
  final String imageAsset;
  final String eyebrow;
  final String title;
  final String description;
  final Widget content;
  final VoidCallback? onBack;

  const RoadCarePhotoAuthLayout({
    super.key,
    required this.imageAsset,
    required this.eyebrow,
    required this.title,
    required this.description,
    required this.content,
    this.onBack,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final bool wide = constraints.maxWidth >= 900;
        final Widget photo = _photoPanel(context, wide: wide);

        if (wide) {
          return Row(
            children: [
              Expanded(flex: 6, child: photo),
              Expanded(
                flex: 5,
                child: SafeArea(
                  child: Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 520),
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 42,
                          vertical: 30,
                        ),
                        child: _animatedContent(),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          );
        }

        final double heroHeight = (constraints.maxHeight * 0.34)
            .clamp(205.0, 300.0)
            .toDouble();

        return Column(
          children: [
            SizedBox(height: heroHeight, width: double.infinity, child: photo),
            Expanded(
              child: SafeArea(
                top: false,
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(26, 28, 26, 32),
                  child: _animatedContent(),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _animatedContent() {
    final ThemeData formTheme = ThemeData.light(useMaterial3: true).copyWith(
      colorScheme: ColorScheme.fromSeed(
        seedColor: const Color(0xFF176B87),
        brightness: Brightness.light,
      ),
    );

    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: const Duration(milliseconds: 700),
      curve: Curves.easeOutCubic,
      builder: (context, value, child) => Opacity(
        opacity: value,
        child: Transform.translate(
          offset: Offset(0, 20 * (1 - value)),
          child: child,
        ),
      ),
      child: Theme(
        data: formTheme,
        child: Material(
          color: formTheme.scaffoldBackgroundColor,
          child: content,
        ),
      ),
    );
  }

  Widget _photoPanel(BuildContext context, {required bool wide}) {
    return Stack(
      fit: StackFit.expand,
      children: [
        Image.asset(
          imageAsset,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) => const ColoredBox(
            color: Color(0xFF176B87),
            child: Icon(Icons.add_road_rounded, size: 64, color: Colors.white),
          ),
        ),
        const DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Color(0x100B2434), Color(0xE60B2434)],
            ),
          ),
        ),
        SafeArea(
          bottom: false,
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    if (onBack != null)
                      IconButton(
                        onPressed: onBack,
                        tooltip: 'Back',
                        style: IconButton.styleFrom(
                          backgroundColor: Colors.white24,
                          foregroundColor: Colors.white,
                        ),
                        icon: const Icon(Icons.arrow_back_rounded),
                      ),
                    const Spacer(),
                    const Text(
                      'ROADCARE',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
                const Spacer(),
                Text(
                  eyebrow.toUpperCase(),
                  style: const TextStyle(
                    color: Color(0xFFF4C95D),
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  title,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: wide ? 42 : 30,
                    height: 1.08,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 10),
                ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 480),
                  child: Text(
                    description,
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 15,
                      height: 1.5,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
