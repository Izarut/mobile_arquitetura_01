import 'package:flutter/material.dart';
import 'package:product_app/core/errors/failure.dart';
import 'package:product_app/domain/repositories/product_repository.dart';
import 'package:product_app/presentation/viewmodel/product_state.dart';

class ProductViewModel extends ChangeNotifier {
  final ProductRepository repository;

  final ValueNotifier<ProductState> state =
      ValueNotifier(ProductState.initial());

  ProductViewModel(this.repository);

  Future<void> loadProducts() async {
    if (state.value.isLoading) return;

    state.value = ProductState.loading();

    try {
      final result = await repository.getProducts();
      state.value = result.fromCache
          ? ProductState.cached(result.products)
          : ProductState.success(result.products);
    } on Failure catch (f) {
      state.value = ProductState.error(f.message);
    } catch (e) {
      state.value = ProductState.error(
        'Erro inesperado: ${e.toString()}',
      );
    }
  }
}
