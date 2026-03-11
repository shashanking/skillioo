import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/services/socket_service.dart';
import '../states/online_state.dart';

class OnlineNotifier extends StateNotifier<OnlineState> {
  final SocketService _socketService;

  OnlineNotifier(this._socketService) : super(const OnlineState()) {
    _init();
  }

  void _init() {
    // Listen to socket status changes
    _socketService.addStatusChangeListener(_handleStatusChange);
  }

  @override
  void dispose() {
    _socketService.removeStatusChangeListener(_handleStatusChange);
    super.dispose();
  }

  void _handleStatusChange(String userId, bool isOnline) {
    if (kDebugMode) {
      debugPrint('OnlineNotifier: User $userId is ${isOnline ? 'online' : 'offline'}');
    }

    final updatedStatuses = Map<String, bool>.from(state.userStatuses);
    updatedStatuses[userId] = isOnline;

    final updatedLastSeen = Map<String, DateTime>.from(state.lastSeenMap);
    if (!isOnline) {
      updatedLastSeen[userId] = DateTime.now();
    }

    state = state.copyWith(
      userStatuses: updatedStatuses,
      lastSeenMap: updatedLastSeen,
    );
  }

  void setConnected(bool connected) {
    state = state.copyWith(isConnected: connected);
  }

  bool isUserOnline(String userId) {
    return state.userStatuses[userId] ?? false;
  }

  DateTime? getLastSeen(String userId) {
    return state.lastSeenMap[userId];
  }

  void clearAllStatuses() {
    state = const OnlineState();
  }
}
