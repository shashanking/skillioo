import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'firebase_options.dart';
import 'core/services/notification_service.dart';
import 'features/call/application/call_providers.dart';

import 'core/router/app_router.dart';
import 'core/services/session_prefs.dart';
import 'core/services/session_state_provider.dart';

/// Global key to access app state from anywhere (needed for call notifications)
final GlobalKey<NavigatorState> appKey = GlobalKey<NavigatorState>();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Warm up session cache before anything else reads tokens.
  // This single call avoids dozens of platform-channel hits later.
  await Future.wait([
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]),
    SessionPrefs.instance.warmUp(),
    Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform),
  ]);

  await NotificationService().init();

  runApp(const ProviderScope(child: MainApp()));
}

class MainApp extends ConsumerStatefulWidget {
  const MainApp({super.key});

  @override
  ConsumerState<MainApp> createState() => _MainAppState();
}

class _MainAppState extends ConsumerState<MainApp> {
  @override
  void initState() {
    super.initState();
    // Populate reactive session state from the already-warm SessionPrefs cache
    ref.read(sessionStateProvider.notifier).refresh();
    _registerFcmToken();
  }

  Future<void> _registerFcmToken() async {
    try {
      final fcmToken = await FirebaseMessaging.instance.getToken();
      if (fcmToken != null && fcmToken.isNotEmpty) {
        await ref
            .read(callNotifierProvider.notifier)
            .registerFcmToken(fcmToken);
      }
    } catch (e) {
      debugPrint('MainApp: Error registering FCM token: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
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
