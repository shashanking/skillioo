import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'locale_notifier.dart';
import 'translations.dart';

extension LocaleExtension on WidgetRef {
  Translations get tr => watch(trProvider);
}
