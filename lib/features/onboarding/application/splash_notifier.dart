import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'splash_state.dart';

class SplashNotifier extends StateNotifier<SplashState> {
  SplashNotifier() : super(const SplashState());

  void onAnimationComplete() {
    state = state.copyWith(isAnimationComplete: true);

    // Add a small delay before navigation for smooth transition
    Future.delayed(const Duration(milliseconds: 500), () {
      state = state.copyWith(shouldNavigate: true);
    });
  }

  void reset() {
    state = const SplashState();
  }
}
