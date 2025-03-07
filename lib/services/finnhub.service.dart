// 🎯 Dart imports:
import 'dart:async';
import 'dart:convert';
import 'dart:io';

// 📦 Package imports:
import 'package:dio/dio.dart';
import 'package:logger/web.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

// 🌎 Project imports:
import 'package:fxtm/config.dart';
import 'package:fxtm/contracts/finnhub_api.contract.dart';
import 'package:fxtm/contracts/finnhub_service.contract.dart';
import 'package:fxtm/contracts/logger_service.contract.dart';
import 'package:fxtm/enums/query_params.enum.dart';
import 'package:fxtm/models/price_update.model.dart';
import 'package:fxtm/models/result.model.dart';
import 'package:fxtm/utilities/forex_categories.utility.dart';

class FinnhubService implements FinnhubServiceContract {
  FinnhubService(this._forexApi, this._loggerService);

  final FinnhubApiContract _forexApi;
  final LoggerServiceContract _loggerService;

  final _symbols = <String>[];
  final _forexUtility = ForexCategoriesUtility();

  StreamController<PriceUpdate> _priceStreamController =
      StreamController<PriceUpdate>.broadcast();
  WebSocketChannel? _channel;

  @override
  Stream<PriceUpdate> get priceStream => _priceStreamController.stream;

  @override
  Map<String, List<List<String>>> get groups => _forexUtility.groups;

  @override
  Future<Result<Map<String, List<List<String>>>>> fetchSymbols() async {
    _symbols.clear();

    final result = await _forexApi.fetchSymbols();

    return result.when(
      success: (symbols) {
        _symbols.addAll(symbols ?? <String>[]);
        _forexUtility.categorizeSymbols(_symbols);
        _forexUtility.splitIntoGroups(50);

        return Result<Map<String, List<List<String>>>>.success(
          _forexUtility.groups,
        );
      },
      failed: (exception) {
        return Result<Map<String, List<List<String>>>>.failed(
          exception ??
              DioException(
                message:
                    'The DioException wasn\'t returned, please check the API and utility',
                requestOptions: RequestOptions(),
              ),
        );
      },
    );
  }

  @override
  Future<bool> connect() async {
    final uri = Uri(
      scheme: Config.scheme,
      host: Config.webSocket,
      queryParameters: {QueryParams.token.name: Config.apiKey},
    );
    _channel = WebSocketChannel.connect(uri);
    _priceStreamController = StreamController<PriceUpdate>.broadcast();

    try {
      await _channel?.ready;
    } on SocketException catch (exception) {
      _loggerService.log(
        'Websocket exception: ${exception.message.toString()}',
        level: Level.error,
      );

      return false;
    } on WebSocketChannelException catch (exception) {
      if (exception.inner != null) {
        final err = exception.inner as dynamic;
        _loggerService.log(
          'Websocket channel exception inner error: ${err.message.toString()}',
          level: Level.error,
        );
      }

      return false;
    }

    return true;
  }

  @override
  void listen() {
    _channel?.stream.listen(
      (message) {
        final dataMap = jsonDecode(message);
        if (dataMap['type'] == 'trade') {
          final data = dataMap['data'] as List<dynamic>;

          for (var trade in data) {
            if (!_priceStreamController.isClosed) {
              _priceStreamController.add(PriceUpdate.fromJson(trade));
            }
          }
        }
      },
      onError: (error, stacktrace) {
        if (error is WebSocketChannelException) {
          if (error.inner != null) {
            final err = error.inner as dynamic;
            _loggerService.log(
              'Websocket inner error: ${err.message.toString()}',
              level: Level.error,
            );
          }
          _loggerService.log(
            'Websocket error: ${error.message}',
            level: Level.error,
          );

          throw Exception('The Web Socket couldn\'t connect');
        }
      },
      onDone: () {
        _loggerService.log('WebSocket Closed', level: Level.info);
      },
    );
  }

  @override
  void subscribe(List<String> symbols) {
    for (var symbol in symbols) {
      _channel?.sink.add(jsonEncode({"type": "subscribe", "symbol": symbol}));
    }
  }

  @override
  void dispose() {
    _channel?.sink.close();
    _priceStreamController.close();
  }
}
