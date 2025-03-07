// 🐦 Flutter imports:
import 'package:flutter/material.dart';

// 📦 Package imports:
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:get_it/get_it.dart';

// 🌎 Project imports:
import 'package:fxtm/blocs/instrument.bloc.dart';
import 'package:fxtm/contracts/router_service.contract.dart';
import 'package:fxtm/events/instrument.event.dart';
import 'package:fxtm/l10n/app_localizations.dart';
import 'package:fxtm/l10n/locale/supported.locales.dart';
import 'package:fxtm/utilities/locator.dart';
import 'pages/main_page.dart';

void main() async {
  const env = String.fromEnvironment('ENV', defaultValue: 'development');
  await dotenv.load(fileName: ".env.$env");
  Locator().registerDependencies();

  runApp(const FXTMApp());
}

class FXTMApp extends StatefulWidget {
  const FXTMApp({super.key});

  @override
  State<FXTMApp> createState() => _FXTMAppState();
}

class _FXTMAppState extends State<FXTMApp> {
  final _routerService = GetIt.instance.get<RouterServiceContract>();

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: <BlocProvider>[
        BlocProvider<InstrumentsBloc>(
          create: (context) => InstrumentsBloc()..add(const FetchSymbols()),
          child: const MainPage(),
        ),
      ],
      child: MaterialApp.router(
        routerConfig: _routerService.router,
        onGenerateTitle: (context) => AppLocalizations.of(context)!.forexTitle,
        localizationsDelegates: const <LocalizationsDelegate<Object>>[
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: supportedLocales,
        theme: ThemeData(primarySwatch: Colors.blue),
      ),
    );
  }
}
