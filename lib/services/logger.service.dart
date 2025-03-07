// 📦 Package imports:
import 'package:logger/logger.dart';

// 🌎 Project imports:
import 'package:fxtm/contracts/logger_service.contract.dart';

class LoggerService implements LoggerServiceContract {
  LoggerService()
    : _logger = Logger(
        filter: DevelopmentFilter(),
        printer: PrettyPrinter(
          levelColors: {
            Level.all: const AnsiColor.fg(4),
            Level.debug: const AnsiColor.fg(2),
            Level.info: const AnsiColor.fg(4),
            Level.error: const AnsiColor.fg(1),
          },
        ),
      );

  final Logger _logger;

  @override
  void log(
    dynamic message, {
    DateTime? time,
    Object? error,
    StackTrace? stackTrace,
    Level? level,
  }) {
    Logger.level = level ?? Level.all;

    switch (Logger.level) {
      case Level.error:
        _logger.e(message, time: time, error: error, stackTrace: stackTrace);
      case Level.fatal:
        _logger.f(message, time: time, error: error, stackTrace: stackTrace);
      case Level.all:
      case Level.off:
      case Level.info:
        _logger.i(message, time: time, error: error, stackTrace: stackTrace);
      case Level.warning:
        _logger.w(message, time: time, error: error, stackTrace: stackTrace);
      case Level.trace:
        _logger.t(message, time: time, error: error, stackTrace: stackTrace);
      default:
        _logger.d(message, time: time, error: error, stackTrace: stackTrace);
    }
  }
}
