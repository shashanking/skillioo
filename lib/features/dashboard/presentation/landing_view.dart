import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:skillioo/core/widgets/bottom_nav_bar.dart';
import 'package:skillioo/features/dashboard/presentation/widgets/placeholder_tabs.dart';

import 'dashboard_screen.dart';

class Landing extends StatefulWidget {
  const Landing({super.key, this.initialTab = 0});

  final int initialTab;

  @override
  State<Landing> createState() => _LandingState();
}

class _LandingState extends State<Landing> {
  late int _currentIndex;
  bool _showNavBar = true;

  late final List<Widget> _pages;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialTab;
    _pages = [
      const DashboardScreen(),
      const ReelsTab(),
      const ProfileMainTab(),
      ChatTab(onChatStateChanged: _onNavBarStateChanged),
      CallTab(onCallStateChanged: _onNavBarStateChanged),
    ];
  }

  @override
  void didUpdateWidget(covariant Landing oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.initialTab != oldWidget.initialTab) {
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      resizeToAvoidBottomInset: !_showNavBar,
      body: Stack(
        fit: StackFit.expand,
        children: [
          // 1. The Content Layer
          IndexedStack(index: _currentIndex, children: _pages),

          // 2. The Floating Glassy Nav Bar Layer
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
