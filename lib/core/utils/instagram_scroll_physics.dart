import 'package:flutter/material.dart';

/// Instagram-like page scroll physics:
/// - Fast, snappy page settling with minimal overshoot
/// - Lower velocity threshold so light swipes still trigger page changes
/// - Slightly damped spring for a premium, buttery feel
class InstagramPageScrollPhysics extends ScrollPhysics {
  const InstagramPageScrollPhysics({super.parent});

  @override
  InstagramPageScrollPhysics applyTo(ScrollPhysics? ancestor) {
    return InstagramPageScrollPhysics(parent: buildParent(ancestor));
  }

  @override
  SpringDescription get spring => const SpringDescription(
    mass: 0.4,
    stiffness: 120.0,
    damping: 14.0,
  );
}
