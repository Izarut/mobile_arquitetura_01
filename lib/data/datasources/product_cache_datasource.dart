import 'package:product_app/data/models/product_model.dart';

class ProductCacheDatasource {
  List<ProductModel>? _cache;
  DateTime? _savedAt;

  void save(List<ProductModel> products) {
    _cache = List.unmodifiable(products);
    _savedAt = DateTime.now();
  }

  List<ProductModel>? get() => _cache;

  DateTime? get savedAt => _savedAt;

  void clear() {
    _cache = null;
    _savedAt = null;
  }

  bool get isEmpty => _cache == null || _cache!.isEmpty;
}
