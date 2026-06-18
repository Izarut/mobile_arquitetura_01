import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:product_app/core/errors/failure.dart';
import 'package:product_app/data/models/product_model.dart';
import 'package:product_app/domain/entities/product.dart';

class ProductRemoteDatasource {
  static const String _baseUrl = 'https://dummyjson.com';

  /// GET /products — retorna lista de produtos da DummyJSON
  Future<List<Product>> fetchProducts() async {
    try {
      final response = await http.get(Uri.parse('$_baseUrl/products'));

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body) as Map<String, dynamic>;
        // DummyJSON envolve a lista numa chave "products"
        final List data = json['products'] as List;
        return data
            .map((e) => ProductModel.fromJson(e as Map<String, dynamic>).toEntity())
            .toList();
      } else {
        throw Failure(
          'Erro ao buscar produtos (código ${response.statusCode}).',
        );
      }
    } on Failure {
      rethrow;
    } catch (_) {
      throw const Failure('Sem conexão com a internet. Verifique sua rede.');
    }
  }

  /// GET /products/{id} — retorna um produto pelo id
  Future<Product> fetchProductById(int id) async {
    try {
      final response = await http.get(Uri.parse('$_baseUrl/products/$id'));

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body) as Map<String, dynamic>;
        return ProductModel.fromJson(json).toEntity();
      } else {
        throw Failure(
          'Produto não encontrado (código ${response.statusCode}).',
        );
      }
    } on Failure {
      rethrow;
    } catch (_) {
      throw const Failure('Sem conexão com a internet. Verifique sua rede.');
    }
  }
}
