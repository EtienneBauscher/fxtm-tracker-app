// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get forexTitle => 'FXTM Forex Tracker';

  @override
  String get oandaTitle => 'OANDA Trading Ticker Prices';

  @override
  String get majorPairsTab => 'Major Pairs';

  @override
  String get minorPairsTab => 'Minor Pairs';

  @override
  String get exoticPairsTab => 'Exotic Pairs';

  @override
  String get groupOneTab => 'Group one';

  @override
  String get groupTwoTab => 'Group two';

  @override
  String get searchInstrumentsPlaceHolder => 'Search instruments';

  @override
  String get intstrumentBlocErrorMessage => 'An error occured, please try again';

  @override
  String get tryAgainButtonText => 'Try again';

  @override
  String get webSocketConnectionErrorMessage => 'The WebSocket couldn\'t connect, please wait a while before navigating again';
}
