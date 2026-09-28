import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/movie_model.dart';

/// เรียก TMDB API ภายนอกตามข้อกำหนดของโจทย์
/// สมัคร API key ฟรีที่ https://www.themoviedb.org/settings/api
/// ⚠️ ห้าม commit API key ลง GitHub ตรงๆ ให้เก็บใน --dart-define หรือไฟล์ .env ที่ไม่ push
class ApiService {
  static const String _baseUrl = 'https://api.themoviedb.org/3';
  static const String _apiKey = 'YOUR_TMDB_API_KEY'; // TODO: แทนที่ด้วยคีย์จริง
  static const String _lang = 'th-TH'; // ให้ผลลัพธ์เป็นภาษาไทยถ้ามี

  Future<List<MovieModel>> getNowPlaying({int page = 1}) async {
    final uri = Uri.parse(
        '$_baseUrl/movie/now_playing?api_key=$_apiKey&language=$_lang&page=$page');
    return _fetchList(uri);
  }

  Future<List<MovieModel>> getUpcoming({int page = 1}) async {
    final uri = Uri.parse(
        '$_baseUrl/movie/upcoming?api_key=$_apiKey&language=$_lang&page=$page');
    return _fetchList(uri);
  }

  Future<MovieModel> getMovieDetail(int movieId) async {
    final uri = Uri.parse(
        '$_baseUrl/movie/$movieId?api_key=$_apiKey&language=$_lang');
    final res = await http.get(uri);
    if (res.statusCode != 200) {
      throw ApiException('โหลดรายละเอียดหนังไม่สำเร็จ (${res.statusCode})');
    }
    return MovieModel.fromJson(jsonDecode(res.body) as Map<String, dynamic>);
  }

  /// ดึงคีย์ตัวอย่างหนัง (YouTube) สำหรับปุ่ม "ดูตัวอย่างหนัง"
  Future<String?> getTrailerKey(int movieId) async {
    final uri =
        Uri.parse('$_baseUrl/movie/$movieId/videos?api_key=$_apiKey');
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
