// 🐦 Flutter imports:
import 'dart:async';

import 'package:flutter/material.dart';

// 📦 Package imports:
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';

// 🌎 Project imports:
import 'package:fxtm/blocs/instrument.bloc.dart';
import 'package:fxtm/cubits/value.cubit.dart';
import 'package:fxtm/enums/price_change.enum.dart';
import 'package:fxtm/events/instrument.event.dart';
import 'package:fxtm/form_fields/custom_form_text.field.dart';
import 'package:fxtm/l10n/app_localizations.dart';
import 'package:fxtm/models/instrument.model.dart';
import 'package:fxtm/states/instrument.state.dart';

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  static const _contrastPaleYellow = Color.fromARGB(255, 251, 241, 212);
  late final _instrumentBloc = BlocProvider.of<InstrumentsBloc>(context);
  late final _i10n = AppLocalizations.of(context)!;
  final _bottomNavBarIndexCubit = ValueCubit<int>(0);
  final _tabBarIndexCubit = ValueCubit<int?>(null);
  final _queryCubit = ValueCubit<String>('');
  final _formKey = GlobalKey<FormBuilderState>();
  final _scrollController = ScrollController();

  @override
  void dispose() {
    _instrumentBloc.dispose();
    _instrumentBloc.close();
    _bottomNavBarIndexCubit.close();
    _tabBarIndexCubit.close();
    _queryCubit.close();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: BlocBuilder<ValueCubit<int?>, int?>(
        bloc: _bottomNavBarIndexCubit,
        builder: (context, index) {
          return Scaffold(
            backgroundColor: Colors.grey.shade900,
            appBar: AppBar(
              centerTitle: true,
              title: Text(
                _i10n.oandaTitle,
                style: const TextStyle(
                  color: _contrastPaleYellow,
                  fontWeight: FontWeight.bold,
                  fontSize: 18.0,
                ),
              ),
              backgroundColor: Colors.blueGrey.shade700,
              bottom: index == 2 ? _buildTabBar() : null,
            ),

            bottomNavigationBar: BlocBuilder<ValueCubit<int?>, int?>(
              bloc: _bottomNavBarIndexCubit,
              builder: (context, state) {
                return BottomNavigationBar(
                  currentIndex: state ?? 0,
                  backgroundColor: _contrastPaleYellow,
                  items: <BottomNavigationBarItem>[
                    BottomNavigationBarItem(
                      label: _i10n.majorPairsTab,
                      icon: const Icon(Icons.looks_one),
                    ),
                    BottomNavigationBarItem(
                      label: _i10n.minorPairsTab,
                      icon: const Icon(Icons.looks_two),
                    ),
                    BottomNavigationBarItem(
                      label: _i10n.exoticPairsTab,
                      icon: const Icon(Icons.looks_3),
                    ),
                  ],
                  onTap: (index) {
                    _bottomNavBarIndexCubit.setValue(index);
                    _instrumentBloc.add(
                      FetchInstruments(
                        index,
                        tabBarIndex: index == 2 ? 0 : null,
                      ),
                    );
                    if (index != 2) {
                      _tabBarIndexCubit.setValue(null);
                    }
                    _reset();
                  },
                );
              },
            ),
            body: Column(
              children: <Widget>[
                FormBuilder(
                  key: _formKey,
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: CustomFormTextField(
                      id: _ForexTickerFormFields.query.name,
                      placeHolderText: _i10n.searchInstrumentsPlaceHolder,
                      onChanged: (query) {
                        if (query != null) {
                          _instrumentBloc.add(UpdateSearchQuery(query));
                        }
                      },
                    ),
                  ),
                ),
                Expanded(
                  child: TabBarView(
                    children: <Widget>[
                      _buildDefaultView(),
                      _buildDefaultView(),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  PreferredSizeWidget _buildTabBar() {
    final width = MediaQuery.sizeOf(context).width;
    final tabWidth = width / 2;

    return PreferredSize(
      preferredSize: Size(width, 50.0),
      child: Container(
        color: _contrastPaleYellow,
        width: width,
        child: BlocBuilder<ValueCubit<int?>, int?>(
          bloc: _tabBarIndexCubit,
          builder: (context, index) {
            return TabBar(
              padding: EdgeInsets.zero,
              labelPadding: EdgeInsets.zero,
              indicatorPadding: EdgeInsets.zero,
              isScrollable: false,
              indicatorSize: TabBarIndicatorSize.tab,
              unselectedLabelColor: Colors.grey,
              unselectedLabelStyle: const TextStyle(
                fontWeight: FontWeight.normal,
              ),
              labelStyle: const TextStyle(color: Colors.deepPurple),
              indicatorColor: Colors.deepPurple,
              indicatorWeight: 5,
              tabAlignment: TabAlignment.center,
              onTap: (tabIndex) {
                _instrumentBloc.add(FetchInstruments(2, tabBarIndex: tabIndex));
                _tabBarIndexCubit.setValue(tabIndex);
                _reset();
              },
              tabs: <Widget>[
                _buildTab(tabWidth, _i10n.groupOneTab),
                _buildTab(tabWidth, _i10n.groupTwoTab),
              ],
            );
          },
        ),
      ),
    );
  }

  Tab _buildTab(double tabWidth, String tabText) {
    return Tab(
      height: 40,
      child: Container(
        alignment: Alignment.center,
        width: tabWidth,
        child: Text(tabText, style: const TextStyle(fontSize: 15.0)),
      ),
    );
  }

  Widget _buildDefaultView() {
    return BlocConsumer<InstrumentsBloc, InstrumentsState>(
      bloc: _instrumentBloc,
      listener: (context, state) {
        if (state is InstrumentsStateSymbolsReady) {
          _instrumentBloc.add(
            FetchInstruments(_bottomNavBarIndexCubit.state ?? 0),
          );
          _reset();
        }
        if (state is InstrumentsStateWebSocketConnectionError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              padding: const EdgeInsets.symmetric(
                horizontal: 20.0,
                vertical: 8.0,
              ),
              backgroundColor: Colors.red.shade700,
              content: Text(_i10n.webSocketConnectionErrorMessage),
            ),
          );
        }
      },
      builder: (context, state) {
        return state.maybeWhen(
          orElse: () {
            return const Center(
              child: CircularProgressIndicator(color: _contrastPaleYellow),
            );
          },
          error: _buildError,
          webSocketConnectionError: (allInstruments, filteredInstruments) {
            /*
          Kludge(etiennebauscher): Due to the subscribtion limitation only one connection can be made at a time and also, only 50 FX Pairs can be subscribed to at once. This forces us to close the connection and re-establish it and subscribe to the selected group. If the user make erratic navigations it can cause the disconnect and reconnect to cause a Websocket channel error, hence the Snackbar in the listener and the Timer to inform the user and to give the connection some time to reset.
          */
            Timer(const Duration(seconds: 20), () {
              _instrumentBloc.add(
                FetchInstruments(
                  _bottomNavBarIndexCubit.state ?? 0,
                  tabBarIndex: _tabBarIndexCubit.state,
                ),
              );
            });
            return _buildInstruments(filteredInstruments);
          },
          loaded: (allInstruments, filteredInstruments) {
            return _buildInstruments(filteredInstruments);
          },
        );
      },
    );
  }

  Widget _buildInstruments(List<Instrument> instruments) {
    return ListView.builder(
      controller: _scrollController,
      itemCount: instruments.length,
      itemBuilder: (context, index) {
        final instrument = instruments[index];

        return _buildInstrument(instrument);
      },
    );
  }

  void _reset() {
    _formKey.currentState?.reset();

    if (_scrollController.hasClients) {
      _scrollController.jumpTo(0.0);
    }
  }

  Widget _buildError() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 30.0, vertical: 50.0),
      child: Column(
        mainAxisSize: MainAxisSize.max,
        children: <Widget>[
          Text(
            _i10n.intstrumentBlocErrorMessage,
            textAlign: TextAlign.center,
            style: const TextStyle(color: _contrastPaleYellow, fontSize: 15.0),
          ),
          const SizedBox(height: 35),
          ElevatedButton(
            style: ButtonStyle(
              backgroundColor: WidgetStateProperty.all(_contrastPaleYellow),
              fixedSize: WidgetStateProperty.all(const Size(180, 40)),
            ),
            onPressed: () {
              _instrumentBloc.add(
                FetchInstruments(
                  _bottomNavBarIndexCubit.state ?? 0,
                  tabBarIndex: _tabBarIndexCubit.state,
                ),
              );
              _bottomNavBarIndexCubit.setValue(0);
              _reset();
            },
            child: Text(
              _i10n.tryAgainButtonText,
              style: const TextStyle(fontSize: 16.0),
            ),
          ),
          const Spacer(),
        ],
      ),
    );
  }

  ListTile _buildInstrument(Instrument instrument) {
    final priceIncreased = instrument.priceChange == PriceChange.increased;
    final priceDecreased = instrument.priceChange == PriceChange.decreased;

    return ListTile(
      title: Text(
        instrument.simpleSymbol,
        style: const TextStyle(color: _contrastPaleYellow),
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          _buildPrice(
            instrument.previousPrice,
            priceIncreased: priceIncreased,
            priceDecreased: priceDecreased,
            reverse: true,
          ),
          _buildPrice(
            instrument.price,
            priceIncreased: priceIncreased,
            priceDecreased: priceDecreased,
          ),
          Icon(
            priceIncreased
                ? Icons.arrow_upward
                : priceDecreased
                ? Icons.arrow_downward
                : Icons.remove,
            color:
                priceIncreased
                    ? Colors.green
                    : priceDecreased
                    ? Colors.red
                    : Colors.grey.shade700,
          ),
        ],
      ),
    );
  }

  Widget _buildPrice(
    double? price, {
    bool priceIncreased = false,
    bool priceDecreased = false,
    bool reverse = false,
  }) {
    return SizedBox(
      width: 82,
      child: Text(
        price?.toStringAsFixed(2) ?? '--',
        style: TextStyle(
          fontSize: 12.0,
          color:
              priceIncreased
                  ? (reverse ? Colors.red : Colors.green)
                  : priceDecreased
                  ? (reverse ? Colors.green : Colors.red)
                  : Colors.grey.shade500,
        ),
      ),
    );
  }
}

enum _ForexTickerFormFields { query }
