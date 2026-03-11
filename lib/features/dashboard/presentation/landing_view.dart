import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:skillioo/core/widgets/bottom_nav_bar.dart';
import 'package:skillioo/features/dashboard/presentation/widgets/placeholder_tabs.dart';

import '../../online/application/online_providers.dart';
import 'dashboard_screen.dart';

class Landing extends ConsumerStatefulWidget {
  const Landing({super.key, this.initialTab = 0, this.initialRecipientId = ''});

  final int initialTab;
  final String initialRecipientId;

  @override
  ConsumerState<Landing> createState() => _LandingState();
}

class _LandingState extends ConsumerState<Landing> {
  late int _currentIndex;
  bool _showNavBar = false; // Hidden by default at top

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialTab;

    // Initialize socket connection
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final socketService = ref.read(socketServiceProvider);
      socketService.connect();

      // Update online notifier connection status
      ref.read(onlineNotifierProvider.notifier).setConnected(true);
    });
  }

  @override
  void dispose() {
    // Disconnect socket when leaving app
    final socketService = ref.read(socketServiceProvider);
    socketService.disconnect();
    ref.read(onlineNotifierProvider.notifier).setConnected(false);
    super.dispose();
  }

  @override
  void didUpdateWidget(covariant Landing oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.initialTab != oldWidget.initialTab ||
        widget.initialRecipientId != oldWidget.initialRecipientId) {
      setState(() {
        _currentIndex = widget.initialTab;
      });
    }
  }

  void _onNavBarStateChanged(bool hideNavBar) {
    setState(() {
      _showNavBar = !hideNavBar;
    });
  }

  void _onDashboardScrollChanged(bool shouldShow) {
    if (_showNavBar != shouldShow) {
      setState(() {
        _showNavBar = shouldShow;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      resizeToAvoidBottomInset: !_showNavBar,
      body: Stack(
        fit: StackFit.expand,
        children: [
          // 1. The Content Layer
          IndexedStack(
            index: _currentIndex,
            children: [
              DashboardScreen(onScrollChanged: _onDashboardScrollChanged),
              ReelsTab(isActive: _currentIndex == 1),
              const ProfileMainTab(),
              ChatTab(
                key: ValueKey('chat-tab-${widget.initialRecipientId}'),
                onChatStateChanged: _onNavBarStateChanged,
                initialRecipientId: widget.initialRecipientId,
              ),
              CallTab(onCallStateChanged: _onNavBarStateChanged),
            ],
          ),

          // 3. The Floating Glassy Nav Bar Layer
          if (_showNavBar)
            Positioned(
              bottom: 20.h,
              left: 20.w,
              right: 20.w,
              child: BottomNavBar(
                selectedIndex: _currentIndex,
                onItemSelected: (index) {
                  setState(() {
                    _currentIndex = index;
                  });
                },
              ),
            ),
        ],
      ),
    );
  }
}
