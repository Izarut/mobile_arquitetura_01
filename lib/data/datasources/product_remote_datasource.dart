import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:product_app/domain/entities/product.dart';

class ProductRemoteDatasource {
  final String baseUrl = 'https://fakestoreapi.com/products';

  Future<List<Product>> fetchProducts() async {
    final response = await http.get(Uri.parse(baseUrl));

    final List data = jsonDecode(response.body);

    return data.map((e) => Product.fromJson(e)).toList();
  }

  Future<Product> addProduct(Product product) async {
    final response = await http.post(
      Uri.parse(baseUrl),
      body: jsonEncode(product.toJson()),
      headers: {'Content-Type': 'application/json'},
    );

    return Product.fromJson(jsonDecode(response.body));
  }

  Future<Product> updateProduct(Product product) async {
    final response = await http.put(
      Uri.parse('$baseUrl/${product.id}'),
      body: jsonEncode(product.toJson()),
      headers: {'Content-Type': 'application/json'},
    );

    return Product.fromJson(jsonDecode(response.body));
  }

  Future<void> deleteProduct(int id) async {
    await http.delete(Uri.parse('$baseUrl/$id'));
  }
}