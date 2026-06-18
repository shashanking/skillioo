import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../../core/widgets/custom_text.dart';
import '../services/session_prefs.dart';
import 'login_required_dialog.dart';

class BottomNavBar extends StatefulWidget {
  final int selectedIndex;
  final Function(int) onItemSelected;

  const BottomNavBar({
    super.key,
    required this.selectedIndex,
    required this.onItemSelected,
  });

  @override
  State<BottomNavBar> createState() => _BottomNavBarState();
}

class _BottomNavBarState extends State<BottomNavBar> {
  bool _isAnonymous = true;

  @override
  void initState() {
    super.initState();
    _checkAnonymousStatus();
  }

  Future<void> _checkAnonymousStatus() async {
    final isAnon = await SessionPrefs.instance.isAnonymous();
    if (mounted) {
      setState(() => _isAnonymous = isAnon);
    }
  }

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(50.r),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10.0, sigmaY: 10.0),
        child: Container(
          height: 64.h,
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(50.r),
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.2),
              width: 2,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.3),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildNavItem(
                0,
                'assets/icons/home.svg',
                "Home",
                enabled: true,
                requiresAuth: false,
              ),
              _buildNavItem(
                1,
                'assets/icons/reels.svg',
                "Reels",
                enabled: true,
                requiresAuth: false,
              ),
              _buildNavItem(
                2,
                'assets/icons/profile.svg',
                "Profile",
                enabled: !_isAnonymous,
                requiresAuth: true,
              ),
              _buildNavItem(
                3,
                'assets/icons/message.svg',
                "Chat",
                enabled: true,
                requiresAuth: true,
              ),
              _buildNavItem(
                4,
                'assets/icons/call.svg',
                "Call",
                enabled: true,
                requiresAuth: true,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(
    int index,
    String iconPath,
    String label, {
    required bool enabled,
    required bool requiresAuth,
  }) {
    final bool isSelected = widget.selectedIndex == index;

    return GestureDetector(
      onTap: enabled
          ? () {
              if (requiresAuth && _isAnonymous) {
                showLoginRequiredDialog(context, feature: label.toLowerCase());
              } else {
                widget.onItemSelected(index);
              }
            }
          : null,
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOutQuart,
        width: isSelected ? 57.w : 50.w,
        height: isSelected ? 57.w : 50.w,
        alignment: Alignment.center,
        child: Stack(
          alignment: Alignment.center,
          children: [
            AnimatedOpacity(
              duration: const Duration(milliseconds: 300),
              opacity: isSelected ? 1.0 : 0.0,
              child: Container(
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    begin: Alignment.bottomLeft,
                    end: Alignment.topRight,
                    colors: [Color(0xFF05DAF1), Color(0xFFC00F8B)],
                  ),
                ),
              ),
            ),

            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SvgPicture.asset(
                  iconPath,
                  colorFilter: const ColorFilter.mode(
                    Colors.white,
                    BlendMode.srcIn,
                  ),
                  width: isSelected ? 20.sp : 18.sp,
                  height: isSelected ? 20.sp : 18.sp,
                ),

                AnimatedSize(
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeOutQuart,
                  child: SizedBox(
                    height: isSelected ? null : 0,
                    child: Padding(
                      padding: EdgeInsets.only(top: 4.h),
                      child: AnimatedOpacity(
                        duration: const Duration(milliseconds: 200),
                        opacity: isSelected ? 1.0 : 0.0,
                        child: CustomText(
                          label,
                          fontSize: 10.sp,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                          maxLines: 1,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
