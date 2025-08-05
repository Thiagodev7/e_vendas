class EnvironmentConfig {
  // Defina o ambiente aqui: 'dev', 'prod', 'homolog'
  static const String _env = String.fromEnvironment(
    'ENV',
    defaultValue: 'dev',
  );

  // URLs por ambiente
  static const Map<String, String> _urls = {
    'dev': 'http://localhost:3077',
    'homolog': '192.168.0.93:3077',
    'prod': 'https://api.seuservidor.com.br',
  };

  static String get baseUrl => _urls[_env] ?? _urls['dev']!;
  static String get environment => _env;
}