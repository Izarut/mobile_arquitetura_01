import 'package:product_app/core/errors/failure.dart';
import 'package:product_app/data/datasources/product_cache_datasource.dart';
import 'package:product_app/data/datasources/product_remote_datasource.dart';
import 'package:product_app/domain/entities/product.dart';
import 'package:product_app/domain/repositories/product_repository.dart';

class ProductRepositoryImpl implements ProductRepository {
  final ProductRemoteDatasource remote;
  final ProductCacheDatasource cache;

  ProductRepositoryImpl(this.remote, this.cache);

  @override
  Future<CacheResult> getProducts() async {
    try {
      final models = await remote.getProducts();

      cache.save(models);

      final products = _toEntities(models);
      return CacheResult(products: products, fromCache: false);
    } catch (e) {
      final cached = cache.get();

      if (cached != null && cached.isNotEmpty) {
        return CacheResult(products: _toEntities(cached), fromCache: true);
      }

      throw Failure(
        'Sem conexão com a API e nenhum dado em cache disponível.',
      );
    }
  }

  List<Product> _toEntities(List<dynamic> models) {
    return models
        .map((m) => Product(
              id: m.id,
              title: m.title,
              price: m.price,
              image: m.image,
            ))
        .toList();
  }
}
