import 'package:product_app/domain/entities/product.dart';

class CacheResult {
  final List<Product> products;
  final bool fromCache;

  CacheResult(this.products, this.fromCache);
}

abstract class ProductRepository {
  Future<CacheResult> getProducts();

  Future<Product> addProduct(Product product);
  Future<Product> updateProduct(Product product);
  Future<void> deleteProduct(int id);
}