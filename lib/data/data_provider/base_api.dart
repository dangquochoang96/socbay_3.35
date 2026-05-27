import 'dart:io';

import 'package:dio/dio.dart';
import 'package:socbay/blocs/root/root_bloc.dart';
import 'package:socbay/config/app_config.dart';
import 'package:socbay/config/app_localization.dart';
import 'package:socbay/constants/localization_key.dart';
import 'package:socbay/data/data_provider/api_manager.dart';
import 'package:socbay/data/response/api_response.dart';
import 'package:socbay/services/connectivity_service.dart';
import 'package:socbay/utils/secure_storage_utils.dart';

import '../../blocs/root/root_event.dart';
import '../../utils/logger_util.dart';

class ErrorMessage {
  static const String headerErrorMessage = 'Failed to parse header value';
  static const String unauthorizedErrorMessage = 'Http status error [401]';
}

const String tag = 'BaseAPI';

class BaseAPI {
  // INSTANTS
  final int receiveTimeout = 20000; // milliseconds
  final int connectTimeout = 20000; // milliseconds

  // PROPERTIES
  Dio _dio = Dio();
  final String _baseUrl = AppConfig.instance.apiBaseUrl;
  late RootBloc _rootBloc;

  // INIT
  BaseAPI({required RootBloc rootBloc}) {
    final BaseOptions options = BaseOptions(
      receiveTimeout: Duration(milliseconds: receiveTimeout),
      connectTimeout: Duration(milliseconds: connectTimeout),
      baseUrl: _baseUrl,
    );
    _dio = Dio(options);
    if (!AppConfig.isProduction()) {
      _setupLoggingInterceptor();
    }
    _rootBloc = rootBloc;
  }

  // FUNCTION
  Future<dynamic> request({
    required ApiManager manager,
    dynamic bodyParams,
    dynamic queryParams,
    String? optionalPath,
    bool isUseAccessToken = true,
  }) async {
    Map responseData;
    ApiConfig? config;
    String? path;
    try {
      config = manager.getConfig();
      // final UserRepository userRepository = UserRepository(this);

      // Check internet connection
      if ((await _checkInternetConnection()) == false) {
        return _errorJson(
          message: appLocalization.text(LocalizationKey.noInternetConnection),
        );
      }

      if (isUseAccessToken) {
        // // Check expired token
        // final bool isTokenExpired = await userRepository.isTokenExpired();
        // if (isTokenExpired) {
        //   _rootBloc.add(AccessTokenExpired());
        //   return null;
        // }
      }

      // // Setup headers and token
      await _setAuthorizationHeader(
        config: config,
        isUseAccessToken: isUseAccessToken,
      );

      // Setup custom path
      path = optionalPath != null
          ? (config.path + optionalPath)
          : config.path;

      LoggerUtil.info(
        'request ${config.method} url=$_baseUrl$path useAccessToken=$isUseAccessToken headers=${_dio.options.headers} body=$bodyParams query=$queryParams',
        tag: tag,
      );

      Response response;
      switch (config.method) {
        case HttpMethod.get:
          response = await _dio.get(path, queryParameters: queryParams ?? {});
          break;
        case HttpMethod.post:
          response = await _dio.post(
            path,
            data: bodyParams ?? {},
            queryParameters: queryParams ?? {},
          );
          break;
        case HttpMethod.put:
          response = await _dio.put(
            path,
            data: bodyParams ?? {},
            queryParameters: queryParams ?? {},
          );
          break;
        case HttpMethod.del:
          response = await _dio.delete(
            path,
            data: bodyParams ?? {},
            queryParameters: queryParams ?? {},
          );
          break;
      }

      responseData = response.data;
    } on DioException catch (exception) {
      LoggerUtil.error(
        'DioException type=${exception.type} message=${exception.message} url=${exception.requestOptions.uri} method=${exception.requestOptions.method}',
        tag: tag,
      );
      if (exception.requestOptions.headers.isNotEmpty) {
        LoggerUtil.info(
          'DioException request headers=${exception.requestOptions.headers}',
          tag: tag,
        );
      }
      LoggerUtil.info(
        'DioException request data=${exception.requestOptions.data}',
        tag: tag,
      );
      if (exception.response != null) {
        LoggerUtil.error(
          'DioException response status=${exception.response?.statusCode} data=${exception.response?.data}',
          tag: tag,
        );
      }
      // The request was made and the server responded with a status code
      // that falls out of the range of 2xx and is also not 304.
      if (exception.response != null) {
        if (exception.response?.data is! String) {
          final String? message = exception.response?.data['message'];
          if (isUseAccessToken &&
              message != null &&
              message == 'Unauthorized') {
            _rootBloc.add(AccessTokenExpired());
            return null;
          }
          return exception.response?.data;
        } else {
          return _errorJson(
            status: exception.response?.statusCode ?? 400,
            message: exception.response?.data,
          );
        }
      }
      return _errorJson(message: exception.message ?? '');
    } catch (e, stackTrace) {
      LoggerUtil.error(
        'Unexpected request error url=$_baseUrl${path ?? ''} error=$e',
        tag: tag,
        stackTrace: stackTrace,
      );
      return _errorJson(message: e.toString());
    }
    LoggerUtil.info(
      '${manager.getConfig().method} - $_baseUrl${manager.getConfig().path} response: $responseData',
    );

    return responseData;
  }

  void _setupLoggingInterceptor() {
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          LoggerUtil.log('----> ${options.method} ${options.uri}');
          if (options.headers.isNotEmpty) {
            LoggerUtil.info('Headers ${options.headers}', tag: tag);
          }
          LoggerUtil.log('Data ${options.data}');
          LoggerUtil.log('Query ${options.queryParameters}');
          LoggerUtil.log('<------------- END HTTP');
          return handler.next(options); //continue
        },
        onResponse: (response, handler) {
          return handler.next(response); // continue
        },
        onError: (DioException error, handler) {
          return handler.next(error); //continue
        },
      ),
    );
  }

  Future<void> _setAuthorizationHeader({
    required ApiConfig config,
    required bool isUseAccessToken,
  }) async {
    _dio.options.headers = config.headers;
    final String? token = await SecureStorageUtil.shared.readData(
      SecureStorageUtil.tokenStorageKey,
    );
    print('token là $token');
    if (isUseAccessToken) {
      _dio.options.headers['Authorization'] = 'Bearer $token';
    }
  }

  Map<String, dynamic> _errorJson({
    int status = HttpStatus.internalServerError,
    String message = '',
  }) {
    return {'status': status, 'message': message, 'data': null};
  }

  Future<bool> _checkInternetConnection() async {
    final ConnectivityService service = ConnectivityService();
    return service.hasConnection();
  }
}
