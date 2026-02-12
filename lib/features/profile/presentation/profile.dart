import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:skillioo/features/subscription/presentation/subscription.dart';

import '../../../../core/widgets/custom_text.dart';

class ProfileSectionScreen extends StatelessWidget {
  final String name;
  final String role;
  final String avatarAssetPath;

  const ProfileSectionScreen({
    super.key,
    required this.name,
    required this.role,
    required this.avatarAssetPath,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF7B2FF7), Color(0xFF14121A), Color(0xFF0C0B10)],
            stops: [0.0, 0.45, 1.0],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 20.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: 16.h),
                Row(
                  children: [
                    Expanded(
                      child: CustomText(
                        'Profile Section',
                        fontSize: 24.sp,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                    _IconCircleButton(
                      icon: Icons.close,
                      onTap: () => Navigator.of(context).maybePop(),
                    ),
                  ],
                ),
                SizedBox(height: 18.h),
                Row(
                  children: [
                    Container(
                      width: 56.w,
                      height: 56.w,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white.withValues(alpha: 0.18),
                        border: Border.all(
                          color: Colors.white.withValues(alpha: 0.18),
                          width: 1.w,
                        ),
                      ),
                      child: ClipOval(
                        child: Image.asset(avatarAssetPath, fit: BoxFit.cover),
                      ),
                    ),
                    SizedBox(width: 14.w),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          CustomText(
                            name,
                            fontSize: 18.sp,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                          SizedBox(height: 4.h),
                          CustomText(
                            role,
                            fontSize: 14.sp,
                            fontWeight: FontWeight.w500,
                            color: Colors.white.withValues(alpha: 0.75),
                          ),
                        ],
                      ),
                    ),
                    _GradientPillButton(
                      label: 'Upgrade',
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => const SubscriptionScreen(),
                          ),
                        );
                      },
                    ),
                  ],
                ),
                SizedBox(height: 22.h),
                CustomText(
                  'Social',
                  fontSize: 18.sp,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
                SizedBox(height: 12.h),
                _MenuGroup(
                  items: const [
                    _MenuItemData(
                      icon: Icons.chat_bubble_outline,
                      label: 'Chat History',
                    ),
                    _MenuItemData(icon: Icons.phone_outlined, label: 'Call'),
                    _MenuItemData(
                      icon: Icons.message_outlined,
                      label: 'Messages',
                    ),
                  ],
                  onItemTap: (_) {},
                ),
                SizedBox(height: 22.h),
                CustomText(
                  'General',
                  fontSize: 18.sp,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
                SizedBox(height: 12.h),
                _MenuGroup(
                  items: const [
                    _MenuItemData(
                      icon: Icons.notifications_none,
                      label: 'Notifications',
                    ),
                    _MenuItemData(
                      icon: Icons.receipt_long_outlined,
                      label: 'Activity',
                    ),
                    _MenuItemData(
                      icon: Icons.verified_user_outlined,
                      label: 'Privacy',
                    ),
                  ],
                  onItemTap: (_) {},
                ),
                const Spacer(),
                SizedBox(
                  width: double.infinity,
                  height: 54.h,
                  child: ElevatedButton(
                    onPressed: () {},
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFB00000),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(18.r),
                      ),
                      elevation: 0,
                    ),
                    child: CustomText(
                      'Logout',
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                ),
                SizedBox(height: 22.h),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _IconCircleButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _IconCircleButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 44.w,
        height: 44.w,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.white.withValues(alpha: 0.14),
        ),
        child: Icon(icon, color: Colors.white, size: 20.sp),
      ),
    );
  }
}

class _GradientPillButton extends StatelessWidget {
  final String label;
  final VoidCallback onTap;

  const _GradientPillButton({required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 18.w, vertical: 10.h),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(18.r),
          gradient: const LinearGradient(
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
            colors: [Color(0xFF00D9FF), Color(0xFF8F39B2)],
          ),
        ),
        child: CustomText(
          label,
          fontSize: 12.sp,
          fontWeight: FontWeight.w700,
          color: Colors.white,
        ),
      ),
    );
  }
}

class _MenuGroup extends StatelessWidget {
  final List<_MenuItemData> items;
  final ValueChanged<_MenuItemData> onItemTap;

  const _MenuGroup({required this.items, required this.onItemTap});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(20.r),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
        child: Container(
          padding: EdgeInsets.symmetric(vertical: 10.h),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(20.r),
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.10),
              width: 1.w,
            ),
          ),
          child: Column(
            children: [
              for (int i = 0; i < items.length; i++)
                _MenuItem(
                  data: items[i],
                  showDivider: i != items.length - 1,
                  onTap: () => onItemTap(items[i]),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MenuItemData {
  final IconData icon;
  final String label;

  const _MenuItemData({required this.icon, required this.label});
}

class _MenuItem extends StatelessWidget {
  final _MenuItemData data;
  final bool showDivider;
  final VoidCallback onTap;

  const _MenuItem({
    required this.data,
    required this.showDivider,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Column(
        children: [
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
            child: Row(
              children: [
                SizedBox(
                  width: 24.w,
                  child: Icon(
                    data.icon,
                    size: 20.sp,
                    color: Colors.white.withValues(alpha: 0.9),
                  ),
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: CustomText(
                    data.label,
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
          if (showDivider)
            Container(
              height: 1,
              margin: EdgeInsets.symmetric(horizontal: 16.w),
              color: Colors.white.withValues(alpha: 0.08),
            ),
        ],
      ),
    );
  }
}
