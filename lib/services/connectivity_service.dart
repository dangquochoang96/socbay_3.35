import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:socbay/utils/logger_util.dart';

class ConnectivityService {
  Future<bool> hasConnection() async {
    final bool internet = await _checkConnection();
    LoggerUtil.info(
      'hasConnection() -> $internet',
      tag: 'ConnectivityService',
    );
    return (internet);
  }

  Future<bool> _checkConnection() async {
    final connectivityResults = await Connectivity().checkConnectivity();
    LoggerUtil.info(
      'checkConnectivity() -> $connectivityResults',
      tag: 'ConnectivityService',
    );

    return connectivityResults.any(
      (result) => result != ConnectivityResult.none,
    );
  }
}
