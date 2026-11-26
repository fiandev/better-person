import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

class AppLocalizations {
  const AppLocalizations(this.locale);

  final Locale locale;

  static const supportedLocales = [Locale('en'), Locale('id')];
  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates = [
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
  ];

  static AppLocalizations of(BuildContext context) =>
      Localizations.of<AppLocalizations>(context, AppLocalizations)!;

  String text(String key) {
    final language = locale.languageCode == 'id' ? _indonesian : _english;
    return language[key] ?? _english[key] ?? key;
  }

  static const _english = {
    'home': 'Home',
    'focus': 'Focus',
    'devotion': 'Devotion',
    'finance': 'Finance',
    'statistics': 'Statistics',
    'settings': 'Settings',
  };

  static const _indonesian = {
    'home': 'Beranda',
    'focus': 'Fokus',
    'devotion': 'Ibadah',
    'finance': 'Keuangan',
    'statistics': 'Statistik',
    'settings': 'Pengaturan',
  };
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) => AppLocalizations.supportedLocales.any(
    (supported) => supported.languageCode == locale.languageCode,
  );

  @override
  Future<AppLocalizations> load(Locale locale) =>
      SynchronousFuture<AppLocalizations>(AppLocalizations(locale));

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}
