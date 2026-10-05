import 'package:flutter/material.dart';

import '../data/movie_data.dart';
import '../models/movie.dart';
import '../widgets/movie_card.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController searchController = TextEditingController();

  List<Movie> filteredMovies = movies;

  @override
  void initState() {
    super.initState();

    searchController.addListener(searchMovies);
  }

  // ============================================================
  // SEARCH MOVIES
  // ============================================================

  void searchMovies() {
    final query = searchController.text.toLowerCase().trim();

    setState(() {
      if (query.isEmpty) {
        filteredMovies = movies;
      } else {
        filteredMovies = movies.where((movie) {
          return movie.title.toLowerCase().contains(query) ||
              movie.genre.toLowerCase().contains(query);
        }).toList();
      }
    });
  }

  // ============================================================
  // CLEAR SEARCH
  // ============================================================

  void clearSearch() {
    searchController.clear();
  }

  @override
  void dispose() {
    searchController.removeListener(searchMovies);
    searchController.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,

      // ========================================================
      // APP BAR
      // ========================================================
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        elevation: 0,

        title: const Text(
          'Search',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),

      // ========================================================
      // BODY
      // ========================================================
      body: Column(
        children: [
          // ======================================================
          // SEARCH BAR
          // ======================================================

          Padding(
            padding: const EdgeInsets.fromLTRB(16, 10, 16, 16),

            child: TextField(
              controller: searchController,

              style: const TextStyle(color: Colors.white),

              decoration: InputDecoration(
                hintText: 'Search movies or genres...',

                hintStyle: const TextStyle(color: Colors.white54),

                prefixIcon: const Icon(Icons.search, color: Colors.white70),

                suffixIcon: searchController.text.isNotEmpty
                    ? IconButton(
                        onPressed: clearSearch,
                        icon: const Icon(Icons.clear, color: Colors.white70),
                      )
                    : null,

                filled: true,

                fillColor: const Color(0xFF242424),

                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide.none,
                ),

                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: Colors.white54),
                ),
              ),
            ),
          ),

          // ======================================================
          // RESULT COUNT
          // ======================================================
          if (searchController.text.isNotEmpty)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),

              child: Align(
                alignment: Alignment.centerLeft,

                child: Text(
                  '${filteredMovies.length} result(s) found',

                  style: const TextStyle(color: Colors.white70, fontSize: 14),
                ),
              ),
            ),

          // ======================================================
          // MOVIE RESULTS
          // ======================================================
          Expanded(
            child: filteredMovies.isEmpty
                ? const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,

                      children: [
                        Icon(Icons.search_off, size: 70, color: Colors.white38),

                        SizedBox(height: 20),

                        Text(
                          'No movies found',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),

                        SizedBox(height: 8),

                        Text(
                          'Try searching with another name.',
                          style: TextStyle(color: Colors.white54, fontSize: 14),
                        ),
                      ],
                    ),
                  )
                : GridView.builder(
                    padding: const EdgeInsets.all(16),

                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 5,
                          crossAxisSpacing: 12,
                          mainAxisSpacing: 20,
                          childAspectRatio: 0.58,
                        ),

                    itemCount: filteredMovies.length,

                    itemBuilder: (context, index) {
                      return MovieCard(movie: filteredMovies[index]);
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
