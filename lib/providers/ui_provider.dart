import 'package:flutter/material.dart';

class UIProvider extends ChangeNotifier {
  bool _showSearch = false;
  bool _showCart = false;
  bool _showFilters = false;

  bool get showSearch => _showSearch;
  bool get showCart => _showCart;
  bool get showFilters => _showFilters;

  void toggleSearch() {
    _showSearch = !_showSearch;
    _showCart = false;
    _showFilters = false;
    notifyListeners();
  }

  void toggleCart() {
    _showCart = !_showCart;
    _showSearch = false;
    _showFilters = false;
    notifyListeners();
  }

  void toggleFilters() {
    _showFilters = !_showFilters;
    _showSearch = false;
    _showCart = false;
    notifyListeners();
  }

  void closeAllOverlays() {
    _showSearch = false;
    _showCart = false;
    _showFilters = false;
    notifyListeners();
  }
}
