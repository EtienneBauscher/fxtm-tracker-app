// 📦 Package imports:
import 'package:freezed_annotation/freezed_annotation.dart';

// 🌎 Project imports:
import 'package:fxtm/enums/collection.enum.dart';

part 'query.model.freezed.dart';

@freezed
class Query<T> with _$Query {
  Query._();

  factory Query({
    required Collection mainCollection,
    T? item,
    Collection? secondCollection,
  }) = _Query;

  String get path {
    StringBuffer pathBuffer = StringBuffer('/${mainCollection.name}');

    if (item != null) {
      pathBuffer.write('/$item');
      if (secondCollection != null) {
        pathBuffer.write('/${secondCollection!.name}');
      }
    }

    return pathBuffer.toString();
  }
}
