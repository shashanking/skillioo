import 'package:flutter_riverpod/flutter_riverpod.dart';

class ProfessionalBioData {
  final String bio;
  final String hourly;
  final String daily;
  final String weekly;
  final String monthly;

  const ProfessionalBioData({
    required this.bio,
    required this.hourly,
    required this.daily,
    required this.weekly,
    required this.monthly,
  });
}

final professionalBioProvider = StateProvider<ProfessionalBioData?>((ref) => null);
