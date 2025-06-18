class Validators {
  static bool isValidCPF(String cpf) {
    cpf = cpf.replaceAll(RegExp(r'[^0-9]'), '');

    if (cpf.length != 11) return false;
    if (RegExp(r'^(\d)\1*$').hasMatch(cpf)) return false;

    List<int> digits = cpf.split('').map(int.parse).toList();

    for (int j = 9; j < 11; j++) {
      int sum = 0;
      for (int i = 0; i < j; i++) {
        sum += digits[i] * ((j + 1) - i);
      }
      int mod = (sum * 10) % 11;
      if (mod == 10) mod = 0;
      if (mod != digits[j]) return false;
    }

    return true;
  }
}