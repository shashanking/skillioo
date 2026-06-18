import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../services/session_prefs.dart';
import 'app_locale.dart';
import 'translations.dart';

class LocaleNotifier extends StateNotifier<AppLocale> {
  LocaleNotifier() : super(AppLocale.en) {
    _loadSavedLocale();
  }

  Future<void> _loadSavedLocale() async {
    final code = await SessionPrefs.instance.getLocale();
    state = AppLocale.fromCode(code);
  }

  Future<void> setLocale(AppLocale locale) async {
    state = locale;
    await SessionPrefs.instance.setLocale(locale.code);
  }

  Translations get translations => Translations(state);
}

final localeNotifierProvider =
    StateNotifierProvider<LocaleNotifier, AppLocale>((ref) {
  return LocaleNotifier();
});

final trProvider = Provider<Translations>((ref) {
  final locale = ref.watch(localeNotifierProvider);
  return Translations(locale);
});
