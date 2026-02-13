import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:skillioo/features/profile/presentation/widgets/bio_tab.dart';
import 'package:skillioo/features/profile/presentation/widgets/certificates_tab.dart';
import 'package:skillioo/features/profile/presentation/widgets/posts_tab.dart';
import 'package:skillioo/features/profile/presentation/widgets/shared_widgets.dart';

import '../../../../core/widgets/custom_text.dart';

class UserProfileScreen extends StatefulWidget {
  const UserProfileScreen({super.key});

  @override
  State<UserProfileScreen> createState() => _UserProfileScreenState();
}

class _UserProfileScreenState extends State<UserProfileScreen> {
  int _selectedTabIndex = 0; // 0: Bio, 1: Posts, 2: Certificates

  // This controller allows the sheet to scroll the internal list
  final DraggableScrollableController _sheetController =
      DraggableScrollableController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF050505),
      body: Stack(
        children: [
          // ------------------------------------------------
          // LAYER 1: Background Content (Header & Stats)
          // ------------------------------------------------
          Positioned.fill(
            child: SingleChildScrollView(
              physics: const ClampingScrollPhysics(),
              child: Padding(
                padding: EdgeInsets.only(bottom: 400.h),
                child: Column(
                  children: [
                    _buildHeaderSection(),
                    SizedBox(height: 60.h),

                    // Name & Title
                    CustomText(
                      'Lisa Dancer',
                      fontSize: 24.sp,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                    SizedBox(height: 8.h),
                    CustomText(
                      'Dancer',
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w400,
                      color: Colors.white70,
                    ),
                    SizedBox(height: 16.h),

                    // Online Badge
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 16.w,
                        vertical: 8.h,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(20.r),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 8.w,
                            height: 8.w,
                            decoration: const BoxDecoration(
                              color: Color(0xFF00C853),
                              shape: BoxShape.circle,
                            ),
                          ),
                          SizedBox(width: 8.w),
                          CustomText(
                            'Online',
                            fontSize: 14.sp,
                            fontWeight: FontWeight.w500,
                            color: const Color(0xFF00C853),
                          ),
                        ],
                      ),
                    ),

                    SizedBox(height: 32.h),

                    // Stats Row 1
                    _buildStatsContainer(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          _buildStatItem('25K', 'Followers'),
                          _buildStatItem('25K', 'Following'),
                          _buildStatItem('25K', 'Reactions'),
                          _buildStatItem('1M', 'Impressions'),
                        ],
                      ),
                    ),

                    SizedBox(height: 16.h),

                    // Stats Row 2
                    _buildStatsContainer(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          _buildStatItem('25', 'Events'),
                          _buildSocialStatItem(Icons.facebook, '10K Followers'),
                          _buildSocialStatItem(
                            Icons.camera_alt_outlined,
                            '10K Followers',
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // ------------------------------------------------
          // LAYER 2: Fixed Top Navigation
          // ------------------------------------------------
          Positioned(
            top: 50.h,
            left: 20.w,
            right: 20.w,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildNavButton(
                  icon: Icons.arrow_back,
                  onTap: () => Navigator.pop(context),
                ),
                _buildNavButton(icon: Icons.edit_outlined, onTap: () {}),
              ],
            ),
          ),

          // ------------------------------------------------
          // LAYER 3: Draggable Bottom Sheet
          // ------------------------------------------------
          DraggableScrollableSheet(
            controller: _sheetController,
            initialChildSize: 0.2,
            minChildSize: 0.2,
            maxChildSize: 1.0,
            builder: (BuildContext context, ScrollController scrollController) {
              return Container(
                decoration: BoxDecoration(
                  color: const Color(0xFF111111),
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(30.r),
                    topRight: Radius.circular(30.r),
                  ),
                  border: Border(
                    top: BorderSide(
                      color: Colors.white.withValues(alpha: 0.6),
                      width: 1,
                    ),
                  ),
                ),
                // Using SingleChildScrollView here ensures the top notch area is draggable
                child: SingleChildScrollView(
                  controller: scrollController,
                  child: Column(
                    children: [
                      SizedBox(height: 22.h),
                      // Drag Handle
                      Center(
                        child: Container(
                          width: 84.w,
                          height: 24.h,
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.8),
                            borderRadius: BorderRadius.circular(48.r),
                          ),
                        ),
                      ),
                      SizedBox(height: 35.h),

                      // Tab Switcher
                      Container(
                        margin: EdgeInsets.symmetric(horizontal: 20.w),
                        height: 50.h,
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(25.r),
                        ),
                        child: Row(
                          children: [
                            _buildTabItem(0, "Bio"),
                            _buildTabItem(1, "Posts"),
                            _buildTabItem(2, "Certificates"),
                          ],
                        ),
                      ),
                      SizedBox(height: 30.h),

                      // Tab Content (Wrapped in SizedBox/Constraint to allow internal content)
                      // We don't use Expanded here because we are inside a SingleChildScrollView
                      // The content is rendered directly.
                      // Note: We don't pass scrollController down because the parent SingleChildScrollView handles the sheet drag
                      IndexedStack(
                        index: _selectedTabIndex,
                        children: [
                          const BioTab(),
                          const PostsTab(),
                          const CertificatesTab(),
                        ],
                      ),

                      // DYNAMIC ACTION BUTTON (Moved here to scroll with sheet)
                      SizedBox(height: 20.h),
                      Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: 20.w,
                          vertical: 20.h,
                        ),
                        child: _buildActionButton(),
                      ),
                      // Extra padding for safe area bottom
                      SizedBox(height: 30.h),
                    ],
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  // --- Dynamic Button Logic ---
  Widget _buildActionButton() {
    String text;
    IconData icon;
    VoidCallback onTap;

    switch (_selectedTabIndex) {
      case 0:
        text = "Edit Charges";
        icon = Icons.edit_outlined;
        onTap = () {};
        break;
      case 1:
        text = "Create Post";
        icon = Icons.add;
        onTap = () {};
        break;
      case 2:
        text = "Upload Certificate";
        icon = Icons.upload_file_outlined;
        onTap = () {};
        break;
      default:
        return const SizedBox.shrink();
    }

    return GradientBorderButton(text: text, icon: icon, onTap: onTap);
  }

  // --- Helper Widgets ---

  Widget _buildTabItem(int index, String text) {
    final bool isSelected = _selectedTabIndex == index;
    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() => _selectedTabIndex = index);
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          margin: EdgeInsets.all(4.w),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24.r),
            gradient: isSelected
                ? const LinearGradient(
                    colors: [Color(0xFF05DAF1), Color(0xFFC00F8B)],
                  )
                : null,
            color: isSelected ? null : Colors.transparent,
          ),
          alignment: Alignment.center,
          child: CustomText(
            text,
            fontSize: 14.sp,
            fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  Widget _buildHeaderSection() {
    return Stack(
      clipBehavior: Clip.none,
      alignment: Alignment.center,
      children: [
        Container(
          height: 220.h,
          width: double.infinity,
          decoration: const BoxDecoration(
            image: DecorationImage(
              image: AssetImage('assets/images/skilled-profile.jpg'),
              fit: BoxFit.cover,
            ),
          ),
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.transparent,
                  const Color(0xFF050505).withValues(alpha: 0.9),
                  const Color(0xFF050505),
                ],
                stops: const [0.0, 0.7, 1.0],
              ),
            ),
          ),
        ),
        Positioned(
          bottom: -50.h,
          child: Container(
            width: 130.w,
            height: 130.w,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: const Color(0xFF050505), width: 4.w),
              image: const DecorationImage(
                image: AssetImage('assets/images/professional-profile.jpg'),
                fit: BoxFit.cover,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildStatsContainer({required Widget child}) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 20.w),
      padding: EdgeInsets.symmetric(vertical: 20.h, horizontal: 16.w),
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E2C),
        borderRadius: BorderRadius.circular(30.r),
      ),
      child: child,
    );
  }

  Widget _buildStatItem(String value, String label) {
    return Column(
      children: [
        CustomText(
          value,
          fontSize: 18.sp,
          fontWeight: FontWeight.w800,
          color: Colors.white,
        ),
        SizedBox(height: 4.h),
        CustomText(
          label,
          fontSize: 12.sp,
          fontWeight: FontWeight.w400,
          color: Colors.white70,
        ),
      ],
    );
  }

  Widget _buildSocialStatItem(IconData icon, String text) {
    return Column(
      children: [
        Icon(icon, color: Colors.white, size: 24.sp),
        SizedBox(height: 4.h),
        CustomText(
          text,
          fontSize: 12.sp,
          fontWeight: FontWeight.w400,
          color: Colors.white70,
        ),
      ],
    );
  }

  Widget _buildNavButton({
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 44.w,
        height: 44.w,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.white.withValues(alpha: 0.15),
        ),
        child: Icon(icon, color: Colors.white, size: 22.sp),
      ),
    );
  }
}
