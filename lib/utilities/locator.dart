// 📦 Package imports:
import 'package:dio/dio.dart';
import 'package:get_it/get_it.dart';

// 🌎 Project imports:
import 'package:fxtm/apis/finnhub.api.dart';
import 'package:fxtm/config.dart';
import 'package:fxtm/contracts/api_request_utility_service.contract.dart';
import 'package:fxtm/contracts/finnhub_api.contract.dart';
import 'package:fxtm/contracts/finnhub_service.contract.dart';
import 'package:fxtm/contracts/locator.contract.dart';
import 'package:fxtm/contracts/logger_service.contract.dart';
import 'package:fxtm/contracts/router_service.contract.dart';
import 'package:fxtm/enums/api.enum.dart';
import 'package:fxtm/services/api_utility.service.dart';
import 'package:fxtm/services/finnhub.service.dart';
import 'package:fxtm/services/logger.service.dart';
import 'package:fxtm/services/router.service.dart';

class Locator implements LocatorContract {
  final _locator = GetIt.instance;

  @override
  void registerDependencies() {
    _locator
      ..registerSingleton<RouterServiceContract>(RouterService())
      ..registerSingleton<LoggerServiceContract>(LoggerService())
      ..registerSingleton<ApiRequestUtilityServiceContract>(
        ApiRequestUtilityService(
          Dio(
              BaseOptions(
                baseUrl: Config.baseUrl,
                connectTimeout: const Duration(seconds: 10),
                receiveTimeout: const Duration(seconds: 10),
              ),
            )
            ..interceptors.add(
              DioInterceptor(_locator.get<LoggerServiceContract>()),
            ),
        ),
        instanceName: Api.forex.name,
      )
      ..registerLazySingleton<FinnhubApiContract>(() {
        return FinnhubApi(
          _locator.get<ApiRequestUtilityServiceContract>(
            instanceName: Api.forex.name,
          ),
        );
      })
      ..registerFactory<FinnhubServiceContract>(() {
        return FinnhubService(
          _locator.get<FinnhubApiContract>(),
          _locator.get<LoggerServiceContract>(),
        );
      });
  }
}
