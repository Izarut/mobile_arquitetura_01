import 'package:product_app/domain/entities/product.dart';
import 'package:product_app/domain/repositories/product_repository.dart';
import 'package:product_app/data/datasources/product_remote_datasource.dart';
import 'package:product_app/data/datasources/product_cache_datasource.dart';
import 'package:product_app/data/models/product_model.dart';

class ProductRepositoryImpl implements ProductRepository {
  final ProductRemoteDatasource remoteDatasource;
  final ProductCacheDatasource cacheDatasource;

  ProductRepositoryImpl(this.remoteDatasource, this.cacheDatasource);

  @override
  Future<CacheResult> getProducts() async {
    try {
      final products = await remoteDatasource.fetchProducts();
      // Salva no cache para uso offline
      cacheDatasource.save(products.map((p) => ProductModel.fromEntity(p)).toList());
      return CacheResult(products, false);
    } catch (_) {
      // Tenta usar o cache se a API falhar
      final cached = cacheDatasource.get();
      if (cached != null && cached.isNotEmpty) {
        return CacheResult(cached.map((m) => m.toEntity()).toList(), true);
      }
      return CacheResult([], true);
    }
  }

  @override
  Future<Product> addProduct(Product product) async {
    return await remoteDatasource.addProduct(product);
  }

  @override
  Future<Product> updateProduct(Product product) async {
    return await remoteDatasource.updateProduct(product);
  }

  @override
  Future<void> deleteProduct(int id) async {
    await remoteDatasource.deleteProduct(id);
  }
}