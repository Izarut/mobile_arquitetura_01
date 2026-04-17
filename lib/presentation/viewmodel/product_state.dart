import 'package:product_app/domain/entities/product.dart';
enum ProductStatus {
  initial, 
  loading, 
  success, 
  error,   
  cached,   
}

class ProductState {
  final ProductStatus status;
  final List<Product> products;
  final String? errorMessage;

  const ProductState({
    this.status = ProductStatus.initial,
    this.products = const [],
    this.errorMessage,
  });

  factory ProductState.initial() => const ProductState();

  factory ProductState.loading() =>
      const ProductState(status: ProductStatus.loading);

  factory ProductState.success(List<Product> products) => ProductState(
        status: ProductStatus.success,
        products: products,
      );

  factory ProductState.cached(List<Product> products) => ProductState(
        status: ProductStatus.cached,
        products: products,
      );

  factory ProductState.error(String message) => ProductState(
        status: ProductStatus.error,
        errorMessage: message,
      );
      
  bool get isLoading => status == ProductStatus.loading;
  bool get hasData =>
      status == ProductStatus.success || status == ProductStatus.cached;
  bool get hasError => status == ProductStatus.error;
  bool get isFromCache => status == ProductStatus.cached;
}
