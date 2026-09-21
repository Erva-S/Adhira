/// Application environment configuration.
enum Environment {
  development,
  staging,
  production,
}

class EnvironmentConfig {
  final Environment environment;
  final String apiBaseUrl;
  final bool enableLogging;
  final bool useMockData;

  const EnvironmentConfig({
    required this.environment,
    required this.apiBaseUrl,
    this.enableLogging = false,
    this.useMockData = true,
  });

  static const EnvironmentConfig development = EnvironmentConfig(
    environment: Environment.development,
    apiBaseUrl: 'http://localhost:3000/api',
    enableLogging: true,
    useMockData: true,
  );

  static const EnvironmentConfig staging = EnvironmentConfig(
    environment: Environment.staging,
    apiBaseUrl: 'https://staging-api.tribal-scholar.gov.in/v1',
    enableLogging: true,
    useMockData: false,
  );

  static const EnvironmentConfig production = EnvironmentConfig(
    environment: Environment.production,
    apiBaseUrl: 'https://api.tribal-scholar.gov.in/v1',
    enableLogging: false,
    useMockData: false,
  );

  /// Current active environment — change this for different build flavors.
  static const EnvironmentConfig current = development;

  bool get isDevelopment => environment == Environment.development;
  bool get isStaging => environment == Environment.staging;
  bool get isProduction => environment == Environment.production;
}
