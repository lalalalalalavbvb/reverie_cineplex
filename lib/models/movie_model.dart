/// โมเดลหนัง แปลงมาจาก response ของ TMDB API
/// อ้างอิง: https://developer.themoviedb.org/reference/movie-now-playing-list
class MovieModel {
  final int id;
  final String title;
  final String overview;
  final String? posterPath;
  final String? backdropPath;
  final double voteAverage;
  final String releaseDate;
  final List<int> genreIds;
  final int? runtimeMinutes; // มีเฉพาะตอนเรียก /movie/{id} (detail)

  MovieModel({
    required this.id,
    required this.title,
    required this.overview,
    required this.posterPath,
    required this.backdropPath,
    required this.voteAverage,
    required this.releaseDate,
    required this.genreIds,
    this.runtimeMinutes,
  });

  factory MovieModel.fromJson(Map<String, dynamic> json) {
    return MovieModel(
      id: json['id'] as int,
      title: (json['title'] ?? json['original_title'] ?? '') as String,
      overview: (json['overview'] ?? '') as String,
      posterPath: json['poster_path'] as String?,
      backdropPath: json['backdrop_path'] as String?,
      voteAverage: ((json['vote_average'] ?? 0) as num).toDouble(),
      releaseDate: (json['release_date'] ?? '') as String,
      genreIds: (json['genre_ids'] as List<dynamic>?)
              ?.map((e) => e as int)
              .toList() ??
          const [],
      runtimeMinutes: json['runtime'] as int?,
    );
  }

  /// TMDB คืนมาแค่ path เช่น "/abc.jpg" ต้องต่อ base url เอง
  /// ขนาดโปสเตอร์ที่ใช้บ่อย: w342 (การ์ด), w780 (hero/backdrop)
  String posterUrl({String size = 'w342'}) => posterPath == null
      ? ''
      : 'https://image.tmdb.org/t/p/$size$posterPath';

  String backdropUrl({String size = 'w780'}) => backdropPath == null
      ? ''
      : 'https://image.tmdb.org/t/p/$size$backdropPath';

  String get year => releaseDate.length >= 4 ? releaseDate.substring(0, 4) : '';
}
