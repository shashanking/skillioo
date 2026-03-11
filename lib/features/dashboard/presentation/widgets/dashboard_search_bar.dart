import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../constants/app_constants.dart';

class DashboardSearchBar extends StatefulWidget {
  final VoidCallback? onTap;
  const DashboardSearchBar({super.key, this.onTap});

  @override
  State<DashboardSearchBar> createState() => DashboardSearchBarState();
}

class DashboardSearchBarState extends State<DashboardSearchBar> {
  bool _interactive = false;
  final FocusNode _focusNode = FocusNode();

  int _currentWordIndex = 0;
  final List<String> _animatedWords = ['Coach', 'Creator', 'Singer', 'Dancer'];
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _startAnimation();
  }

  void _startAnimation() {
    _timer = Timer.periodic(const Duration(seconds: 2), (timer) {
      if (mounted) {
        setState(() {
          _currentWordIndex = (_currentWordIndex + 1) % _animatedWords.length;
        });
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _focusNode.dispose();
    super.dispose();
  }

  void requestFocus() {
    if (!_interactive) {
      setState(() {
        _interactive = true;
      });
    }
    _focusNode.requestFocus();
  }

  void reset() {
    if (_interactive) {
      setState(() {
        _interactive = false;
      });
    }
    _focusNode.unfocus();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      child: GestureDetector(
        onTap: widget.onTap,
        child: Container(
          height: 54.h,
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(28.r),
          ),
          child: Row(
            children: [
              SizedBox(width: 16.w),
              Image.asset(AppAssets.searchPng, width: 20.w, height: 20.w),
              SizedBox(width: 12.w),
              Expanded(
                child: Stack(
                  alignment: Alignment.centerLeft,
                  children: [
                    // The actual TextField (transparent background, no hint)
                    TextField(
                      focusNode: _focusNode,
                      readOnly: !_interactive,
                      onTap: () {
                        if (!_interactive) {
                          FocusScope.of(context).unfocus();
                          widget.onTap?.call();
                        }
                      },
                      decoration: const InputDecoration(
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.zero,
                      ),
                      style: TextStyle(
                        fontFamily: 'Outfit',
                        fontSize: 14.sp,
                        color: Colors.white,
                      ),
                    ),
                    // Animated hint text when not focused
                    if (!_focusNode.hasFocus && !_interactive)
                      IgnorePointer(
                        child: Row(
                          children: [
                            Text(
                              'Are you looking for ',
                              style: TextStyle(
                                fontFamily: 'Outfit',
                                fontSize: 14.sp,
                                fontWeight: FontWeight.w400,
                                color: Colors.white.withValues(alpha: 0.6),
                              ),
                            ),
                            AnimatedSwitcher(
                              duration: const Duration(milliseconds: 300),
                              transitionBuilder:
                                  (Widget child, Animation<double> animation) {
                                    return FadeTransition(
                                      opacity: animation,
                                      child: SlideTransition(
                                        position: Tween<Offset>(
                                          begin: const Offset(0.0, 0.2),
                                          end: Offset.zero,
                                        ).animate(animation),
                                        child: child,
                                      ),
                                    );
                                  },
                              child: Text(
                                _animatedWords[_currentWordIndex],
                                key: ValueKey<int>(_currentWordIndex),
                                style: TextStyle(
                                  fontFamily: 'Outfit',
                                  fontSize: 14.sp,
                                  fontWeight: FontWeight.w400,
                                  color: Colors.white.withValues(alpha: 0.6),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              ),
              SizedBox(width: 12.w),
              Image.asset(AppAssets.micPng, width: 20.w, height: 20.w),
              SizedBox(width: 16.w),
            ],
          ),
        ),
      ),
    );
  }
}
