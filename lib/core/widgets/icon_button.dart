import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class IconCircleButton extends StatelessWidget {
  final IconData? icon;
  final String? assetPath;
  final VoidCallback onTap;

  const IconCircleButton({super.key, this.icon, this.assetPath, required this.onTap})
      : assert(icon != null || assetPath != null);

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
        child: assetPath != null
            ? Center(
                child: Image.asset(assetPath!, width: 20.sp, height: 20.sp, color: Colors.white),
              )
            : Icon(icon, color: Colors.white, size: 20.sp),
      ),
    );
  }
}
