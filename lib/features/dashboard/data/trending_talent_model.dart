import 'package:flutter/material.dart';

class TrendingTalent {
  final String name;
  final String views;
  final String likes;
  final String timer;
  final String imagePath;
  final Color tintColor;
  final Duration initialDuration;

  const TrendingTalent({
    required this.name,
    required this.views,
    required this.likes,
    required this.timer,
    required this.imagePath,
    required this.tintColor,
    Duration? initialDuration,
  }) : initialDuration = initialDuration ?? const Duration(seconds: 85);
}
