import 'package:flutter/material.dart';

import '../../constants/app_constants.dart';

class CommonBackground extends StatelessWidget {
  final Widget child;

  const CommonBackground({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        // image: DecorationImage(
        //   image: AssetImage('assets/images/Animation.svg'),
        //   fit: BoxFit.cover,
        // ),
        gradient: AppColors.primaryGradient,
      ),
      child: child,
    );
    
  }
}
