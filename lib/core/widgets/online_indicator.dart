import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../features/online/application/online_providers.dart';

class OnlineIndicator extends ConsumerWidget {
  final String userId;
  final double size;
  final Color onlineColor;
  final Color offlineColor;
  final bool showBorder;
  /// Seed value from the API response, used until the socket reports status.
  final bool initialIsOnline;

  const OnlineIndicator({
    super.key,
    required this.userId,
    this.size = 12,
    this.onlineColor = const Color(0xFF00FF00),
    this.offlineColor = Colors.grey,
    this.showBorder = true,
    this.initialIsOnline = false,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final onlineState = ref.watch(onlineNotifierProvider);
    // Prefer live socket data; fall back to the API seed value.
    final isOnline = onlineState.userStatuses.containsKey(userId)
        ? onlineState.userStatuses[userId]!
        : initialIsOnline;

    return Container(
      width: size.w,
      height: size.w,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: isOnline ? onlineColor : offlineColor,
        border: showBorder
            ? Border.all(
                color: Colors.white,
                width: 2.w,
              )
            : null,
      ),
    );
  }
}
