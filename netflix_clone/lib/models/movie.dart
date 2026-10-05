class Movie {
  final String title;
  final String year;
  final String genre;
  final double rating;
  final String imageUrl;
  final String description;

  const Movie({
    required this.title,
    required this.year,
    required this.genre,
    required this.rating,
    required this.imageUrl,
    required this.description,
  });

  // =============================================================
  // CONVERT MOVIE TO JSON
  // =============================================================

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'year': year,
      'genre': genre,
      'rating': rating,
      'imageUrl': imageUrl,
      'description': description,
    };
  }

  // =============================================================
  // CREATE MOVIE FROM JSON
  // =============================================================

  factory Movie.fromJson(Map<String, dynamic> json) {
    return Movie(
      title: json['title'] as String,
      year: json['year'] as String,
      genre: json['genre'] as String,
      rating: (json['rating'] as num).toDouble(),
      imageUrl: json['imageUrl'] as String,
      description: json['description'] as String,
    );
  }
}
