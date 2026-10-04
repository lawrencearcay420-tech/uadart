import 'package:clothingapp/data/models/user.dart';

class UserRepository {
  User? _currentUser;

  User? get currentUser => _currentUser;

  void setUser(User? user) {
    _currentUser = user;
  }

  bool get isAuthenticated => _currentUser != null;

  bool get isAdmin => _currentUser?.role == UserRole.admin;

  void logout() {
    _currentUser = null;
  }

  void loadUser(User? user) {
    _currentUser = user;
  }
}
