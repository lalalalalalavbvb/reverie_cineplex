import 'package:flutter/material.dart';
import '../../core/theme.dart';
import '../../models/movie_model.dart';
import '../../services/api_service.dart';
import '../../widgets/custom_button.dart';
import '../../models/booking_model.dart';
import '../booking/booking_flow.dart';

class MovieDetailScreen extends StatefulWidget {
  final int movieId;
  const MovieDetailScreen({
    super.key,
    required this.movieId,
    this.onTicketPreview,
  });
  final ValueChanged<BookingModel>? onTicketPreview;

  @override
  State<MovieDetailScreen> createState() => _MovieDetailScreenState();
}

class _MovieDetailScreenState extends State<MovieDetailScreen> {
  final _api = ApiService();
  late Future<MovieModel> _future;
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
            return const SafeArea(
              child: Column(
                children: [
                  Align(alignment: Alignment.centerLeft, child: BackButton()),
                  Expanded(child: Center(child: CircularProgressIndicator())),
                ],
              ),
            );
          }
          if (snap.hasError || !snap.hasData) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const BackButton(),
                  const Text(
                    'โหลดข้อมูลหนังไม่สำเร็จ',
                    style: TextStyle(color: AppColors.textMuted),
                  ),
                  TextButton(
                    onPressed: () => setState(
                      () => _future = _api.getMovieDetail(widget.movieId),
                    ),
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
                                Colors.black.withValues(alpha: 0.35),
                                BlendMode.darken,
                              ),
                            )
                          : null,
                    ),
                    alignment: Alignment.bottomLeft,
                    padding: const EdgeInsets.all(20),
                    child: Text(
                      movie.title,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
              ),
              SliverPadding(
                padding: const EdgeInsets.all(20),
                sliver: SliverList(
                  delegate: SliverChildListDelegate([
                    Row(
                      children: [
                        Text(
                          '⭐ ${movie.voteAverage.toStringAsFixed(1)}',
                          style: const TextStyle(
                            color: AppColors.accent,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(width: 8),
                        if (movie.runtimeMinutes != null)
                          Text(
                            '${movie.runtimeMinutes} นาที',
                            style: const TextStyle(
                              color: AppColors.textMuted,
                              fontSize: 12,
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      movie.overview.isEmpty
                          ? 'ยังไม่มีเรื่องย่อ'
                          : movie.overview,
                      style: const TextStyle(
                        color: AppColors.textMuted,
                        height: 1.6,
                      ),
                    ),
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
          child: FutureBuilder<MovieModel>(
            future: _future,
            builder: (context, snapshot) => CustomButton(
              label: 'เลือกรอบฉาย / จองตั๋ว',
              onPressed: !snapshot.hasData
                  ? null
                  : () => Navigator.push(
                      context,
                      MaterialPageRoute<void>(
                        builder: (_) => BookingFlow(
                          movie: snapshot.data!,
                          onTicketPreview: widget.onTicketPreview,
                        ),
                      ),
                    ),
            ),
          ),
        ),
      ),
    );
  }
}
