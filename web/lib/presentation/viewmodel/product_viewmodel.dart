import 'package:flutter/material.dart';
import 'package:product_app/core/errors/failure.dart';
import 'package:product_app/domain/entities/product.dart';
import 'package:product_app/domain/repositories/product_repository.dart';
import 'package:product_app/presentation/viewmodel/product_state.dart';

class ProductViewModel extends ChangeNotifier {
  final ProductRepository repository;

  final ValueNotifier<ProductState> state =
      ValueNotifier(ProductState.initial());

  List<Product> _products = []; // 🔥 estado local real
  int _idCounter = 1000;

  ProductViewModel(this.repository);

  Future<void> loadProducts() async {
    if (state.value.isLoading) return;

    state.value = ProductState.loading();

    try {
      final result = await repository.getProducts();

      _products = result.products; // 🔥 salva local

      state.value = result.fromCache
          ? ProductState.cached(_products)
          : ProductState.success(_products);
    } on Failure catch (f) {
      state.value = ProductState.error(f.message);
    } catch (e) {
      state.value =
          ProductState.error('Erro inesperado: ${e.toString()}');
    }
  }

  // ⭐ FAVORITO
  void toggleFavorite(int productId) {
    _products = _products.map((product) {
      if (product.id == productId) {
        product.favorite = !product.favorite;
      }
      return product;
    }).toList();

    state.value = ProductState.success(_products);
  }

  // ➕ CREATE
  Future<void> addProduct(Product product) async {
    final newProduct = Product(
      id: _idCounter++,
      title: product.title,
      price: product.price,
      description: product.description,
      image: product.image,
    );

    _products = [..._products, newProduct];

    state.value = ProductState.success(_products);
  }

  // ✏️ UPDATE
  Future<void> updateProduct(Product updatedProduct) async {
    _products = _products.map((product) {
      if (product.id == updatedProduct.id) {
        return updatedProduct;
      }
      return product;
    }).toList();

    state.value = ProductState.success(_products);
  }

  // ❌ DELETE
  Future<void> deleteProduct(int id) async {
    _products = _products.where((p) => p.id != id).toList();

    state.value = ProductState.success(_products);
  }
}