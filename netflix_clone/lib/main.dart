import 'package:flutter/material.dart';

import 'models/movie.dart';
import 'data/movie_data.dart';
import 'widgets/movie_card.dart';

import 'screens/my_list_screen.dart';
import 'screens/movie_details_screen.dart';
import 'screens/search_screen.dart';
import 'screens/profile_screen.dart';
import 'screens/splash_screen.dart';

import 'services/my_list_service.dart';
import 'services/language_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await MyListService.loadMyList();
  await LanguageService.loadLanguage();

  runApp(const NetflixCloneApp());
}

// ============================================================
// APP
// ============================================================

class NetflixCloneApp extends StatelessWidget {
  const NetflixCloneApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<String>(
      valueListenable: LanguageService.language,
      builder: (context, language, child) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'Netflix Clone',

          theme: ThemeData(
            brightness: Brightness.dark,
            scaffoldBackgroundColor: Colors.black,
            primaryColor: Colors.red,

            colorScheme: ColorScheme.fromSeed(
              seedColor: Colors.red,
              brightness: Brightness.dark,
            ),

            useMaterial3: true,

            appBarTheme: const AppBarTheme(
              backgroundColor: Colors.black,
              foregroundColor: Colors.white,
              elevation: 0,
              surfaceTintColor: Colors.transparent,
            ),
          ),

          home: const SplashScreen(),
        );
      },
    );
  }
}

// ============================================================
// HOME SCREEN
// ============================================================

class HomeScreen extends StatefulWidget {
  final String profileName;

  const HomeScreen({super.key, this.profileName = 'Padmini'});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int selectedIndex = 0;

  late final List<Widget> screens;

  @override
  void initState() {
    super.initState();

    screens = [
      HomeContent(profileName: widget.profileName),
      const SearchScreen(),
      const MyListScreen(),
      const ProfileScreen(),
    ];
  }

  void onNavigationTap(int index) {
    setState(() {
      selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,

      body: IndexedStack(index: selectedIndex, children: screens),

      bottomNavigationBar: ValueListenableBuilder<String>(
        valueListenable: LanguageService.language,

        builder: (context, language, child) {
          return NavigationBarTheme(
            data: NavigationBarThemeData(
              backgroundColor: const Color(0xff090909),

              indicatorColor: Colors.red.withValues(alpha: 0.18),

              labelTextStyle: WidgetStateProperty.all(
                const TextStyle(fontSize: 11, fontWeight: FontWeight.w500),
              ),
            ),

            child: NavigationBar(
              selectedIndex: selectedIndex,

              onDestinationSelected: onNavigationTap,

              height: 68,

              destinations: [
                NavigationDestination(
                  icon: const Icon(Icons.home_outlined),

                  selectedIcon: const Icon(Icons.home, color: Colors.red),

                  label: LanguageService.text('Home', 'హోమ్'),
                ),

                NavigationDestination(
                  icon: const Icon(Icons.search),

                  selectedIcon: const Icon(Icons.search, color: Colors.red),

                  label: LanguageService.text('Search', 'శోధన'),
                ),

                NavigationDestination(
                  icon: const Icon(Icons.bookmark_border),

                  selectedIcon: const Icon(Icons.bookmark, color: Colors.red),

                  label: LanguageService.text('My List', 'నా జాబితా'),
                ),

                NavigationDestination(
                  icon: const Icon(Icons.person_outline),

                  selectedIcon: const Icon(Icons.person, color: Colors.red),

                  label: LanguageService.text('Profile', 'ప్రొఫైల్'),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

// ============================================================
// HOME CONTENT
// ============================================================

class HomeContent extends StatelessWidget {
  final String profileName;

  const HomeContent({super.key, required this.profileName});

  // ==========================================================
  // MOVIE CATEGORIES
  // ==========================================================

  static final List<Movie> trendingMovies = [
    movies[0],
    movies[1],
    movies[2],
    movies[4],
    movies[6],
    movies[11],
  ];

  static final List<Movie> popularMovies = [
    movies[2],
    movies[3],
    movies[5],
    movies[7],
    movies[8],
    movies[13],
  ];

  static final List<Movie> topRatedMovies = [
    movies[0],
    movies[2],
    movies[3],
    movies[1],
    movies[19],
    movies[16],
  ];

  static final List<Movie> newReleaseMovies = [
    movies[13],
    movies[17],
    movies[12],
    movies[19],
    movies[9],
    movies[5],
  ];

  static final List<Movie> topTenMovies = [
    movies[0],
    movies[2],
    movies[1],
    movies[3],
    movies[4],
    movies[6],
    movies[11],
    movies[5],
    movies[7],
    movies[8],
  ];

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<String>(
      valueListenable: LanguageService.language,

      builder: (context, language, child) {
        return Scaffold(
          backgroundColor: Colors.black,

          body: CustomScrollView(
            physics: const BouncingScrollPhysics(),

            slivers: [
              // ==================================================
              // TOP BAR
              // ==================================================

              SliverAppBar(
                backgroundColor: Colors.black,

                surfaceTintColor: Colors.transparent,

                floating: true,

                titleSpacing: 18,

                title: Row(
                  children: [
                    const Text(
                      'N',
                      style: TextStyle(
                        color: Colors.red,
                        fontSize: 31,
                        fontWeight: FontWeight.w900,
                        letterSpacing: -2,
                      ),
                    ),

                    const SizedBox(width: 10),

                    const Text(
                      'NETFLIX',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.5,
                      ),
                    ),
                  ],
                ),

                actions: [
                  // SEARCH

                  IconButton(
                    tooltip: LanguageService.text('Search', 'శోధన'),

                    icon: const Icon(
                      Icons.search,
                      color: Colors.white,
                      size: 26,
                    ),

                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const SearchScreen(),
                        ),
                      );
                    },
                  ),

                  const SizedBox(width: 4),

                  // PROFILE
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const ProfileScreen(),
                        ),
                      );
                    },

                    child: Container(
                      width: 36,
                      height: 36,

                      margin: const EdgeInsets.only(right: 15),

                      alignment: Alignment.center,

                      decoration: BoxDecoration(
                        color: Colors.red,

                        borderRadius: BorderRadius.circular(6),

                        border: Border.all(color: Colors.white24),

                        boxShadow: [
                          BoxShadow(
                            color: Colors.red.withValues(alpha: 0.25),

                            blurRadius: 8,
                          ),
                        ],
                      ),

                      child: Text(
                        profileName.isNotEmpty
                            ? profileName[0].toUpperCase()
                            : 'P',

                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 17,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),

              // ==================================================
              // WELCOME
              // ==================================================
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(18, 8, 18, 0),

                  child: Row(
                    children: [
                      Flexible(
                        child: Text(
                          '${LanguageService.text('Welcome back', 'తిరిగి స్వాగతం')}, $profileName',

                          overflow: TextOverflow.ellipsis,

                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 19,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),

                      const SizedBox(width: 6),

                      const Text('👋', style: TextStyle(fontSize: 18)),
                    ],
                  ),
                ),
              ),

              // ==================================================
              // HERO
              // ==================================================
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.only(top: 14),

                  child: _FeaturedMovie(movie: movies[0]),
                ),
              ),

              // ==================================================
              // TRENDING
              // ==================================================
              SliverToBoxAdapter(
                child: SectionTitle(
                  title: LanguageService.text(
                    'Trending Now',
                    'ఇప్పుడు ట్రెండింగ్',
                  ),
                ),
              ),

              SliverToBoxAdapter(child: MovieRow(moviesList: trendingMovies)),

              // ==================================================
              // TOP 10
              // ==================================================
              SliverToBoxAdapter(
                child: SectionTitle(
                  title: LanguageService.text(
                    'Top 10 Movies Today',
                    'ఈరోజు టాప్ 10 సినిమాలు',
                  ),
                ),
              ),

              SliverToBoxAdapter(child: TopTenRow(moviesList: topTenMovies)),

              // ==================================================
              // POPULAR
              // ==================================================
              SliverToBoxAdapter(
                child: SectionTitle(
                  title: LanguageService.text(
                    'Popular on Netflix',
                    'నెట్‌ఫ్లిక్స్‌లో పాపులర్',
                  ),
                ),
              ),

              SliverToBoxAdapter(child: MovieRow(moviesList: popularMovies)),

              // ==================================================
              // NEW RELEASES
              // ==================================================
              SliverToBoxAdapter(
                child: SectionTitle(
                  title: LanguageService.text('New Releases', 'కొత్త విడుదలలు'),
                ),
              ),

              SliverToBoxAdapter(child: MovieRow(moviesList: newReleaseMovies)),

              // ==================================================
              // TOP RATED
              // ==================================================
              SliverToBoxAdapter(
                child: SectionTitle(
                  title: LanguageService.text('Top Rated', 'అత్యధిక రేటింగ్'),
                ),
              ),

              SliverToBoxAdapter(child: MovieRow(moviesList: topRatedMovies)),

              // ==================================================
              // FOOTER
              // ==================================================
              const SliverToBoxAdapter(child: SizedBox(height: 35)),

              SliverToBoxAdapter(
                child: Column(
                  children: [
                    const Text(
                      'N',
                      style: TextStyle(
                        color: Colors.red,
                        fontSize: 28,
                        fontWeight: FontWeight.w900,
                      ),
                    ),

                    const SizedBox(height: 8),

                    const Text(
                      'Netflix Clone',
                      style: TextStyle(
                        color: Colors.white54,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 5),

                    Text(
                      LanguageService.text(
                        'Flutter Project',
                        'ఫ్లట్టర్ ప్రాజెక్ట్',
                      ),

                      style: const TextStyle(
                        color: Colors.white30,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ),

              const SliverToBoxAdapter(child: SizedBox(height: 35)),
            ],
          ),
        );
      },
    );
  }
}

// ============================================================
// FEATURED MOVIE
// ============================================================

class _FeaturedMovie extends StatelessWidget {
  final Movie movie;

  const _FeaturedMovie({required this.movie});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 500,

      margin: const EdgeInsets.symmetric(horizontal: 10),

      child: Stack(
        fit: StackFit.expand,

        children: [
          // ==================================================
          // POSTER
          // ==================================================

          ClipRRect(
            borderRadius: BorderRadius.circular(10),

            child: Image.network(
              movie.imageUrl,

              fit: BoxFit.cover,

              errorBuilder: (context, error, stackTrace) {
                return Container(
                  color: Colors.grey.shade900,

                  child: const Center(
                    child: Icon(Icons.movie, color: Colors.white54, size: 60),
                  ),
                );
              },
            ),
          ),

          // ==================================================
          // GRADIENT
          // ==================================================
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),

              gradient: LinearGradient(
                begin: Alignment.topCenter,

                end: Alignment.bottomCenter,

                colors: [
                  Colors.black.withValues(alpha: 0.15),

                  Colors.transparent,

                  Colors.black.withValues(alpha: 0.20),

                  Colors.black.withValues(alpha: 0.95),
                ],

                stops: const [0.0, 0.30, 0.60, 1.0],
              ),
            ),
          ),

          // ==================================================
          // N SERIES BADGE
          // ==================================================
          Positioned(
            top: 18,
            left: 18,

            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),

              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.55),

                borderRadius: BorderRadius.circular(5),
              ),

              child: const Text(
                'N SERIES',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.5,
                ),
              ),
            ),
          ),

          // ==================================================
          // INFORMATION
          // ==================================================
          Positioned(
            left: 22,
            right: 22,
            bottom: 20,

            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,

              children: [
                Text(
                  movie.title,

                  maxLines: 2,

                  overflow: TextOverflow.ellipsis,

                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 31,
                    fontWeight: FontWeight.w900,
                    height: 1.05,
                  ),
                ),

                const SizedBox(height: 10),

                Row(
                  children: [
                    Text(
                      movie.year,
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 13,
                      ),
                    ),

                    const SizedBox(width: 12),

                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 5,
                        vertical: 2,
                      ),

                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.white54),
                      ),

                      child: const Text(
                        'HD',
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),

                    const SizedBox(width: 12),

                    const Icon(Icons.star, color: Colors.amber, size: 16),

                    const SizedBox(width: 4),

                    Text(
                      movie.rating.toString(),

                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 7),

                Text(
                  movie.genre,

                  maxLines: 1,

                  overflow: TextOverflow.ellipsis,

                  style: const TextStyle(color: Colors.white60, fontSize: 12),
                ),

                const SizedBox(height: 16),

                // ==================================================
                // BUTTONS
                // ==================================================
                Row(
                  children: [
                    // PLAY

                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  MovieDetailsScreen(movie: movie),
                            ),
                          );
                        },

                        icon: const Icon(Icons.play_arrow, color: Colors.black),

                        label: Text(
                          LanguageService.text('Play', 'ప్లే'),

                          style: const TextStyle(
                            color: Colors.black,
                            fontWeight: FontWeight.bold,
                          ),
                        ),

                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,

                          padding: const EdgeInsets.symmetric(vertical: 13),

                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(5),
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(width: 9),

                    // MY LIST
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () async {
                          final messenger = ScaffoldMessenger.of(context);

                          final wasAdded = !MyListService.isInMyList(movie);

                          await MyListService.toggleMovie(movie);

                          if (!context.mounted) {
                            return;
                          }

                          messenger.showSnackBar(
                            SnackBar(
                              backgroundColor: Colors.grey.shade900,

                              content: Text(
                                wasAdded
                                    ? '${movie.title} ${LanguageService.text('added to My List', 'నా జాబితాకు జోడించబడింది')}'
                                    : '${movie.title} ${LanguageService.text('removed from My List', 'నా జాబితా నుండి తొలగించబడింది')}',
                              ),

                              duration: const Duration(seconds: 2),
                            ),
                          );
                        },

                        icon: Icon(
                          MyListService.isInMyList(movie)
                              ? Icons.check
                              : Icons.add,

                          color: Colors.white,
                        ),

                        label: Text(
                          LanguageService.text('My List', 'నా జాబితా'),

                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),

                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: Colors.white54),

                          padding: const EdgeInsets.symmetric(vertical: 13),

                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(5),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ============================================================
// MOVIE ROW
// ============================================================

class MovieRow extends StatelessWidget {
  final List<Movie> moviesList;

  const MovieRow({super.key, required this.moviesList});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 238,

      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 15),

        physics: const BouncingScrollPhysics(),

        scrollDirection: Axis.horizontal,

        itemCount: moviesList.length,

        separatorBuilder: (context, index) {
          return const SizedBox(width: 12);
        },

        itemBuilder: (context, index) {
          return SizedBox(
            width: 130,

            child: MovieCard(movie: moviesList[index]),
          );
        },
      ),
    );
  }
}

// ============================================================
// TOP 10 ROW
// ============================================================

class TopTenRow extends StatelessWidget {
  final List<Movie> moviesList;

  const TopTenRow({super.key, required this.moviesList});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 235,

      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 15),

        physics: const BouncingScrollPhysics(),

        scrollDirection: Axis.horizontal,

        itemCount: moviesList.length,

        separatorBuilder: (context, index) {
          return const SizedBox(width: 14);
        },

        itemBuilder: (context, index) {
          final movie = moviesList[index];

          return GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => MovieDetailsScreen(movie: movie),
                ),
              );
            },

            child: SizedBox(
              width: 155,

              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,

                children: [
                  SizedBox(
                    width: 45,

                    child: Text(
                      '${index + 1}',

                      style: TextStyle(
                        fontSize: 76,
                        fontWeight: FontWeight.w900,

                        height: 0.9,

                        foreground: Paint()
                          ..style = PaintingStyle.stroke
                          ..strokeWidth = 2
                          ..color = Colors.white38,
                      ),
                    ),
                  ),

                  Expanded(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(7),

                      child: Image.network(
                        movie.imageUrl,

                        height: 190,

                        fit: BoxFit.cover,

                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            height: 190,

                            color: Colors.grey.shade900,

                            child: const Icon(
                              Icons.movie,
                              color: Colors.white54,
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

// ============================================================
// SECTION TITLE
// ============================================================

class SectionTitle extends StatelessWidget {
  final String title;

  const SectionTitle({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(18, 25, 18, 12),

      child: Row(
        children: [
          Container(
            width: 4,
            height: 22,

            decoration: BoxDecoration(
              color: Colors.red,

              borderRadius: BorderRadius.circular(3),
            ),
          ),

          const SizedBox(width: 10),

          Expanded(
            child: Text(
              title,

              style: const TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),

          const Icon(Icons.chevron_right, color: Colors.white54, size: 22),
        ],
      ),
    );
  }
}
