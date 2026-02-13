import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class GalleryItem {
  final String type;
  final String imagePath;

  const GalleryItem({required this.type, required this.imagePath});
}

class GalleryGrid extends StatelessWidget {
  final List<GalleryItem> items;

  const GalleryGrid({super.key, required this.items});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          crossAxisSpacing: 12.w,
          mainAxisSpacing: 12.h,
          childAspectRatio: 1.0,
        ),
        itemCount: items.length,
        itemBuilder: (context, index) {
          return _GalleryCard(item: items[index]);
        },
      ),
    );
  }
}

class _GalleryCard extends StatelessWidget {
  final GalleryItem item;

  const _GalleryCard({required this.item});

  @override
  Widget build(BuildContext context) {
    final isProfessional = item.type == 'Professional';
    final borderColor = isProfessional
        ? const Color(0xFF8F39B2).withValues(alpha: 0.6)
        : const Color(0xFF2F208E).withValues(alpha: 0.6);

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: borderColor, width: 1.5.w),
        image: DecorationImage(
          image: AssetImage(item.imagePath),
          fit: BoxFit.cover,
        ),
      ),
      child: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(15.r),
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.transparent,
                  Colors.black.withValues(alpha: 0.6),
                ],
              ),
            ),
          ),
          Positioned(
            top: 6.w,
            left: 6.w,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(6.r),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 4, sigmaY: 4),
                child: Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 6.w,
                    vertical: 3.h,
                  ),
                  decoration: BoxDecoration(
                    color: isProfessional
                        ? const Color(0xFF8F39B2).withValues(alpha: 0.5)
                        : const Color(0xFF2F208E).withValues(alpha: 0.5),
                    borderRadius: BorderRadius.circular(6.r),
                  ),
                  child: Text(
                    item.type,
                    style: TextStyle(
                      fontFamily: 'Outfit',
                      fontSize: 8.sp,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                      fontStyle: FontStyle.italic,
                    ),
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
