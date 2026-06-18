import 'package:product_app/domain/entities/user_session.dart';

class SessionManager {
  SessionManager._();

  static final SessionManager instance = SessionManager._();

  UserSession? _currentUser;

  UserSession? get currentUser => _currentUser;

  bool get isAuthenticated => _currentUser != null;

  void saveSession(UserSession user) {
    _currentUser = user;
  }

  void logout() {
    _currentUser = null;
  }
}