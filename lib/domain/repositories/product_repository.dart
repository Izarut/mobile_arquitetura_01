import 'package:product_app/domain/entities/product.dart';

/// Resultado que indica se os dados vieram da API ou do cache local.
class CacheResult {
  final List<Product> products;
  final bool fromCache;

  CacheResult(this.products, this.fromCache);
}

abstract class ProductRepository {
  /// Busca todos os produtos (com fallback para cache offline).
  Future<CacheResult> getProducts();

  /// Busca um produto pelo ID direto na API.
  Future<Product> getProductById(int id);

  /// Operações locais — não chamam a API remota.
  Future<Product> addProduct(Product product);
  Future<Product> updateProduct(Product product);
  Future<void> deleteProduct(int id);
}
