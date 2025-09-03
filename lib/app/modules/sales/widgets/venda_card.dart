import 'package:e_vendas/app/core/model/plano_model.dart';
import 'package:e_vendas/app/core/model/venda_model.dart';
import 'package:e_vendas/app/core/theme/app_colors.dart';
import 'package:flutter/material.dart';

/// Card de venda (UI + callbacks).
/// Mostra:
/// - Origem (Local/Nuvem)
/// - Número da proposta (se houver)
/// - Ciclo de cobrança: "Mensal — venc. dia X" ou "Anual (-10%)"
/// - Métricas (vidas, mensal, adesão)
class VendaCard extends StatelessWidget {
  const VendaCard({
    super.key,
    required this.titularNome,
    required this.planoNome,
    required this.codigoPlano,
    required this.vidas,
    required this.mensalidade,
    required this.adesao,
    required this.origin,
    this.nroProposta,
    this.billingCycle,
    this.dueDay,
    this.pagamentoConcluido,
    this.contratoAssinado,
    required this.onEditarCliente,
    required this.onEditarPlano,
    required this.onFinalizar,
    required this.onRemover,
  });

  final String titularNome;
  final String planoNome;
  final String codigoPlano;
  final int vidas;
  final String mensalidade;
  final String adesao;
  final VendaOrigin origin;

  final int? nroProposta;
  final BillingCycle? billingCycle;
  final int? dueDay;

  final bool? pagamentoConcluido;
  final bool? contratoAssinado;

  final VoidCallback onEditarCliente;
  final VoidCallback onEditarPlano;
  final VoidCallback onFinalizar;
  final VoidCallback onRemover;

  String? _billingLabel() {
    if (billingCycle == null) return null;
    if (billingCycle == BillingCycle.anual) {
      return 'Anual (-10%)';
    }
    final d = dueDay;
    return d != null ? 'Mensal — venc. dia $d' : 'Mensal';
    }
  

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final isCloud = origin == VendaOrigin.cloud;
    final billingText = _billingLabel();

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cs.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: cs.outlineVariant),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Título + badges
          Row(
            children: [
              Container(
                decoration: BoxDecoration(
                  color: (isCloud ? AppColors.primary : Colors.grey).withOpacity(0.12),
                  borderRadius: BorderRadius.circular(8),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                child: Row(
                  children: [
                    Icon(
                      isCloud ? Icons.cloud_done : Icons.smartphone,
                      size: 16,
                      color: isCloud ? AppColors.primary : Colors.grey[700],
                    ),
                    const SizedBox(width: 6),
                    Text(
                      isCloud ? 'Nuvem' : 'Local',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: isCloud ? AppColors.primary : Colors.grey[700],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  titularNome,
                  style: const TextStyle(
                    fontWeight: FontWeight.w800,
                    fontSize: 18,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              if (nroProposta != null) ...[
                const SizedBox(width: 8),
                _StatusChip(
                  icon: Icons.receipt_long,
                  label: 'Proposta #$nroProposta',
                  fg: AppColors.primary,
                  bg: AppColors.primary.withOpacity(0.10),
                ),
              ],
            ],
          ),

          const SizedBox(height: 10),

          // Plano + código
          Text(
            planoNome,
            style: TextStyle(fontSize: 14, color: cs.onSurfaceVariant),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          if (codigoPlano.isNotEmpty)
            Text(
              'Código: $codigoPlano',
              style: TextStyle(fontSize: 12, color: cs.onSurfaceVariant),
            ),

          // Ciclo de cobrança
          if (billingText != null) ...[
            const SizedBox(height: 6),
            Text(
              billingText,
              style: TextStyle(fontSize: 12, color: cs.onSurfaceVariant),
            ),
          ],

          // Chips de status (opcionais)
          if (pagamentoConcluido != null || contratoAssinado != null) ...[
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                if (pagamentoConcluido != null)
                  _StatusChip(
                    icon: pagamentoConcluido! ? Icons.check_circle : Icons.schedule,
                    label: pagamentoConcluido!
                        ? 'Pagamento concluído'
                        : 'Pagamento pendente',
                    fg: pagamentoConcluido! ? Colors.green[700]! : cs.onSurfaceVariant,
                    bg: pagamentoConcluido!
                        ? Colors.green.withOpacity(0.12)
                        : cs.surfaceVariant,
                  ),
                if (contratoAssinado != null)
                  _StatusChip(
                    icon: contratoAssinado! ? Icons.assignment_turned_in : Icons.description,
                    label: contratoAssinado!
                        ? 'Contrato assinado'
                        : 'Contrato pendente',
                    fg: contratoAssinado! ? Colors.green[700]! : cs.onSurfaceVariant,
                    bg: contratoAssinado!
                        ? Colors.green.withOpacity(0.12)
                        : cs.surfaceVariant,
                  ),
              ],
            ),
          ],

          const Divider(height: 24),

          // Vidas + valores
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Metric(label: 'Vidas', value: '$vidas'),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Metric(label: 'Mensal', value: 'R\$ $mensalidade'),
                  Metric(label: 'Adesão', value: 'R\$ $adesao'),
                ],
              ),
            ],
          ),

          const Spacer(),

          // Ações
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              PopupMenuButton<String>(
                icon: Icon(Icons.edit, color: AppColors.primary),
                onSelected: (value) {
                  if (value == 'editar_cliente') {
                    onEditarCliente();
                  } else if (value == 'editar_plano') {
                    onEditarPlano();
                  }
                },
                itemBuilder: (context) => const [
                  PopupMenuItem(
                    value: 'editar_cliente',
                    child: Text('Editar Cliente'),
                  ),
                  PopupMenuItem(
                    value: 'editar_plano',
                    child: Text('Editar Plano'),
                  ),
                ],
              ),
              const SizedBox(width: 8),
              IconButton(
                icon: const Icon(Icons.check_circle, color: Colors.green),
                tooltip: 'Finalizar Venda',
                onPressed: onFinalizar,
              ),
              IconButton(
                icon: const Icon(Icons.delete, color: Colors.red),
                tooltip: 'Remover Venda',
                onPressed: onRemover,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class Metric extends StatelessWidget {
  const Metric({super.key, required this.label, required this.value});
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(fontSize: 12, color: cs.onSurfaceVariant)),
        const SizedBox(height: 2),
        Text(
          value,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
        ),
      ],
    );
  }
}

class _StatusChip extends StatelessWidget {
  const _StatusChip({
    required this.icon,
    required this.label,
    required this.fg,
    required this.bg,
  });

  final IconData icon;
  final String label;
  final Color fg;
  final Color bg;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 32,
      padding: const EdgeInsets.symmetric(horizontal: 10),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: fg.withOpacity(0.35)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: fg),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              color: fg,
              fontWeight: FontWeight.w600,
              fontSize: 12,
              height: 1.0,
            ),
          ),
        ],
      ),
    );
  }
}