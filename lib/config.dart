// 📦 Package imports:
import 'package:flutter_dotenv/flutter_dotenv.dart';

class Config {
  static String get baseUrl => dotenv.get('forexBaseUrl', fallback: '');
  static String get apiKey => dotenv.get('apiKey', fallback: '');
  static String get webSocket => dotenv.get('finnhubws', fallback: '');
  static String get scheme => dotenv.get('scheme', fallback: '');
}
