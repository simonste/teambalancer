import 'package:flutter/material.dart';
import 'package:teambalancer/l10n/app_localizations.dart';
import 'package:intl/intl.dart';

export 'package:teambalancer/l10n/app_localizations.dart';

extension AppLocalizationsX on BuildContext {
  AppLocalizations get l10n => AppLocalizations.of(this)!;
}

DateFormat getDateTimeFormatter(context) {
  Locale currentLocale = Localizations.localeOf(context);
  if (currentLocale.languageCode == 'de') {
    return DateFormat('EEE, d. MMM y, HH:mm', 'de_DE');
  } else {
    return DateFormat('EEE, MMM d, y h:mm a');
  }
}

DateFormat getDateFormatter(context) {
  Locale currentLocale = Localizations.localeOf(context);
  if (currentLocale.languageCode == 'de') {
    return DateFormat('EEE, d. MMM y', 'de_DE');
  } else {
    return DateFormat('EEE, MMM d, y');
  }
}

DateFormat getTimeFormatter(context) {
  Locale currentLocale = Localizations.localeOf(context);
  if (currentLocale.languageCode == 'de') {
    return DateFormat('HH:mm', 'de_DE');
  } else {
    return DateFormat('h:mm a');
  }
}
