// Enums e DTOs compartilhados pelas stores

enum PayMethod { card, pix }

enum PaymentStatus { none, aguardando, pago, erro }

class ResumoValores {
  final int vidas;
  final double adesaoIndividual;
  final double mensalidadeIndividual;
  final double proRataIndividual;
  final double mensalidadeTotal;
  final double proRataTotal;
  final double totalPrimeiraCobranca;

  const ResumoValores({
    required this.vidas,
    required this.adesaoIndividual,
    required this.mensalidadeIndividual,
    required this.proRataIndividual,
    required this.mensalidadeTotal,
    required this.proRataTotal,
    required this.totalPrimeiraCobranca,
  });
}