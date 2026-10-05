import 'package:flutter/material.dart';

import '../services/my_list_service.dart';
import '../widgets/movie_card.dart';

class MyListScreen extends StatelessWidget {
  const MyListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,

      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,

        elevation: 0,

        title: const Text(
          'My List',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),

      body: ValueListenableBuilder<int>(
        valueListenable: MyListService.listVersion,

        builder: (context, version, child) {
          final myMovies = MyListService.myList;

          // ====================================================
          // EMPTY STATE
          // ====================================================

          if (myMovies.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,

                children: [
                  Container(
                    width: 90,
                    height: 90,

                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.05),

                      shape: BoxShape.circle,
                    ),

                    child: const Icon(
                      Icons.bookmark_outline,
                      size: 45,
                      color: Colors.white38,
                    ),
                  ),

                  const SizedBox(height: 22),

                  const Text(
                    'Your list is empty',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 21,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 8),

                  const Text(
                    'Add movies to watch them later.',
                    style: TextStyle(color: Colors.white54, fontSize: 13),
                  ),

                  const SizedBox(height: 20),

                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 18,
                      vertical: 10,
                    ),

                    decoration: BoxDecoration(
                      color: Colors.red,
                      borderRadius: BorderRadius.circular(5),
                    ),

                    child: const Text(
                      'Add movies from Home',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                      ),
                    ),
                  ),
                ],
              ),
            );
          }

          // ====================================================
          // MOVIE LIST
          // ====================================================

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,

            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(18, 10, 18, 5),

                child: Text(
                  '${myMovies.length} ${myMovies.length == 1 ? 'title' : 'titles'} in My List',

                  style: const TextStyle(color: Colors.white70, fontSize: 13),
                ),
              ),

              Expanded(
                child: GridView.builder(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 30),

                  physics: const BouncingScrollPhysics(),

                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 5,

                    crossAxisSpacing: 12,
                    mainAxisSpacing: 22,

                    childAspectRatio: 0.58,
                  ),

                  itemCount: myMovies.length,

                  itemBuilder: (context, index) {
                    return MovieCard(movie: myMovies[index]);
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
