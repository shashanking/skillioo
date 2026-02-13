import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:skillioo/core/widgets/bottom_nav_bar.dart';
import 'package:skillioo/features/dashboard/presentation/widgets/placeholder_tabs.dart';

import 'dashboard_screen.dart';

class Landing extends StatefulWidget {
  const Landing({super.key});

  @override
  State<Landing> createState() => _LandingState();
}

class _LandingState extends State<Landing> {
  int _currentIndex = 0;

  late final List<Widget> _pages;

  @override
  void initState() {
    super.initState();
    _pages = [
      const DashboardScreen(),
      const ReelsTab(),
      const ProfileMainTab(),
      const ChatTab(),
      const CallTab(),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      resizeToAvoidBottomInset: false,
      body: Stack(
        fit: StackFit.expand,
        children: [
          // 1. The Content Layer
          IndexedStack(index: _currentIndex, children: _pages),

          // 2. The Floating Glassy Nav Bar Layer
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
