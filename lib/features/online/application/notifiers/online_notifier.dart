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
      debugPrint(
        'OnlineNotifier: User $userId is ${isOnline ? 'online' : 'offline'}',
      );
    }

    // Defer state update to avoid modifying provider during widget build
    Future.microtask(() {
      if (!mounted) return;

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
    });
  }

  /// Seeds statuses from API data for users the socket hasn't reported yet.
  /// Socket events always win — this only fills in the blanks.
  void seedStatuses(Map<String, bool> statuses) {
    if (statuses.isEmpty) return;
    final updated = Map<String, bool>.from(state.userStatuses);
    bool changed = false;
    for (final entry in statuses.entries) {
      if (!updated.containsKey(entry.key)) {
        updated[entry.key] = entry.value;
        changed = true;
      }
    }
    if (changed) {
      state = state.copyWith(userStatuses: updated);
    }
  }

  void setConnected(bool connected) {
    if (state.isConnected != connected) {
      state = state.copyWith(isConnected: connected);
    }
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
