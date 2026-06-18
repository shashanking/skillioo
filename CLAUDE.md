# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Build & Run Commands

```bash
flutter pub get                                # Install dependencies
dart run build_runner build --delete-conflicting-outputs  # Generate *.freezed.dart and *.g.dart files
dart run build_runner watch --delete-conflicting-outputs  # Watch mode for code generation
flutter run                                    # Run on connected device/emulator
flutter build apk                              # Build Android APK
flutter build ios                              # Build iOS app
flutter test                                   # Run tests
flutter test test/path/to/file_test.dart       # Run a single test file
flutter test --plain-name "test name"          # Run a single test by name
dart analyze lib/path/to/file.dart             # Analyze specific files
```

After modifying any class annotated with `@freezed` or `@JsonSerializable`, re-run build_runner to regenerate code.

**Android-native changes** (manifest, Kotlin in `android/app/src/main/kotlin/...`) require a full rebuild — `flutter clean && flutter run` — and sometimes an `adb uninstall com.example.skillioo` first, since Android caches service registrations.

## Architecture

**State management:** Riverpod with three patterns:
- `StateNotifierProvider` + Freezed immutable states — complex mutable state with actions (most feature notifiers)
- `FutureProvider` / `FutureProvider.family` — read-only async data that doesn't need mutations (profile detail, categories, hiring rates; see `profile_detail_provider.dart`, `category_provider.dart`)
- `StateProvider<T>` — simple scalar or set state (e.g., `dashboardCityFilterProvider`, `likedProfileIdsProvider`)

**Three-layer feature structure** (Clean Architecture without a repository layer):
```
features/<name>/
  domain/       – services (HTTP calls via BaseServiceProvider) and models (@JsonSerializable)
  application/  – providers, notifiers (StateNotifier), and states (@freezed)
  presentation/ – screens and widgets (ConsumerWidget / ConsumerStatefulWidget)
```
Services are injected into notifiers through Riverpod providers; there is no separate repository/data layer.

**Routing:** GoRouter configured in `lib/core/router/app_router.dart` (~50 routes). All routes use a custom `FadeTransition`. State is passed via query parameters.

**API layer:** Three microservices behind `https://skillioo.mitraconsultancy.co.in/`:
- Customer MS (`/customer/api`) – auth, profiles, chat, calls, follows, notifications, online presence, FCM tokens, documents
- Post MS (`/post/api`) – posts, reels, stories, comments, reactions, media
- Payment MS (`/payment/api`) – subscriptions, payments, hiring rates

All endpoint constants live in `lib/core/config/api_config.dart`. HTTP calls go through `BaseServiceProvider` (`lib/core/services/base_service_provider.dart`), which JSON-encodes bodies and throws `Exception('HTTP Error: <code>')` on 5xx. **Auth is NOT auto-injected** — services hold a `_authToken` field set via `setAuthToken(token)`, and notifiers must refresh it before each call (see the `_ensurePostAuth` / `getAccessToken()` pattern in `post_notifier.dart`, `profile_list_notifier.dart`, etc.).

**Shared HTTP client with retry:** `sharedHttpClientProvider` (`lib/core/services/shared_http_client.dart`) is the single `http.Client` instance used by most services for keep-alive. It is wrapped in `RetryHttpClient` (`lib/core/services/retry_http_client.dart`) which retries GET/HEAD on 502/503/504 and `SocketException`/`TimeoutException` (400ms then 1.2s backoff). This is critical because Customer MS occasionally 502s on cold-start. Non-idempotent verbs (POST/PUT/PATCH/DELETE) are never retried. Note: a few legacy services (e.g. `DocumentService`, `CallService`) instantiate their own `http.Client()` in their constructor when none is passed — when calling them from new code, always go through the provider (`postDocumentServiceProvider`, `callServiceProvider`) so retry applies.

**Realtime — Socket.io** (`lib/core/services/socket_service.dart`):
- Origin derived from `ApiConfig.customerBaseUrl` host; path `/customer/socket.io`
- Transports: `['websocket', 'polling']` (websocket-first; polling fallback). `disableAutoConnect()` is NOT used — the socket auto-connects on creation.
- Backend expects the client to `emit('register', { profileId: <id> })` after `onConnect`; profileId is **not** in the URL query.
- Singleton; `connect()` is called from `Landing.initState` post-frame.

**Realtime — Twilio Voice (VoIP):**
- Dart wrapper: `lib/features/call/domain/twilio_voice_service.dart` over `twilio_voice_flutter` package.
- Accept/reject bypass the package and use a custom MethodChannel `com.example.skillioo/call_manager` (defined in `android/app/src/main/kotlin/com/example/skillioo/MainActivity.kt`).
- **Native FCM handling is custom** because Android allows only one `FirebaseMessagingService` to win MESSAGING_EVENT delivery. We declare `MyFirebaseMessagingService` (priority=100) in the manifest — it calls `Voice.handleMessage(...)` and stores the resulting `CallInvite` in `ActiveCallInviteStore` (our own static store), which `MainActivity.answerCall` reads. We do NOT rely on `TwilioVoiceFlutterPlugin.activeCallInvite` being set by the package's internal service. The firebase_messaging plugin's separate broadcast receiver still fires for Dart `onMessage` because it listens on `c2dm.intent.RECEIVE`, not `MESSAGING_EVENT`.
- **FCM token rotation:** `onFcmTokenRefreshCallback` (in `lib/core/services/notification_service.dart`) is set by `Landing.initState` and re-registers with Twilio Voice whenever the token rotates. Without this, Twilio keeps pushing to the old token and FCM rejects it (Twilio error code 52103).
- **Incoming-call screen orchestration** (see `CallNotifier._setupSocketCallbacks` and `notification_service.dart`):
  - Socket `incomingCall` event **only** stashes caller metadata + the backend's callId into state. It does NOT open the incoming-call screen.
  - The Twilio FCM push (detected by `twi_message_type=twilio.voice.call` in Dart) is the trigger that flips `state.status = incomingCall` and opens the screen. The package does not surface incoming CallInvites to Dart via its event stream — the FCM payload itself is the Dart-side signal.

**Session/auth:** `SessionPrefs` singleton wraps `FlutterSecureStorage` for tokens, profile JSON, locale, and login timestamps. `sessionStateProvider` is the reactive snapshot — call `refresh()` after login/logout. Auth flow: phone → OTP → PIN.

**`AuthPrefs`** (`lib/core/services/auth_prefs.dart`) is a separate singleton for PIN storage and biometric authentication. Use `AuthPrefs.instance` for PIN/biometric operations; `SessionPrefs.instance` for tokens and profile data — don't mix the two.

## Key Conventions

- Responsive sizing via `flutter_screenutil` (375×812 design base). Use `.w`, `.h`, `.sp` extensions.
- Dark theme with Material 3. Color palette and gradients defined in `lib/constants/app_constants.dart`.
- Custom fonts: Outfit (body text, weights 400/500/600), Neue Montreal Bold (headings).
- Generic `ApiResponse<T>` wrapper (`lib/core/models/api_response.dart`) for typed API responses with unified error handling.
- Singleton pattern for `SessionPrefs`, `SocketService`, `NotificationService`, `TwilioVoiceService`, `VideoControllerRegistry`. Every `VideoPlayerController` must call `VideoControllerRegistry.instance.register()` on init and `unregister()` on dispose. `disposeAll()` is called before Twilio calls to free file descriptors — Twilio's native VoIP `select()` syscall crashes above 1024 open FDs and ExoPlayer instances each consume many.
- Localization via `lib/core/localization/` with `LocaleNotifier` Riverpod provider.
- `use_build_context_synchronously` is suppressed project-wide in `analysis_options.yaml`. Don't add `// ignore:` workarounds or restructure async code to satisfy it.

## Important Patterns and Gotchas

**Media items have no direct URL — they have `documentId` arrays.** Reels/posts come back with `documentId: ["<uuid>", ...]` and the client resolves these to actual URLs via `DocumentService.getDocumentsByIds`. Two consumer widgets implement this independently: `combined_media_grid.dart` (home feed) and `reels_page.dart` (reels tab). Both have a local `_cachedDocuments` map keyed by document UUID, a retry-once wrapper around the service call (Customer MS sometimes 502s on cold-start), and use `ref.read(postDocumentServiceProvider)` so requests go through the retrying shared client. `resolvePreferredDocument` and `isVideoDocument` in `media_document_resolver.dart` pick the right document for a given mediaType. **An item with all `documentId`s unresolved is silently skipped** — if everything is being skipped you'll see "No media available" with no error.

**Home feed filters out the current user's own content.** `combined_media_grid.dart:222-225` drops any media where `userReferenceId == currentUserId` so users don't see their own posts in the discover feed. Confusing in dev when only one test account has posted — feed will look empty even though the API returned items.

**First-load self-heal pattern.** Several consumer widgets (`CombinedMediaGrid`, `ProfilesReelsPage`, `ProfileTab`, `GalleryGrid`) have a `_didAutoRetry` flag and a `ref.listen` in `build()` that catches the `loading → error` transition with empty data and re-fires the fetch once after 800ms. Prevents the UI from being stuck empty when the cold-start fetch transiently fails. Pair this with the HTTP-layer retry in `RetryHttpClient` for two layers of resilience.

**Don't preload heavy data from `Landing.initState`.** Earlier the landing screen preloaded `profileList`, `fetchFeed(reel)`, and `fetchFeed(post)` via `addPostFrameCallback`. That raced with the tab widgets' own `if (state.empty && !state.loading)` gates — if Landing's call failed, every tab would skip its own fetch and the UI would be stuck empty. The preload was removed; each tab fetches on mount. Only follow data is still preloaded (`fetchFollowing`, `fetchFollowCount` — used pervasively, low risk).

## Feature Modules

auth, call, chat, dashboard, follow, onboarding, online, payment, posts, profile, subscription. Each follows the domain/application/presentation structure above.
