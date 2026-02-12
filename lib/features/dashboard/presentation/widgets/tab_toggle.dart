import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/widgets/custom_text.dart';
import 'profile_dropdown.dart';

class TabToggle extends StatefulWidget {
  final int selectedIndex;
  final ValueChanged<int> onTabChanged;
  final ValueChanged<ProfileType?>? onProfileTypeChanged;

  const TabToggle({
    super.key,
    required this.selectedIndex,
    required this.onTabChanged,
    this.onProfileTypeChanged,
  });

  @override
  State<TabToggle> createState() => _TabToggleState();
}

class _TabToggleState extends State<TabToggle> {
  ProfileType? _selectedProfileType;

  void _showProfileDropdown() {
    // Find the profile tab position
    final RenderBox renderBox = context.findRenderObject() as RenderBox;
    final Offset offset = renderBox.localToGlobal(Offset.zero);
    final Size size = renderBox.size;

    // Calculate profile tab position (it's the second tab)
    final profileTabWidth = size.width / 2 - 6.w; // Account for spacing
    final profileTabX =
        offset.dx + profileTabWidth + 6.w; // Start of profile tab

    showMenu(
      context: context,
      position: RelativeRect.fromLTRB(
        profileTabX,
        offset.dy + size.height,
        profileTabX + profileTabWidth,
        offset.dy + size.height + 200,
      ),
      items: [
        PopupMenuItem(
          value: ProfileType.professional,
          child: Row(
            children: [
              CustomText(
                'Professional',
                fontSize: 14.sp,
                fontWeight: FontWeight.w500,
                color: Colors.black,
              ),
              const Spacer(),
              if (_selectedProfileType == ProfileType.professional)
                Icon(Icons.check, size: 16.sp, color: const Color(0xFF05DAF1)),
            ],
          ),
        ),
        PopupMenuItem(
          value: ProfileType.skilled,
          child: Row(
            children: [
              CustomText(
                'Skilled',
                fontSize: 14.sp,
                fontWeight: FontWeight.w500,
                color: Colors.black,
              ),
              const Spacer(),
              if (_selectedProfileType == ProfileType.skilled)
                Icon(Icons.check, size: 16.sp, color: const Color(0xFF05DAF1)),
            ],
          ),
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
    ).then((value) {
      if (value != null) {
        setState(() {
          _selectedProfileType = value;
        });
        widget.onProfileTypeChanged?.call(_selectedProfileType);
      }
    });
  }

  String get _profileTabText {
    switch (_selectedProfileType) {
      case ProfileType.professional:
        return 'Professional';
      case ProfileType.skilled:
        return 'Skilled';
      case null:
        return 'Profile';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      child: Row(
        children: [
          _buildTab('Gallery', 0),
          SizedBox(width: 12.w),
          _buildTab('Profile', 1),
        ],
      ),
    );
  }

  Widget _buildTab(String label, int index) {
    final isSelected = widget.selectedIndex == index;
    final isProfileSelected = widget.selectedIndex == 1 && index == 1;
    final displayText = index == 1 ? _profileTabText : label;

    return Expanded(
      child: GestureDetector(
        onTap: () {
          if (index == 1 && widget.selectedIndex == 1) {
            // Profile tab is already selected, trigger dropdown
            _showProfileDropdown();
          } else {
            widget.onTabChanged(index);
          }
        },
        child: Container(
          padding: EdgeInsets.symmetric(vertical: 12.h),
          decoration: BoxDecoration(
            color: isSelected
                ? Colors.white
                : Colors.white.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(20.r),
          ),
          child: Center(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CustomText(
                  displayText,
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w600,
                  color: isSelected ? Colors.black : Colors.white,
                ),
                if (isProfileSelected) ...[
                  SizedBox(width: 4.w),
                  Icon(
                    Icons.keyboard_arrow_down,
                    size: 16.sp,
                    color: isSelected ? Colors.black : Colors.white,
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
