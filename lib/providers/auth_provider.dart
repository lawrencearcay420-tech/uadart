import 'package:flutter/material.dart';
import 'package:clothingapp/data/models/user.dart';
import 'package:clothingapp/data/repositories/user_repository.dart';
import 'package:clothingapp/data/repositories/storage_repository.dart';

class AuthProvider extends ChangeNotifier {
  final UserRepository _userRepository;
  final StorageRepository _storage;
  bool _isLoading = false;

  AuthProvider(this._userRepository, this._storage);

  bool get isLoading => _isLoading;
  User? get currentUser => _userRepository.currentUser;
  bool get isAuthenticated => _userRepository.isAuthenticated;
  bool get isAdmin => _userRepository.isAdmin;

  Future<void> loadUser() async {
    _isLoading = true;
    notifyListeners();
    final user = await _storage.loadUser();
    _userRepository.loadUser(user);
    _isLoading = false;
    notifyListeners();
  }

  Future<void> login(String email, String password) async {
    _isLoading = true;
    notifyListeners();

    await Future.delayed(const Duration(milliseconds: 800));

    final isDemoAdmin =
        email == 'admin@underasawa.com' && password == 'admin123';
    final isDemoUser = email == 'demo@user.com' && password == 'demo123';

    User? user;
    if (isDemoAdmin) {
      user = User.create('Admin User', 'admin@underasawa.com', UserRole.admin);
    } else if (isDemoUser || password.isNotEmpty) {
      user = User.create(
        isDemoUser ? 'Demo User' : 'Demo User',
        isDemoUser ? 'demo@user.com' : email,
        UserRole.customer,
      );
    }

    if (user != null) {
      _userRepository.setUser(user);
      await _storage.saveUser(user);
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> register(String name, String email) async {
    _isLoading = true;
    notifyListeners();
    try {
      final user = User.create(name.trim(), email.trim(), UserRole.customer);
      _userRepository.setUser(user);
      await _storage.saveUser(user);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loginAsDemo() async {
    _isLoading = true;
    notifyListeners();
    await Future.delayed(const Duration(milliseconds: 800));

    final user = User.create('Demo User', 'demo@user.com', UserRole.customer);
    _userRepository.setUser(user);
    await _storage.saveUser(user);

    _isLoading = false;
    notifyListeners();
  }

  Future<void> logout() async {
    _userRepository.logout();
    await _storage.removeUser();
    notifyListeners();
  }

  Future<void> updateProfile(String name, String email, String? phone) async {
    final current = _userRepository.currentUser;
    if (current == null) return;
    final updated = current.copyWith(name: name, email: email, phone: phone);
    _userRepository.setUser(updated);
    await _storage.saveUser(updated);
    notifyListeners();
  }
}
