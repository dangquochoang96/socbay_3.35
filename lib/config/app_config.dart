enum Flavor { staging, production, development }

const String appProductionPackageName = 'com.socbay.app';
const String appStagingPackageName = 'com.socbay.app';
const String appDevelopmentPackageName = 'com.socbay.app';
const String apiUrl = ' ';
const String protocol = 'http://';

extension FlavorExtension on Flavor {
  FlavorValues getValues() {
    switch (this) {
      case Flavor.development:
        return FlavorValues(
          apiUrl: 'api.chothuetatca.com',
          // apiUrl: 'feasible-glowworm-finally.ngrok-free.app'
        );
      case Flavor.staging:
        return FlavorValues(
          //todo change api stg
          apiUrl: 'api.chothuetatca.com',
          // apiUrl: 'feasible-glowworm-finally.ngrok-free.app'
        );
      default:
        return FlavorValues(
          //todo change api prd
          apiUrl: 'api.chothuetatca.com',
          // apiUrl: 'feasible-glowworm-finally.ngrok-free.app'
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

  static bool isProduction() => _instance!.flavor == Flavor.production;

  static bool isStaging() => _instance!.flavor == Flavor.staging;
}
