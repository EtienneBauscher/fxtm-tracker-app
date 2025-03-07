// 📦 Package imports:
import 'package:freezed_annotation/freezed_annotation.dart';

part 'price_update.model.freezed.dart';

@freezed
class PriceUpdate with _$PriceUpdate {
  factory PriceUpdate({required String symbol, required double price}) =
      _PriceUpdate;

  factory PriceUpdate.fromJson(Map<String, dynamic> json) {
    final price =
        json['p'] is int ? (json['p'] as int).toDouble() : json['p'] as double;
    return PriceUpdate(symbol: json['s'] as String, price: price);
  }
}
