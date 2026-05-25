import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:socbay/blocs/root/root_bloc.dart';
import 'package:socbay/blocs/root/root_state.dart';
import 'package:socbay/blocs/tab_bar/tab_bar_bloc.dart';
import 'package:socbay/screens/auth/login_screen.dart';
import 'package:socbay/screens/splash_screen.dart';
import 'package:socbay/screens/home_tab_bar/tab_bar_screen.dart';
import 'package:socbay/utils/logger_util.dart';
import 'package:socbay/widgets/dialog/custom_alert_dialog.dart';

import 'blocs/root/root_event.dart';

class Root extends StatefulWidget {
  const Root({super.key});

  @override
  _RootState createState() => _RootState();
}

class _RootState extends State<Root> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  late RootBloc _rootBloc;
  late TabBarBloc _tabBarBloc;

  @override
  void initState() {
    //_rootBloc = BlocProvider.of<RootBloc>(context);
    _rootBloc = RootBloc();
    _tabBarBloc = TabBarBloc();
    super.initState();
  }

  @override
  void dispose() {
    _rootBloc.close();
    _tabBarBloc.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: null,
      child: Scaffold(
        key: _scaffoldKey,
        resizeToAvoidBottomInset: false,
        body: BlocConsumer<RootBloc, RootState>(
          listener: (ctx, state) {
            LoggerUtil.info('blocListener => $state');
            if(state is ShowAccessTokenExpiredAlert){
              _showAccessTokenExpiredAlert();
            }
            if(state is Authenticated){

            }
          },
          buildWhen: (preState, nextState) {
            LoggerUtil.info('build when $preState => $nextState');
            return true;
          },
          builder: (context, state) {
            if (state is Unauthenticated) {
              return const LoginScreen();
            }else if (state is Authenticated) {
              return const TabBarScreen();
            }
            return const SplashScreen();
          },
        ),
      ),
    );
  }

  Future _showAccessTokenExpiredAlert() async {
    Navigator.popUntil(context, (route) => route.isFirst);
    CustomAlertDialog.show(
      context,
      content: 'Phiên đăng nhập hết hạn.',
      isShowButtonClose: false,
      isShowTitle: false,
      leftText: 'OK',
      isLeftPositive: true,
      leftAction: () {
        _rootBloc.add(DismissAccessTokenExpiredAlert());
        Navigator.pop(context);
      },
    );
  }
}
