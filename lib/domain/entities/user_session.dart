class UserSession {
  final int id;
  final String username;
  final String email;
  final String firstName;
  final String lastName;
  final String token;

  const UserSession({
    required this.id,
    required this.username,
    required this.email,
    required this.firstName,
    required this.lastName,
    required this.token,
  });

  String get fullName => '$firstName $lastName';
}