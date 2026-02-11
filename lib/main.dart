import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'core/router/app_router.dart';

void main() {
  runApp(const ProviderScope(child: MainApp()));
}

class MainApp extends ConsumerWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ScreenUtilInit(
      designSize: const Size(375, 812), // iPhone X dimensions as base
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (context, child) {
        final baseTheme = ThemeData.dark(useMaterial3: true);

        final outfitTextTheme = baseTheme.textTheme.apply(fontFamily: 'Outfit');

        final titleTheme = outfitTextTheme.copyWith(
          displayLarge: outfitTextTheme.displayLarge?.copyWith(
            fontFamily: 'Neue',
          ),
          displayMedium: outfitTextTheme.displayMedium?.copyWith(
            fontFamily: 'Neue',
          ),
          displaySmall: outfitTextTheme.displaySmall?.copyWith(
            fontFamily: 'Neue',
          ),
          headlineLarge: outfitTextTheme.headlineLarge?.copyWith(
            fontFamily: 'Neue',
          ),
          headlineMedium: outfitTextTheme.headlineMedium?.copyWith(
            fontFamily: 'Neue',
          ),
          headlineSmall: outfitTextTheme.headlineSmall?.copyWith(
            fontFamily: 'Neue',
          ),
          titleLarge: outfitTextTheme.titleLarge?.copyWith(fontFamily: 'Neue'),
          titleMedium: outfitTextTheme.titleMedium?.copyWith(
            fontFamily: 'Neue',
          ),
          titleSmall: outfitTextTheme.titleSmall?.copyWith(fontFamily: 'Neue'),
        );

        return MaterialApp.router(
          title: 'Skillioo',
          debugShowCheckedModeBanner: false,
          theme: baseTheme.copyWith(textTheme: titleTheme),
          routerConfig: appRouter,
        );
      },
    );
  }
}
