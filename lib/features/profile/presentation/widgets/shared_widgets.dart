import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/widgets/custom_text.dart';

class GalleryItem {
  final String imagePath;
  final String type; // 'Professional' or 'Personal'

  GalleryItem({required this.imagePath, required this.type});
}

class GradientBorderButton extends StatelessWidget {
  final String text;
  final VoidCallback onTap;
  final IconData? icon;

  const GradientBorderButton({
    super.key,
    required this.text,
    required this.onTap,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Stack(
        children: [
          // Layer 1: Fill
          Container(
            height: 56.h,
            width: double.infinity,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(28.r),
              gradient: LinearGradient(
                colors: [
                  const Color(0xFF05DAF1).withValues(
                    alpha: 0.2,
                  ), // Lower opacity for better text visibility
                  const Color(0xFFC00F8B).withValues(alpha: 0.2),
                ],
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (icon != null) ...[
                  Icon(icon, color: Colors.white, size: 20.sp),
                  SizedBox(width: 8.w),
                ],
                CustomText(
                  text,
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ],
            ),
          ),

          // Layer 2: Gradient Border
          Positioned.fill(
            child: IgnorePointer(
              child: ShaderMask(
                shaderCallback: (Rect bounds) {
                  return const LinearGradient(
                    colors: [Color(0xFF05DAF1), Color(0xFFC00F8B)],
                  ).createShader(bounds);
                },
                blendMode: BlendMode.srcIn,
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(28.r),
                    border: Border.all(color: Colors.white, width: 1.w),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
