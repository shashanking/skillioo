import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../constants/app_constants.dart';

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen> {
  bool _showPng = false;

  late final ImageProvider _gifProvider;
  late final ImageProvider _pngProvider;

  @override
  void initState() {
    super.initState();
    _gifProvider = const AssetImage(AppAssets.logoGif);
    _pngProvider = const AssetImage(AppAssets.logoPng);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      precacheImage(_pngProvider, context);
      Future.delayed(const Duration(milliseconds: 3300), () {
        if (mounted) {
          setState(() {
            _showPng = true;
          });

          Future.delayed(const Duration(milliseconds: 900), () {
            if (mounted) {
              context.go('/start');
            }
          });
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(gradient: AppColors.primaryGradient),
        child: Center(
          child: Hero(
            tag: 'logo',
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 600),
              switchInCurve: Curves.easeInOut,
              switchOutCurve: Curves.easeInOut,
              transitionBuilder: (child, animation) {
                return FadeTransition(opacity: animation, child: child);
              },
              child: Image(
                key: ValueKey<bool>(_showPng),
                image: _showPng ? _pngProvider : _gifProvider,
                width: _showPng ? 180.0 : null,
                fit: BoxFit.contain,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
