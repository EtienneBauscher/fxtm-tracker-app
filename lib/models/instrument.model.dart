// 📦 Package imports:
import 'package:freezed_annotation/freezed_annotation.dart';

// 🌎 Project imports:
import 'package:fxtm/enums/price_change.enum.dart';

part 'instrument.model.freezed.dart';

@freezed
class Instrument with _$Instrument {
  const Instrument._();

  const factory Instrument({
    required String symbol,
    double? price,
    double? previousPrice,
  }) = _Instrument;

  PriceChange get priceChange {
    if (previousPrice == null || price == null) return PriceChange.unchanged;
    if (price! > previousPrice!) return PriceChange.increased;
    if (price! < previousPrice!) return PriceChange.decreased;
    return PriceChange.unchanged;
  }

  String get simpleSymbol => symbol.split(":")[1];
}
