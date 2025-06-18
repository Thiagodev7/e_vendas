import 'package:flutter/material.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import '../../core/theme/app_colors.dart';
import 'stores/planos_store.dart';

class PlanosPage extends StatefulWidget {
  const PlanosPage({super.key});

  @override
  State<PlanosPage> createState() => _PlanosPageState();
}

class _PlanosPageState extends State<PlanosPage> {
  final store = Modular.get<PlanosStore>();

  @override
  void initState() {
    super.initState();
    store.getPlanos();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Planos Disponíveis'),
        centerTitle: true,
      ),
      body: Observer(
        builder: (_) {
          if (store.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (store.errorMessage != null) {
            return Center(child: Text(store.errorMessage!));
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: store.planos.length,
            itemBuilder: (context, index) {
              final plano = store.planos[index];
              return Card(
                elevation: 4,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16)),
                margin: const EdgeInsets.only(bottom: 16),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        plano.nomeContrato,
                        style: theme.textTheme.titleLarge?.copyWith(
                          color: AppColors.primary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Código Plano: ${plano.codigoPlano} | Carência: ${plano.diasCarencia} dias',
                        style: theme.textTheme.bodyMedium,
                      ),
                      const SizedBox(height: 16),

                      // Lista de valores
                      ...plano.valores.map(
                        (valor) => ListTile(
                          contentPadding: EdgeInsets.zero,
                          title: Text(valor.descricao),
                          subtitle: Text(
                              '${valor.qtdeVida} vidas - R\$ ${valor.valorTotal}'),
                        ),
                      )
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}