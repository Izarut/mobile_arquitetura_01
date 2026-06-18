import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:product_app/core/errors/failure.dart';
import 'package:product_app/data/models/auth_model.dart';

class AuthRemoteDatasource {
  static const String _baseUrl = 'https://dummyjson.com';

  Future<AuthModel> login({
    required String username,
    required String password,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/auth/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'username': username,
          'password': password,
          'expiresInMins': 60,
        }),
      );

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body) as Map<String, dynamic>;
        return AuthModel.fromJson(json);
      } else if (response.statusCode == 400 || response.statusCode == 401) {
        throw const Failure('Usuário ou senha inválidos.');
      } else {
        throw Failure(
          'Erro no servidor (código ${response.statusCode}). Tente novamente.',
        );
      }
    } on Failure {
      rethrow;
    } catch (e) {
      throw Failure('Sem conexão com a internet. Verifique sua rede.');
    }
  }
}