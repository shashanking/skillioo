import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/widgets/custom_text.dart';

enum ProfileType { professional, skilled }

class ProfileDropdown extends StatefulWidget {
  final ProfileType selectedType;
  final ValueChanged<ProfileType> onTypeChanged;

  const ProfileDropdown({
    super.key,
    required this.selectedType,
    required this.onTypeChanged,
  });

  @override
  State<ProfileDropdown> createState() => _ProfileDropdownState();
}

class _ProfileDropdownState extends State<ProfileDropdown>
    with TickerProviderStateMixin {
  late OverlayEntry _overlayEntry;
  bool _isDropdownOpen = false;
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _opacityAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );
    _scaleAnimation = Tween<double>(begin: 0.95, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOutBack),
    );
    _opacityAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    if (_isDropdownOpen) {
      _removeOverlay();
    }
    super.dispose();
  }

  void _toggleDropdown() {
    if (_isDropdownOpen) {
      _removeOverlay();
    } else {
      _showOverlay();
    }
  }

  void _showOverlay() {
    _overlayEntry = OverlayEntry(
      builder: (context) => _DropdownOverlay(
        onSelected: (type) {
          widget.onTypeChanged(type);
          _removeOverlay();
        },
        onClose: _removeOverlay,
        scaleAnimation: _scaleAnimation,
        opacityAnimation: _opacityAnimation,
        selectedType: widget.selectedType,
      ),
    );
    Overlay.of(context).insert(_overlayEntry);
    setState(() {
      _isDropdownOpen = true;
    });
    _animationController.forward();
  }

  void _removeOverlay() {
    _animationController.reverse().then((_) {
      _overlayEntry.remove();
      setState(() {
        _isDropdownOpen = false;
      });
    });
  }

  String get _displayText {
    switch (widget.selectedType) {
      case ProfileType.professional:
        return 'Professional';
      case ProfileType.skilled:
        return 'Skilled';
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _toggleDropdown,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(24.r),
          border: Border.all(
            color: Colors.white.withValues(alpha: 0.2),
            width: 1.w,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            CustomText(
              _displayText,
              fontSize: 14.sp,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
            SizedBox(width: 8.w),
            AnimatedRotation(
              turns: _isDropdownOpen ? 0.5 : 0,
              duration: const Duration(milliseconds: 200),
              child: Icon(
                Icons.keyboard_arrow_down,
                size: 20.sp,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DropdownOverlay extends StatelessWidget {
  final ValueChanged<ProfileType> onSelected;
  final VoidCallback onClose;
  final Animation<double> scaleAnimation;
  final Animation<double> opacityAnimation;
  final ProfileType selectedType;

  const _DropdownOverlay({
    required this.onSelected,
    required this.onClose,
    required this.scaleAnimation,
    required this.opacityAnimation,
    required this.selectedType,
  });

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: GestureDetector(
        onTap: onClose,
        child: Container(
          color: Colors.transparent,
          child: Center(
            child: GestureDetector(
              onTap: () {}, // Prevent tap through
              child: AnimatedBuilder(
                animation: _animationCombined,
                builder: (context, child) {
                  return Transform.scale(
                    scale: scaleAnimation.value,
                    child: Opacity(
                      opacity: opacityAnimation.value,
                      child: _DropdownContent(
                        onSelected: onSelected,
                        selectedType: selectedType,
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );
  }

  Listenable get _animationCombined =>
      Listenable.merge([scaleAnimation, opacityAnimation]);
}

class _DropdownContent extends StatelessWidget {
  final ValueChanged<ProfileType> onSelected;
  final ProfileType selectedType;

  const _DropdownContent({
    required this.onSelected,
    required this.selectedType,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 200.w,
      padding: EdgeInsets.symmetric(vertical: 8.h),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A1A),
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.1),
          width: 1.w,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.3),
            blurRadius: 20.r,
            offset: Offset(0, 8.h),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildOption(ProfileType.professional),
          _buildDivider(),
          _buildOption(ProfileType.skilled),
        ],
      ),
    );
  }

  Widget _buildOption(ProfileType type) {
    final isSelected = selectedType == type;
    final text = type == ProfileType.professional ? 'Professional' : 'Skilled';

    return GestureDetector(
      onTap: () => onSelected(type),
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
        decoration: BoxDecoration(
          color: isSelected
              ? Colors.white.withValues(alpha: 0.1)
              : Colors.transparent,
        ),
        child: Row(
          children: [
            CustomText(
              text,
              fontSize: 14.sp,
              fontWeight: FontWeight.w500,
              color: Colors.white,
            ),
            const Spacer(),
            if (isSelected)
              Icon(Icons.check, size: 16.sp, color: const Color(0xFF05DAF1)),
          ],
        ),
      ),
    );
  }

  Widget _buildDivider() {
    return Container(
      height: 1.h,
      margin: EdgeInsets.symmetric(horizontal: 8.w),
      color: Colors.white.withValues(alpha: 0.1),
    );
  }
}
