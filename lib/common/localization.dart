import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:intl/intl.dart';

export 'package:flutter_gen/gen_l10n/app_localizations.dart';

extension AppLocalizationsX on BuildContext {
  AppLocalizations get l10n => AppLocalizations.of(this)!;
}

DateFormat getDateFormatter(context) {
  Locale currentLocale = Localizations.localeOf(context);
  if (currentLocale.languageCode == 'de') {
    return DateFormat('EEE, d. MMM y, HH:mm', 'de_DE');
  } else {
    return DateFormat('EEE, MMM d, y h:mm a');
  }
}
