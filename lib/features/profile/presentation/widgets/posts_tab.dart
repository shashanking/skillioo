import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:skillioo/features/posts/presentation/post_screen.dart';
import 'package:skillioo/features/profile/presentation/widgets/shared_widgets.dart'; // Ensure GalleryItem is imported

class PostsTab extends StatelessWidget {
  const PostsTab({super.key});

  @override
  Widget build(BuildContext context) {
    // Dummy Data
    final List<GalleryItem> items = List.generate(
      12,
      (index) => GalleryItem(
        imagePath:
            'assets/images/skilled-profile.jpg', // Replace with real asset
        type: index % 2 == 0 ? 'Professional' : 'Personal',
      ),
    );

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20.w),
      child: GridView.builder(
        // Important for nested scrolling
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        padding: EdgeInsets.zero,
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          crossAxisSpacing: 10.w,
          mainAxisSpacing: 10.w,
          childAspectRatio: 1.0,
        ),
        itemCount: items.length,
        itemBuilder: (context, index) {
          return GalleryCard(item: items[index]);
        },
      ),
    );
  }
}

class GalleryCard extends StatelessWidget {
  final GalleryItem item;

  const GalleryCard({super.key, required this.item});

  @override
  Widget build(BuildContext context) {
    final isProfessional = item.type == 'Professional';
    final borderColor = isProfessional
        ? const Color(0xFF8F39B2).withValues(alpha: 0.6)
        : const Color(0xFF2F208E).withValues(alpha: 0.6);

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const PostViewScreen()),
        );
      },
      child: Container(
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

            // Positioned(
            //   top: 6.w,
            //   left: 6.w,
            //   child: ClipRRect(
            //     borderRadius: BorderRadius.circular(6.r),
            //     child: BackdropFilter(
            //       filter: ImageFilter.blur(sigmaX: 4, sigmaY: 4),
            //       child: Container(
            //         padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 3.h),
            //         decoration: BoxDecoration(
            //           color: isProfessional
            //               ? const Color(0xFF8F39B2).withValues(alpha: 0.5)
            //               : const Color(0xFF2F208E).withValues(alpha: 0.5),
            //           borderRadius: BorderRadius.circular(6.r),
            //         ),
            //         child: Text(
            //           item.type,
            //           style: TextStyle(
            //             fontFamily: 'Outfit',
            //             fontSize: 8.sp,
            //             fontWeight: FontWeight.w600,
            //             color: Colors.white,
            //             fontStyle: FontStyle.italic,
            //           ),
            //         ),
            //       ),
            //     ),
            //   ),
            // ),
          ],
        ),
      ),
    );
  }
}
