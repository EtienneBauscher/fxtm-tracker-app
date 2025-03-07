// 📦 Package imports:
import 'package:freezed_annotation/freezed_annotation.dart';

// 🌎 Project imports:
import 'package:fxtm/models/price_update.model.dart';

part 'instrument.event.freezed.dart';

@freezed
class InstrumentsEvent with _$InstrumentsEvent {
  const factory InstrumentsEvent.fetchSymbols() = FetchSymbols;
  const factory InstrumentsEvent.fetchInstruments(
    int index, {
    int? tabBarIndex,
  }) = FetchInstruments;
  const factory InstrumentsEvent.connectWebSocket(
    int index, {
    int? tabBarIndex,
  }) = ConnectWebSocket;
  const factory InstrumentsEvent.updateSearchQuery(String query) =
      UpdateSearchQuery;
  const factory InstrumentsEvent.priceUpdated(PriceUpdate update) =
      PriceUpdated;
}
