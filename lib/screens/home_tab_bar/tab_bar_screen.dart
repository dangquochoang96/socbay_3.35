import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:socbay/blocs/tab_bar/tab_bar_bloc.dart';
import 'package:socbay/blocs/tab_bar/tab_bar_event.dart';
import 'package:socbay/blocs/tab_bar/tab_bar_state.dart';
import 'package:socbay/data/event_bus/event_bus_event.dart';
import 'package:socbay/screens/home_tab_bar/tab_bar_component.dart';
import 'package:socbay/utils/color_util.dart';

import '../../application.dart';

class TabBarScreen extends StatefulWidget {
  static const String routeName = '/tab';

  const TabBarScreen({Key? key}) : super(key: key);

  @override
  _TabBarScreenState createState() => _TabBarScreenState();
}

class _TabBarScreenState extends State<TabBarScreen> with RouteAware {
  late TabBarBloc _tabBarBloc;
  int _selectedIndex = 0;
  late StreamSubscription _goToSearchStream;
  int firstLoad = 0;

  @override
  void initState() {
    _tabBarBloc = BlocProvider.of<TabBarBloc>(context);
    _goToSearchStream = App.instance.eventBus
        .on<EventBusFinishSearchStaffEvent>()
        .listen((event) {
      _onItemTapped(2);
    });
    super.initState();
  }

  @override
  void dispose() {
    _goToSearchStream.cancel();
    firstLoad = 0;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: _buildBottomBar(),
      body: BlocConsumer<TabBarBloc, TabBarState>(
        listener: (context, state) {
          if (state is TabbarChanged) {
            _selectedIndex = state.index;
          }
        },
        buildWhen: (preState, nextState) => nextState is TabbarChanged,
        builder: (ctx, state) {
          return IndexedStack(
            index: state is TabbarChanged ? state.index : 0,
            children: getTabBarWidgetItem(context),
          );
        },
      ),
    );
  }

  Widget _buildBottomBar() {
    return BlocBuilder<TabBarBloc, TabBarState>(
      buildWhen: (preState, nextState) => nextState is TabbarChanged,
      builder: (ctx, state) {
        return BottomNavigationBar(
          type: BottomNavigationBarType.fixed,
          backgroundColor: ColorUtil.white,
          elevation: 0.0,
          fixedColor: ColorUtil.bangladeshGreen,
          items: getTabBarItems(),
          currentIndex: state is TabbarChanged ? state.index : 0,
          unselectedItemColor: Colors.grey,
          onTap: _onItemTapped,
        );
      },
    );
  }

  void _onItemTapped(int index) {
    if (_selectedIndex != index ||
        (_selectedIndex == 0 && index == 0 && firstLoad == 0)) {
      _tabBarBloc.add(TabBarPressed(index: index));
      setState(() {
        _selectedIndex = index;
        firstLoad = 1;
      });
    }
  }
}
