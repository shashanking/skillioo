import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Types of profiles a user can choose during onboarding.
enum ProfileType { individual, group }

/// Holds the currently selected profile type for onboarding.
///
/// null means no selection has been made yet.
final profileTypeProvider = StateProvider<ProfileType?>((ref) => null);
