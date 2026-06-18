import 'package:product_app/data/datasources/auth_remote_datasource.dart';
import 'package:product_app/domain/entities/user_session.dart';
import 'package:product_app/domain/repositories/auth_repository.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDatasource remoteDatasource;

  AuthRepositoryImpl(this.remoteDatasource);

  @override
  Future<UserSession> login({
    required String username,
    required String password,
  }) async {
    final authModel = await remoteDatasource.login(
      username: username,
      password: password,
    );
    return authModel.toEntity();
  }
}