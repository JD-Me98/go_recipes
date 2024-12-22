import 'package:flutter/material.dart';
import 'package:go_recipes/features/authentication/models/user.dart';

class UserProvider with ChangeNotifier {
  User? _currentUser;

  User? get currentUser => _currentUser;

  void setUser(User user) {
    _currentUser = user;
    notifyListeners(); // Notify listeners to rebuild the UI
  }

  void clearUser() {
    _currentUser = null;
    notifyListeners(); // Notify listeners to rebuild the UI
  }
}
