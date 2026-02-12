import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/widgets/custom_text.dart';

class SubscriptionScreen extends StatefulWidget {
  const SubscriptionScreen({super.key});

  @override
  State<SubscriptionScreen> createState() => _SubscriptionScreenState();
}

class _SubscriptionScreenState extends State<SubscriptionScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(() {
      if (_tabController.indexIsChanging ||
          _tabController.index != _currentIndex) {
        setState(() {
          _currentIndex = _tabController.index;
        });
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  // Shared Gradients
  final Gradient _pinkBlueGradient = const LinearGradient(
    begin: Alignment.topRight,
    end: Alignment.bottomLeft, // Approx 225deg
    colors: [Color(0xFFC00F8B), Color(0xFF05DAF1)],
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF4A148C), // Deep Purple top
              Color(0xFF14121A), // Dark middle
              Color(0xFF000000), // Black bottom
            ],
            stops: [0.0, 0.5, 1.0],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // 1. Back Button & Header
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 10.h),
                child: Row(
                  children: [
                    GestureDetector(
                      onTap: () => Navigator.of(context).pop(),
                      child: Container(
                        width: 40.w,
                        height: 40.w,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white.withValues(alpha: 0.1),
                        ),
                        child: Icon(
                          Icons.arrow_back,
                          color: Colors.white,
                          size: 20.sp,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // 2. Titles
              SizedBox(height: 10.h),
              CustomText(
                'Level Up Your Access.',
                fontSize: 22.sp,
                fontWeight: FontWeight.w700,
                color: Colors.white,
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 8.h),
              CustomText(
                'Unlock everything. No limits.',
                fontSize: 14.sp,
                fontWeight: FontWeight.w400,
                color: Colors.white70,
                textAlign: TextAlign.center,
              ),

              SizedBox(height: 24.h),

              // 3. Custom Tab Toggle
              Center(
                child: Container(
                  width: 180.w,
                  height: 44.h,
                  padding: EdgeInsets.all(4.w),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(22.r),
                  ),
                  child: TabBar(
                    controller: _tabController,
                    indicator: BoxDecoration(
                      borderRadius: BorderRadius.circular(20.r),
                      gradient: _pinkBlueGradient,
                    ),
                    labelColor: Colors.white,
                    unselectedLabelColor: Colors.white70,
                    labelStyle: TextStyle(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w600,
                    ),
                    indicatorSize: TabBarIndicatorSize.tab,
                    dividerColor: Colors.transparent,
                    tabs: const [
                      Tab(text: 'Pro'),
                      Tab(text: 'Elite'),
                    ],
                  ),
                ),
              ),

              SizedBox(height: 24.h),

              // 4. Cards Tab View
              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    // PRO CARD
                    _buildSubscriptionCard(
                      planName: 'Pro Plan',
                      price: '21',
                      description: 'Everything unlocked. No limits.',
                      bgImage: 'assets/images/pro-bg.png',
                      icon: Icons.star_border,
                      tags: ['Unlimited Chat & Calls', '24 hrs valid'],
                      benefits: [
                        'Direct access to top talents.',
                        'Connect anytime, explore professionals and groups.',
                        'View unlimited profiles.',
                      ],
                    ),
                    // ELITE CARD
                    _buildSubscriptionCard(
                      planName: 'Elite Plan',
                      price: '59',
                      description: 'Maximum visibility. Top priority access',
                      bgImage: 'assets/images/elite-bg.png',
                      icon: Icons.workspace_premium, // Crown icon equivalent
                      tags: ['Unlimited Chat & Calls', '10 days valid'],
                      benefits: [
                        'Direct access to top talents.',
                        'Connect anytime, explore professionals and groups.',
                        'View unlimited profiles.',
                      ],
                    ),
                  ],
                ),
              ),

              // 5. Indicators
              Padding(
                padding: EdgeInsets.only(bottom: 20.h, top: 20.h),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _buildIndicator(isActive: _currentIndex == 0),
                    SizedBox(width: 8.w),
                    _buildIndicator(isActive: _currentIndex == 1),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildIndicator({required bool isActive}) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      width: isActive ? 48.w : 12.w,
      height: isActive ? 24.h : 12.h,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24.r),
        color: isActive ? null : Colors.white,
        gradient: isActive ? _pinkBlueGradient : null,
      ),
    );
  }

  Widget _buildSubscriptionCard({
    required String planName,
    required String price,
    required String description,
    required String bgImage,
    required IconData icon,
    required List<String> tags,
    required List<String> benefits,
  }) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 20.w),
      // The Gradient Border Wrapper
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24.r),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight, // 331 deg approx
          colors: [Color(0xFFB2B2B2), Color(0xFF000000)],
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(1.0), // 1px border width
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(23.r),
            color: Colors.black, // Fallback
            image: DecorationImage(
              image: AssetImage(bgImage),
              fit: BoxFit.cover,
            ),
          ),
          child: Padding(
            padding: EdgeInsets.all(24.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Plan Label with Icon
                Row(
                  children: [
                    Icon(icon, color: Colors.white, size: 20.sp),
                    SizedBox(width: 8.w),
                    CustomText(
                      planName,
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w500,
                      color: Colors.white,
                    ),
                  ],
                ),
                SizedBox(height: 16.h),

                // Price
                RichText(
                  text: TextSpan(
                    children: [
                      TextSpan(
                        text: '₹ ',
                        style: TextStyle(
                          fontSize: 24.sp,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                          fontFamily: 'Inter', // Assuming Inter or similar
                        ),
                      ),
                      TextSpan(
                        text: price,
                        style: TextStyle(
                          fontSize: 36.sp,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                          fontFamily: 'Inter',
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 8.h),

                // Description
                CustomText(
                  description,
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w400,
                  color: Colors.white,
                ),
                SizedBox(height: 24.h),

                // Tags (Unlimited Chat, Validity)
                Row(
                  children: tags.map((tag) {
                    return Container(
                      margin: EdgeInsets.only(right: 12.w),
                      padding: EdgeInsets.symmetric(
                        horizontal: 16.w,
                        vertical: 10.h,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(20.r),
                      ),
                      child: CustomText(
                        tag,
                        fontSize: 12.sp,
                        fontWeight: FontWeight.w500,
                        color: Colors.white,
                      ),
                    );
                  }).toList(),
                ),
                SizedBox(height: 30.h),

                // Benefits Header
                CustomText(
                  'Benefits -',
                  fontSize: 20.sp,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
                SizedBox(height: 16.h),

                // Benefits List
                ...benefits.map(
                  (benefit) => Padding(
                    padding: EdgeInsets.only(bottom: 12.h),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: EdgeInsets.only(top: 6.h),
                          child: Container(
                            width: 4.w,
                            height: 4.w,
                            decoration: const BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                            ),
                          ),
                        ),
                        SizedBox(width: 12.w),
                        Expanded(
                          child: CustomText(
                            benefit,
                            fontSize: 15.sp,
                            fontWeight: FontWeight.w400,
                            color: Colors.white.withValues(alpha: 0.9),
                            height: 1.4,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const Spacer(),

                // Upgrade Button
                _GradientBorderButton(text: 'Upgrade', onTap: () {}),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// Custom Button with Gradient Border AND Gradient Fill (opacity)
class _GradientBorderButton extends StatelessWidget {
  final String text;
  final VoidCallback onTap;

  const _GradientBorderButton({required this.text, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      // Using Stack to separate Fill and Border
      child: Stack(
        children: [
          // Layer 1: The Semi-Transparent Fill & Text
          Container(
            height: 56.h,
            width: double.infinity,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(28.r),
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  const Color(0xFF05DAF1).withValues(alpha: 0.4),
                  const Color(0xFFC00F8B).withValues(alpha: 0.4),
                ],
              ),
            ),
            child: CustomText(
              text,
              fontSize: 16.sp,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),

          // Layer 2: The Gradient Border Overlay
          // We use ShaderMask on a transparent container with a white border
          // This ensures the gradient is applied ONLY to the border stroke.
          Positioned.fill(
            child: IgnorePointer(
              child: ShaderMask(
                shaderCallback: (Rect bounds) {
                  return const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [Color(0xFF05DAF1), Color(0xFFC00F8B)],
                  ).createShader(bounds);
                },
                blendMode: BlendMode.srcIn,
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(28.r),
                    border: Border.all(
                      color: Colors.white, // The canvas for the shader
                      width: 1.w, // Border thickness
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
