enum AppLocale {
  en,
  hi,
  mr,
  kn,
  te,
  ml;

  String get code {
    switch (this) {
      case AppLocale.en:
        return 'en';
      case AppLocale.hi:
        return 'hi';
      case AppLocale.mr:
        return 'mr';
      case AppLocale.kn:
        return 'kn';
      case AppLocale.te:
        return 'te';
      case AppLocale.ml:
        return 'ml';
    }
  }

  String get displayName {
    switch (this) {
      case AppLocale.en:
        return 'English';
      case AppLocale.hi:
        return 'Hindi';
      case AppLocale.mr:
        return 'Marathi';
      case AppLocale.kn:
        return 'Kannada';
      case AppLocale.te:
        return 'Telugu';
      case AppLocale.ml:
        return 'Malayalam';
    }
  }

  String get nativeName {
    switch (this) {
      case AppLocale.en:
        return 'English';
      case AppLocale.hi:
        return 'हिन्दी';
      case AppLocale.mr:
        return 'मराठी';
      case AppLocale.kn:
        return 'ಕನ್ನಡ';
      case AppLocale.te:
        return 'తెలుగు';
      case AppLocale.ml:
        return 'മലയാളം';
    }
  }

  static AppLocale fromCode(String code) {
    return AppLocale.values.firstWhere(
      (l) => l.code == code,
      orElse: () => AppLocale.en,
    );
  }
}
