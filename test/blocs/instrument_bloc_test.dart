// 🎯 Dart imports:
import 'dart:async';

// 📦 Package imports:
import 'package:bloc_test/bloc_test.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

// 🌎 Project imports:
import 'package:fxtm/blocs/instrument.bloc.dart';
import 'package:fxtm/contracts/finnhub_service.contract.dart';
import 'package:fxtm/contracts/logger_service.contract.dart';
import 'package:fxtm/events/instrument.event.dart';
import 'package:fxtm/models/instrument.model.dart';
import 'package:fxtm/models/price_update.model.dart';
import 'package:fxtm/models/result.model.dart';
import 'package:fxtm/states/instrument.state.dart';
import 'package:fxtm/utilities/forex_categories.utility.dart';
import 'instrument_bloc_test.mocks.dart';

@GenerateMocks([FinnhubServiceContract, LoggerServiceContract])
late FinnhubServiceContract _finnhubService;
late InstrumentsBloc _instrumentsBloc;

final _dependencies = GetIt.instance;
final _forexCategoriesUtility = ForexCategoriesUtility();

void _setUpDependencies() {
  _dependencies
    ..registerSingleton<FinnhubServiceContract>(MockFinnhubServiceContract())
    ..registerSingleton<LoggerServiceContract>(MockLoggerServiceContract());
}

void _commonSetup() {
  _finnhubService = _dependencies.get<FinnhubServiceContract>();
  _instrumentsBloc = InstrumentsBloc();
}

final _mockServiceSymbols = <String>[];
const _mockSymbols = <String>[
  'OANDA:EUR_USD',
  'OANDA:USD_JPY',
  'OANDA:GBP_USD',
  'OANDA:USD_CHF',
  'OANDA:AUD_USD',
  'OANDA:USD_CAD',
  'OANDA:NZD_USD',
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
  'OANDA:USD_HUF',
  'OANDA:USD_TRY',
  'OANDA:EUR_SGD',
  'OANDA:XAG_NZD',
  'OANDA:XPT_USD',
  'OANDA:AUD_SGD',
];
final _allInstruments = <Instrument>[];
final _mockGroupedSymbols = <String, List<List<String>>>{};

void main() {
  setUpAll(_setUpDependencies);

  group('Instrument Bloc OnFetchSymbols tests:\n', _testOnFetchSymbols);
  group('Instrument Bloc OnFetchInstruments tests:\n', _testOnFetchInstruments);
  group('Instrument Bloc OnConnectWebSocket tests:\n', _testOnConnectWebSocket);
  group(
    'Instrument Bloc OnUpdateSearchQuery tests:\n',
    _testOnUpdateSearchQuery,
  );
}

void _testOnFetchSymbols() {
  setUp(_commonSetup);
  blocTest<InstrumentsBloc, InstrumentsState>(
    'Given a call to fetch the symbols,\n'
    'When the finnhub service responds successfully,\n'
    'Then we categorize and group the symbols and emit the symbols ready state',
    build: () {
      return _instrumentsBloc;
    },
    setUp: () {
      _setUpCategories();

      when(_finnhubService.fetchSymbols()).thenAnswer((_) async {
        return Success<Map<String, List<List<String>>>>(
          _forexCategoriesUtility.groups,
        );
      });
    },
    act: (bloc) => bloc.add(const FetchSymbols()),
    expect: () {
      return const <InstrumentsState>[
        InstrumentsState.loading(),
        InstrumentsState.symbolsReady(),
      ];
    },
  );

  blocTest<InstrumentsBloc, InstrumentsState>(
    'Given a call to fetch the symbols,\n'
    'When the finnhub responds responds with an exception,\n'
    'Then we emit an error state',
    build: () {
      return _instrumentsBloc;
    },
    setUp: () {
      when(_finnhubService.fetchSymbols()).thenAnswer((_) async {
        return Failed<Map<String, List<List<String>>>>(
          DioException(
            requestOptions: RequestOptions(),
            message: 'An error occurred',
          ),
        );
      });
    },
    act: (bloc) => bloc.add(const FetchSymbols()),
    expect: () {
      return const <InstrumentsState>[
        InstrumentsState.loading(),
        InstrumentsState.error(),
      ];
    },
  );
}

void _testOnFetchInstruments() {
  setUp(_commonSetup);

  blocTest<InstrumentsBloc, InstrumentsState>(
    'Given a call to fetch the instruments,\n'
    'When the correct group of symbols have been retrieved successfully,\n'
    'Then we add instruments with each symbol and emit them in the loaded state',
    build: () {
      return _instrumentsBloc;
    },
    setUp: () {
      _finnhubService.dispose();
      _setUpCategories();
      when(_finnhubService.groups).thenReturn(_forexCategoriesUtility.groups);

      final group = _mockGroupedSymbols.keys.toList()[0];
      final symbols = _mockGroupedSymbols[group]![0];

      _addInstruments(symbols);

      when(
        _finnhubService.priceStream,
      ).thenAnswer((_) => StreamController<PriceUpdate>.broadcast().stream);
      when(_finnhubService.connect()).thenAnswer((invocation) async => true);

      _finnhubService.priceStream.listen((update) {
        _instrumentsBloc.add(PriceUpdated(update));
      });
    },
    act: (bloc) => bloc.add(const FetchInstruments(0)),
    expect: () {
      return <InstrumentsState>[
        const InstrumentsState.loading(),
        InstrumentsState.loaded(
          allInstruments: _allInstruments,
          filteredInstruments: _allInstruments,
        ),
      ];
    },
  );

  blocTest<InstrumentsBloc, InstrumentsState>(
    'Given a call to fetch the instruments,\n'
    'When the instruments are added to the list,\n'
    'Then we emit the loaded state',
    build: () {
      return _instrumentsBloc;
    },
    setUp: () {
      _finnhubService.dispose();
      _setUpCategories();

      when(_finnhubService.groups).thenReturn(_forexCategoriesUtility.groups);

      final group = _mockGroupedSymbols.keys.toList()[1];
      final symbols = _mockGroupedSymbols[group]![0];

      _addInstruments(symbols);
    },
    act: (bloc) => bloc.add(const FetchInstruments(1)),
    expect: () {
      return <InstrumentsState>[
        const InstrumentsState.loading(),
        InstrumentsState.loaded(
          allInstruments: _allInstruments,
          filteredInstruments: _allInstruments,
        ),
      ];
    },
  );
}

void _testOnConnectWebSocket() {
  setUp(_commonSetup);

  blocTest<InstrumentsBloc, InstrumentsState>(
    'Given an event is added to connect to the WebSocket,\n'
    'When connection is established, the priceStream listened to and,\n'
    'the symbols subscribed to, Then we do nothing',
    build: () {
      return _instrumentsBloc;
    },
    setUp: () {
      when(_finnhubService.connect()).thenAnswer((invocation) async => true);
      _finnhubService.priceStream.listen((update) {
        _instrumentsBloc.add(PriceUpdated(update));
      });
      _setUpCategories();
      when(_finnhubService.groups).thenReturn(_forexCategoriesUtility.groups);

      final group = _mockGroupedSymbols.keys.toList()[1];
      final symbols = _mockGroupedSymbols[group]![0];

      _finnhubService.listen();
      _finnhubService.subscribe(symbols);
    },
    act: (bloc) => bloc.add(const ConnectWebSocket(1)),
    seed: () {
      _finnhubService.dispose();

      return InstrumentsState.loaded(
        allInstruments: _allInstruments,
        filteredInstruments: _allInstruments,
      );
    },
    expect: () {
      return <InstrumentsState>[];
    },
  );

  blocTest<InstrumentsBloc, InstrumentsState>(
    'Given an event is added to connect to the WebSocket,\n'
    'When connection failes,\n'
    'Then we emit a WebSocketConnectionErrorState',
    build: () {
      return _instrumentsBloc;
    },
    setUp: () {
      when(_finnhubService.connect()).thenAnswer((invocation) async => false);
    },
    act: (bloc) => bloc.add(const ConnectWebSocket(1)),
    seed: () {
      _finnhubService.dispose();

      return InstrumentsState.loaded(
        allInstruments: _allInstruments,
        filteredInstruments: _allInstruments,
      );
    },
    expect: () {
      return <InstrumentsState>[
        InstrumentsState.webSocketConnectionError(
          allInstruments: _allInstruments,
          filteredInstruments: _allInstruments,
        ),
      ];
    },
  );
}

void _testOnUpdateSearchQuery() {
  setUp(_commonSetup);

  blocTest<InstrumentsBloc, InstrumentsState>(
    'Given a search query is done for a FX pair or Currency,\n'
    'When the event has completed the filtering,\n'
    'Then we emit the filtered instruments in the loaded state',
    build: () {
      return _instrumentsBloc;
    },
    act: (bloc) => bloc.add(const UpdateSearchQuery('uad')),
    setUp: () {
      _instrumentsBloc.add(const FetchInstruments(1));
      _setUpCategories();
      when(_finnhubService.groups).thenReturn(_forexCategoriesUtility.groups);
      final group = _mockGroupedSymbols.keys.toList()[1];
      final symbols = _mockGroupedSymbols[group]![0];
      _addInstruments(symbols);

      when(_finnhubService.connect()).thenAnswer((invocation) async => true);
      _finnhubService.priceStream.listen((update) {
        _instrumentsBloc.add(PriceUpdated(update));
      });
      _setUpCategories();
      when(_finnhubService.groups).thenReturn(_forexCategoriesUtility.groups);
      final connectGroup = _mockGroupedSymbols.keys.toList()[1];
      final connectSymbols = _mockGroupedSymbols[connectGroup]![0];
      _addInstruments(connectSymbols);

      _finnhubService.listen();
      _finnhubService.subscribe(connectSymbols);
    },

    expect: () {
      final filtered =
          _allInstruments.where((instrument) {
            return instrument.symbol.toLowerCase().contains('uad');
          }).toList();

      return <InstrumentsState>[
        InstrumentsState.loaded(
          allInstruments: _allInstruments,
          filteredInstruments: filtered,
        ),
      ];
    },
  );
}

void _setUpCategories() {
  _allInstruments.clear();
  _mockServiceSymbols.clear();
  _mockGroupedSymbols.clear();
  _mockServiceSymbols.addAll(_mockSymbols);
  _forexCategoriesUtility.categorizeSymbols(_mockServiceSymbols);
  _forexCategoriesUtility.splitIntoGroups(50);
  _mockGroupedSymbols.addAll(_forexCategoriesUtility.groups);
}

void _addInstruments(List<String> symbols) {
  for (final symbol in symbols) {
    _allInstruments.add(Instrument(symbol: symbol));
  }
}
