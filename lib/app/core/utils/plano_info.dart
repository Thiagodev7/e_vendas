class PlanoInfo {
  static final Map<String, Map<String, dynamic>> _planos = {
    'quality': {
      'beneficios': [
        'Consultas',
        'Urgências Odontológicas',
        'Plantão 24h (Goiânia e Anápolis)',
        'Exames Radiológicos (radiografias)',
        'Prevenção em saúde bucal',
        'Dentística (restaurações)',
        'Periodontia (raspagens)',
        'Endodontia (tratamento de canais)',
        'Cirurgias (extrações)',
        'Próteses (blocos e coroas unitárias)',
        'Odontopediatria (tratamento para crianças)',
      ],
      'observacao': null,
    },
    'quality plus': {
      'beneficios': [
        'Consultas',
        'Urgências Odontológicas',
        'Plantão 24h (Goiânia e Anápolis)',
        'Exames Radiológicos (radiografias)',
        'Prevenção em saúde bucal',
        'Dentística (restaurações)',
        'Periodontia (raspagens)',
        'Endodontia (tratamento de canais)',
        'Cirurgias (extrações)',
        'Próteses (blocos e coroas unitárias)',
        'Odontopediatria (tratamento para crianças)',
      ],
      'observacao': null,
    },
    'smart': {
      'beneficios': [
        'Consultas',
        'Urgências Odontológicas',
        'Plantão 24h (Goiânia e Anápolis)',
        'Exames Radiológicos (radiografias)',
        'Prevenção em saúde bucal',
        'Dentística (restaurações)',
        'Periodontia (raspagem supragengival)',
        'Cirurgias (extrações)',
        'Odontopediatria (tratamento para crianças)',
      ],
      'observacao':
          'Este é um plano em que você paga, além da mensalidade, uma taxa por cada serviço contratado.',
    },
    'kids': {
      'beneficios': [
        'Consultas',
        'Urgências Odontológicas',
        'Plantão 24h (Goiânia e Anápolis)',
        'Exames Radiológicos (radiografias)',
        'Prevenção em saúde bucal',
        'Dentística (restaurações)',
        'Cirurgias (extrações)',
        'Odontopediatria (tratamento para crianças)',
      ],
      'observacao':
          'Este é um plano em que você paga, além da mensalidade, uma taxa por cada serviço contratado.',
    },
    'light plus': {
      'beneficios': [
        'Consultas',
        'Urgências Odontológicas',
        'Plantão 24h (Goiânia e Anápolis)',
        'Prevenção em saúde bucal',
      ],
      'observacao':
          'Este é um plano em que você paga, além da mensalidade, uma taxa por cada serviço contratado.',
    },
  };

  /// Retorna os benefícios formatados em texto
  static String getInfo(String plano) {
    final key = plano
        .toLowerCase()
        .replaceFirst(RegExp(r'^uni\s+', caseSensitive: false), '')
        .trim();

    final data = _planos[key];

    if (data == null) return 'Informações não disponíveis para este plano.';

    final beneficios = (data['beneficios'] as List<String>)
        .map((b) => '☑️ $b')
        .join('\n');

    final observacao = data['observacao'] != null
        ? '\n\n${data['observacao']}'
        : '';

    return 'Cobertura deste plano para você:\n$beneficios$observacao';
  }
}