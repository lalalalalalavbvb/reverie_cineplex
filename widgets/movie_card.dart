import 'package:flutter/material.dart';
import '../core/theme.dart';
import 'package:reverie_cineplex/models/movie_model.dart';

/// การ์ดโปสเตอร์หนัง ใช้ทั้งใน Home grid และหน้าอื่นๆ
/// สัดส่วน 2:3 คงที่ ไม่ว่าจะอยู่ใน grid กี่คอลัมน์ก็ตาม (responsive)
class MovieCard extends StatelessWidget {
  final MovieModel movie;
  final VoidCallback onTap;

  const MovieCard({super.key, required this.movie, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AspectRatio(
            aspectRatio: 2 / 3,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(14),
              child: movie.posterPath == null
                  ? Container(color: AppColors.surface2)
                  : Image.network(
                      movie.posterUrl(),
                      fit: BoxFit.cover,
                      loadingBuilder: (ctx, child, progress) {
                        if (progress == null) return child;
                        return Container(
                          color: AppColors.surface2,
                          child: const Center(
                            child: CircularProgressIndicator(strokeWidth: 2),
                          ),
                        );
                      },
                      errorBuilder: (ctx, err, st) =>
                          Container(color: AppColors.surface2),
                    ),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            movie.title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppColors.textMain,
                  fontWeight: FontWeight.w500,
                ),
          ),
          Row(
            children: [
              const Icon(Icons.star, size: 12, color: AppColors.accent),
              const SizedBox(width: 3),
              Text(
                movie.voteAverage.toStringAsFixed(1),
                style: const TextStyle(fontSize: 11, color: AppColors.accent),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
