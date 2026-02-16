import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../constants/app_constants.dart';
import '../common_background.dart';
import '../custom_text.dart';
import '../icon_button.dart';

class FavouritesScreen extends StatelessWidget {
  const FavouritesScreen({super.key});

  // Dummy favourites data
  static final List<_FavouriteItem> _items = [
    _FavouriteItem(
      imagePath: AppAssets.professionalProfileJpg,
      type: AppStrings.professional,
    ),
    _FavouriteItem(
      imagePath: AppAssets.skilledProfileJpg,
      type: AppStrings.professional,
    ),
    _FavouriteItem(
      imagePath: AppAssets.profileImg1,
      type: AppStrings.skilled,
    ),
    _FavouriteItem(
      imagePath: AppAssets.professionalProfileJpg,
      type: AppStrings.professional,
    ),
    _FavouriteItem(
      imagePath: AppAssets.skilledProfileJpg,
      type: AppStrings.professional,
    ),
    _FavouriteItem(
      imagePath: AppAssets.profileImg1,
      type: AppStrings.skilled,
    ),
    _FavouriteItem(
      imagePath: AppAssets.professionalProfileJpg,
      type: AppStrings.professional,
    ),
    _FavouriteItem(
      imagePath: AppAssets.skilledProfileJpg,
      type: AppStrings.professional,
    ),
    _FavouriteItem(
      imagePath: AppAssets.profileImg1,
      type: AppStrings.skilled,
    ),
    _FavouriteItem(
      imagePath: AppAssets.professionalProfileJpg,
      type: AppStrings.professional,
    ),
    _FavouriteItem(
      imagePath: AppAssets.skilledProfileJpg,
      type: AppStrings.professional,
    ),
    _FavouriteItem(
      imagePath: AppAssets.profileImg1,
      type: AppStrings.skilled,
    ),
    _FavouriteItem(
      imagePath: AppAssets.professionalProfileJpg,
      type: AppStrings.professional,
    ),
    _FavouriteItem(
      imagePath: AppAssets.skilledProfileJpg,
      type: AppStrings.professional,
    ),
    _FavouriteItem(
      imagePath: AppAssets.profileImg1,
      type: AppStrings.skilled,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CommonBackground(
        child: SafeArea(
          child: Column(
            children: [
              // Header
              Container(
                padding: EdgeInsets.fromLTRB(16.w, 12.h, 16.w, 24.h),
                decoration: BoxDecoration(
                  color: AppColors.glassWhite12,
                ),
                child: Row(
                  children: [
                    IconCircleButton(
                      icon: Icons.arrow_back,
                      onTap: () => Navigator.of(context).maybePop(),
                    ),
                    SizedBox(width: 24.w),
                    CustomText(
                      AppStrings.favourites,
                      fontSize: 24.sp,
                      fontWeight: FontWeight.w700,
                      fontFamily: 'Neue',
                      color: AppColors.foundationBlack20,
                    ),
                  ],
                ),
              ),
              // Grid
              Expanded(
                child: GridView.builder(
                  padding: EdgeInsets.symmetric(
                    horizontal: 16.w,
                    vertical: 24.h,
                  ),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    crossAxisSpacing: 10.w,
                    mainAxisSpacing: 10.h,
                    childAspectRatio: 1.0,
                  ),
                  itemCount: _items.length,
                  itemBuilder: (context, index) {
                    return _buildFavouriteCard(_items[index]);
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFavouriteCard(_FavouriteItem item) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24.r),
        image: DecorationImage(
          image: AssetImage(item.imagePath),
          fit: BoxFit.cover,
          colorFilter: ColorFilter.mode(
            Colors.black.withValues(alpha: 0.2),
            BlendMode.darken,
          ),
        ),
      ),
      child: Stack(
        children: [
          Positioned(
            top: 10.w,
            left: 10.w,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(24.r),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 4, sigmaY: 4),
                child: Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 4.w,
                    vertical: 0,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.glassWhite48,
                    borderRadius: BorderRadius.circular(24.r),
                  ),
                  child: CustomText(
                    item.type,
                    fontSize: 10.sp,
                    fontWeight: FontWeight.w500,
                    color: AppColors.foundationBlack20,
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

class _FavouriteItem {
  final String imagePath;
  final String type;

  const _FavouriteItem({required this.imagePath, required this.type});
}
