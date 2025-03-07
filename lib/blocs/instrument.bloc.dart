// 🎯 Dart imports:
import 'dart:async';

// 📦 Package imports:
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:logger/web.dart';

// 🌎 Project imports:
import 'package:fxtm/contracts/finnhub_service.contract.dart';
import 'package:fxtm/contracts/logger_service.contract.dart';
import 'package:fxtm/events/instrument.event.dart';
import 'package:fxtm/models/instrument.model.dart';
import 'package:fxtm/states/instrument.state.dart';

final _getIt = GetIt.instance;

class InstrumentsBloc extends Bloc<InstrumentsEvent, InstrumentsState> {
  InstrumentsBloc()
    : _finnhubService = _getIt.get<FinnhubServiceContract>(),
      _loggerService = _getIt.get<LoggerServiceContract>(),
      super(const InstrumentsState.loading()) {
    on<FetchSymbols>(_onFetchSymbols);
    on<FetchInstruments>(_onFetchInstruments);
    on<ConnectWebSocket>(_connectWebSocket);
    on<UpdateSearchQuery>(_onUpdateSearchQuery);
    on<PriceUpdated>(_onPriceUpdated);
  }

  final FinnhubServiceContract _finnhubService;
  final LoggerServiceContract _loggerService;
  final _allInstruments = <Instrument>[];

  Future<void> _onFetchSymbols(
    FetchSymbols event,
    Emitter<InstrumentsState> emit,
  ) async {
    emit(const InstrumentsState.loading());
    final result = await _finnhubService.fetchSymbols();

    result.when(
      success: (symbols) {
        emit(const InstrumentsState.symbolsReady());
      },
      failed: (exception) {
        _loggerService.log(
          '${exception.error}\n${exception.message}\n${exception.type}',
          level: Level.error,
        );

        emit(const InstrumentsState.error());
      },
    );
  }

  Future<void> _onFetchInstruments(
    FetchInstruments event,
    Emitter<InstrumentsState> emit,
  ) async {
    _finnhubService.dispose();
    emit(const InstrumentsState.loading());

    _allInstruments.clear();
    final groupSymbols = _getCategoryGroupSymbols(
      event.index,
      tabBarIndex: event.tabBarIndex,
    );

    if (groupSymbols.isNotEmpty == true) {
      for (final symbol in groupSymbols) {
        final instrument = Instrument(symbol: symbol);

        _allInstruments.add(instrument);
      }
    }

    emit(
      InstrumentsState.loaded(
        instruments: List<Instrument>.from(_allInstruments),
      ),
    );

    add(ConnectWebSocket(event.index, tabBarIndex: event.tabBarIndex));
  }

  Future<void> _connectWebSocket(
    ConnectWebSocket event,
    Emitter<InstrumentsState> emit,
  ) async {
    final connect = await _finnhubService.connect();

    if (!connect) {
      return emit(
        InstrumentsState.webSocketConnectionError(
          instruments: List<Instrument>.from(_allInstruments),
        ),
      );
    }

    _finnhubService.priceStream.listen((update) {
      add(PriceUpdated(update));
    });
    final groupSymbols = _getCategoryGroupSymbols(
      event.index,
      tabBarIndex: event.tabBarIndex,
    );

    _finnhubService.listen();
    _finnhubService.subscribe(groupSymbols);
  }

  void _onUpdateSearchQuery(
    UpdateSearchQuery event,
    Emitter<InstrumentsState> emit,
  ) {
    final query = event.query.toLowerCase();
    final filtered =
        _allInstruments.where((instrument) {
          return instrument.symbol.toLowerCase().contains(query);
        }).toList();

    _loggerService.log('Query: ${event.query}', level: Level.info);

    emit(InstrumentsState.loaded(instruments: filtered));
  }

  void _onPriceUpdated(PriceUpdated event, Emitter<InstrumentsState> emit) {
    final update = event.update;
    final index = _allInstruments.indexWhere(
      (instrument) => instrument.symbol == event.update.symbol,
    );

    if (index != -1) {
      final instrument = _allInstruments[index];
      final updatedInstrument = instrument.copyWith(
        previousPrice: instrument.price,
        price: update.price,
      );
      _allInstruments.replaceRange(index, index + 1, <Instrument>[
        updatedInstrument,
      ]);

      if (state is InstrumentsStateInstrumentsLoaded) {
        final currentState = state as InstrumentsStateInstrumentsLoaded;
        final filteredIndex = currentState.instruments.indexWhere(
          (filteredInstrument) => filteredInstrument.symbol == update.symbol,
        );
        if (filteredIndex != -1) {
          final updatedFiltered = List<Instrument>.from(
            currentState.instruments,
          )..[filteredIndex] = updatedInstrument;

          emit(InstrumentsState.loaded(instruments: updatedFiltered));
        }
      }
    }
  }

  void dispose() {
    _finnhubService.dispose();
  }

  List<String> _getCategoryGroupSymbols(int index, {int? tabBarIndex}) {
    final groups = _finnhubService.groups;
    final group = groups.keys.toList()[index];
    return tabBarIndex == 1 ? groups[group]![1] : groups[group]![0];
  }
}
