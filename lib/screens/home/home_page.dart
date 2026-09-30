import 'package:flutter/material.dart';
import '../../core/theme.dart';
import '../../models/movie_model.dart';
import '../../services/api_service.dart';
import '../../widgets/movie_card.dart';
import '../../widgets/bottom_nav.dart';
import '../movie/movie_detail.dart';
import '../../models/booking_model.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key, this.embedded = false, this.onTicketPreview});
  final bool embedded;
  final ValueChanged<BookingModel>? onTicketPreview;

  @override
  State<HomePage> createState() => _HomePageState();
}

enum _HomeTab { nowPlaying, upcoming }

class _HomePageState extends State<HomePage> {
  final _api = ApiService();
  final _scrollController = ScrollController();
  _HomeTab _tab = _HomeTab.nowPlaying;

  // เก็บ future แยกกัน จะได้ไม่ต้องยิง API ซ้ำทุกครั้งที่สลับแท็บ
  late Future<List<MovieModel>> _nowPlayingFuture;
  late Future<List<MovieModel>> _upcomingFuture;

  @override
  void initState() {
    super.initState();
    _nowPlayingFuture = _api.getNowPlaying();
    _upcomingFuture = _api.getUpcoming();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _refresh() async {
    setState(() {
      _nowPlayingFuture = _api.getNowPlaying();
      _upcomingFuture = _api.getUpcoming();
    });
    await Future.wait([_nowPlayingFuture, _upcomingFuture]);
  }

  @override
  Widget build(BuildContext context) {
    final isTablet = Responsive.isTablet(context);
    final activeFuture = _tab == _HomeTab.nowPlaying
        ? _nowPlayingFuture
        : _upcomingFuture;

    final body = Scrollbar(
      controller: _scrollController,
      thumbVisibility: true,
      trackVisibility: true,
      interactive: true,
      thickness: 6,
      radius: const Radius.circular(8),
      child: RefreshIndicator(
        onRefresh: _refresh,
        child: CustomScrollView(
          key: const PageStorageKey('home-movies'),
          controller: _scrollController,
          primary: false,
          physics: const AlwaysScrollableScrollPhysics(
            parent: BouncingScrollPhysics(),
          ),
          slivers: [
            SliverToBoxAdapter(child: _buildHeader()),
            if (ApiService.isDemo)
              const SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: Text(
                    'ข้อมูลตัวอย่าง • ยังไม่ได้ตั้งค่า TMDB API',
                    style: TextStyle(color: AppColors.accent),
                  ),
                ),
              ),
            SliverToBoxAdapter(child: _buildTabs()),
            SliverToBoxAdapter(child: _buildHero()),
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
              sliver: FutureBuilder<List<MovieModel>>(
                future: activeFuture,
                builder: (context, snap) {
                  if (snap.connectionState == ConnectionState.waiting) {
                    return const SliverFillRemaining(
                      child: Center(child: CircularProgressIndicator()),
                    );
                  }
                  if (snap.hasError) {
                    return SliverFillRemaining(
                      child: _ErrorState(onRetry: _refresh),
                    );
                  }
                  final movies = snap.data ?? [];
                  if (movies.isEmpty) {
                    return const SliverFillRemaining(child: _EmptyState());
                  }
                  return SliverGrid(
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: Responsive.gridColumns(context),
                      mainAxisSpacing: 16,
                      crossAxisSpacing: 16,
                      childAspectRatio: 0.55,
                    ),
                    delegate: SliverChildBuilderDelegate(
                      (context, i) => MovieCard(
                        movie: movies[i],
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => MovieDetailScreen(
                              movieId: movies[i].id,
                              onTicketPreview: widget.onTicketPreview,
                            ),
                          ),
                        ),
                      ),
                      childCount: movies.length,
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );

    // แท็บเล็ต: มี side nav แทน bottom nav (ตาม mockup)
    if (isTablet && !widget.embedded) {
      return Scaffold(
        body: Row(
          children: [
            _TabletSideNav(currentIndex: 0, onTap: (_) {}),
            Expanded(child: body),
          ],
        ),
      );
    }

    return Scaffold(
      body: SafeArea(child: body),
      bottomNavigationBar: widget.embedded
          ? null
          : AppBottomNav(currentIndex: 0, onTap: (_) {}),
    );
  }

  Widget _buildHeader() {
    final colors = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'สวัสดี,',
                style: TextStyle(color: colors.onSurfaceVariant, fontSize: 13),
              ),
              Text(
                'เม่ย 👋',
                style: TextStyle(
                  color: colors.onSurface,
                  fontSize: 22,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const CircleAvatar(
            radius: 20,
            backgroundColor: AppColors.primary,
            child: Text('ม', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  Widget _buildTabs() {
    final colors = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
      child: Container(
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: colors.surfaceContainer,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            _tabButton('กำลังฉาย', _HomeTab.nowPlaying),
            _tabButton('เร็วๆ นี้', _HomeTab.upcoming),
          ],
        ),
      ),
    );
  }

  Widget _tabButton(String label, _HomeTab tab) {
    final active = _tab == tab;
    final colors = Theme.of(context).colorScheme;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _tab = tab),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          padding: const EdgeInsets.symmetric(vertical: 9),
          decoration: BoxDecoration(
            color: active ? AppColors.primary : Colors.transparent,
            borderRadius: BorderRadius.circular(9),
          ),
          alignment: Alignment.center,
          child: Text(
            label,
            style: TextStyle(
              color: active ? Colors.white : colors.onSurfaceVariant,
              fontWeight: active ? FontWeight.w600 : FontWeight.w400,
              fontSize: 14,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHero() {
    return FutureBuilder<List<MovieModel>>(
      future: _nowPlayingFuture,
      builder: (context, snap) {
        final first = (snap.data != null && snap.data!.isNotEmpty)
            ? snap.data!.first
            : null;
        if (first == null) return const SizedBox(height: 16);
        return Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
          child: Container(
            height: 160,
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color(0xFF5A189A),
                  AppColors.primary,
                  AppColors.accent,
                ],
              ),
              image: first.backdropPath != null
                  ? DecorationImage(
                      image: NetworkImage(first.backdropUrl()),
                      fit: BoxFit.cover,
                      colorFilter: ColorFilter.mode(
                        Colors.black.withValues(alpha: 0.35),
                        BlendMode.darken,
                      ),
                    )
                  : null,
            ),
            alignment: Alignment.bottomLeft,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  first.title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                Text(
                  '⭐ ${first.voteAverage.toStringAsFixed(1)} · ${first.year}',
                  style: const TextStyle(color: Colors.white70, fontSize: 12),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _TabletSideNav extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;
  const _TabletSideNav({required this.currentIndex, required this.onTap});

  @override
  Widget build(BuildContext context) {
    const items = ['หน้าหลัก', 'ตั๋วของฉัน', 'โปรไฟล์'];
    const icons = [
      Icons.home_rounded,
      Icons.confirmation_number_rounded,
      Icons.person_rounded,
    ];
    return Container(
      width: 220,
      color: AppColors.surface1,
      padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          RichText(
            text: const TextSpan(
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
              children: [
                TextSpan(
                  text: 'Cine',
                  style: TextStyle(color: AppColors.textMain),
                ),
                TextSpan(
                  text: 'Go',
                  style: TextStyle(color: AppColors.primary),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          for (var i = 0; i < items.length; i++)
            Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: Material(
                color: i == currentIndex
                    ? AppColors.surface2
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(12),
                child: InkWell(
                  borderRadius: BorderRadius.circular(12),
                  onTap: () => onTap(i),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 12,
                    ),
                    child: Row(
                      children: [
                        Icon(
                          icons[i],
                          size: 18,
                          color: i == currentIndex
                              ? AppColors.primary
                              : AppColors.textMuted,
                        ),
                        const SizedBox(width: 10),
                        Text(
                          items[i],
                          style: TextStyle(
                            color: i == currentIndex
                                ? AppColors.primary
                                : AppColors.textMuted,
                            fontWeight: i == currentIndex
                                ? FontWeight.w600
                                : FontWeight.w400,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: const [
          Icon(
            Icons.movie_filter_outlined,
            size: 40,
            color: AppColors.textMuted,
          ),
          SizedBox(height: 8),
          Text(
            'ยังไม่มีหนังในหมวดนี้',
            style: TextStyle(color: AppColors.textMuted),
          ),
        ],
      ),
    );
  }
}

class _ErrorState extends StatelessWidget {
  final VoidCallback onRetry;
  const _ErrorState({required this.onRetry});
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.wifi_off_rounded,
            size: 40,
            color: AppColors.textMuted,
          ),
          const SizedBox(height: 8),
          const Text(
            'โหลดข้อมูลไม่สำเร็จ ลองใหม่อีกครั้ง',
            style: TextStyle(color: AppColors.textMuted),
          ),
          const SizedBox(height: 12),
          TextButton(onPressed: onRetry, child: const Text('ลองใหม่')),
        ],
      ),
    );
  }
}
