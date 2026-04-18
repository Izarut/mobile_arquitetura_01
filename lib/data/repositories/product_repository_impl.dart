import 'package:product_app/domain/entities/product.dart';
import 'package:product_app/domain/repositories/product_repository.dart';
import 'package:product_app/data/datasources/product_remote_datasource.dart';

class ProductRepositoryImpl implements ProductRepository {
  final ProductRemoteDatasource remoteDatasource;

  ProductRepositoryImpl(this.remoteDatasource);

  @override
  Future<CacheResult> getProducts() async {
    try {
      final products = await remoteDatasource.fetchProducts();
      return CacheResult(products, false);
    } catch (_) {
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