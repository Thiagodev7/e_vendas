// lib/app/modules/home/stores/recent_sales_store.dart
import 'package:e_vendas/app/core/model/recent_sale_model.dart';
import 'package:e_vendas/app/modules/sales/services/sales_service.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:mobx/mobx.dart';

part 'recent_sales_store.g.dart';

class RecentSalesStore = _RecentSalesStoreBase with _$RecentSalesStore;

abstract class _RecentSalesStoreBase with Store {
  _RecentSalesStoreBase({SalesService? service})
      : _service = service ?? Modular.get<SalesService>();

  final SalesService _service;

  @observable
  ObservableList<RecentSaleModel> vendas = ObservableList.of([]);

  @observable
  bool isLoading = false;

  @action
  Future<void> load({required int vendedorId, int limit = 10}) async {
    isLoading = true;
    try {
      final list =
          await _service.fetchRecentSales(vendedorId: vendedorId, limit: limit);
      vendas = ObservableList.of(list);
    } finally {
      isLoading = false;
    }
  }
}