import 'package:flutter/material.dart';
import '../../core/theme.dart';
import '../../models/movie_model.dart';
import '../../services/api_service.dart';
import '../../widgets/custom_button.dart';

/// หน้ารายละเอียดหนัง + เลือกรอบฉาย รวมอยู่หน้าเดียวกัน
/// (โครงสร้างโปรเจกต์ยังไม่มีไฟล์ showtime แยก ถ้าจะแยกทีหลัง
///  ย้าย _ShowtimeSection ไปเป็น screens/booking/showtime_page.dart ได้เลย)
class MovieDetailScreen extends StatefulWidget {
  final int movieId;
  const MovieDetailScreen({super.key, required this.movieId});

  @override
  State<MovieDetailScreen> createState() => _MovieDetailScreenState();
}

class _MovieDetailScreenState extends State<MovieDetailScreen> {
  final _api = ApiService();
  late Future<MovieModel> _future;
  int _selectedDate = 0;
  String? _selectedTime;

  // ข้อมูลโรง/รอบฉายเป็น mock ไว้ก่อน — ของจริงเพื่อนคนที่ 2/3 จะดึงจาก Firestore
  // (TMDB ไม่มีข้อมูลโรงหนัง/รอบฉาย)
  final _cinemas = const [
    {'name': 'CineGo สาขาสยาม', 'info': 'โรง 3 · 2D · ซับไทย', 'times': ['13:00', '15:30', '18:00', '20:45']},
    {'name': 'CineGo สาขาเมกา', 'info': 'โรง 1 · IMAX', 'times': ['14:00', '17:15', '21:00']},
  ];

  @override
  void initState() {
    super.initState();
    _future = _api.getMovieDetail(widget.movieId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder<MovieModel>(
        future: _future,
        builder: (context, snap) {
          if (snap.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snap.hasError || !snap.hasData) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('โหลดข้อมูลหนังไม่สำเร็จ',
                      style: TextStyle(color: AppColors.textMuted)),
                  TextButton(
                    onPressed: () => setState(() => _future = _api.getMovieDetail(widget.movieId)),
                    child: const Text('ลองใหม่'),
                  ),
                ],
              ),
            );
          }
          final movie = snap.data!;
          return CustomScrollView(
            slivers: [
              SliverAppBar(
                expandedHeight: 260,
                pinned: true,
                backgroundColor: AppColors.bg,
                flexibleSpace: FlexibleSpaceBar(
                  background: Container(
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [Color(0xFF5A189A), AppColors.primary],
                      ),
                      image: movie.backdropPath != null
                          ? DecorationImage(
                              image: NetworkImage(movie.backdropUrl()),
                              fit: BoxFit.cover,
                              colorFilter: ColorFilter.mode(
                                  Colors.black.withOpacity(0.35), BlendMode.darken),
                            )
                          : null,
                    ),
                    alignment: Alignment.bottomLeft,
                    padding: const EdgeInsets.all(20),
                    child: Text(movie.title,
                        style: const TextStyle(
                            color: Colors.white, fontSize: 24, fontWeight: FontWeight.w700)),
                  ),
                ),
              ),
              SliverPadding(
                padding: const EdgeInsets.all(20),
                sliver: SliverList(
                  delegate: SliverChildListDelegate([
                    Row(
                      children: [
                        Text('⭐ ${movie.voteAverage.toStringAsFixed(1)}',
                            style: const TextStyle(
                                color: AppColors.accent, fontWeight: FontWeight.w600)),
                        const SizedBox(width: 8),
                        if (movie.runtimeMinutes != null)
                          Text('${movie.runtimeMinutes} นาที',
                              style: const TextStyle(color: AppColors.textMuted, fontSize: 12)),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(movie.overview.isEmpty ? 'ยังไม่มีเรื่องย่อ' : movie.overview,
                        style: const TextStyle(color: AppColors.textMuted, height: 1.6)),
                    const SizedBox(height: 24),
                    const Text('เลือกรอบฉาย',
                        style: TextStyle(
                            color: AppColors.textMain,
                            fontWeight: FontWeight.w600,
                            fontSize: 16)),
                    const SizedBox(height: 12),
                    _dateRow(),
                    const SizedBox(height: 16),
                    for (final c in _cinemas) _cinemaCard(c),
                  ]),
                ),
              ),
            ],
          );
        },
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 12),
          child: CustomButton(
            label: 'ไปเลือกที่นั่ง',
            onPressed: _selectedTime == null
                ? null
                : () {
                    // TODO: ต่อกับ Navigator.pushNamed('/seat', arguments: {...})
                    // หน้าเลือกที่นั่งเป็นงานของคนที่ 3 (Booking + Admin)
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('ไปที่นั่ง: รอบ $_selectedTime')),
                    );
                  },
          ),
        ),
      ),
    );
  }

  Widget _dateRow() {
    final days = ['จ', 'อ', 'พ', 'พฤ', 'ศ'];
    return Row(
      children: List.generate(days.length, (i) {
        final active = _selectedDate == i;
        return Expanded(
          child: GestureDetector(
            onTap: () => setState(() {
              _selectedDate = i;
              _selectedTime = null;
            }),
            child: Container(
              margin: const EdgeInsets.only(right: 8),
              padding: const EdgeInsets.symmetric(vertical: 10),
              decoration: BoxDecoration(
                color: active ? AppColors.primary : AppColors.surface1,
                borderRadius: BorderRadius.circular(12),
              ),
              alignment: Alignment.center,
              child: Column(
                children: [
                  Text(days[i],
                      style: TextStyle(
                          fontSize: 11, color: active ? Colors.white : AppColors.textMuted)),
                  Text('${24 + i}',
                      style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: active ? Colors.white : AppColors.textMain)),
                ],
              ),
            ),
          ),
        );
      }),
    );
  }

  Widget _cinemaCard(Map<String, dynamic> c) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface1,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(c['name'] as String,
              style: const TextStyle(color: AppColors.textMain, fontWeight: FontWeight.w600)),
          Text(c['info'] as String,
              style: const TextStyle(color: AppColors.textMuted, fontSize: 12)),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: (c['times'] as List<String>).map((t) {
              final active = _selectedTime == t;
              return GestureDetector(
                onTap: () => setState(() => _selectedTime = t),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                        color: active ? AppColors.primary : AppColors.surface2, width: 1.4),
                  ),
                  child: Text(t,
                      style: TextStyle(
                          fontSize: 13,
                          color: active ? AppColors.primary : AppColors.textMain,
                          fontWeight: active ? FontWeight.w600 : FontWeight.w400)),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}
