// 🎯 Dart imports:
import 'dart:convert';

// 🌎 Project imports:
import 'package:fxtm/contracts/api_request_utility_service.contract.dart';
import 'package:fxtm/contracts/finnhub_api.contract.dart';
import 'package:fxtm/enums/collection.enum.dart';
import 'package:fxtm/enums/forex_item.enum.dart';
import 'package:fxtm/enums/http_method.enum.dart';
import 'package:fxtm/enums/query_params.enum.dart';
import 'package:fxtm/models/api_response.model.dart';
import 'package:fxtm/models/query.model.dart';
import 'package:fxtm/utilities/api_request_wrapper.utlity.dart';

class FinnhubApi implements FinnhubApiContract {
  FinnhubApi(this._apiRequestUtility);

  final ApiRequestUtilityServiceContract _apiRequestUtility;

  @override
  Future<ApiResponse<List<String>>> fetchSymbols() async {
    return await apiRequestWrapper<List<String>>(
      request: () {
        return _apiRequestUtility.request<String>(
          method: HttpMethod.get,
          query: Query<String>(
            mainCollection: Collection.forex,
            item: ForexItem.symbol.name,
          ),
          queryParameters: {QueryParams.exchange.name: "oanda"},
        );
      },
      fromJson: _decodeSymbolsJson,
    );
  }

  List<String> _decodeSymbolsJson(dynamic data) {
    final dataList = jsonDecode(data) as List<dynamic>;
    final symbols =
        dataList.map((symbolJson) {
          return symbolJson[ForexItem.symbol.name] as String;
        }).toList();

    return symbols;
  }
}
