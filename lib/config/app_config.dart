import 'package:socbay/application.dart';

enum Flavor { staging, production, development }

const String appProductionPackageName = 'com.socbay.app';
const String appStagingPackageName = 'com.socbay.app';
const String appDevelopmentPackageName = 'com.socbay.app';
const String apiUrl = ' ';
const String protocol = 'https://';
const String apiPrefix = 'api';

extension FlavorExtension on Flavor {
  FlavorValues getValues() {
    switch (this) {
      case Flavor.development:
        return FlavorValues(apiUrl: 'api.iongeyser.com');
      case Flavor.staging:
        return FlavorValues(
          //todo change api stg
          apiUrl: 'api.iongeyser.com',
        );
      default:
        return FlavorValues(
          //todo change api prd
          apiUrl: 'api.iongeyser.com',
        );
    }
  }
}

class FlavorValues {
  final String apiUrl;

  FlavorValues({required this.apiUrl});
}

class AppConfig {
  final Flavor flavor;
  final String name;
  final FlavorValues values;

  static AppConfig? _instance;

  factory AppConfig(Flavor flavor, String name) {
    return _instance ??= AppConfig._internal(flavor, name, flavor.getValues());
  }

  AppConfig._internal(this.flavor, this.name, this.values);

  static AppConfig get instance {
    return _instance!;
  }

  String get apiHost {
    return values.apiUrl
        .trim()
        .replaceFirst(RegExp(r'^https?://'), '')
        .replaceAll(RegExp(r'/+$'), '');
  }

  String get apiVersionPath {
    return App.versionApi.trim().replaceAll(RegExp(r'^/+|/+$'), '');
  }

  String get apiBasePath {
    final segments = <String>[
      apiPrefix,
      if (apiVersionPath.isNotEmpty) apiVersionPath,
    ];
    return '/${segments.join('/')}';
  }

  String buildApiPath(String endpoint) {
    final normalizedEndpoint = endpoint
        .trim()
        .replaceAll(RegExp(r'^/+'), '')
        .replaceFirst(RegExp(r'^api(?:/|$)'), '');
    if (normalizedEndpoint.isEmpty) {
      return apiBasePath;
    }
    return '$apiBasePath/$normalizedEndpoint';
  }

  Uri apiUri(String endpoint, [Map<String, dynamic>? queryParameters]) {
    return Uri.http(apiHost, buildApiPath(endpoint), queryParameters);
  }

  Uri apiSecureUri(String endpoint, [Map<String, dynamic>? queryParameters]) {
    return Uri.https(apiHost, buildApiPath(endpoint), queryParameters);
  }

  String apiUrl(String endpoint) {
    return Uri(
      scheme: protocol.replaceAll('://', ''),
      host: apiHost,
      path: buildApiPath(endpoint),
    ).toString();
  }

  String get apiBaseUrl => apiUrl('');

  static bool isProduction() => _instance!.flavor == Flavor.production;

  static bool isStaging() => _instance!.flavor == Flavor.staging;
}
