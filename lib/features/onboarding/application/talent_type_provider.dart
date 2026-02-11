import 'package:flutter_riverpod/flutter_riverpod.dart';

enum TalentType { professional, skilled }

final talentTypeProvider = StateProvider<TalentType?>((ref) => null);
