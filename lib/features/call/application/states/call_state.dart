import 'package:freezed_annotation/freezed_annotation.dart';

import '../../domain/call_models.dart';

part 'call_state.freezed.dart';

enum CallStateStatus {
  idle,
  loading,
  calling,
  ringing,
  incomingCall,
  success,
  error,
}

@freezed
class CallState with _$CallState {
  const factory CallState({
    @Default(CallStateStatus.idle) CallStateStatus status,
    @Default('') String errorMessage,
    @Default('') String twilioToken,
    CallData? currentCall,
    @Default(false) bool isInCall,
    @Default('') String callerId,
    @Default('') String recipientId,
    @Default('') String callerName,
    @Default('') String callerAvatar,
  }) = _CallState;
}
