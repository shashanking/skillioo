import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../domain/profile_list_service.dart';
import 'notifiers/profile_list_notifier.dart';
import 'states/profile_list_state.dart';

final profileListServiceProvider = Provider<ProfileListService>((ref) {
  return ProfileListService();
});

final profileListNotifierProvider =
    StateNotifierProvider<ProfileListNotifier, ProfileListState>((ref) {
  final service = ref.watch(profileListServiceProvider);
  return ProfileListNotifier(service);
});
