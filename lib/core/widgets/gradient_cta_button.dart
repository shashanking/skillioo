import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../constants/app_constants.dart';

// gradient border and gradient color button for cta
class GradientCtaButton extends StatelessWidget {
  final String? label;
  final Widget? child;
  final VoidCallback? onPressed;
  final double height;
  final double? width;
  final EdgeInsetsGeometry padding;
  final BorderRadius? borderRadius;
  final bool enabled;
  final Widget? leading;
  final Widget? trailing;
  final Color? disabledBackgroundColor;
  final Color? labelColor;

  const GradientCtaButton({
    super.key,
    this.label,
    this.child,
    required this.onPressed,
    this.height = 58,
    this.width,
    this.padding = EdgeInsets.zero,
    this.borderRadius,
    this.enabled = true,
    this.leading,
    this.trailing,
    this.disabledBackgroundColor,
    this.labelColor,
  }) : assert(
         label != null || child != null,
         'Either label or child must be provided',
       );

  @override
  Widget build(BuildContext context) {
    final BorderRadius radius = borderRadius ?? BorderRadius.circular(29.r);
    final isEnabled = enabled && onPressed != null;
    final BorderRadius blackLayerRadius = BorderRadius.circular(
      (radius.topLeft.x - 1.2.w).clamp(0.0, double.infinity),
    );
    final BorderRadius buttonRadius = BorderRadius.circular(
      (radius.topLeft.x - 2.6.w).clamp(0.0, double.infinity),
    );

    return SizedBox(
      width: width,
      height: height.h,
      child: Stack(
        fit: StackFit.passthrough,
        children: [
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: isEnabled
                    ? AppColors.ctaBorderGradient
                    : AppColors.ctaGradientDeactivated,
                borderRadius: radius,
              ),
            ),
          ),
          Positioned.fill(
            child: Padding(
              padding: EdgeInsets.all(1.w),
              child: ClipRRect(
                borderRadius: blackLayerRadius,
                child: Container(color: Colors.black),
              ),
            ),
          ),
          ClipRRect(
            borderRadius: buttonRadius,
            child: Material(
              color: Colors.transparent,
              child: Ink(
                decoration: BoxDecoration(
                  gradient: isEnabled
                      ? AppColors.ctaGradient
                      : AppColors.ctaGradientDeactivated,
                ),
                child: InkWell(
                  onTap: isEnabled ? onPressed : null,
                  child: Padding(
                    padding: padding,
                    child: Center(
                      child:
                          child ??
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              if (leading != null) ...[
                                leading!,
                                SizedBox(width: 8.w),
                              ],
                              Text(
                                label!,
                                style: TextStyle(
                                  fontFamily: 'Outfit',
                                  fontSize: 16.sp,
                                  fontWeight: FontWeight.w600,
                                  color: labelColor ?? const Color(0xFFF5F5F5),
                                ),
                              ),
                              if (trailing != null) ...[
                                SizedBox(width: 8.w),
                                trailing!,
                              ],
                            ],
                          ),
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
