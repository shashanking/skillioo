import 'package:freezed_annotation/freezed_annotation.dart';

part 'online_state.freezed.dart';

@freezed
class OnlineState with _$OnlineState {
  const factory OnlineState({
    // Map of userId -> isOnline status
    @Default({}) Map<String, bool> userStatuses,
    
    // Map of userId -> lastSeen timestamp
    @Default({}) Map<String, DateTime> lastSeenMap,
    
    // Current user's connection status
    @Default(false) bool isConnected,
  }) = _OnlineState;
}
