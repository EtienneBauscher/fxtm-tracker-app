// 🌎 Project imports:
import 'package:fxtm/contracts/forex_categories_utility.contract.dart';
import 'package:fxtm/enums/categories.enum.dart';

class ForexCategoriesUtility implements ForexCategoriesUtilityContract {
  static const majorPairs = {
    'OANDA:EUR_USD',
    'OANDA:USD_JPY',
    'OANDA:GBP_USD',
    'OANDA:USD_CHF',
    'OANDA:AUD_USD',
    'OANDA:USD_CAD',
    'OANDA:NZD_USD',
  };
  static const minorPairs = <String>[
    'OANDA:EUR_GBP',
    'OANDA:EUR_CHF',
    'OANDA:EUR_CAD',
    'OANDA:EUR_AUD',
    'OANDA:EUR_NZD',
    'OANDA:GBP_EUR',
    'OANDA:GBP_CHF',
    'OANDA:GBP_CAD',
    'OANDA:GBP_AUD',
    'OANDA:GBP_NZD',
    'OANDA:EUR_JPY',
    'OANDA:GBP_JPY',
    'OANDA:CHF_JPY',
    'OANDA:CAD_JPY',
    'OANDA:AUD_JPY',
    'OANDA:NZD_JPY',
    'OANDA:AUD_CAD',
    'OANDA:AUD_NZD',
    'OANDA:AUD_CHF',
    'OANDA:NZD_CAD',
    'OANDA:NZD_CHF',
    'OANDA:CHF_CAD',
  ];

  final _categories = <String, List<String>>{
    Categories.majors.name: <String>[],
    Categories.minors.name: <String>[],
    Categories.exotics.name: <String>[],
  };
  final _groups = <String, List<List<String>>>{};

  @override
  Map<String, List<List<String>>> get groups => _groups;

  @override
  void categorizeSymbols(List<String> symbols) {
    _categories[Categories.majors.name]?.clear();
    _categories[Categories.minors.name]?.clear();
    _categories[Categories.exotics.name]?.clear();

    for (var symbol in symbols) {
      if (majorPairs.contains(symbol)) {
        _categories[Categories.majors.name]?.add(symbol);
      }
      if (minorPairs.contains(symbol)) {
        _categories[Categories.minors.name]?.add(symbol);
      }
      if (!majorPairs.contains(symbol) && !minorPairs.contains(symbol)) {
        _categories[Categories.exotics.name]?.add(symbol);
      }
    }
  }

  @override
  void splitIntoGroups(int maxSize) {
    _groups.clear();

    for (var category in _categories.keys) {
      _groups[category] = <List<String>>[];
      final categorySymbols = _categories[category]!;

      for (int index = 0; index < categorySymbols.length; index += maxSize) {
        final endIndex =
            index + maxSize > categorySymbols.length
                ? categorySymbols.length
                : index + maxSize;

        _groups[category]!.add(categorySymbols.sublist(index, endIndex));
      }
    }
  }
}
