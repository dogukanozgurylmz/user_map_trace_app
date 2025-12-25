enum Environment { production, development }

final class Config {
  static late Environment currentEnvironment;

  static String get apiBaseUrl {
    switch (currentEnvironment) {
      case Environment.production:
        return 'http://router.project-osrm.org';
      case Environment.development:
        return 'http://router.project-osrm.org';
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
