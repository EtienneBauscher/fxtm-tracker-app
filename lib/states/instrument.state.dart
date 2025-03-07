// 📦 Package imports:
import 'package:freezed_annotation/freezed_annotation.dart';

// 🌎 Project imports:
import 'package:fxtm/models/instrument.model.dart';

part 'instrument.state.freezed.dart';

@freezed
class InstrumentsState with _$InstrumentsState {
  const factory InstrumentsState.loading() = InstrumentsStateInstrumentsLoading;
  const factory InstrumentsState.symbolsReady() = InstrumentsStateSymbolsReady;
  const factory InstrumentsState.loaded({
    required List<Instrument> instruments,
  }) = InstrumentsStateInstrumentsLoaded;
  const factory InstrumentsState.webSocketConnectionError({
    required List<Instrument> instruments,
  }) = InstrumentsStateWebSocketConnectionError;
  const factory InstrumentsState.error() = InstrumentsStateError;
}
