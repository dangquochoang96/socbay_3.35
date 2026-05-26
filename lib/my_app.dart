import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:socbay/blocs/booking/booking_bloc.dart';
import 'package:socbay/blocs/booking/detail_booking/detail_booking_bloc.dart';
import 'package:socbay/blocs/home/home_bloc.dart';
import 'package:socbay/blocs/product_category/product_category_bloc.dart';
import 'package:socbay/blocs/rent-task/rent_task_screen_bloc.dart';
import 'package:socbay/blocs/rent-task/rent_task_screen_ktv_bloc.dart';
import 'package:socbay/blocs/staff/new_task/staff_service_screen_bloc.dart';
import 'package:socbay/blocs/staff/new_task_sale/staff_service_screen_sale_bloc.dart';
import 'package:socbay/blocs/tab_bar/tab_bar_bloc.dart';
import 'package:socbay/blocs/task/task_screen_sale_bloc.dart';
import 'package:socbay/blocs/user_info/user_new_order/user_new_order_bloc.dart';
import 'package:socbay/config/app_config.dart';
import 'package:socbay/data/repository/auth/api_repository.dart';
import 'package:socbay/routes.dart';
import 'package:socbay/services/navigation_service.dart';
import 'package:socbay/utils/theme_util.dart';

import 'blocs/evaluate/evaluate_bloc.dart';
import 'blocs/history/history_screen_bloc.dart';
import 'blocs/auth/login_screen_bloc.dart';
import 'blocs/historyid/historyid_screen_bloc.dart';
import 'blocs/task/task_screen_bloc.dart';
import 'blocs/root/root_bloc.dart';
import 'blocs/technique/technique_screen_bloc.dart';
import 'data/data_provider/base_api.dart';

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> with WidgetsBindingObserver {
  final routes = Routes();

  @override
  void initState() {
    //Đăng ký Observer
    WidgetsBinding.instance.addObserver(this);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () {
        // Close keyboard when tap outside input zone (textField,...)
        WidgetsBinding.instance.focusManager.primaryFocus?.unfocus();
      },
      child: _buildRepositoryProvider(
        child: _buildPrimaryBlocProvider(
          child: MaterialApp(
            localizationsDelegates: const [
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            supportedLocales: const [
              Locale('en', 'US'), // English
              Locale('he', 'IL'),
              Locale('vi', 'VN'), // Hebrew
            ],
            debugShowCheckedModeBanner: false,
            title: AppConfig.instance.name,
            theme: ThemeUtil.appTheme,
            initialRoute: Routes.root,
            navigatorKey: NavigationService.instance.navigatorKey,
            onGenerateRoute: (settings) => routes.routePage(settings),
          ),
        ),
      ),
    );
  }

  Widget _buildPrimaryBlocProvider({required Widget child}) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<TabBarBloc>(create: (context) => TabBarBloc()),
        BlocProvider<LoginScreenBloc>(
          create: (context) => LoginScreenBloc(
            apiRepository: RepositoryProvider.of<ApiRepository>(context),
          ),
        ),
        BlocProvider<HomeBloc>(
          create: (context) => HomeBloc(
            apiRepository: RepositoryProvider.of<ApiRepository>(context),
          ),
        ),
        BlocProvider<UserNewOrderBloc>(
          create: (context) => UserNewOrderBloc(
            apiRepository: RepositoryProvider.of<ApiRepository>(context),
          ),
        ),
        BlocProvider<HistoryScreenBloc>(
          create: (context) => HistoryScreenBloc(
            apiRepository: RepositoryProvider.of<ApiRepository>(context),
          ),
        ),
        BlocProvider<HistoryidScreenBloc>(
          create: (context) => HistoryidScreenBloc(
            apiRepository: RepositoryProvider.of<ApiRepository>(context),
          ),
        ),
        BlocProvider<TechniqueScreenBloc>(
          create: (context) => TechniqueScreenBloc(
            apiRepository: RepositoryProvider.of<ApiRepository>(context),
            args: {},
          ),
        ),
        BlocProvider<EvaluateScreenBloc>(
          create: (context) => EvaluateScreenBloc(
            apiRepository: RepositoryProvider.of<ApiRepository>(context),
            args: {},
          ),
        ),
        BlocProvider<ProductCategoryScreenBloc>(
          create: (context) => ProductCategoryScreenBloc(
            apiRepository: RepositoryProvider.of<ApiRepository>(context),
          ),
        ),
        BlocProvider<BookingBloc>(
          create: (context) => BookingBloc(
            apiRepository: RepositoryProvider.of<ApiRepository>(context),
          ),
        ),
        BlocProvider<TaskScreenBloc>(
          create: (context) => TaskScreenBloc(
            apiRepository: RepositoryProvider.of<ApiRepository>(context),
          ),
        ),
        BlocProvider<TaskScreenSaleBloc>(
          create: (context) => TaskScreenSaleBloc(
            apiRepository: RepositoryProvider.of<ApiRepository>(context),
          ),
        ),
        BlocProvider<RentTaskScreenKTVBloc>(
          create: (context) => RentTaskScreenKTVBloc(
            apiRepository: RepositoryProvider.of<ApiRepository>(context),
          ),
        ),
        BlocProvider<RentTaskScreenSaleBloc>(
          create: (context) => RentTaskScreenSaleBloc(
            apiRepository: RepositoryProvider.of<ApiRepository>(context),
          ),
        ),
        BlocProvider<DetailBookingBloc>(
          create: (context) => DetailBookingBloc(
            apiRepository: RepositoryProvider.of<ApiRepository>(context),
            args: {},
          ),
        ),
        BlocProvider<StaffServiceScreenBloc>(
          create: (context) => StaffServiceScreenBloc(
            apiRepository: RepositoryProvider.of<ApiRepository>(context),
            args: {},
          ),
        ),
        BlocProvider<StaffServiceSaleScreenBloc>(
          create: (context) => StaffServiceSaleScreenBloc(
            apiRepository: RepositoryProvider.of<ApiRepository>(context),
            args: {},
          ),
        ),
      ],
      child: child,
    );
  }

  Widget _buildRepositoryProvider({required Widget child}) {
    final BaseAPI baseAPI = BaseAPI(
      rootBloc: BlocProvider.of<RootBloc>(context),
    );
    return MultiRepositoryProvider(
      providers: [
        RepositoryProvider<ApiRepository>(
          create: (ctx) => ApiRepository(baseAPI),
        ),
      ],
      child: child,
    );
  }

  @override
  void dispose() {
    //Remove Observer
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  Future<void> didChangeAppLifecycleState(AppLifecycleState state) async {
    super.didChangeAppLifecycleState(state);
  }
}
