import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:socbay/blocs/root/root_bloc.dart';
import 'package:socbay/blocs/root/root_event.dart';
import 'package:socbay/config/app_config.dart';
import 'package:socbay/config/app_localization.dart';
import 'package:socbay/my_app.dart';
import 'package:socbay/services/push_notification_service.dart';
import 'package:socbay/utils/logger_util.dart';
import 'package:socbay/utils/simple_bloc_delegate.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:socbay/firebase_options.dart';

class MyHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    return super.createHttpClient(context)
      ..badCertificateCallback =
          (X509Certificate cert, String host, int port) => true;
  }
}

Future main() async {
  await runZonedGuarded(() async {
    WidgetsFlutterBinding.ensureInitialized();
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    await PushNotificationService.instance.initialize();

    Bloc.observer = SimpleBlocObserver();
    //transparent status bar and navigation bar
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        systemNavigationBarColor: Colors.transparent,
        systemNavigationBarIconBrightness: Brightness.light,
        statusBarIconBrightness: Brightness.light,
      ),
    );
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);

    var flavor = Flavor.development;
    PackageInfo packageInfo = await PackageInfo.fromPlatform();
    switch (packageInfo.packageName) {
      case appProductionPackageName:
        flavor = Flavor.production;
        break;
      default:
        break;
    }
    await appLocalization.init();
    LoggerUtil.info('app name: ${packageInfo.packageName}');
    AppConfig(flavor, '');
    HttpOverrides.global = MyHttpOverrides();
    runApp(
      BlocProvider<RootBloc>(
        create: (context) => RootBloc()..add(AppStarted()),
        child: const MyApp(),
      ),
    );
  }, (e, s) => {});
}
