import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/movie_model.dart';

class ApiService {
  static const String _baseUrl = 'https://api.themoviedb.org/3';
  static const String _apiKey = String.fromEnvironment('TMDB_API_KEY');
  static bool get isDemo => _apiKey.isEmpty;
  static final demoMovie = MovieModel(
    id: -1,
    title: 'จีบซ้ำซ้ำ เฮนรี่จำไม่ได้',
    overview:
        'ภาพยนตร์ตัวอย่างสำหรับทดลองเลือกโรงภาพยนตร์ รอบฉาย และจองที่นั่ง ข้อมูลการจองยังไม่เชื่อมระบบจริง',
    posterPath: null,
    backdropPath: null,
    voteAverage: 0,
    releaseDate: '2026-09-17',
    genreIds: const [],
    runtimeMinutes: 115,
  );
  static const String _lang = 'th-TH';

  Future<List<MovieModel>> getNowPlaying({int page = 1}) async {
    if (isDemo) return [demoMovie];
    final uri = Uri.parse(
      '$_baseUrl/movie/now_playing?api_key=$_apiKey&language=$_lang&page=$page',
    );
    return _fetchList(uri);
  }

  Future<List<MovieModel>> getUpcoming({int page = 1}) async {
    if (isDemo) return [];
    final uri = Uri.parse(
      '$_baseUrl/movie/upcoming?api_key=$_apiKey&language=$_lang&page=$page',
    );
    return _fetchList(uri);
  }

  Future<MovieModel> getMovieDetail(int movieId) async {
    if (isDemo && movieId == demoMovie.id) return demoMovie;
    final uri = Uri.parse(
      '$_baseUrl/movie/$movieId?api_key=$_apiKey&language=$_lang',
    );
    final res = await http.get(uri);
    if (res.statusCode != 200) {
      throw ApiException('โหลดรายละเอียดหนังไม่สำเร็จ (${res.statusCode})');
    }
    return MovieModel.fromJson(jsonDecode(res.body) as Map<String, dynamic>);
  }

  Future<String?> getTrailerKey(int movieId) async {
    if (isDemo) return null;
    final uri = Uri.parse('$_baseUrl/movie/$movieId/videos?api_key=$_apiKey');
    final res = await http.get(uri);
    if (res.statusCode != 200) return null;
    final results = (jsonDecode(res.body)['results'] as List<dynamic>);
    final trailer = results.firstWhere(
      (v) => v['type'] == 'Trailer' && v['site'] == 'YouTube',
      orElse: () => null,
    );
    return trailer?['key'] as String?;
  }

  Future<List<MovieModel>> _fetchList(Uri uri) async {
    final res = await http.get(uri);
    if (res.statusCode != 200) {
      throw ApiException('เรียก TMDB ไม่สำเร็จ (${res.statusCode})');
    }
    final body = jsonDecode(res.body) as Map<String, dynamic>;
    final results = body['results'] as List<dynamic>;
    return results
        .map((e) => MovieModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }
}

class ApiException implements Exception {
  final String message;
  ApiException(this.message);
  @override
  String toString() => message;
}
