import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';

class FoodImage extends StatelessWidget {
  const FoodImage({super.key, required this.base64, this.fit = BoxFit.cover});

  final String base64;
  final BoxFit fit;

  static final Map<String, Uint8List?> _cache = {};

  static Uint8List? decode(String data) {
    if (data.isEmpty) return null;
    if (_cache.length > 60) _cache.clear();
    return _cache.putIfAbsent(data, () {
      try {
        return base64Decode(data);
      } catch (_) {
        return null;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final bytes = decode(base64);
    if (bytes == null) return const _Placeholder();
    return Image.memory(
      bytes,
      fit: fit,
      gaplessPlayback: true,
      errorBuilder: (_, _, _) => const _Placeholder(),
    );
  }
}

class _Placeholder extends StatelessWidget {
  const _Placeholder();

  @override
  Widget build(BuildContext context) => Container(
    color: Colors.white10,
    alignment: Alignment.center,
    child: const Icon(Icons.fastfood, size: 40, color: Colors.white38),
  );
}