import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:skillioo/features/profile/presentation/profile.dart';

import '../../../../constants/app_constants.dart';

class DashboardTopBar extends StatelessWidget {
  const DashboardTopBar({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _IconButton(assetPath: AppAssets.menuPng),
          Row(
            children: [
              _IconButton(assetPath: AppAssets.locationPng),
              SizedBox(width: 12.w),
              _IconButton(assetPath: AppAssets.addPng),
              SizedBox(width: 12.w),
              _AvatarButton(),
            ],
          ),
        ],
      ),
    );
  }
}

class _IconButton extends StatelessWidget {
  final String assetPath;

  const _IconButton({required this.assetPath});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 48.w,
      height: 48.w,
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Center(
        child: Image.asset(assetPath, width: 24.w, height: 24.w),
      ),
    );
  }
}

class _AvatarButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => ProfileSectionScreen(
              name: 'Praveen Chandra',
              role: 'Software Engineer',
              avatarAssetPath: AppAssets.logoPng,
            ),
          ),
        );
      },
      child: Container(
        width: 48.w,
        height: 48.w,
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(12.r),
        ),
        child: Center(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12.r),
            child: Image.asset(
              AppAssets.logoPng,
              width: 48.w,
              height: 48.w,
              fit: BoxFit.cover,
            ),
          ),
        ),
      ),
    );
  }
}
