import 'package:e_vendas/app/core/stores/global_store.dart';
import 'package:e_vendas/app/modules/finish_sale/page/finish_sale_page.dart';
import 'package:e_vendas/app/modules/finish_sale/service/contract_service.dart';
import 'package:e_vendas/app/modules/finish_sale/service/datanext_service.dart';
import 'package:e_vendas/app/modules/finish_sale/service/payment_service.dart';
import 'package:e_vendas/app/modules/finish_sale/store/finalizacao_store.dart';
import 'package:e_vendas/app/modules/finish_sale/store/finish_contract_store.dart';
import 'package:e_vendas/app/modules/finish_sale/store/finish_payment_store.dart';
import 'package:e_vendas/app/modules/finish_sale/store/finish_resumo_store.dart';
import 'package:e_vendas/app/modules/finish_sale/store/finish_sale_store.dart';
import 'package:e_vendas/app/modules/sales/services/sales_service.dart';
import 'package:e_vendas/app/modules/sales/stores/sales_store.dart';
import 'package:flutter_modular/flutter_modular.dart';
class FinishSaleModule extends Module {
  @override
  void binds(i) {
    // Services
    i.addLazySingleton(SalesService.new);
    i.addLazySingleton(PaymentService.new);
    i.addLazySingleton(ContractService.new);
    i.addLazySingleton(DatanextService.new);

    // Global (se já houver em outro módulo raiz, remova daqui)
    i.addLazySingleton(GlobalStore.new);

    // Stores da Finalização
    i.addLazySingleton(FinishSaleStore.new);       // orquestradora (se ainda usada)
    i.addLazySingleton(FinishPaymentStore.new);    // pagamentos
    i.addLazySingleton(FinishContractStore.new);   // contrato (DocuSign)
    i.addLazySingleton(FinishResumoStore.new);     // cálculo/resumo de valores
    i.addLazySingleton(FinalizacaoStore.new);       // finalização (Datanext)

    // Store de vendas (lista/CRUD)
    i.addLazySingleton(SalesStore.new);
  }

  @override
  void routes(r) {
    r.child(
      '/',
      child: (context) {
        final args = r.args.data as Map<String, dynamic>?;
        final vendaIndex = args?['vendaIndex'] as int?;
        return FinishSalePage(vendaIndex: vendaIndex);
      },
    );
  }
}