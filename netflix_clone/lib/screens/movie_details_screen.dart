import 'package:flutter/material.dart';

import '../models/movie.dart';
import '../services/my_list_service.dart';
import 'video_player_screen.dart';

class MovieDetailsScreen extends StatefulWidget {
  final Movie movie;

  const MovieDetailsScreen({super.key, required this.movie});

  @override
  State<MovieDetailsScreen> createState() => _MovieDetailsScreenState();
}

class _MovieDetailsScreenState extends State<MovieDetailsScreen> {
  @override
  Widget build(BuildContext context) {
    final movie = widget.movie;
    final isAdded = MyListService.isInMyList(movie);

    return Scaffold(
      backgroundColor: Colors.black,

      // =========================================================
      // APP BAR
      // =========================================================
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'Movie Details',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),

      // =========================================================
      // BODY
      // =========================================================
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // =====================================================
            // MOVIE POSTER
            // =====================================================
            SizedBox(
              width: double.infinity,
              height: 500,
              child: Image.network(
                movie.imageUrl,
                fit: BoxFit.cover,

                loadingBuilder: (context, child, loadingProgress) {
                  if (loadingProgress == null) {
                    return child;
                  }

                  return Container(
                    color: Colors.grey.shade900,
                    child: const Center(
                      child: CircularProgressIndicator(color: Colors.red),
                    ),
                  );
                },

                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    color: Colors.grey.shade900,
                    child: const Center(
                      child: Icon(Icons.movie, size: 80, color: Colors.white54),
                    ),
                  );
                },
              ),
            ),

            // =====================================================
            // MOVIE INFORMATION
            // =====================================================
            Padding(
              padding: const EdgeInsets.all(20),

              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,

                children: [
                  // -------------------------------------------------
                  // TITLE
                  // -------------------------------------------------
                  Text(
                    movie.title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 30,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 12),

                  // -------------------------------------------------
                  // YEAR / HD / RATING
                  // -------------------------------------------------
                  Row(
                    children: [
                      Text(
                        movie.year,
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 15,
                        ),
                      ),

                      const SizedBox(width: 15),

                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 7,
                          vertical: 3,
                        ),

                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.white54),
                          borderRadius: BorderRadius.circular(3),
                        ),

                        child: const Text(
                          'HD',
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),

                      const SizedBox(width: 15),

                      const Icon(Icons.star, color: Colors.amber, size: 18),

                      const SizedBox(width: 5),

                      Text(
                        movie.rating.toString(),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 12),

                  // -------------------------------------------------
                  // GENRE
                  // -------------------------------------------------
                  Text(
                    movie.genre,
                    style: const TextStyle(color: Colors.white70, fontSize: 14),
                  ),

                  const SizedBox(height: 25),

                  // =================================================
                  // PLAY BUTTON
                  // =================================================
                  SizedBox(
                    width: double.infinity,
                    height: 52,

                    child: ElevatedButton.icon(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                VideoPlayerScreen(movie: movie),
                          ),
                        );
                      },

                      icon: const Icon(
                        Icons.play_arrow,
                        color: Colors.black,
                        size: 26,
                      ),

                      label: const Text(
                        'Play',
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 17,
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: Colors.black,
                        elevation: 0,

                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(6),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 12),

                  // =================================================
                  // MY LIST BUTTON
                  // =================================================
                  SizedBox(
                    width: double.infinity,
                    height: 52,

                    child: OutlinedButton.icon(
                      onPressed: () async {
                        // Get messenger before await.
                        // This avoids the async BuildContext warning.
                        final messenger = ScaffoldMessenger.of(context);

                        await MyListService.toggleMovie(movie);

                        if (!mounted) return;

                        setState(() {});

                        final nowAdded = MyListService.isInMyList(movie);

                        messenger.showSnackBar(
                          SnackBar(
                            content: Text(
                              nowAdded
                                  ? '${movie.title} added to My List'
                                  : '${movie.title} removed from My List',
                            ),
                            duration: const Duration(seconds: 2),
                          ),
                        );
                      },

                      icon: Icon(
                        isAdded ? Icons.check : Icons.add,
                        color: Colors.white,
                      ),

                      label: Text(
                        isAdded ? 'Added to My List' : 'My List',

                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                        ),
                      ),

                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: Colors.white54),

                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(6),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 30),

                  // =================================================
                  // ABOUT THIS MOVIE
                  // =================================================
                  const Text(
                    'About this movie',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 21,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 10),

                  Text(
                    movie.description,
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 15,
                      height: 1.6,
                    ),
                  ),

                  const SizedBox(height: 30),

                  // =================================================
                  // MOVIE INFORMATION
                  // =================================================
                  const Text(
                    'Movie Information',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 21,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 15),

                  _InfoRow(label: 'Title', value: movie.title),

                  _InfoRow(label: 'Release Year', value: movie.year),

                  _InfoRow(label: 'Genre', value: movie.genre),

                  _InfoRow(label: 'Rating', value: movie.rating.toString()),

                  const SizedBox(height: 20),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// =============================================================
// INFORMATION ROW
// =============================================================

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;

  const _InfoRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),

      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,

        children: [
          SizedBox(
            width: 110,

            child: Text(
              label,
              style: const TextStyle(color: Colors.white54, fontSize: 14),
            ),
          ),

          Expanded(
            child: Text(
              value,
              style: const TextStyle(color: Colors.white, fontSize: 14),
            ),
          ),
        ],
      ),
    );
  }
}
