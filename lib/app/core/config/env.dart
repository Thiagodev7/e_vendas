
enum Environment {
  production,
  development,
  local,
}

class Env {
  /// Defina aqui o ambiente atual
  static const Environment current = Environment.local;

  /// URL da API de acordo com o ambiente selecionado
  static String get apiUrl {
    switch (current) {
      case Environment.production:
         return "https://bevendasonline.uniodontogoiania.com.br:3033";
      case Environment.local:
        return 'http://localhost:3033';
      case Environment.development:
        return 'http://192.168.0.91:3000';
    }
  }
}