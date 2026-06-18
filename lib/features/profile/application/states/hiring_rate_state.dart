import 'package:freezed_annotation/freezed_annotation.dart';

part 'hiring_rate_state.freezed.dart';

enum HiringRateStatus { initial, loading, success, error }

@freezed
class HiringRateState with _$HiringRateState {
  const factory HiringRateState({
    @Default(HiringRateStatus.initial) HiringRateStatus status,
    @Default({}) Map<String, dynamic> hiringRateData,
    @Default('') String errorMessage,
  }) = _HiringRateState;
}
