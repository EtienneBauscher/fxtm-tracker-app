// 🌎 Project imports:
import 'package:fxtm/models/price_update.model.dart';
import 'package:fxtm/models/result.model.dart';

abstract class FinnhubServiceContract {
  Map<String, List<List<String>>> get groups;
  Stream<PriceUpdate> get priceStream;
  Future<Result<Map<String, List<List<String>>>>> fetchSymbols();
  Future<bool> connect();
  void subscribe(List<String> symbols);
  void listen();
  void dispose();
}
