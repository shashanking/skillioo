import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/services/socket_service.dart';
import 'notifiers/online_notifier.dart';
import 'states/online_state.dart';

final socketServiceProvider = Provider<SocketService>((ref) {
  return SocketService();
});

final onlineNotifierProvider =
    StateNotifierProvider<OnlineNotifier, OnlineState>((ref) {
  final socketService = ref.watch(socketServiceProvider);
  return OnlineNotifier(socketService);
});
