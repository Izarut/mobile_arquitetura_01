import 'package:product_app/domain/entities/user_session.dart';

abstract class AuthRepository {
  Future<UserSession> login({
    required String username,
    required String password,
  });
}