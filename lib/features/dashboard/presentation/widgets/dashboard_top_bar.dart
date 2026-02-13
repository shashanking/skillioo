import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:skillioo/core/widgets/app_menu_screen.dart';
import 'package:skillioo/features/profile/presentation/profile.dart';
import 'package:skillioo/features/profile/presentation/widgets/select_location_screen.dart';

import '../../../../constants/app_constants.dart';
import '../../../../core/widgets/custom_text.dart';

class DashboardTopBar extends StatelessWidget {
  const DashboardTopBar({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const AppMenuScreen()),
              );
            },
            child: _IconButton(assetPath: AppAssets.menuPng),
          ),
          Row(
            children: [
              GestureDetector(
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => const SelectLocationScreen(),
                    ),
                  );
                },
                child: _IconButton(assetPath: AppAssets.locationPng),
              ),
              SizedBox(width: 12.w),
              const _AddMenuButton(),
              SizedBox(width: 12.w),
              _AvatarButton(),
            ],
          ),
        ],
      ),
    );
  }
}

enum _AddMenuAction { upload, createProfile }

class _AddMenuButton extends StatelessWidget {
  const _AddMenuButton();

  Future<void> _showAddMenu(BuildContext context) async {
    final RenderBox renderBox = context.findRenderObject() as RenderBox;
    final Offset offset = renderBox.localToGlobal(Offset.zero);
    final Size size = renderBox.size;

    final router = GoRouter.of(context);

    final value = await showMenu<_AddMenuAction>(
      context: context,
      position: RelativeRect.fromLTRB(
        offset.dx,
        offset.dy + size.height,
        offset.dx + size.width,
        offset.dy + size.height + 200,
      ),
      items: const [
        PopupMenuItem(
          value: _AddMenuAction.upload,
          child: _AddMenuItemRow(title: 'Upload'),
        ),
        PopupMenuItem(
          value: _AddMenuAction.createProfile,
          child: _AddMenuItemRow(title: 'Create Profile'),
        ),
      ],
      color: Colors.white,
      elevation: 8,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16.r),
        side: BorderSide(
          color: Colors.black.withValues(alpha: 0.1),
          width: 1.w,
        ),
      ),
    );

    if (value == null) return;

    switch (value) {
      case _AddMenuAction.upload:
        router.push('/upload-videos');
        break;
      case _AddMenuAction.createProfile:
        router.push('/profile-type');
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Builder(
      builder: (btnContext) {
        return GestureDetector(
          onTap: () => _showAddMenu(btnContext),
          child: _IconButton(assetPath: AppAssets.addPng),
        );
      },
    );
  }
}

class _AddMenuItemRow extends StatelessWidget {
  final String title;

  const _AddMenuItemRow({required this.title});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        CustomText(
          title,
          fontSize: 14.sp,
          fontWeight: FontWeight.w500,
          color: Colors.black,
        ),
      ],
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
