import 'package:product_app/domain/entities/product.dart';

class CacheResult {
  final List<Product> products;
  final bool fromCache;

  const CacheResult({required this.products, required this.fromCache});
}

abstract class ProductRepository {
  Future<CacheResult> getProducts();
}
