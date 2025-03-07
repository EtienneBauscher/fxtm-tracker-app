// 📦 Package imports:
import 'package:logger/web.dart';

abstract class LoggerServiceContract {
  void log(
    dynamic message, {
    DateTime? time,
    Object? error,
    StackTrace? stackTrace,
    Level? level,
  });
}
