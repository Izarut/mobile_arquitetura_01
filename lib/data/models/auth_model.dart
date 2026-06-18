import 'package:product_app/domain/entities/user_session.dart';

class AuthModel {
  final int id;
  final String username;
  final String email;
  final String firstName;
  final String lastName;
  final String token;

  const AuthModel({
    required this.id,
    required this.username,
    required this.email,
    required this.firstName,
    required this.lastName,
    required this.token,
  });

  factory AuthModel.fromJson(Map<String, dynamic> json) {
    return AuthModel(
      id: json['id'] as int,
      username: json['username'] as String,
      email: json['email'] as String,
      firstName: json['firstName'] as String,
      lastName: json['lastName'] as String,
      token: json['accessToken'] as String,
    );
  }

  UserSession toEntity() {
    return UserSession(
      id: id,
      username: username,
      email: email,
      firstName: firstName,
      lastName: lastName,
      token: token,
    );
  }
}