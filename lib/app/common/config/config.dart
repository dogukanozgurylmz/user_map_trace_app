enum Environment { production, development }

final class Config {
  static late Environment currentEnvironment;

  static String get apiBaseUrl {
    switch (currentEnvironment) {
      case Environment.production:
        return 'https://api.mygen.co';
      case Environment.development:
        return 'https://api.mygen.co';
    }
  }

  static String get apiBaseUrl2 {
    switch (currentEnvironment) {
      case Environment.production:
        return 'https://test-engine-stg.funooka.com';
      case Environment.development:
        return 'https://test-engine-stg.funooka.com';
    }
  }

  static String get environmentName {
    switch (currentEnvironment) {
      case Environment.production:
        return 'Production';
      case Environment.development:
        return 'Development';
    }
  }
}
